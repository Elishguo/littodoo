#!/usr/bin/env bash
# Build Littodoo.app on macOS 12+ (needs Xcode Command Line Tools: xcode-select --install)
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/embed-ui.py
OUT="build/Littodoo.app"
rm -rf build && mkdir -p "$OUT/Contents/MacOS" "$OUT/Contents/Resources"
swiftc -O mac/main.swift -o "$OUT/Contents/MacOS/Littodoo" -framework Cocoa -framework WebKit
# Icon: make .icns from assets/icon.png
ICONSET=build/AppIcon.iconset; mkdir -p "$ICONSET"
for s in 16 32 128 256 512; do
  sips -z $s $s assets/icon.png --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
  sips -z $((s*2)) $((s*2)) assets/icon.png --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$OUT/Contents/Resources/AppIcon.icns"
cat > "$OUT/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleDisplayName</key><string>Littodoo</string>
<key>CFBundleExecutable</key><string>Littodoo</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundleIdentifier</key><string>com.littodoo.app</string>
<key>CFBundleName</key><string>Littodoo</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>1.1</string>
<key>CFBundleVersion</key><string>2</string>
<key>LSMinimumSystemVersion</key><string>12.0</string>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
codesign --force --deep -s - "$OUT" || true
echo "Built $OUT  ->  drag it to /Applications"
