package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"image/png"
	"io"
	"os"
	"sort"
	"strings"

	_ "embed" // Required for embedding font data

	"golang.org/x/image/font"
	"golang.org/x/image/font/opentype"
	"golang.org/x/image/math/fixed"
)

//go:embed fonts/MPLUS1Code-Regular.ttf
var fontData []byte

// --- Core Logic ---

// parseJSON reads JSON from an io.Reader and converts it into a table structure,
// respecting the user-defined column order with advanced wildcards.
func parseJSON(r io.Reader, columnOrder string) ([][]string, error) {
	var data []map[string]interface{}
	decoder := json.NewDecoder(r)
	if err := decoder.Decode(&data); err != nil {
		return nil, fmt.Errorf("failed to decode json: %w", err)
	}

	if len(data) == 0 {
		return [][]string{}, nil
	}

	// 1. Collect all unique keys from the data and sort them for deterministic order.
	allHeadersSet := make(map[string]bool)
	for _, row := range data {
		for key := range row {
			allHeadersSet[key] = true
		}
	}
	allHeadersList := make([]string, 0, len(allHeadersSet))
	for h := range allHeadersSet {
		allHeadersList = append(allHeadersList, h)
	}
	sort.Strings(allHeadersList)

	var finalHeaders []string
	if columnOrder == "" {
		// Default behavior: use all headers sorted alphabetically.
		finalHeaders = allHeadersList
	} else {
		// Custom order logic with wildcards
		userPatterns := strings.Split(columnOrder, ",")
		usedHeaders := make(map[string]bool)

		for _, pattern := range userPatterns {
			trimmedPattern := strings.TrimSpace(pattern)

			if trimmedPattern == "*" {
				// Wildcard for all remaining columns
				futureExplicitHeaders := make(map[string]bool)
				wildcardFound := false
				for _, p := range userPatterns {
					p = strings.TrimSpace(p)
					if p == "*" {
						wildcardFound = true
						continue
					}
					if wildcardFound && !strings.HasSuffix(p, "*") {
						futureExplicitHeaders[p] = true
					}
				}

				var remainingHeaders []string
				for _, header := range allHeadersList {
					if !usedHeaders[header] && !futureExplicitHeaders[header] {
						remainingHeaders = append(remainingHeaders, header)
					}
				}
				finalHeaders = append(finalHeaders, remainingHeaders...)
				for _, h := range remainingHeaders {
					usedHeaders[h] = true
				}
			} else if strings.HasSuffix(trimmedPattern, "*") {
				// Prefix wildcard (e.g., "col*")
				prefix := strings.TrimSuffix(trimmedPattern, "*")
				var matchedHeaders []string
				for _, header := range allHeadersList {
					if strings.HasPrefix(header, prefix) && !usedHeaders[header] {
						matchedHeaders = append(matchedHeaders, header)
					}
				}
				finalHeaders = append(finalHeaders, matchedHeaders...)
				for _, h := range matchedHeaders {
					usedHeaders[h] = true
				}
			} else {
				// Specific column name
				if allHeadersSet[trimmedPattern] && !usedHeaders[trimmedPattern] {
					finalHeaders = append(finalHeaders, trimmedPattern)
					usedHeaders[trimmedPattern] = true
				}
			}
		}
	}

	// 2. Create the table data structure (headers + rows) using the final header order.
	table := make([][]string, len(data)+1)
	table[0] = finalHeaders
	for i, rowMap := range data {
		row := make([]string, len(finalHeaders))
		for j, header := range finalHeaders {
			if val, ok := rowMap[header]; ok {
				row[j] = fmt.Sprintf("%v", val)
			} else {
				row[j] = "" // Handle missing keys for a given row
			}
		}
		table[i+1] = row
	}

	return table, nil
}

// --- Output Renderers ---

