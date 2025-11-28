# Build script for Flutter web
# This script builds the Flutter web app for production

Write-Host "Building Flutter web app..." -ForegroundColor Green

# Build Flutter web
flutter build web --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build completed successfully!" -ForegroundColor Green
    Write-Host "Output directory: build/web" -ForegroundColor Cyan
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

