package main

import (
	"encoding/json"
	"errors"
	"fmt"
)

// renderAsSlackBlockKit formats the table as Slack Block Kit JSON.
func renderAsSlackBlockKit(table [][]string) ([]byte, error) {
	if len(table) == 0 {
		return nil, errors.New("cannot generate Slack Block Kit from empty data")
	}

	type TextStyle struct {
		Bold bool `json:"bold,omitempty"`
	}

	type TextElement struct {
		Type  string     `json:"type"`
		Text  string     `json:"text"`
		Style *TextStyle `json:"style,omitempty"`
	}

	type RichTextSection struct {
		Type    string        `json:"type"`		
		Elements []TextElement `json:"elements"`
	}

	type RichText struct {
		Type    string            `json:"type"`
		Elements []RichTextSection `json:"elements"`
	}

	type TableBlock struct {
		Type string `json:"type"`
		Rows [][]RichText `json:"rows"`
	}

	var tableRows [][]RichText

	// Header row
	headerRow := make([]RichText, len(table[0]))
	for i, header := range table[0] {
		headerRow[i] = RichText{
			Type: "rich_text",
			Elements: []RichTextSection{
				{
					Type: "rich_text_section",
					Elements: []TextElement{
						{
							Type: "text",
							Text: header,
							Style: &TextStyle{Bold: true},
						},
					},
				},
			},
		}
	}
	tableRows = append(tableRows, headerRow)

	// Data rows
	for _, rowData := range table[1:] {
		dataRow := make([]RichText, len(rowData))
		for i, cell := range rowData {
			dataRow[i] = RichText{
				Type: "rich_text",
				Elements: []RichTextSection{
					{
						Type: "rich_text_section",
						Elements: []TextElement{
							{
								Type: "text",
								Text: cell,
							},
						},
					},
				},
			}
		}
		tableRows = append(tableRows, dataRow)
	}

	// Wrap in a top-level "blocks" object
	output := map[string]interface{}{
		"blocks": []TableBlock{
			{
				Type: "table",
				Rows: tableRows,
			},
		},
	}

	jsonData, err := json.MarshalIndent(output, "", "  ")
	if err != nil {
		return nil, fmt.Errorf("failed to marshal Slack Block Kit JSON: %w", err)
	}

	return jsonData, nil
}
