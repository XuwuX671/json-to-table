# Makefile for json-to-table

# --- Configuration ---
VERSION := 0.1.0
SOURCE_FILE := json-to-table.go
OUTPUT_NAME := json-to-table
RELEASE_DIR := release
MODULE_NAME := json-to-table
TMP_DIR := .tmp

# Font configuration
FONT_DIR := fonts
FONT_FILE := Mplus1Code-Regular.ttf
FONT_PATH := $(FONT_DIR)/$(FONT_FILE)
FONT_LICENSE := FONTS_LICENSE
FONT_URL := "https://github.com/coz-m/MPLUS_FONTS/archive/refs/tags/v2023.08.23.zip"

# Go parameters
GO := go
LDFLAGS := -ldflags="-X main.version=$(VERSION)"
GO_BUILD := $(GO) build $(LDFLAGS)
GO_MOD_TIDY := $(GO) mod tidy

# Build targets
.PHONY: all build clean tidy help package

all: build

help:
	@echo "Usage:"
	@echo "  make all          - Build binaries for all target platforms (default)."
	@echo "  make build        - Alias for 'all'."
	@echo "  make package      - Build and package all binaries into ZIP archives for release."
	@echo "  make build-macos  - Build for macOS (Universal)."
	@echo "  make build-linux  - Build for Linux (amd64)."
	@echo "  make build-windows- Build for Windows (amd64)."
	@echo "  make font         - Download and prepare the font."
	@echo "  make tidy         - Run go mod tidy."
	@echo "  make clean        - Remove build artifacts and downloaded font."

# --- Build Recipes ---

build: tidy $(FONT_PATH)
	@echo "🚀 Starting build process for json-to-table..."
	@rm -rf $(RELEASE_DIR)
	@mkdir -p $(RELEASE_DIR)
	@$(MAKE) build-macos
	@$(MAKE) build-windows
	@$(MAKE) build-linux
	@echo "\n✅ All builds completed successfully!"
	@echo "   Binaries are located in the './$(RELEASE_DIR)' directory."

build-macos: $(FONT_PATH)
	@echo "📦 Building for macOS (Universal)..."
	@GOOS=darwin GOARCH=amd64 $(GO_BUILD) -o $(RELEASE_DIR)/$(OUTPUT_NAME)_amd64 $(SOURCE_FILE)
	@GOOS=darwin GOARCH=arm64 $(GO_BUILD) -o $(RELEASE_DIR)/$(OUTPUT_NAME)_arm64 $(SOURCE_FILE)
	@lipo -create -output $(RELEASE_DIR)/$(OUTPUT_NAME)_macos_universal $(RELEASE_DIR)/$(OUTPUT_NAME)_amd64 $(RELEASE_DIR)/$(OUTPUT_NAME)_arm64
	@rm $(RELEASE_DIR)/$(OUTPUT_NAME)_amd64 $(RELEASE_DIR)/$(OUTPUT_NAME)_arm64
	@echo "🍏 macOS build complete: ./$(RELEASE_DIR)/$(OUTPUT_NAME)_macos_universal"

build-windows: $(FONT_PATH)
	@echo "📦 Building for Windows (amd64)..."
	@GOOS=windows GOARCH=amd64 $(GO_BUILD) -o $(RELEASE_DIR)/$(OUTPUT_NAME)_windows_amd64.exe $(SOURCE_FILE)
	@echo "🪟  Windows build complete: ./$(RELEASE_DIR)/$(OUTPUT_NAME)_windows_amd64.exe"

build-linux: $(FONT_PATH)
	@echo "📦 Building for Linux (amd64)..."
	@GOOS=linux GOARCH=amd64 $(GO_BUILD) -o $(RELEASE_DIR)/$(OUTPUT_NAME)_linux_amd64 $(SOURCE_FILE)
	@echo "🐧 Linux build complete: ./$(RELEASE_DIR)/$(OUTPUT_NAME)_linux_amd64"

# --- Packaging ---

package: build
	@echo "📦 Packaging binaries for release..."
	@cp $(FONT_LICENSE) $(RELEASE_DIR)/
	@cd $(RELEASE_DIR) && \
	zip -j $(OUTPUT_NAME)-v$(VERSION)-macos-universal.zip $(OUTPUT_NAME)_macos_universal $(FONT_LICENSE) && \
	zip -j $(OUTPUT_NAME)-v$(VERSION)-windows-amd64.zip $(OUTPUT_NAME)_windows_amd64.exe $(FONT_LICENSE) && \
	zip -j $(OUTPUT_NAME)-v$(VERSION)-linux-amd64.zip $(OUTPUT_NAME)_linux_amd64 $(FONT_LICENSE)
	@rm $(RELEASE_DIR)/$(FONT_LICENSE)
	@echo "\n✅ All packages created successfully in './$(RELEASE_DIR)' directory."

# --- Dependency Management ---

$(FONT_PATH):
	@echo "🖋️  Font not found. Downloading and extracting..."
	@mkdir -p $(FONT_DIR)
	@mkdir -p $(TMP_DIR)
	@curl -s -L -o $(TMP_DIR)/mplus.zip $(FONT_URL)
	@unzip -o $(TMP_DIR)/mplus.zip -d $(TMP_DIR)/mplus_unzipped
	@find $(TMP_DIR)/mplus_unzipped -name "MPLUS1Code-Regular.ttf" -exec mv {} $(FONT_PATH) \;
	@rm -rf $(TMP_DIR)
	@echo "   > Font installed successfully."

font: $(FONT_PATH)

tidy:
	@echo "📦 Tidying dependencies..."
	@$(GO_MOD_TIDY)

# --- Cleanup ---

clean:
	@echo "🧹 Cleaning up old builds, fonts, and temporary files..."
	@rm -rf $(RELEASE_DIR) $(FONT_DIR) $(TMP_DIR)
	@echo "   > Cleanup complete."