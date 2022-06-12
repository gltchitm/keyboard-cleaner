#!/usr/bin/env sh

if [ -d build/KeyboardCleaner.app ]; then
    rm -rf build/Keyboard\ Cleaner.app
fi

mkdir -p build/Keyboard\ Cleaner.app/Contents
mkdir build/Keyboard\ Cleaner.app/Contents/MacOS

version=$(cat VERSION)
build_id=$(uuidgen | sed y/ABCDEF/abcdef/)

cat << EOF > build/Keyboard\ Cleaner.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Keyboard Cleaner</string>
    <key>CFBundleDisplayName</key>
    <string>Keyboard Cleaner</string>
    <key>CFBundleExecutable</key>
    <string>keyboard-cleaner</string>
    <key>CFBundleIdentifier</key>
    <string>com.github.gltchitm.KeyboardCleaner</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>$version</string>
    <key>CFBundleShortVersionString</key>
    <string>$version</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>MacOSX</string>
    </array>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>LSUIElement</key>
    <true />
</dict>
</plist>
EOF

cat << EOF > build/Keyboard\ Cleaner.app/Contents/keyboard-cleaner-build.txt
Keyboard Cleaner

Version: $version
Build ID: $build_id
Built: $(date)
EOF

clang \
    -framework Cocoa \
    -o build/Keyboard\ Cleaner.app/Contents/MacOS/keyboard-cleaner \
    src/main.m

echo "Built Keyboard Cleaner!"
echo "  Version: $version"
echo "  Build ID: $build_id"
