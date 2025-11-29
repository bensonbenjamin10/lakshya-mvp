# Deployment script for Next.js Admin Panel
# This script builds and deploys the admin panel to Firebase Hosting + Cloud Run

Write-Host "Starting admin panel deployment..." -ForegroundColor Green

# Step 1: Build Next.js admin app
Write-Host "`nStep 1: Building Next.js admin app..." -ForegroundColor Yellow
Set-Location admin
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed! Aborting deployment." -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host "Build completed successfully!" -ForegroundColor Green
Set-Location ..

# Step 2: Deploy to Firebase
Write-Host "`nStep 2: Deploying to Firebase Hosting + Cloud Run..." -ForegroundColor Yellow
firebase deploy --only hosting:admin,run:admin

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nAdmin panel deployment completed successfully!" -ForegroundColor Green
    Write-Host "Admin panel is now live!" -ForegroundColor Cyan
} else {
    Write-Host "`nDeployment failed!" -ForegroundColor Red
    exit 1
}

