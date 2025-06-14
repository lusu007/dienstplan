#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[DEBUG]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to check if adb is available
check_adb() {
    if ! command -v adb &> /dev/null; then
        print_error "adb is not installed or not in PATH"
        exit 1
    fi
}

# Function to check if flutter is available
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "flutter is not installed or not in PATH"
        exit 1
    fi
}

# Function to check if device is connected
check_device() {
    if ! adb devices | grep -q "device$"; then
        print_error "No device connected"
        exit 1
    fi
}

# Function to get the process ID of the app
get_pid() {
    local pid=$(adb shell ps | grep dienstplan | awk '{print $2}')
    if [ -z "$pid" ]; then
        print_error "App is not running"
        return 1
    fi
    echo $pid
}

# Function to show logs
show_logs() {
    print_message "Showing logs from device..."
    adb logcat -v time | grep -i "dienstplan"
}

# Function to clear logs
clear_logs() {
    print_message "Clearing logs..."
    adb logcat -c
}

# Function to start the app
start_app() {
    print_message "Starting app..."
    check_flutter
    check_device
    
    # Check if app is already running
    if get_pid &> /dev/null; then
        print_warning "App is already running. Use --restart to restart it."
        return 1
    fi
    
    # Start the app
    flutter run
}

# Function to restart the app
restart_app() {
    print_message "Restarting app..."
    check_flutter
    check_device
    
    # Kill the app if it's running
    local pid=$(get_pid)
    if [ $? -eq 0 ]; then
        print_info "Stopping app (PID: $pid)..."
        adb shell am force-stop com.example.dienstplan
        sleep 2
    fi
    
    # Start the app
    flutter run
}

# Function to attach to running app
attach_to_app() {
    local pid=$(get_pid)
    if [ $? -eq 0 ]; then
        print_message "Attaching to process $pid..."
        flutter attach --pid $pid
    fi
}

# Function to show app info
show_app_info() {
    print_message "Showing app info..."
    adb shell dumpsys package com.example.dienstplan | grep -E "versionName|versionCode|firstInstallTime|lastUpdateTime"
}

# Function to uninstall app
uninstall_app() {
    print_warning "Are you sure you want to uninstall the app? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_message "Uninstalling app..."
        adb uninstall com.example.dienstplan
    else
        print_info "Uninstall cancelled"
    fi
}

# Function to show help
show_help() {
    echo "Usage: ./debug.sh [option]"
    echo "Options:"
    echo "  -s, --start       Start the app"
    echo "  -r, --restart     Restart the app"
    echo "  -a, --attach      Attach to running app"
    echo "  -l, --logs        Show logs"
    echo "  -c, --clear       Clear logs"
    echo "  -i, --info        Show app info"
    echo "  -u, --uninstall   Uninstall the app"
    echo "  -h, --help        Show this help message"
}

# Main script
check_adb
check_device

case "$1" in
    -s|--start)
        start_app
        ;;
    -r|--restart)
        restart_app
        ;;
    -a|--attach)
        attach_to_app
        ;;
    -l|--logs)
        show_logs
        ;;
    -c|--clear)
        clear_logs
        ;;
    -i|--info)
        show_app_info
        ;;
    -u|--uninstall)
        uninstall_app
        ;;
    -h|--help)
        show_help
        ;;
    *)
        print_warning "No option specified"
        show_help
        ;;
esac 