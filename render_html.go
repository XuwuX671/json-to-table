package main

import (
	"bytes"
	"fmt"
	"html/template"

	_ "embed" // Required for embedding font data
)

//go:embed templates/html_table.html
var htmlTemplateContent string

// renderAsHTML formats the table as an HTML table with basic styling.
func renderAsHTML(table [][]string) (string, error) {
	if len(table) == 0 {
		return "", nil
	}

	parsedTemplate, err := template.New("html_table").Parse(htmlTemplateContent)
	if err != nil {
		return "", fmt.Errorf("failed to parse html template: %w", err)
	}

	data := struct {
		Headers []string
		Rows    [][]string
	}{
		Headers: table[0],
		Rows:    table[1:],
	}

	var buf bytes.Buffer
	if err := parsedTemplate.Execute(&buf, data); err != nil {
		return "", fmt.Errorf("failed to execute html template: %w", err)
	}

	return buf.String(), nil
}
