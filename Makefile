# Makefile for json-to-table

# --- Configuration ---
# Dynamically get version from git tag, or default to 0.0.0-dev if no tags exist
VERSION := $(shell git describe --tags --abbrev=0 --match "v[0-9]*" 2>/dev/null || echo "0.0.0-dev")
VERSION_CLEAN := $(patsubst v%,%,$(VERSION))

SOURCE_FILE := json-to-table.go
OUTPUT_NAME := json-to-table
DIST_DIR := dist
MODULE_NAME := json-to-table

# Font configuration
FONT_LICENSE := FONTS_LICENSE

# Go parameters
GO := go
GOBIN := $(shell go env GOBIN)
LDFLAGS := -ldflags="-X main.version=$(VERSION)"
GO_BUILD := $(GO) build $(LDFLAGS)
GO_MOD_TIDY := $(GO) mod tidy

# Build targets
.PHONY: all build clean tidy help package vulncheck lint

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
	@echo "  make vulncheck    - Run vulnerability checks."
	@echo "  make lint         - Run lint checks."

# --- Build Recipes ---

build: tidy
	@echo "🚀 Starting build process for json-to-table..."
	@rm -rf $(DIST_DIR)
	@$(MAKE) build-macos
	@$(MAKE) build-windows
	@$(MAKE) build-linux
	@echo "\n✅ All builds completed successfully!"
	@echo "   Binaries are located in the './$(DIST_DIR)' directory."

build-macos:
	@echo "📦 Building for macOS (Universal)..."
	@mkdir -p $(DIST_DIR)/macos
	@GOOS=darwin GOARCH=amd64 $(GO_BUILD) -o $(DIST_DIR)/macos/$(OUTPUT_NAME)_amd64 $(SOURCE_FILE)
	@GOOS=darwin GOARCH=arm64 $(GO_BUILD) -o $(DIST_DIR)/macos/$(OUTPUT_NAME)_arm64 $(SOURCE_FILE)
	@lipo -create -output $(DIST_DIR)/macos/$(OUTPUT_NAME) $(DIST_DIR)/macos/$(OUTPUT_NAME)_amd64 $(DIST_DIR)/macos/$(OUTPUT_NAME)_arm64
	@rm $(DIST_DIR)/macos/$(OUTPUT_NAME)_amd64 $(DIST_DIR)/macos/$(OUTPUT_NAME)_arm64
	@echo "🍏 macOS build complete: ./$(DIST_DIR)/macos/$(OUTPUT_NAME)"

build-windows:
	@echo "📦 Building for Windows (amd64)..."
	@mkdir -p $(DIST_DIR)/windows
	@GOOS=windows GOARCH=amd64 $(GO_BUILD) -o $(DIST_DIR)/windows/$(OUTPUT_NAME).exe $(SOURCE_FILE)
	@echo "🪟  Windows build complete: ./$(DIST_DIR)/windows/$(OUTPUT_NAME).exe"

build-linux:
	@echo "📦 Building for Linux (amd64)..."
	@mkdir -p $(DIST_DIR)/linux
	@GOOS=linux GOARCH=amd64 $(GO_BUILD) -o $(DIST_DIR)/linux/$(OUTPUT_NAME) $(SOURCE_FILE)
	@echo "🐧 Linux build complete: ./$(DIST_DIR)/linux/$(OUTPUT_NAME)"

# --- Packaging ---

package: build
	@echo "📦 Packaging binaries for release..."
	@cp $(FONT_LICENSE) $(DIST_DIR)/macos/
	@cp $(FONT_LICENSE) $(DIST_DIR)/windows/
	@cp $(FONT_LICENSE) $(DIST_DIR)/linux/
	@cd $(DIST_DIR)/macos && zip ../$(OUTPUT_NAME)-$(VERSION_CLEAN)-macos-universal.zip ./*
	@cd $(DIST_DIR)/windows && zip ../$(OUTPUT_NAME)-$(VERSION_CLEAN)-windows-amd64.zip ./*
	@cd $(DIST_DIR)/linux && zip ../$(OUTPUT_NAME)-$(VERSION_CLEAN)-linux-amd64.zip ./*
	@echo "\n✅ All packages created successfully in './$(DIST_DIR)' directory."

# --- Code Quality ---

vulncheck:
	@echo "🔍 Running vulnerability checks..."
	@$(GO) vet ./...
	@$(GOBIN)govulncheck ./...
	@echo "   > Vulnerability checks complete."

lint:
	@echo "🧹 Running lint checks..."
	@$(GOBIN)golangci-lint run ./...
	@echo "   > Lint checks complete."

# --- Dependency Management ---

tidy:
	@echo "📦 Tidying dependencies..."
	@$(GO_MOD_TIDY)

# --- Cleanup ---

clean:
	@echo "🧹 Cleaning up old builds..."
	@rm -rf $(DIST_DIR)
	@echo "   > Cleanup complete."