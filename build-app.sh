#!/bin/bash
# Build Airmail2Hookmark as a proper macOS app bundle

set -e

APP_NAME="Airmail2Hookmark"
BUILD_DIR=".build/release"
APP_BUNDLE="$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Building $APP_NAME..."

# Build release version
swift build -c release

# Create app bundle structure
echo "Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/"

# Copy Info.plist
cp "Airmail2Hookmark/Sources/Resources/Info.plist" "$CONTENTS_DIR/"

# Create PkgInfo
echo -n "APPL????" > "$CONTENTS_DIR/PkgInfo"

# Create app icon using iconutil
echo "Creating app icon..."
ICON_SRC="Airmail2Hookmark/Sources/Resources/Assets.xcassets/AppIcon.appiconset"
ICONSET_DIR="/tmp/AppIcon.iconset"
if [ -d "$ICON_SRC" ]; then
    rm -rf "$ICONSET_DIR"
    mkdir -p "$ICONSET_DIR"
    # Copy icons with iconutil naming convention
    cp "$ICON_SRC/icon_16x16.png" "$ICONSET_DIR/icon_16x16.png"
    cp "$ICON_SRC/icon_16x16@2x.png" "$ICONSET_DIR/icon_16x16@2x.png"
    cp "$ICON_SRC/icon_32x32.png" "$ICONSET_DIR/icon_32x32.png"
    cp "$ICON_SRC/icon_32x32@2x.png" "$ICONSET_DIR/icon_32x32@2x.png"
    cp "$ICON_SRC/icon_128x128.png" "$ICONSET_DIR/icon_128x128.png"
    cp "$ICON_SRC/icon_128x128@2x.png" "$ICONSET_DIR/icon_128x128@2x.png"
    cp "$ICON_SRC/icon_256x256.png" "$ICONSET_DIR/icon_256x256.png"
    cp "$ICON_SRC/icon_256x256@2x.png" "$ICONSET_DIR/icon_256x256@2x.png"
    cp "$ICON_SRC/icon_512x512.png" "$ICONSET_DIR/icon_512x512.png"
    cp "$ICON_SRC/icon_512x512@2x.png" "$ICONSET_DIR/icon_512x512@2x.png"
    # Create icns file
    iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
    rm -rf "$ICONSET_DIR"
fi

# Update Info.plist with actual values (replace Xcode variables)
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.airmail2hookmark.app" "$CONTENTS_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable $APP_NAME" "$CONTENTS_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :LSMinimumSystemVersion 13.0" "$CONTENTS_DIR/Info.plist" 2>/dev/null || true
# Set icon file for icns (CFBundleIconFile for legacy, keep CFBundleIconName for Xcode builds)
/usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$CONTENTS_DIR/Info.plist" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Set :CFBundleIconFile AppIcon" "$CONTENTS_DIR/Info.plist" 2>/dev/null || true

# Register with Launch Services (refresh URL scheme registration)
echo "Registering with Launch Services..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$PWD/$APP_BUNDLE"

echo ""
echo "Build complete: $APP_BUNDLE"
echo ""
echo "To run:"
echo "  open $APP_BUNDLE"
echo ""
echo "To install to Applications:"
echo "  cp -r $APP_BUNDLE /Applications/"
