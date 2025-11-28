#!/bin/bash
# Build script for Flutter web
# This script builds the Flutter web app for production

echo "Building Flutter web app..."

# Build Flutter web
flutter build web --release

if [ $? -eq 0 ]; then
    echo "Build completed successfully!"
    echo "Output directory: build/web"
else
    echo "Build failed!"
    exit 1
fi

