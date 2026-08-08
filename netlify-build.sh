#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting Astra Frontend Build for Netlify..."

# Extract the exact Flutter version your team is using from FVM config
FLUTTER_VERSION=$(grep '"flutterSdkVersion"' .fvm/fvm_config.json | cut -d '"' -f 4)

if [ -z "$FLUTTER_VERSION" ]; then
    echo "Warning: Could not read FVM config, defaulting to 'stable'"
    FLUTTER_VERSION="stable"
fi

echo "Installing Flutter version: $FLUTTER_VERSION"

# Clone the flutter repository
git clone https://github.com/flutter/flutter.git _flutter

# Checkout the specific version to match the local development environment perfectly
cd _flutter
git checkout $FLUTTER_VERSION
cd ..

# Add flutter to PATH
export PATH="$PATH:`pwd`/_flutter/bin"

echo "Verifying Flutter Installation:"
flutter --version

echo "Enabling Web Support..."
flutter config --enable-web

echo "Fetching Dependencies..."
flutter pub get

echo "Building Production Web Bundle..."
flutter build web --release

echo "Build Completed Successfully!"
