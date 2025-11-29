# Firebase Setup Script for paperLMS project
# This script helps verify Firebase configuration

Write-Host "Firebase Setup for paperLMS" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""

# Check if Firebase CLI is installed
Write-Host "Checking Firebase CLI..." -ForegroundColor Yellow
$firebaseVersion = firebase --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Firebase CLI version: $firebaseVersion" -ForegroundColor Green
} else {
    Write-Host "Firebase CLI not found. Install it with: npm install -g firebase-tools" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check current project
Write-Host "Current Firebase project configuration:" -ForegroundColor Yellow
Get-Content .firebaserc | Write-Host

Write-Host ""
Write-Host "To complete setup:" -ForegroundColor Cyan
Write-Host "1. Make sure you're logged in: firebase login --reauth" -ForegroundColor White
Write-Host "2. Set the project: firebase use paperlms-001" -ForegroundColor White
Write-Host "3. Get web app config from Firebase Console:" -ForegroundColor White
Write-Host "   - Go to Firebase Console > Project Settings > General" -ForegroundColor Gray
Write-Host "   - Scroll to 'Your apps' section" -ForegroundColor Gray
Write-Host "   - Add a web app if you haven't already" -ForegroundColor Gray
Write-Host "   - Copy the Firebase config values" -ForegroundColor Gray
Write-Host "4. Update lib/config/firebase_config.dart with your config (optional, for build-time config)" -ForegroundColor White
Write-Host "5. Build and deploy: .\scripts\deploy.ps1" -ForegroundColor White

Write-Host ""
Write-Host "Note: Firebase Analytics will work automatically once Firebase is initialized." -ForegroundColor Yellow
Write-Host "The app will gracefully handle missing Firebase config during development." -ForegroundColor Yellow