// renderAsText formats the table as plain text with aligned columns.
func renderAsText(table [][]string) (string, error) {
	if len(table) == 0 {
		return "", nil
	}
	
	colWidths := make([]int, len(table[0]))
	for _, row := range table {
		for i, cell := range row {
			width := 0
			for _, r := range cell {
				if r > 255 {
					width += 2
				} else {
					width++
				}
			}
			if width > colWidths[i] {
				colWidths[i] = width
			}
		}
	}

	var builder strings.Builder
	// Header
	for i, header := range table[0] {
		cellWidth := 0
		for _, r := range header {
			if r > 255 { cellWidth += 2 } else { cellWidth++ }
		}
		padding := colWidths[i] - cellWidth
		builder.WriteString(fmt.Sprintf("| %s%s ", header, strings.Repeat(" ", padding)))
	}
	builder.WriteString("|\n")

	// Separator
	for _, width := range colWidths {
		builder.WriteString(fmt.Sprintf("|-%s-", strings.Repeat("-", width)))
	}
	builder.WriteString("|\n")

	// Body
	for _, row := range table[1:] {
		for i, cell := range row {
			cellWidth := 0
			for _, r := range cell {
				if r > 255 { cellWidth += 2 } else { cellWidth++ }
			}
			padding := colWidths[i] - cellWidth
			builder.WriteString(fmt.Sprintf("| %s%s ", cell, strings.Repeat(" ", padding)))
		}
		builder.WriteString("|\n")
	}

	return builder.String(), nil
}

// renderAsMarkdown formats the table as a GitHub-Flavored Markdown table.
func renderAsMarkdown(table [][]string) (string, error) {
	if len(table) == 0 {
		return "", nil
	}

	var builder strings.Builder
	// Header
	builder.WriteString("| " + strings.Join(table[0], " | ") + " |\n")
	// Separator
	separator := make([]string, len(table[0]))
	for i := range separator {
		separator[i] = "---"
	}
	builder.WriteString("| " + strings.Join(separator, " | ") + " |\n")
	// Body
	for _, row := range table[1:] {
		builder.WriteString("| " + strings.Join(row, " | ") + " |\n")
	}

	return builder.String(), nil
}

