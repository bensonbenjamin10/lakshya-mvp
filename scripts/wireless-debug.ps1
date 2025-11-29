# Wireless Debugging Helper Script for Android
# This script helps you connect to your Android device wirelessly for Flutter debugging

param(
    [Parameter(Mandatory=$false)]
    [string]$DeviceIP,
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 5555,
    
    [Parameter(Mandatory=$false)]
    [switch]$Pair,
    
    [Parameter(Mandatory=$false)]
    [int]$PairPort,
    
    [Parameter(Mandatory=$false)]
    [string]$PairCode
)

Write-Host "=== Android Wireless Debugging Helper ===" -ForegroundColor Cyan
Write-Host ""

# Find ADB - check PATH first, then common locations
$adbPath = Get-Command adb -ErrorAction SilentlyContinue
if (-not $adbPath) {
    # Try common Android SDK locations
    $commonPaths = @(
        "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
        "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe",
        "$env:ANDROID_HOME\platform-tools\adb.exe",
        "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe",
        "C:\Android\platform-tools\adb.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            $adbPath = $path
            $sdkRoot = Split-Path (Split-Path $path)
            $platformToolsPath = Split-Path $path
            $cmdlineToolsPath = Join-Path $sdkRoot "cmdline-tools\latest\bin"
            
            # Add platform-tools to PATH for this session
            if ($env:PATH -notlike "*$platformToolsPath*") {
                $env:PATH += ";$platformToolsPath"
            }
            
            # Add cmdline-tools to PATH for this session (for avdmanager, sdkmanager)
            if (Test-Path $cmdlineToolsPath) {
                if ($env:PATH -notlike "*$cmdlineToolsPath*") {
                    $env:PATH += ";$cmdlineToolsPath"
                }
            }
            
            Write-Host "Found ADB at: $path" -ForegroundColor Yellow
            Write-Host "Added Android SDK tools to PATH for this session." -ForegroundColor Yellow
            break
        }
    }
    
    if (-not $adbPath -or -not (Test-Path $adbPath)) {
        Write-Host "ERROR: ADB not found in PATH or common locations." -ForegroundColor Red
        Write-Host "Please install Android SDK Platform Tools or add to PATH." -ForegroundColor Yellow
        Write-Host "Download from: https://developer.android.com/studio/releases/platform-tools" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Or add to PATH: $env:LOCALAPPDATA\Android\Sdk\platform-tools" -ForegroundColor Cyan
        exit 1
    }
}

# Get full path to adb executable
if ($adbPath -is [System.Management.Automation.CommandInfo]) {
    $adbExe = $adbPath.Source
} else {
    $adbExe = $adbPath
}

Write-Host "Using ADB at: $adbExe" -ForegroundColor Green
Write-Host ""

# Method 1: Pairing (Android 11+)
if ($Pair) {
    if (-not $DeviceIP -or -not $PairPort) {
        Write-Host "ERROR: For pairing, you need to provide:" -ForegroundColor Red
        Write-Host "  -DeviceIP: The IP address shown in Wireless Debugging settings" -ForegroundColor Yellow
        Write-Host "  -PairPort: The port number shown in Wireless Debugging settings" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Example: .\wireless-debug.ps1 -Pair -DeviceIP 192.168.1.100 -PairPort 12345" -ForegroundColor Cyan
        exit 1
    }
    
    Write-Host "Pairing with device at $DeviceIP`:$PairPort..." -ForegroundColor Yellow
    if ($PairCode) {
        Write-Host "Using pairing code: $PairCode" -ForegroundColor Cyan
        & $adbExe pair $DeviceIP`:$PairPort
    } else {
        Write-Host "You will be prompted to enter the pairing code from your device." -ForegroundColor Cyan
        & $adbExe pair $DeviceIP`:$PairPort
    }
    
    Write-Host ""
    Write-Host "After pairing, use the connection port shown on your device to connect." -ForegroundColor Yellow
    Write-Host "Example: .\wireless-debug.ps1 -DeviceIP $DeviceIP -Port <CONNECTION_PORT>" -ForegroundColor Cyan
    exit 0
}

# Method 2: Connect (after pairing or using TCP/IP)
if ($DeviceIP) {
    Write-Host "Connecting to device at $DeviceIP`:$Port..." -ForegroundColor Yellow
    & $adbExe connect "$DeviceIP`:$Port"
    
    Write-Host ""
    Write-Host "Checking connected devices..." -ForegroundColor Cyan
    & $adbExe devices
    
    Write-Host ""
    Write-Host "You can now run Flutter commands:" -ForegroundColor Green
    Write-Host "  flutter devices" -ForegroundColor Cyan
    Write-Host "  flutter run" -ForegroundColor Cyan
    exit 0
}

# Interactive mode - show instructions
Write-Host "=== Wireless Debugging Setup ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Choose your method:" -ForegroundColor Yellow
Write-Host ""
Write-Host "METHOD 1: Wireless Debugging (Android 11+)" -ForegroundColor Green
Write-Host "  1. On your device: Settings → Developer Options → Wireless Debugging → ON" -ForegroundColor White
Write-Host "  2. Tap 'Pair device with pairing code'" -ForegroundColor White
Write-Host "  3. Note the IP address and port shown" -ForegroundColor White
Write-Host "  4. Run: .\wireless-debug.ps1 -Pair -DeviceIP <IP> -PairPort <PORT>" -ForegroundColor Cyan
Write-Host "  5. Enter the pairing code when prompted" -ForegroundColor White
Write-Host "  6. After pairing, note the connection port shown on device" -ForegroundColor White
Write-Host "  7. Run: .\wireless-debug.ps1 -DeviceIP <IP> -Port <CONNECTION_PORT>" -ForegroundColor Cyan
Write-Host ""
Write-Host "METHOD 2: ADB over TCP/IP (All Android versions)" -ForegroundColor Green
Write-Host "  1. Connect device via USB first" -ForegroundColor White
Write-Host "  2. Run: adb tcpip 5555" -ForegroundColor Cyan
Write-Host "  3. Find your device IP: Settings → About Phone → IP Address" -ForegroundColor White
Write-Host "  4. Disconnect USB" -ForegroundColor White
Write-Host "  5. Run: .\wireless-debug.ps1 -DeviceIP <IP> -Port 5555" -ForegroundColor Cyan
Write-Host ""
Write-Host "To check connected devices: adb devices" -ForegroundColor Yellow
Write-Host "To disconnect: adb disconnect <IP>:<PORT>" -ForegroundColor Yellow
Write-Host ""

# Show current devices
Write-Host "Current connected devices:" -ForegroundColor Cyan
& $adbExe devices

