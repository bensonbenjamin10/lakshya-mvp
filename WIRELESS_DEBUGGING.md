# Wireless Debugging Guide for Android Devices

This guide explains how to set up wireless debugging for your Flutter Android app, allowing you to debug without a USB cable.

## Prerequisites

- Android device with Developer Options enabled
- Android SDK Platform Tools installed (includes `adb`)
- Device and computer on the same Wi-Fi network

## Method 1: Wireless Debugging (Android 11+) - Recommended

This is the modern, secure method for Android 11 and later.

### Step-by-Step Instructions

1. **Enable Developer Options** (if not already enabled):
   - Go to **Settings → About Phone**
   - Tap **Build Number** 7 times
   - Go back to **Settings → Developer Options**

2. **Enable Wireless Debugging**:
   - In Developer Options, find **Wireless Debugging**
   - Toggle it **ON**
   - Tap on **Wireless Debugging** to open settings

3. **Pair Your Device**:
   - Tap **Pair device with pairing code**
   - Note the **IP address** and **port** shown (e.g., `192.168.1.100:12345`)
   - Note the **pairing code** (6-digit number)

4. **Pair from Computer**:
   ```powershell
   # Using the helper script
   .\scripts\wireless-debug.ps1 -Pair -DeviceIP 192.168.1.100 -PairPort 12345
   
   # Or manually
   adb pair 192.168.1.100:12345
   # Enter the pairing code when prompted
   ```

5. **Connect to Device**:
   - After pairing, your device will show a **connection port** (different from pairing port)
   - Connect using that port:
   ```powershell
   .\scripts\wireless-debug.ps1 -DeviceIP 192.168.1.100 -Port <CONNECTION_PORT>
   
   # Or manually
   adb connect 192.168.1.100:<CONNECTION_PORT>
   ```

6. **Verify Connection**:
   ```powershell
   adb devices
   # Should show your device with "device" status
   ```

7. **Run Flutter App**:
   ```powershell
   flutter devices  # Should show your wireless device
   flutter run      # Deploy and run your app
   ```

## Method 2: ADB over TCP/IP (All Android Versions)

This method works on all Android versions but requires an initial USB connection.

### Step-by-Step Instructions

1. **Connect via USB**:
   - Connect your device to computer via USB cable
   - Enable **USB Debugging** in Developer Options

2. **Enable TCP/IP Mode**:
   ```powershell
   adb tcpip 5555
   ```

3. **Find Device IP Address**:
   - On device: **Settings → About Phone → Status → IP Address**
   - Or: **Settings → Wi-Fi → Tap on connected network → View IP Address**

4. **Disconnect USB**:
   - Unplug the USB cable

5. **Connect Wirelessly**:
   ```powershell
   # Using the helper script
   .\scripts\wireless-debug.ps1 -DeviceIP 192.168.1.100 -Port 5555
   
   # Or manually
   adb connect 192.168.1.100:5555
   ```

6. **Verify and Run**:
   ```powershell
   adb devices
   flutter devices
   flutter run
   ```

## Using the Helper Scripts

### PowerShell (Windows)
```powershell
# Show instructions
.\scripts\wireless-debug.ps1

# Pair device (Android 11+)
.\scripts\wireless-debug.ps1 -Pair -DeviceIP 192.168.1.100 -PairPort 12345

# Connect device
.\scripts\wireless-debug.ps1 -DeviceIP 192.168.1.100 -Port 5555
```

### Bash (Linux/Mac)
```bash
# Show instructions
./scripts/wireless-debug.sh

# Pair device (Android 11+)
./scripts/wireless-debug.sh -Pair -DeviceIP 192.168.1.100 -PairPort 12345

# Connect device
./scripts/wireless-debug.sh -DeviceIP 192.168.1.100 -Port 5555
```

## Troubleshooting

### Device Not Showing Up
- Ensure device and computer are on the same Wi-Fi network
- Check firewall settings (may need to allow ADB connections)
- Try disconnecting and reconnecting:
  ```powershell
  adb disconnect
  adb connect <IP>:<PORT>
  ```

### Connection Drops
- Keep device screen on or disable battery optimization for ADB
- Ensure Wi-Fi stays connected
- Reconnect if needed:
  ```powershell
  adb connect <IP>:<PORT>
  ```

### ADB Not Found
- Install Android SDK Platform Tools:
  - Download from: https://developer.android.com/studio/releases/platform-tools
  - Add to PATH environment variable

### Flutter Not Detecting Device
- After connecting via ADB, run:
  ```powershell
  flutter devices
  ```
- If still not showing, restart Flutter:
  ```powershell
  flutter doctor
  ```

## Disconnecting

To disconnect wireless debugging:
```powershell
adb disconnect <IP>:<PORT>
# Or disconnect all
adb disconnect
```

## Tips

- **Keep pairing info**: After pairing (Android 11+), you can reconnect without re-pairing as long as you use the same connection port
- **Auto-connect**: You can add the connection command to a startup script
- **Multiple devices**: You can connect multiple devices wirelessly simultaneously
- **Security**: Wireless debugging is only active when enabled in Developer Options

## Quick Reference

```powershell
# Check connected devices
adb devices

# List Flutter devices
flutter devices

# Run app on wireless device
flutter run -d <device-id>

# Hot reload (press 'r' in terminal)
# Hot restart (press 'R' in terminal)
# Quit (press 'q' in terminal)
```

