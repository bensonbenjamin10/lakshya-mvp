#!/bin/bash

# Wireless Debugging Helper Script for Android
# This script helps you connect to your Android device wirelessly for Flutter debugging

DEVICE_IP=""
PORT=5555
PAIR=false
PAIR_PORT=""
PAIR_CODE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -DeviceIP)
            DEVICE_IP="$2"
            shift 2
            ;;
        -Port)
            PORT="$2"
            shift 2
            ;;
        -Pair)
            PAIR=true
            shift
            ;;
        -PairPort)
            PAIR_PORT="$2"
            shift 2
            ;;
        -PairCode)
            PAIR_CODE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "=== Android Wireless Debugging Helper ==="
echo ""

# Check if ADB is available
if ! command -v adb &> /dev/null; then
    echo "ERROR: ADB not found in PATH. Please install Android SDK Platform Tools."
    echo "Download from: https://developer.android.com/studio/releases/platform-tools"
    exit 1
fi

echo "ADB found: $(which adb)"
echo ""

# Method 1: Pairing (Android 11+)
if [ "$PAIR" = true ]; then
    if [ -z "$DEVICE_IP" ] || [ -z "$PAIR_PORT" ]; then
        echo "ERROR: For pairing, you need to provide:"
        echo "  -DeviceIP: The IP address shown in Wireless Debugging settings"
        echo "  -PairPort: The port number shown in Wireless Debugging settings"
        echo ""
        echo "Example: ./wireless-debug.sh -Pair -DeviceIP 192.168.1.100 -PairPort 12345"
        exit 1
    fi
    
    echo "Pairing with device at $DEVICE_IP:$PAIR_PORT..."
    if [ -n "$PAIR_CODE" ]; then
        echo "Using pairing code: $PAIR_CODE"
        echo "$PAIR_CODE" | adb pair $DEVICE_IP:$PAIR_PORT
    else
        echo "You will be prompted to enter the pairing code from your device."
        adb pair $DEVICE_IP:$PAIR_PORT
    fi
    
    echo ""
    echo "After pairing, use the connection port shown on your device to connect."
    echo "Example: ./wireless-debug.sh -DeviceIP $DEVICE_IP -Port <CONNECTION_PORT>"
    exit 0
fi

# Method 2: Connect (after pairing or using TCP/IP)
if [ -n "$DEVICE_IP" ]; then
    echo "Connecting to device at $DEVICE_IP:$PORT..."
    adb connect $DEVICE_IP:$PORT
    
    echo ""
    echo "Checking connected devices..."
    adb devices
    
    echo ""
    echo "You can now run Flutter commands:"
    echo "  flutter devices"
    echo "  flutter run"
    exit 0
fi

# Interactive mode - show instructions
echo "=== Wireless Debugging Setup ==="
echo ""
echo "Choose your method:"
echo ""
echo "METHOD 1: Wireless Debugging (Android 11+)"
echo "  1. On your device: Settings → Developer Options → Wireless Debugging → ON"
echo "  2. Tap 'Pair device with pairing code'"
echo "  3. Note the IP address and port shown"
echo "  4. Run: ./wireless-debug.sh -Pair -DeviceIP <IP> -PairPort <PORT>"
echo "  5. Enter the pairing code when prompted"
echo "  6. After pairing, note the connection port shown on device"
echo "  7. Run: ./wireless-debug.sh -DeviceIP <IP> -Port <CONNECTION_PORT>"
echo ""
echo "METHOD 2: ADB over TCP/IP (All Android versions)"
echo "  1. Connect device via USB first"
echo "  2. Run: adb tcpip 5555"
echo "  3. Find your device IP: Settings → About Phone → IP Address"
echo "  4. Disconnect USB"
echo "  5. Run: ./wireless-debug.sh -DeviceIP <IP> -Port 5555"
echo ""
echo "To check connected devices: adb devices"
echo "To disconnect: adb disconnect <IP>:<PORT>"
echo ""

# Show current devices
echo "Current connected devices:"
adb devices

