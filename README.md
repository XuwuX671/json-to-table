# **JSON to Table (json-to-table)**

This project was collaboratively developed by **magifd2** and **Google's Gemini**.

[日本語のREADMEはこちら](README.ja.md)

## **Overview**

`json-to-table` is a versatile command-line utility written in Go, designed as a companion tool for [`magifd2/splunk-cli`](https://github.com/magifd2/splunk-cli). It formats a JSON array into a well-structured table. It reads JSON data from standard input, making it ideal for directly piping the output of commands like `splunk-cli ... | jq .results` to convert it into a human-readable format or an image suitable for reports.

For a detailed list of changes, please see the [CHANGELOG](CHANGELOG.md).

### **Key Features**

*   **Versatile Input**: Accepts a JSON array of objects from standard input.
*   **Multiple Output Formats**:
    *   `text`: Plain text with borders, suitable for terminal display.
    *   `md`: GitHub Flavored Markdown table.
    *   `png`: **Image format with Japanese font support**, perfect for sharing in reports or chat.
    *   `html`: Self-contained HTML file with basic styling.
    *   `slack-block-kit`: JSON output formatted for Slack Block Kit, ideal for direct use in Slack messages.
*   **Flexible Column Selection and Ordering**:
    *   **Include Columns**: Specify the columns to display and their order using the `--columns` (`-c`) flag.
    *   **Exclude Columns**: Specify columns to exclude from the output using the `--exclude-columns` (`-e`) flag.
    *   Supports powerful wildcards like `*` (for all remaining columns) and `prefix*` (for prefix matching) for both inclusion and exclusion.
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

*   **Output as an HTML file:**
    ```bash
    splunk-cli run ... | jq .results | json-to-table --format html -o report.html
    ```

*   **Output as Slack Block Kit JSON:**
    ```bash
    splunk-cli run ... | jq .results | json-to-table --format slack-block-kit
    ```

### **Column Selection and Ordering**

`json-to-table` processes column selection in two stages: first exclusion, then inclusion.

#### **1. Excluding Columns (`--exclude-columns` or `-e`)**

Specify column names or patterns to remove from the initial set of available columns. Wildcards behave similarly to `--columns`.

*   **Exclude specific columns:**
    ```bash
    ... | json-to-table -e "id,timestamp"
    ```
    (Excludes `id` and `timestamp` from the output.)

*   **Exclude columns by prefix:**
    ```bash
    ... | json-to-table -e "http_*,_internal*"
    ```
    (Excludes all columns starting with `http_` or `_internal`.)

*   **Exclude all columns (use with caution, results in empty table):**
    ```bash
    ... | json-to-table -e "*"
    ```

#### **2. Including and Ordering Columns (`--columns` or `-c`)**

After any exclusions are applied, use this flag to specify which of the *remaining* columns to display and in what order. Wildcards allow for flexible ordering.

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

#### **Combined Usage Example**

To exclude `_internal_id` and `timestamp` first, then display `user`, `action`, and all other remaining columns:

```bash
... | json-to-table -e "_internal_id,timestamp" -c "user,action,*