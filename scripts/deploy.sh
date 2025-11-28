#!/bin/bash
# Deployment script for Firebase Hosting
# This script builds and deploys the Flutter web app to Firebase Hosting

echo "Starting deployment process..."

# Step 1: Build Flutter web app
echo ""
echo "Step 1: Building Flutter web app..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "Build failed! Aborting deployment."
    exit 1
fi

echo "Build completed successfully!"

# Step 2: Deploy to Firebase Hosting
echo ""
echo "Step 2: Deploying to Firebase Hosting..."
firebase deploy --only hosting

if [ $? -eq 0 ]; then
    echo ""
    echo "Deployment completed successfully!"
    echo "Your app is now live on Firebase Hosting!"
else
    echo ""
    echo "Deployment failed!"
    exit 1
fi

