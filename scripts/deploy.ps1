# Deployment script for Firebase Hosting
# This script builds and deploys the Flutter web app to Firebase Hosting

Write-Host "Starting deployment process..." -ForegroundColor Green

# Step 1: Build Flutter web app
Write-Host "`nStep 1: Building Flutter web app..." -ForegroundColor Yellow
flutter build web --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed! Aborting deployment." -ForegroundColor Red
    exit 1
}

Write-Host "Build completed successfully!" -ForegroundColor Green

# Step 2: Deploy to Firebase Hosting
Write-Host "`nStep 2: Deploying to Firebase Hosting..." -ForegroundColor Yellow
firebase deploy --only hosting

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nDeployment completed successfully!" -ForegroundColor Green
    Write-Host "Your app is now live on Firebase Hosting!" -ForegroundColor Cyan
} else {
    Write-Host "`nDeployment failed!" -ForegroundColor Red
    exit 1
}

