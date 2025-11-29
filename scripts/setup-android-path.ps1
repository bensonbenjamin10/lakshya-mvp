# Android SDK PATH Setup Script
# Adds Android SDK tools to PATH for the current PowerShell session

Write-Host "=== Android SDK PATH Setup ===" -ForegroundColor Cyan
Write-Host ""

$androidSdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$platformToolsPath = "$androidSdkPath\platform-tools"
$cmdlineToolsPath = "$androidSdkPath\cmdline-tools\latest\bin"

# Check if Android SDK exists
if (-not (Test-Path $androidSdkPath)) {
    Write-Host "ERROR: Android SDK not found at: $androidSdkPath" -ForegroundColor Red
    Write-Host "Please install Android Studio or Android SDK." -ForegroundColor Yellow
    exit 1
}

Write-Host "Android SDK found at: $androidSdkPath" -ForegroundColor Green
Write-Host ""

# Add to PATH if not already present
$pathsToAdd = @()

if (Test-Path $platformToolsPath) {
    if ($env:PATH -notlike "*$platformToolsPath*") {
        $env:PATH += ";$platformToolsPath"
        $pathsToAdd += "platform-tools (adb, fastboot)"
        Write-Host "[OK] Added platform-tools to PATH" -ForegroundColor Green
    } else {
        Write-Host "[OK] platform-tools already in PATH" -ForegroundColor Yellow
    }
} else {
    Write-Host "[X] platform-tools not found" -ForegroundColor Red
}

if (Test-Path $cmdlineToolsPath) {
    if ($env:PATH -notlike "*$cmdlineToolsPath*") {
        $env:PATH += ";$cmdlineToolsPath"
        $pathsToAdd += "cmdline-tools (sdkmanager, avdmanager)"
        Write-Host "[OK] Added cmdline-tools to PATH" -ForegroundColor Green
    } else {
        Write-Host "[OK] cmdline-tools already in PATH" -ForegroundColor Yellow
    }
} else {
    Write-Host "[X] cmdline-tools not found" -ForegroundColor Red
}

Write-Host ""

# Verify tools are accessible
Write-Host "Verifying tools..." -ForegroundColor Cyan

$tools = @("adb", "sdkmanager", "avdmanager")
foreach ($tool in $tools) {
    $found = Get-Command $tool -ErrorAction SilentlyContinue
    if ($found) {
        Write-Host "  [OK] $tool found at: $($found.Source)" -ForegroundColor Green
    } else {
        Write-Host "  [X] $tool not found" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== PATH Updated for Current Session ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: This only affects the current PowerShell session." -ForegroundColor Yellow
Write-Host "To make it permanent, add these paths to your system PATH:" -ForegroundColor Yellow
Write-Host "  $platformToolsPath" -ForegroundColor Cyan
Write-Host "  $cmdlineToolsPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Or run this script at the start of each session." -ForegroundColor Yellow

