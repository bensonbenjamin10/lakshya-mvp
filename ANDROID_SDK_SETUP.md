# Android SDK Tools Setup Guide

This guide helps you set up Android SDK command-line tools (`adb`, `avdmanager`, `sdkmanager`) in your PATH.

## Quick Setup

Run the setup script to add Android SDK tools to your PATH for the current session:

```powershell
.\scripts\setup-android-path.ps1
```

This will:
- Add `platform-tools` (adb, fastboot) to PATH
- Add `cmdline-tools` (sdkmanager, avdmanager) to PATH
- Verify all tools are accessible

## Verify Installation

After running the setup script, verify the tools are accessible:

```powershell
adb --version
sdkmanager --version
avdmanager list avd
```

## Permanent PATH Setup

To make these tools permanently available (without running the script each time):

### Windows GUI Method:
1. Press `Win + X` and select **System**
2. Click **Advanced system settings**
3. Click **Environment Variables**
4. Under **System variables**, find and select **Path**, then click **Edit**
5. Click **New** and add:
   - `C:\Users\<YourUsername>\AppData\Local\Android\Sdk\platform-tools`
   - `C:\Users\<YourUsername>\AppData\Local\Android\Sdk\cmdline-tools\latest\bin`
6. Click **OK** on all dialogs
7. Restart your terminal/PowerShell

### PowerShell Method (Run as Administrator):
```powershell
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$platformTools = "$env:LOCALAPPDATA\Android\Sdk\platform-tools"
$cmdlineTools = "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin"

if ($userPath -notlike "*$platformTools*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$platformTools", "User")
}

if ($userPath -notlike "*$cmdlineTools*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$cmdlineTools", "User")
}

Write-Host "PATH updated. Please restart your terminal." -ForegroundColor Green
```

## Available Tools

### ADB (Android Debug Bridge)
- **Location**: `platform-tools\adb.exe`
- **Usage**: `adb devices`, `adb connect`, `adb install`, etc.
- **See**: `WIRELESS_DEBUGGING.md` for wireless debugging setup

### SDK Manager
- **Location**: `cmdline-tools\latest\bin\sdkmanager.bat`
- **Usage**: Install/update Android SDK components
- **Examples**:
  ```powershell
  sdkmanager --list                    # List available packages
  sdkmanager "platform-tools"         # Install platform-tools
  sdkmanager "platforms;android-34"   # Install Android 34 platform
  sdkmanager --update                  # Update all installed packages
  ```

### AVD Manager
- **Location**: `cmdline-tools\latest\bin\avdmanager.bat`
- **Usage**: Manage Android Virtual Devices (emulators)
- **Examples**:
  ```powershell
  avdmanager list avd                  # List all AVDs
  avdmanager create avd -n MyAVD -k "system-images;android-34;google_apis;x86_64"
  avdmanager delete avd -n MyAVD       # Delete an AVD
  ```

## Common Issues

### "Command not found" after adding to PATH
- **Solution**: Restart your terminal/PowerShell window
- The PATH changes only take effect in new terminal sessions

### Tools still not found after restart
- **Solution**: Verify the paths exist:
  ```powershell
  Test-Path "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
  Test-Path "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\avdmanager.bat"
  ```
- If paths don't exist, you may need to install Android SDK Platform Tools or Command-line Tools via Android Studio

### Flutter not detecting tools
- Run `flutter doctor -v` to see Flutter's detected Android SDK location
- Ensure Flutter and your PATH point to the same SDK location

## Integration with Other Scripts

The `wireless-debug.ps1` script automatically adds these tools to PATH when it runs, so you don't need to run `setup-android-path.ps1` separately if you're just using wireless debugging.

## References

- [Android SDK Platform Tools](https://developer.android.com/studio/releases/platform-tools)
- [Android SDK Command-line Tools](https://developer.android.com/studio/command-line)
- [Flutter Android Setup](https://docs.flutter.dev/get-started/install/windows#android-setup)

