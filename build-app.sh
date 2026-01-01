#!/bin/bash
# Build Airmail2Hookmark using Xcode

set -e

APP_NAME="Airmail2Hookmark"
PROJECT="Airmail2Hookmark.xcodeproj"

# Check if xcodebuild is available and points to Xcode (not CommandLineTools)
XCODE_PATH=$(xcode-select -p 2>/dev/null)
if [[ "$XCODE_PATH" == *"CommandLineTools"* ]]; then
    echo "Error: xcode-select points to CommandLineTools, not Xcode.app"
    echo "Run: sudo xcode-select -s /Applications/Xcode.app"
    exit 1
fi

echo "Building $APP_NAME (macOS)..."
xcodebuild -project "$PROJECT" \
    -scheme "$APP_NAME" \
    -configuration Release \
    -derivedDataPath .build \
    build

# Copy the built app to current directory
APP_PATH=".build/Build/Products/Release/$APP_NAME.app"
if [ -d "$APP_PATH" ]; then
    rm -rf "$APP_NAME.app"
    cp -r "$APP_PATH" .
    echo ""
    echo "Build complete: $APP_NAME.app"
    echo ""
    echo "To run:"
    echo "  open $APP_NAME.app"
    echo ""
    echo "To install to Applications:"
    echo "  cp -r $APP_NAME.app /Applications/"
else
    echo "Build succeeded but app not found at expected path"
    echo "Check: .build/Build/Products/Release/"
fi
