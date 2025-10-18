#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "➡️ Ensuring Flutter dependencies are installed"
flutter pub get

echo "➡️ Verifying iOS info.plist encryption declaration"
PLIST_FILE="ios/Runner/Info.plist"
if [ -f "$PLIST_FILE" ] && command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then
  if ! /usr/libexec/PlistBuddy -c "Print :ITSAppUsesNonExemptEncryption" "$PLIST_FILE" >/dev/null 2>&1; then
    /usr/libexec/PlistBuddy -c "Add :ITSAppUsesNonExemptEncryption bool NO" "$PLIST_FILE"
    echo "Added ITSAppUsesNonExemptEncryption flag to Info.plist"
  else
    echo "Info.plist already declares encryption usage"
  fi
else
  echo "⚠️ Skipping Info.plist encryption check (not running on macOS)"
fi

echo "➡️ Validating iOS assets"
if [ ! -d "ios/Runner/Assets.xcassets/AppIcon.appiconset" ]; then
  echo "❌ Missing AppIcon asset catalog" >&2
  exit 1
fi

echo "➡️ Validating Android launcher icons"
if [ ! -d "android/app/src/main/res/mipmap-hdpi" ]; then
  echo "❌ Missing Android launcher icons" >&2
  exit 1
fi

echo "✅ App Store preparation checklist passed"
