# Makefile for json-to-table

# --- Configuration ---
SOURCE_FILE := json-to-table.go
OUTPUT_NAME := json-to-table
DIST_DIR := dist_table
MODULE_NAME := json-to-table

# Font configuration
FONT_DIR := fonts
FONT_FILE := Mplus1Code-Regular.ttf
FONT_PATH := $(FONT_DIR)/$(FONT_FILE)
FONT_URL := "https://fonts.google.com/download?family=M%20PLUS%201%20Code"

# Go parameters
GO := go
GO_BUILD := $(GO) build
GO_MOD_TIDY := $(GO) mod tidy

# Build targets
.PHONY: all build clean tidy help

all: build

help:
	@echo "Usage:"
	@echo "  make all          - Build binaries for all target platforms (default)."
	@echo "  make build        - Alias for 'all'."
	@echo "  make build-macos  - Build for macOS (Universal)."
	@echo "  make build-linux  - Build for Linux (amd64)."
	@echo "  make build-windows- Build for Windows (amd64)."
	@echo "  make font         - Download and prepare the font."
	@echo "  make tidy         - Run go mod tidy."
	@echo "  make clean        - Remove build artifacts and downloaded font."

# --- Build Recipes ---

build: tidy $(FONT_PATH)
	@echo "🚀 Starting build process for json-to-table..."
	@rm -rf $(DIST_DIR)
	@mkdir -p $(DIST_DIR)/macos $(DIST_DIR)/windows $(DIST_DIR)/linux
	@$(MAKE) build-macos
	@$(MAKE) build-windows
	@$(MAKE) build-linux
	@echo "\n✅ All builds completed successfully!"
	@echo "   Binaries are located in the './$(DIST_DIR)' directory, organized by OS."

build-macos: $(FONT_PATH)
	@echo "📦 Building for macOS (Universal)..."
	@GOOS=darwin GOARCH=amd64 $(GO_BUILD) -o $(DIST_DIR)/macos/$(OUTPUT_NAME)_amd64 $(SOURCE_FILE)
	@GOOS=darwin GOARCH=arm64 $(GO_BUILD) -o $(DIST_DIR)/macos/$(OUTPUT_NAME)_arm64 $(SOURCE_FILE)
	@lipo -create -output $(DIST_DIR)/macos/$(OUTPUT_NAME) $(DIST_DIR)/macos/$(OUTPUT_NAME)_amd64 $(DIST_DIR)/macos/$(OUTPUT_NAME)_arm64
	@rm $(DIST_DIR)/macos/$(OUTPUT_NAME)_amd64 $(DIST_DIR)/macos/$(OUTPUT_NAME)_arm64
	@echo "🍏 macOS build complete: ./$(DIST_DIR)/macos/$(OUTPUT_NAME)"

build-windows: $(FONT_PATH)
	@echo "📦 Building for Windows (amd64)..."
	@GOOS=windows GOARCH=amd64 $(GO_BUILD) -o $(DIST_DIR)/windows/$(OUTPUT_NAME).exe $(SOURCE_FILE)
	@echo "🪟  Windows build complete: ./$(DIST_DIR)/windows/$(OUTPUT_NAME).exe"

build-linux: $(FONT_PATH)
	@echo "📦 Building for Linux (amd64)..."
	@GOOS=linux GOARCH=amd64 $(GO_BUILD) -o $(DIST_DIR)/linux/$(OUTPUT_NAME) $(SOURCE_FILE)
	@echo "🐧 Linux build complete: ./$(DIST_DIR)/linux/$(OUTPUT_NAME)"

# --- Dependency Management ---

$(FONT_PATH):
	@echo "🖋️  Font not found. Downloading and extracting..."
	@mkdir -p $(FONT_DIR)
	@curl -s -L -o /tmp/mplus.zip $(FONT_URL)
	@unzip -o /tmp/mplus.zip -d /tmp/mplus_unzipped
	@find /tmp/mplus_unzipped -name "MPLUS1Code-Regular.ttf" -exec mv {} $(FONT_PATH) \;
	@rm /tmp/mplus.zip
	@rm -rf /tmp/mplus_unzipped
	@echo "   > Font installed successfully."

font: $(FONT_PATH)

tidy:
	@echo "📦 Tidying dependencies..."
	@$(GO_MOD_TIDY)

# --- Cleanup ---

clean:
	@echo "🧹 Cleaning up old builds and fonts..."
	@rm -rf $(DIST_DIR) $(FONT_DIR)
	@echo "   > Cleanup complete."
