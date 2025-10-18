#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

./tool/release/app_store_prepare.sh

echo "➡️ Building Android app bundle"
flutter build appbundle --release

echo "➡️ Building iOS IPA"
flutter build ipa --release

echo "✅ Release artifacts generated"
