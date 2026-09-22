#!/bin/bash
# Builds the Android release App Bundle (.aab) for Play Store submission.
#
# Wraps `flutter build appbundle --release` so the required build-time
# config (API_BASE_URL, etc.) can never be silently forgotten the way a
# bare `flutter build appbundle --release` would allow — that would ship a
# binary that crashes for every user on first launch (see dart_defines.json).

set -e

DEFINES_FILE="dart_defines.json"

if [ ! -f "$DEFINES_FILE" ]; then
  echo "ERROR: $DEFINES_FILE not found."
  echo "Copy dart_defines.example.json to $DEFINES_FILE and fill in real values before releasing."
  exit 1
fi

if ! grep -q '"API_BASE_URL"' "$DEFINES_FILE"; then
  echo "ERROR: API_BASE_URL is missing from $DEFINES_FILE."
  exit 1
fi

echo "Building Android release App Bundle using $DEFINES_FILE..."
flutter build appbundle --release --dart-define-from-file="$DEFINES_FILE"

echo ""
echo "Done: build/app/outputs/bundle/release/app-release.aab"
