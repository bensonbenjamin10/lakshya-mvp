# Manual Cloud Run Deployment Script
# This script helps you deploy the admin panel to Cloud Run manually

Write-Host "Manual Cloud Run Deployment Script" -ForegroundColor Green
Write-Host "====================================`n" -ForegroundColor Green

# Check if gcloud is installed
$gcloudInstalled = Get-Command gcloud -ErrorAction SilentlyContinue
if (-not $gcloudInstalled) {
    Write-Host "⚠️  gcloud CLI not found!" -ForegroundColor Yellow
    Write-Host "   Install from: https://cloud.google.com/sdk/docs/install" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Or use Option 3: Google Cloud Console (no CLI needed)" -ForegroundColor Cyan
    Write-Host "   See: admin/MANUAL_DEPLOYMENT.md" -ForegroundColor Cyan
    exit 1
}

Write-Host "✅ gcloud CLI found`n" -ForegroundColor Green

# Check if we're authenticated
Write-Host "Checking authentication..." -ForegroundColor Cyan
$authStatus = gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>&1
if (-not $authStatus) {
    Write-Host "⚠️  Not authenticated. Running: gcloud auth login" -ForegroundColor Yellow
    gcloud auth login
} else {
    Write-Host "✅ Authenticated as: $authStatus`n" -ForegroundColor Green
}

# Set project
Write-Host "Setting project to paperlms-001..." -ForegroundColor Cyan
gcloud config set project paperlms-001
Write-Host "✅ Project set`n" -ForegroundColor Green

# Check if we're in the right directory
if (-not (Test-Path "admin/package.json")) {
    Write-Host "❌ Error: admin/package.json not found" -ForegroundColor Red
    Write-Host "   Make sure you're in the project root directory" -ForegroundColor Yellow
    exit 1
}

Write-Host "Ready to deploy!`n" -ForegroundColor Green
Write-Host "Deployment options:" -ForegroundColor Yellow
Write-Host "1. Deploy from source (recommended) - Builds and deploys automatically" -ForegroundColor White
Write-Host "2. Build Docker image locally first" -ForegroundColor White
Write-Host "3. Use Google Cloud Console (no CLI)" -ForegroundColor White
Write-Host ""
$choice = Read-Host "Choose option (1-3) or press Enter for option 1"

if ($choice -eq "2") {
    Write-Host "`nBuilding Docker image..." -ForegroundColor Cyan
    Set-Location admin
    docker build -t gcr.io/paperlms-001/admin:latest .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Docker build failed!" -ForegroundColor Red
        Set-Location ..
        exit 1
    }
    Write-Host "✅ Docker image built`n" -ForegroundColor Green
    
    Write-Host "Pushing to Google Container Registry..." -ForegroundColor Cyan
    gcloud auth configure-docker
    docker push gcr.io/paperlms-001/admin:latest
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Docker push failed!" -ForegroundColor Red
        Set-Location ..
        exit 1
    }
    Write-Host "✅ Image pushed`n" -ForegroundColor Green
    Set-Location ..
    
    Write-Host "Deploying to Cloud Run..." -ForegroundColor Cyan
    gcloud run deploy admin `
        --image gcr.io/paperlms-001/admin:latest `
        --region us-central1 `
        --platform managed `
        --allow-unauthenticated `
        --project paperlms-001 `
        --set-env-vars "NEXT_PUBLIC_SUPABASE_URL=https://spzcjpvtikyoykbgnlgr.supabase.co,NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwemNqcHZ0aWt5b3lrYmdubGdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNTY2NzgsImV4cCI6MjA3OTkzMjY3OH0.m06J6IujRB6dX0Cqw00Y6NnGgGUCo6yU7CdnqSIWVzc"
} elseif ($choice -eq "3") {
    Write-Host "`nOpening Google Cloud Console..." -ForegroundColor Cyan
    Start-Process "https://console.cloud.google.com/run?project=paperlms-001"
    Write-Host "`nSee admin/MANUAL_DEPLOYMENT.md for console deployment steps" -ForegroundColor Yellow
    exit 0
} else {
    # Option 1: Deploy from source (default)
    Write-Host "`nDeploying from source (this will take 5-10 minutes)..." -ForegroundColor Cyan
    Write-Host "Building and deploying to Cloud Run..." -ForegroundColor Gray
    Write-Host ""
    
    Set-Location admin
    
    gcloud run deploy admin `
        --source . `
        --region us-central1 `
        --platform managed `
        --allow-unauthenticated `
        --project paperlms-001 `
        --set-env-vars "NEXT_PUBLIC_SUPABASE_URL=https://spzcjpvtikyoykbgnlgr.supabase.co,NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwemNqcHZ0aWt5b3lrYmdubGdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNTY2NzgsImV4cCI6MjA3OTkzMjY3OH0.m06J6IujRB6dX0Cqw00Y6NnGgGUCo6yU7CdnqSIWVzc"
    
    Set-Location ..
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Deployment successful!" -ForegroundColor Green
    Write-Host "`nYour admin panel is now live at:" -ForegroundColor Cyan
    Write-Host "   https://admin-lakshya.web.app" -ForegroundColor White
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Test the admin panel" -ForegroundColor White
    Write-Host "2. Login with admin/faculty credentials" -ForegroundColor White
    Write-Host "3. Verify all features work correctly" -ForegroundColor White
} else {
    Write-Host "`n❌ Deployment failed!" -ForegroundColor Red
    Write-Host "Check the error messages above" -ForegroundColor Yellow
    Write-Host "See admin/MANUAL_DEPLOYMENT.md for troubleshooting" -ForegroundColor Cyan
    exit 1
}


