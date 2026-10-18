#!/bin/bash
set -e

echo "🔨 Building ChooseBrowser with Swift Package Manager..."

# Build
swift build -c release

# Find the built executable
BUILD_DIR=$(swift build -c release --show-bin-path)
APP_BINARY="$BUILD_DIR/ChooseBrowser"

if [ ! -f "$APP_BINARY" ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build successful: $APP_BINARY"

# Create .app bundle
APP_NAME="ChooseBrowser"
APP_PATH="/Applications/$APP_NAME.app"
CONTENTS="$APP_PATH/Contents"
MACOS="$CONTENTS/MacOS"

echo "📦 Creating app bundle..."

rm -rf "$APP_PATH"
mkdir -p "$MACOS"
mkdir -p "$CONTENTS/Resources"

# Copy binary
cp "$APP_BINARY" "$MACOS/$APP_NAME"

# Copy Info.plist
cp ChooseBrowser/Info.plist "$CONTENTS/Info.plist"

# Copy icon
mkdir -p "$CONTENTS/Resources"
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "$CONTENTS/Resources/AppIcon.icns"
    echo "🎨 Icon copied"
fi

# Create PkgInfo
echo -n "APPL????" > "$CONTENTS/PkgInfo"

# Code sign
echo "🔐 Signing app..."
codesign --force --deep --sign - "$APP_PATH"

echo "✅ Installed to $APP_PATH"
echo ""
echo "📋 Next steps:"
echo "1. Open ChooseBrowser from /Applications"
echo "2. Go to System Preferences → Safari → Default Web Browser → Choose ChooseBrowser"
echo "3. Add URL rules from the menu bar icon"
echo ""
echo "Or run directly:"
echo "  $APP_BINARY"