// renderAsPNG formats the table as a PNG image with grid lines and alternating row colors.
func renderAsPNG(table [][]string, title string, fontSize float64) ([]byte, error) {
	if len(table) == 0 {
		return nil, errors.New("cannot generate image from empty data")
	}

	// --- Colors ---
	bgColorHeader := color.RGBA{R: 238, G: 242, B: 249, A: 255} // Light blue-gray
	bgColorEven := color.RGBA{R: 248, G: 249, B: 250, A: 255} // Very light gray
	bgColorOdd := color.White
	lineColor := color.RGBA{R: 222, G: 226, B: 230, A: 255} // Light gray

	// --- Font and Metrics ---
	parsedFont, err := opentype.Parse(fontData)
	if err != nil {
		return nil, fmt.Errorf("failed to parse font: %w", err)
	}

	face, err := opentype.NewFace(parsedFont, &opentype.FaceOptions{
		Size:    fontSize,
		DPI:     72,
		Hinting: font.HintingFull,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create font face: %w", err)
	}
	defer face.Close()

	// --- Layout Calculation ---
	padding := int(fontSize)
	cellPadding := padding / 2
	lineHeight := face.Metrics().Height.Ceil() + cellPadding*2

	titleHeight := 0
	if title != "" {
		titleHeight = lineHeight + padding
	}

	colWidths := make([]int, len(table[0]))
	for _, row := range table {
		for i, cell := range row {
			width := font.MeasureString(face, cell).Ceil()
			if width > colWidths[i] {
				colWidths[i] = width
			}
		}
	}

	totalWidth := 0
	for _, w := range colWidths {
		totalWidth += w + padding
	}
	totalHeight := titleHeight + len(table)*lineHeight + padding

	// --- Image Drawing ---
	img := image.NewRGBA(image.Rect(0, 0, totalWidth, totalHeight))
	draw.Draw(img, img.Bounds(), image.White, image.Point{}, draw.Src)

	drawer := &font.Drawer{
		Dst:  img,
		Src:  image.Black, // Use image.Black which is an image.Image
		Face: face,
	}

	// --- Draw Backgrounds and Text ---
	y := titleHeight + padding/2
	if title != "" {
		titleX := (totalWidth - font.MeasureString(face, title).Ceil()) / 2
		drawer.Dot = fixed.P(titleX, titleHeight-padding/2)
		drawer.DrawString(title)
	}

	for i, row := range table {
		rowY := y + i*lineHeight
		
		var bgColor color.Color
		if i == 0 {
			bgColor = bgColorHeader
		} else if (i-1)%2 == 0 {
			bgColor = bgColorOdd
		} else {
			bgColor = bgColorEven
		}
		draw.Draw(img, image.Rect(0, rowY, totalWidth, rowY+lineHeight), &image.Uniform{C: bgColor}, image.Point{}, draw.Src)

		x := 0
		for j, cell := range row {
			textX := x + cellPadding
			textY := rowY + (lineHeight-face.Metrics().Height.Ceil())/2 + face.Metrics().Ascent.Ceil()
			drawer.Dot = fixed.P(textX, textY)
			drawer.DrawString(cell)
			x += colWidths[j] + padding
		}
	}

	// --- Draw Grid Lines ---
	tableTop := titleHeight + padding/2
	tableBottom := tableTop + len(table)*lineHeight
	// Horizontal lines
	for i := 0; i <= len(table); i++ {
		yLine := tableTop + i*lineHeight
		for x := 0; x < totalWidth; x++ {
			img.Set(x, yLine, lineColor)
		}
	}
	// Vertical lines
	x := 0
	for i := 0; i < len(colWidths); i++ {
		for y := tableTop; y < tableBottom; y++ {
			img.Set(x, y, lineColor)
		}
		x += colWidths[i] + padding
	}
	// Last vertical line
	for y := tableTop; y < tableBottom; y++ {
		img.Set(totalWidth-1, y, lineColor)
	}

	// --- Encoding ---
	var buf bytes.Buffer
	if err := png.Encode(&buf, img); err != nil {
		return nil, fmt.Errorf("failed to encode png: %w", err)
	}
	return buf.Bytes(), nil
}

// --- Main Execution ---

func main() {
	format := flag.String("format", "text", "Output format: text, md, png")
	output := flag.String("o", "", "Output file path (default: stdout)")
	title := flag.String("title", "", "Title for the image output")
	fontSize := flag.Float64("font-size", 12, "Font size for the image output")
	columns := flag.String("columns", "", "Comma-separated list of columns in desired order. Use '*' as a wildcard for other columns.")
	flag.StringVar(columns, "c", "", "Shorthand for --columns")

	flag.Parse()

	// Check if data is being piped
	stat, _ := os.Stdin.Stat()
	if (stat.Mode() & os.ModeCharDevice) != 0 {
		fmt.Fprintln(os.Stderr, "Error: This tool requires JSON data to be piped via stdin.")
		fmt.Fprintln(os.Stderr, "Usage: cat data.json | json-to-table")
		fmt.Fprintln(os.Stderr, "   or: splunk-cli run ... | jq .results | json-to-table --format png -o report.png")
		os.Exit(1)
	}

	table, err := parseJSON(os.Stdin, *columns)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error parsing JSON: %v\n", err)
		os.Exit(1)
	}

	var outData []byte
	var outStr string

	switch strings.ToLower(*format) {
	case "text":
		outStr, err = renderAsText(table)
	case "md", "markdown":
		outStr, err = renderAsMarkdown(table)
	case "png":
		outData, err = renderAsPNG(table, *title, *fontSize)
	default:
		err = fmt.Errorf("unknown format: %s", *format)
	}

	if err != nil {
		fmt.Fprintf(os.Stderr, "Error rendering output: %v\n", err)
		os.Exit(1)
	}

	// Determine output destination
	var writer io.Writer = os.Stdout
	if *output != "" {
		file, err := os.Create(*output)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error creating output file: %v\n", err)
			os.Exit(1)
		}
		defer file.Close()
		writer = file
	}

	// Write the output
	if outData != nil {
		_, err = writer.Write(outData)
	} else {
		_, err = io.WriteString(writer, outStr)
	}
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error writing output: %v\n", err)
		os.Exit(1)
	}
}
