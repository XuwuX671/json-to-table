#!/bin/bash
#
# This script builds the json-to-table tool for macOS (Universal),
# Windows (amd64), and Linux (amd64).

# Exit immediately if a command exits with a non-zero status.
set -e

echo "🚀 Starting build process for json-to-table..."

# --- Configuration ---
SOURCE_FILE="json-to-table.go"
OUTPUT_NAME="json-to-table"
DIST_DIR="dist_table"
MODULE_NAME="json-to-table"
FONT_DIR="fonts"
FONT_FILE="Mplus1Code-Regular.ttf"
FONT_URL="https://fonts.google.com/download?family=M%20PLUS%201%20Code"

# --- Font Management ---
echo "🖋️  Checking for font..."
if [ ! -f "${FONT_DIR}/${FONT_FILE}" ]; then
    echo "   > Font not found. Downloading and extracting..."
    mkdir -p ${FONT_DIR}
    # Download the zip file from Google Fonts
    curl -s -L -o /tmp/mplus.zip "${FONT_URL}"
    # Unzip and find the specific font file, then move it to the correct location
    unzip -o /tmp/mplus.zip -d /tmp/mplus_unzipped
    # The exact path might vary, so we search for it
    find /tmp/mplus_unzipped -name "MPLUS1Code-Regular.ttf" -exec mv {} "${FONT_DIR}/${FONT_FILE}" \;
    # Clean up temporary files
    rm /tmp/mplus.zip
    rm -rf /tmp/mplus_unzipped
    echo "   > Font installed successfully."
else
    echo "   > Font already exists."
fi

# --- Dependency Management ---
echo "📦 Managing dependencies..."
# Initialize Go module if go.mod doesn't exist
if [ ! -f go.mod ]; then
    echo "   > Initializing Go module..."
    go mod init ${MODULE_NAME}
fi
# Tidy dependencies to download required packages like golang.org/x/image
echo "   > Tidying dependencies..."
go mod tidy

# --- Build Process ---
# Clean up previous builds and create distribution directories
echo "🧹 Cleaning up old builds..."
rm -rf ./${DIST_DIR}
mkdir -p ./${DIST_DIR}/macos ./${DIST_DIR}/windows ./${DIST_DIR}/linux

# --- macOS Universal Binary ---
echo "📦 Building for macOS (Universal)..."
# Build for Intel (amd64)
GOOS=darwin GOARCH=amd64 go build -o ./${DIST_DIR}/macos/${OUTPUT_NAME}_amd64 ./${SOURCE_FILE}
# Build for Apple Silicon (arm64)
GOOS=darwin GOARCH=arm64 go build -o ./${DIST_DIR}/macos/${OUTPUT_NAME}_arm64 ./${SOURCE_FILE}
# Combine into a universal binary using lipo
lipo -create -output ./${DIST_DIR}/macos/${OUTPUT_NAME} ./${DIST_DIR}/macos/${OUTPUT_NAME}_amd64 ./${DIST_DIR}/macos/${OUTPUT_NAME}_arm64
# Clean up temporary architecture-specific binaries
rm ./${DIST_DIR}/macos/${OUTPUT_NAME}_amd64 ./${DIST_DIR}/macos/${OUTPUT_NAME}_arm64
echo "🍏 macOS build complete: ./${DIST_DIR}/macos/${OUTPUT_NAME}"
echo "---"


# --- Windows amd64 Binary ---
echo "📦 Building for Windows (amd64)..."
GOOS=windows GOARCH=amd64 go build -o ./${DIST_DIR}/windows/${OUTPUT_NAME}.exe ./${SOURCE_FILE}
echo "🪟 Windows build complete: ./${DIST_DIR}/windows/${OUTPUT_NAME}.exe"
echo "---"


# --- Linux amd64 Binary ---
echo "📦 Building for Linux (amd64)..."
GOOS=linux GOARCH=amd64 go build -o ./${DIST_DIR}/linux/${OUTPUT_NAME} ./${SOURCE_FILE}
echo "🐧 Linux build complete: ./${DIST_DIR}/linux/${OUTPUT_NAME}"
echo "---"


echo ""
echo "✅ All builds completed successfully!"
echo "   Binaries are located in the './${DIST_DIR}' directory, organized by OS."