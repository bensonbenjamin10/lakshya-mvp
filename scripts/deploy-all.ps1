# Deployment script for both Flutter App and Admin Panel
# This script builds and deploys both applications

Write-Host "Starting full deployment..." -ForegroundColor Green

# Deploy Flutter app
Write-Host "`n=== Deploying Flutter App ===" -ForegroundColor Cyan
& ".\scripts\deploy-app.ps1"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter app deployment failed!" -ForegroundColor Red
    exit 1
}

# Deploy Admin panel
Write-Host "`n=== Deploying Admin Panel ===" -ForegroundColor Cyan
& ".\scripts\deploy-admin.ps1"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Admin panel deployment failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Full deployment completed successfully! ===" -ForegroundColor Green

