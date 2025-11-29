# Setup script for GitHub Actions Cloud Run Deployment
# This script helps verify prerequisites and provides next steps

Write-Host "GitHub Actions Cloud Run Deployment Setup" -ForegroundColor Green
Write-Host "==========================================`n" -ForegroundColor Green

# Check if we're in a git repository
$isGitRepo = Test-Path ".git"
if (-not $isGitRepo) {
    Write-Host "⚠️  Warning: Not in a git repository" -ForegroundColor Yellow
    Write-Host "   Initialize git: git init" -ForegroundColor Gray
    Write-Host ""
}

# Check for GitHub Actions workflow
$workflowExists = Test-Path ".github/workflows/deploy-admin.yml"
if ($workflowExists) {
    Write-Host "✅ GitHub Actions workflow found" -ForegroundColor Green
} else {
    Write-Host "❌ GitHub Actions workflow not found" -ForegroundColor Red
}

# Check for required files
$requiredFiles = @(
    "admin/package.json",
    "admin/next.config.ts",
    "admin/Dockerfile",
    "firebase.json"
)

Write-Host "`nChecking required files..." -ForegroundColor Cyan
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file (missing)" -ForegroundColor Red
    }
}

# Check for .env.local
$envLocalExists = Test-Path "admin/.env.local"
if ($envLocalExists) {
    Write-Host "`n✅ admin/.env.local found (will be ignored by git)" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  admin/.env.local not found" -ForegroundColor Yellow
    Write-Host "   This is okay - secrets will be set in GitHub" -ForegroundColor Gray
}

Write-Host "`n" + "="*50 -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "="*50 -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Create Google Cloud Service Account:" -ForegroundColor White
Write-Host "   https://console.cloud.google.com/iam-admin/serviceaccounts?project=paperlms-001" -ForegroundColor Gray
Write-Host "   - Name: github-actions-deploy" -ForegroundColor Gray
Write-Host "   - Roles: Cloud Run Admin, Service Account User, Storage Admin" -ForegroundColor Gray
Write-Host "   - Download JSON key" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Add GitHub Secrets:" -ForegroundColor White
Write-Host "   Go to: Your Repo → Settings → Secrets and variables)" -ForegroundColor Gray
Write-Host "   Add these secrets:" -ForegroundColor Gray
Write-Host "   - GCP_SA_KEY (paste entire JSON key file)" -ForegroundColor Gray
Write-Host "   - NEXT_PUBLIC_SUPABASE_URL" -ForegroundColor Gray
Write-Host "   - NEXT_PUBLIC_SUPABASE_ANON_KEY" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Enable APIs (if not already enabled):" -ForegroundColor White
Write-Host "   https://console.cloud.google.com/apis/library?project=paperlms-001" -ForegroundColor Gray
Write-Host "   - Cloud Build API" -ForegroundColor Gray
Write-Host "   - Artifact Registry API" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Push to GitHub:" -ForegroundColor White
Write-Host "   git add ." -ForegroundColor Gray
Write-Host "   git commit -m 'Add GitHub Actions for Cloud Run deployment'" -ForegroundColor Gray
Write-Host "   git push origin main" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Monitor deployment:" -ForegroundColor White
Write-Host "   GitHub → Actions tab → Watch the workflow run" -ForegroundColor Gray
Write-Host ""
Write-Host "Full instructions: .github/SETUP.md" -ForegroundColor Cyan
Write-Host ""

