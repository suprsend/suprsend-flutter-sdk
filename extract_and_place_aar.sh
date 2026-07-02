#!/usr/bin/env bash
set -euo pipefail

AAR_ZIP="/Users/D/suprsend/SSAarD/downloads/com-suprsend-native-0.1.14.zip"

ANDROID_LIBS_DIR="android/libs"

TEMP_DIR="$(mktemp -d)"

unzip -q "$AAR_ZIP" -d "$TEMP_DIR"

mkdir -p "$ANDROID_LIBS_DIR"
cp "$TEMP_DIR"/com/suprsend/native/*/*.aar "$ANDROID_LIBS_DIR/"

rm -rf "$TEMP_DIR"