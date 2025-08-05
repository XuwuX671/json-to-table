# Makefile for json-to-table

# --- Configuration ---
VERSION := 0.1.0
SOURCE_FILE := json-to-table.go
OUTPUT_NAME := json-to-table
RELEASE_DIR := release
MODULE_NAME := json-to-table

# Font configuration
FONT_LICENSE := FONTS_LICENSE

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
	@echo "  make tidy         - Run go mod tidy."
	@echo "  make clean        - Remove build artifacts."

# --- Build Recipes ---

build: tidy
	@echo "🚀 Starting build process for json-to-table..."
	@rm -rf $(RELEASE_DIR)
	@mkdir -p $(RELEASE_DIR)
	@$(MAKE) build-macos
	@$(MAKE) build-windows
	@$(MAKE) build-linux
	@echo "\n✅ All builds completed successfully!"
	@echo "   Binaries are located in the './$(RELEASE_DIR)' directory."

build-macos:
	@echo "📦 Building for macOS (Universal)..."
	@GOOS=darwin GOARCH=amd64 $(GO_BUILD) -o $(RELEASE_DIR)/$(OUTPUT_NAME)_amd64 $(SOURCE_FILE)
	@GOOS=darwin GOARCH=arm64 $(GO_BUILD) -o $(RELEASE_DIR)/$(OUTPUT_NAME)_arm64 $(SOURCE_FILE)
	@lipo -create -output $(RELEASE_DIR)/$(OUTPUT_NAME)_macos_universal $(RELEASE_DIR)/$(OUTPUT_NAME)_amd64 $(RELEASE_DIR)/$(OUTPUT_NAME)_arm64
	@rm $(RELEASE_DIR)/$(OUTPUT_NAME)_amd64 $(RELEASE_DIR)/$(OUTPUT_NAME)_arm64
	@echo "🍏 macOS build complete: ./$(RELEASE_DIR)/$(OUTPUT_NAME)_macos_universal"

build-windows:
	@echo "📦 Building for Windows (amd64)..."
	@GOOS=windows GOARCH=amd64 $(GO_BUILD) -o $(RELEASE_DIR)/$(OUTPUT_NAME)_windows_amd64.exe $(SOURCE_FILE)
	@echo "🪟  Windows build complete: ./$(RELEASE_DIR)/$(OUTPUT_NAME)_windows_amd64.exe"

build-linux:
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

tidy:
	@echo "📦 Tidying dependencies..."
	@$(GO_MOD_TIDY)

# --- Cleanup ---

clean:
	@echo "🧹 Cleaning up old builds..."
	@rm -rf $(RELEASE_DIR)
	@echo "   > Cleanup complete."
