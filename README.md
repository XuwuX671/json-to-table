# **JSON to Table (json-to-table)**

This project was collaboratively developed by **magifd2** and **Google's Gemini**.

[日本語のREADMEはこちら](README.ja.md)

## **Overview**

`json-to-table` is a versatile command-line utility written in Go that formats a JSON array into a well-structured table. It reads JSON data from standard input, making it ideal for directly piping the output of commands like `splunk-cli ... | jq .results` to convert it into a human-readable format or an image suitable for reports.

### **Key Features**

*   **Versatile Input**: Accepts a JSON array of objects from standard input.
*   **Multiple Output Formats**:
    *   `text`: Plain text with borders, suitable for terminal display.
    *   `md`: GitHub Flavored Markdown table.
    *   `png`: **Image format with Japanese font support**, perfect for sharing in reports or chat.
*   **Flexible Column Ordering**:
    *   Specify the columns to display and their order using the `--columns` (`-c`) flag.
    *   Supports powerful wildcards like `*` (for all remaining columns) and `prefix*` (for prefix matching).
*   **Image Customization**:
    *   Add a title to the image with `--title`.
    *   Adjust the font size with `--font-size`.
*   **Self-Contained**: Embeds a Japanese font within the binary, eliminating external dependencies and allowing it to run as a single executable file.

## **Installation**

Pre-compiled binaries for macOS, Windows, and Linux are available on the [Releases](https://github.com/magifd2/json-to-table/releases) page.

## **Usage**

### **Basic Pipeline**

The primary use case is to filter the output of `splunk-cli` with `jq` and pipe the result to `json-to-table`.

```bash
# Display splunk-cli results as a text table
splunk-cli run --silent -spl "..." | jq .results | json-to-table
```

### **Specifying Output Format**

Use the `--format` flag to change the output format.

*   **Output as a Markdown file:**
    ```bash
    splunk-cli run ... | jq .results | json-to-table --format md -o report.md
    ```

*   **Output as a PNG image file:**
    ```bash
    splunk-cli run ... | jq .results | json-to-table --format png --title "DNS Query Ranking" -o report.png
    ```

### **Specifying Column Order (`--columns` or `-c`)**

Specify column names in a comma-separated list. Wildcards allow for flexible ordering.

*   **Bring specific columns to the front, with the rest following:**
    ```bash
    ... | json-to-table -c "user,*"
    ```

*   **Place specific columns at the beginning and end:**
    ```bash
    ... | json-to-table -c "user,*,count,total"
    ```

*   **Group columns by prefix:**
    Displays all columns starting with `http_` together.
    ```bash
    ... | json-to-table -c "user,http_*,*"
    ```

*   **Display only a specific set of columns in a defined order:**
    ```bash
    ... | json-to-table -c "user,action,status"
    ```

## **Building from Source**

To build the project from source, you need Go and `make` installed. The build process will automatically handle the required font dependency.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/magifd2/json-to-table.git
    cd json-to-table
    ```

2.  **Build the binaries:**
    ```bash
    make build
    ```
    The compiled binaries will be placed in the `release` directory.

3.  **Create release packages (ZIP):**
    ```bash
    make package
    ```
    This will create ZIP archives for each OS in the `release` directory, ready for a GitHub release.

## **Flags**

*   `--format`: Output format (`text`, `md`, `png`). Default is `text`.
*   `-o <file>`: Output file path. Default is standard output.
*   `--columns, -c <order>`: Comma-separated list of columns in the desired order.
*   `--title <text>`: Title for the PNG output.
*   `--font-size <number>`: Font size for the PNG output. Default is 12.
*   `--version`: Print version information and exit.

## **Acknowledgements**

This tool uses the **Mplus 1 Code** font, which is licensed under the SIL Open Font License, Version 1.1. We are grateful to the M+ FONTS Project for providing this excellent font.

## **License**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## **Author**

[magifd2](https://github.com/magifd2)
