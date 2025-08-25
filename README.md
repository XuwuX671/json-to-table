[![Release](https://img.shields.io/github/v/release/XuwuX671/json-to-table?style=for-the-badge)](https://github.com/XuwuX671/json-to-table/releases)

# JSON to Table: CLI Formatter for Markdown, HTML, PNG & Text

![json-to-table-demo](https://raw.githubusercontent.com/XuwuX671/json-to-table/main/docs/demo.png)

Table of Contents
- Features
- Quick install
- Download releases (binary)
- Basic usage
- Examples
  - Text table
  - Markdown table
  - HTML table
  - PNG export (Japanese font)
  - Use with jq
  - Use with splunk-cli
- Output customization
  - Columns and field selection
  - Column order and width
  - Alignment and number formats
  - Headers, captions, and footers
  - Templates
- PNG rendering details
  - Fonts and Japanese text
  - Image scaling and DPI
- Integration with pipelines and tools
- File formats and encoding
- Performance and limits
- Building from source
- Tests and CI
- Contributing
- License
- Releases and download links

Features
- Convert JSON arrays of objects into readable tables.
- Support for plain text, Markdown, HTML, PNG with embedded fonts.
- Handles nested fields via dot notation.
- Field selection and ordering via flags.
- Column width control and auto-wrap.
- Numeric and date formatting.
- Works well with jq, splunk-cli, and other CLI tools.
- Fast, single-binary distribution for Linux, macOS, and Windows.

Quick install

Install from source with Go:
```bash
go install github.com/XuwuX671/json-to-table@latest
```

Download a release binary and run it:
- Visit the Releases page: https://github.com/XuwuX671/json-to-table/releases
- Download the platform-specific asset and execute it.

Download and run the release binary (example)
```bash
# Example for Linux amd64. Replace the filename with the exact asset shown on the Releases page.
curl -L -o json-to-table https://github.com/XuwuX671/json-to-table/releases/download/v1.0.0/json-to-table_linux_amd64
chmod +x json-to-table
./json-to-table --help
```
The above shows the pattern. Download the release asset file and execute it on your machine. Check the Releases page for the exact filename you need:
https://github.com/XuwuX671/json-to-table/releases

Basic usage

json-to-table reads JSON from stdin or from a file. It expects an array of objects at the top level.
- Read from stdin and output a text table:
```bash
cat events.json | json-to-table --format text
```
- Read a JSON file and output Markdown:
```bash
json-to-table --input events.json --format md --output events.md
```
- Print help:
```bash
json-to-table --help
```

Input shape

The tool accepts JSON like this:
```json
[
  {"time": "2025-01-01T10:00:00Z", "user": "alice", "action": "login", "count": 1},
  {"time": "2025-01-01T10:05:00Z", "user": "bob", "action": "view", "count": 5}
]
```
It also supports arrays returned by jq or splunk-cli.

Examples

Text table
```bash
cat events.json | json-to-table --format text --fields time,user,action,count
```
Output (text)
```
+---------------------+-------+--------+-------+
| time                | user  | action | count |
+---------------------+-------+--------+-------+
| 2025-01-01T10:00:00Z| alice | login  |     1 |
| 2025-01-01T10:05:00Z| bob   | view   |     5 |
+---------------------+-------+--------+-------+
```

Markdown table
```bash
cat events.json | json-to-table --format md --fields user,action,count
```
Output (Markdown)
```md
| user  | action | count |
|-------|--------|------:|
| alice | login  |     1 |
| bob   | view   |     5 |
```

HTML table
```bash
cat events.json | json-to-table --format html --fields time,user,action
```
Output (HTML)
```html
<table class="json-to-table">
  <thead>
    <tr><th>time</th><th>user</th><th>action</th></tr>
  </thead>
  <tbody>
    <tr><td>2025-01-01T10:00:00Z</td><td>alice</td><td>login</td></tr>
    <tr><td>2025-01-01T10:05:00Z</td><td>bob</td><td>view</td></tr>
  </tbody>
</table>
```

PNG export (with Japanese font)
```bash
cat events.json | json-to-table --format png --fields user,action --font /path/to/NotoSansJP-Regular.otf --output table.png
```
- The PNG option renders HTML to image and embeds the given font.
- For Japanese text, use a font that contains CJK glyphs, e.g. Noto Sans JP.
- The release binary includes a helper to fetch common fonts. Download the release asset and run the included tool to install fonts if needed.

Use with jq
```bash
# pipe structured jq output
jq -c '.results' input.json | json-to-table --format md --fields "user,meta.score"
```
- Use jq to transform or filter fields before passing to json-to-table.
- Use jq's -r and -c options to produce compact JSON arrays.

Use with splunk-cli
```bash
splunk search 'index=main | head 50 | fields _time,user,action' -o json | json-to-table --format md --fields _time,user,action
```
- splunk-cli can output JSON arrays suitable for json-to-table.
- Use --fields to limit output and order columns.

Output customization

Fields and selectors
- Use --fields to list fields and nested keys. Use dot notation for nested values: user.name, meta.score.
- Use '*' to include all top-level fields. Use a comma-separated list for order.

Example
```bash
json-to-table --fields time,user.name,metrics.cpu
```

Column width, wrapping, and truncation
- --max-width N sets a maximum column width in characters.
- --wrap enables wrapping within a cell.
- --truncate enables truncation with ellipsis when width exceeds max.

Alignment and formatting
- --align allow left/center/right per column via a string like "lcr".
- --format-number field:fmt sets numeric format. Example: --format-number count:0d or --format-number price:.2f
- --format-date field:layout sets date layout. Example: --format-date time:2006-01-02T15:04:05Z07:00

Headers, captions, and footers
- --header toggles header display.
- --caption "Report title" adds a caption to HTML and PNG output.
- --footer "Generated by json-to-table" adds a small footer.

Templates
- Use custom templates for HTML and Markdown with --template path.
- Template files use Go template syntax and receive a JSON structure:
  - .Rows (array)
  - .Fields (array)
  - .Meta (map with runtime info)
- Example:
```bash
json-to-table --format html --template ./templates/simple.html --input data.json
```

PNG rendering details

How PNG output works
- The CLI renders an HTML table and converts it to PNG using an embedded renderer.
- The renderer can use headless Chromium or a pure Go renderer depending on the build.
- The release builds include the renderer for common platforms.

Fonts and Japanese text
- For Japanese text, pick a font that supports Japanese glyphs.
- Supply the path via --font or install a system font and call by family name.
- Example using Noto Sans JP:
```bash
json-to-table --format png --font /usr/share/fonts/truetype/noto/NotoSansJP-Regular.otf --output table.png
```
- If fonts are missing, characters may render as tofu (boxed glyphs). Provide a font with CJK coverage.

Image scaling and DPI
- --dpi sets dots per inch. Default is 96.
- --scale scales the image after render. Use to get high-resolution output.
- For print, use --dpi 300 and an appropriate --scale.

Integration with pipelines and tools

Use in scripts
- json-to-table plays well with shell scripts. It reads from stdin and writes to stdout or file.
- Use exit codes to detect success. Exit code 0 on success, non-zero on error.

Examples
- Save Markdown and commit to repo:
```bash
jq '.hits' events.json | json-to-table --format md --fields time,user,action > report.md
git add report.md && git commit -m "Add events report"
```
- Automated report generation in CI:
```bash
cat data.json | json-to-table --format html --output report.html
# archive the report artifact
```

File formats and encodings

Input
- JSON must be UTF-8 encoded.
- Arrays must be at top level. The tool can auto-detect arrays inside objects via a --path option.
- Accepts both compact and pretty JSON.

Output
- Text and Markdown are UTF-8.
- HTML outputs use <meta charset="utf-8">.
- PNG embeds fonts and uses UTF-8 glyph shaping for non-Latin scripts.

Performance and limits

Memory and throughput
- The CLI streams JSON for moderate sizes.
- For massive files (>100 MB), use jq to prefilter or split the data.
- The renderer keeps the HTML table in memory during PNG export.

Limits
- Nested objects render when referenced. Deeply nested objects may not convert to flat cells without a template.
- Arrays inside cells render as JSON strings unless a custom template processes them.

Building from source

Prerequisites
- Go 1.20 or later.
- git, make (optional).
- Optional: headless Chromium for PNG renderer if you build that variant.

Build steps
```bash
git clone https://github.com/XuwuX671/json-to-table.git
cd json-to-table
go build ./cmd/json-to-table
# or
make build
```
Release builds
- Release artifacts include static binaries for linux/amd64, linux/arm64, darwin/amd64, darwin/arm64, and windows/amd64.
- Each release asset uses the naming convention: json-to-table_<os>_<arch> or json-to-table_<os>_<arch>.exe for Windows.

Tests and CI

Local tests
```bash
go test ./...
```
- The project includes unit tests for parsers, table layout, and renderer stubs.
- Add tests for new table templates and edge cases.

Continuous integration
- The repository uses GitHub Actions to run tests and build release artifacts.
- CI builds cross-platform binaries and uploads to the Releases page for download.

Contributing

How to contribute
- Fork the repo.
- Create a branch: git checkout -b fix/feature-name
- Add tests for new behavior.
- Open a pull request with a clear description of changes.

Coding style
- Keep functions short.
- Use clear names for flags and variables.
- Document exported functions and CLI flags.

Reporting bugs
- Open an issue on GitHub with a minimal reproduction. Include:
  - Input JSON or a minimal jq command
  - CLI command used
  - Expected and actual output

Roadmap (high-level)
- Add CSV export and import.
- Add more templates for reports and dashboards.
- Improve PNG renderer performance for large tables.
- Add built-in font installer for common CJK fonts.

License
- MIT License. See LICENSE file in the repo.

Releases and download links

Download binaries, release notes, and assets from the Releases page:
https://github.com/XuwuX671/json-to-table/releases

When the link lists assets, download the file for your platform and execute it. Example filenames:
- json-to-table_linux_amd64
- json-to-table_darwin_arm64
- json-to-table_windows_amd64.exe

Badges and status

[![Go Reference](https://pkg.go.dev/badge/github.com/XuwuX671/json-to-table.svg)](https://pkg.go.dev/github.com/XuwuX671/json-to-table)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/XuwuX671/json-to-table/blob/main/LICENSE)

Examples and real-world use cases

1) Daily report in Markdown for a CI job
- Use a scheduled job to collect events, filter via jq, and convert to Markdown for repository docs.
```bash
curl -s 'https://api.example.com/events' | jq '.items' | json-to-table --format md --fields timestamp,user,action > docs/daily-events.md
```

2) Embed a PNG table in an email
- Generate PNG with fonts and attach to an email client that accepts images.
```bash
cat events.json | json-to-table --format png --output events.png --font /usr/share/fonts/truetype/noto/NotoSansJP-Regular.otf
```

3) Integrate with Splunk dashboards
- Use splunk-cli to export search results and convert to HTML for static dashboards.
```bash
splunk search 'index=web | stats count by status' -o json | json-to-table --format html --output status_counts.html
```

Advanced examples

Custom column transforms
- Use a template to transform values. Template receives row map and can call functions.
- Example transform: format epoch to date, colorize status tags, or link user names.

Export a styled HTML report
```bash
json-to-table --format html --template ./templates/report.html --css ./templates/report.css --input data.json --output report.html
```
- The template can embed CSS and build a full report page with charts and summaries.

Troubleshooting

Common issues and quick checks
- If PNG shows missing glyphs, verify that the font path supports the script and is readable.
- If large JSON fails due to memory, filter or split input with jq.
- If nested fields return empty, confirm the field path with dot notation matches the JSON.

Command-line reference (selected flags)

General
- --input PATH     Read JSON from file. Default: stdin.
- --output PATH    Write output to file. Default: stdout.
- --format TYPE    Output format: text | md | html | png. Default: text.
- --fields LIST    Comma-separated list of fields and nested keys.
- --path JSONPATH  Path to array inside JSON (e.g. data.results).

Formatting
- --max-width N    Max column width in characters.
- --wrap           Wrap text in cells.
- --truncate       Truncate long cells with ellipsis.
- --align STR      Alignment string like lcr.
- --header/--no-header Show or hide header row.

Rendering and fonts
- --font PATH      Path to font file for PNG rendering.
- --dpi INT        Dots per inch for PNG. Default: 96.
- --scale FLOAT    Scale factor for PNG output.

Templates and extensions
- --template PATH  Path to custom template file for HTML/Markdown.
- --tmpl-funcs     Load custom template functions (advanced).

Debug and info
- --verbose        Show debug logs.
- --version        Print version.
- --help           Show help.

Design notes (internal)
- The CLI uses a modular pipeline:
  1. JSON input -> decoder -> normalize rows
  2. Column planner -> compute widths and formats
  3. Formatter -> text/md/html
  4. Optional renderer -> PNG via HTML
- The PNG renderer uses an HTML renderer API. This keeps the table layout consistent between HTML and PNG outputs.
- The codebase uses Go templates for HTML. This gives users a clear extension point.

Security
- The tool does not execute arbitrary code from templates by default.
- When using user-provided templates, run with minimal privileges and review template code.

Examples gallery

Markdown preview
![markdown-screenshot](https://raw.githubusercontent.com/XuwuX671/json-to-table/main/docs/markdown_preview.png)

HTML preview
![html-screenshot](https://raw.githubusercontent.com/XuwuX671/json-to-table/main/docs/html_preview.png)

PNG with Japanese
![png-jp](https://raw.githubusercontent.com/XuwuX671/json-to-table/main/docs/png_japanese.png)

Support and contact
- Open issues on GitHub for bugs and feature requests.
- Submit pull requests for enhancements or fixes.

Changelog
- See release notes on the Releases page:
https://github.com/XuwuX671/json-to-table/releases

Archive and packaging
- Releases include tar.gz, zip, and platform binaries.
- Tags follow semantic versioning.

FAQ

Q: Can I render a table with nested arrays?
A: Yes. You can reference nested arrays with a template. By default arrays serialize to JSON strings inside cells.

Q: Can I control row order?
A: Yes. Sort before passing data using jq or sort via template logic.

Q: Does PNG support high DPI?
A: Yes. Use --dpi and --scale to control resolution.

Q: How do I add colors to HTML?
A: Use a custom template or CSS. The tool produces plain HTML that accepts CSS classes.

Q: Where can I download prebuilt binaries?
A: Download from Releases:
https://github.com/XuwuX671/json-to-table/releases

Appendix: sample templates

Simple Markdown template (templates/simple.md)
```gotemplate
| {{ range $i, $f := .Fields }}{{ if $i }} | {{ end }}{{ $f }}{{ end }} |
|{{ range $i, $f := .Fields }}{{ if $i }}|{{ end }} --- {{ end }}|
{{- range .Rows }}
| {{ range $i, $f := $.Fields }}{{ if $i }} | {{ end }}{{ index . $f }}{{ end }} |
{{- end }}
```

Minimal HTML template (templates/simple.html)
```gotemplate
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<style>{{ .Meta.CSS }}</style>
</head>
<body>
<table class="json-to-table">
  <thead>
    <tr>{{ range .Fields }}<th>{{ . }}</th>{{ end }}</tr>
  </thead>
  <tbody>
    {{ range .Rows }}
    <tr>
      {{ range $f := $.Fields }}<td>{{ index . $f }}</td>{{ end }}
    </tr>
    {{ end }}
  </tbody>
</table>
</body>
</html>
```

Closing notes
- Use the Releases page to get binaries and assets:
https://github.com/XuwuX671/json-to-table/releases

- Download the correct release asset for your platform and execute the binary file provided on that page.