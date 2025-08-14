package main

import (
	"fmt"
	"strings"
)

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
