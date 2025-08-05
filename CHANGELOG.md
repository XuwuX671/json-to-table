# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-08-05

### Added

- HTML output format (`--format html`).
- Version information (`--version`) via `ldflags`.
- `FONTS_LICENSE` file for Mplus 1 Code font.
- `README.ja.md` for Japanese documentation.
- `make package` target to create zipped release archives.

### Changed

- Build system switched from `build.sh` to `Makefile`.
- Build output directory changed from `dist_table` to `dist`.
- Standardized executable names (e.g., `json-to-table`, `json-to-table.exe`).
- Font handling: Mplus 1 Code font is now embedded directly in the repository.
- READMEs updated to reflect new build process and HTML output.
- Overview in READMEs clarified to state `splunk-cli` companion tool role.
- Improved error handling with `%+v` formatting for better debuggability.

### Removed

- Outdated `BUILD.md` file.
- `build.sh` script.

### Fixed

- Corrected `parseJSON` return value for empty data.
- Resolved font download issues during build by embedding the font directly.
- Fixed redundant 'v' prefix in release package filenames.
