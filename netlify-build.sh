#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting Astra Frontend Build for Netlify..."

# Extract the exact Flutter version your team is using from FVM config
if [ -f ".fvm/fvm_config.json" ]; then
    FLUTTER_VERSION=$(grep '"flutterSdkVersion"' .fvm/fvm_config.json | cut -d '"' -f 4)
else
    FLUTTER_VERSION=""
fi

if [ -z "$FLUTTER_VERSION" ]; then
    echo "Warning: Could not read FVM config, defaulting to 'stable'"
    FLUTTER_VERSION="stable"
fi

echo "Installing Flutter version: $FLUTTER_VERSION"

# Clean up any cached flutter directory from previous failed builds
if [ -d "_flutter" ]; then
    echo "Found cached _flutter directory, cleaning up to ensure fresh install..."
    rm -rf _flutter
fi

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

echo "Generating .env file from Netlify Environment Variables..."
# This ensures flutter_dotenv has the required .env file at runtime
echo "API_BASE_URL=$API_BASE_URL" > .env

echo "Building Production Web Bundle..."
flutter build web --release

echo "Build Completed Successfully!"
