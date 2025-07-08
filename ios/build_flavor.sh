#!/bin/bash

# Build script for iOS flavors
# Usage: ./build_flavor.sh [dev|prod] [debug|release]

FLAVOR=${1:-dev}
BUILD_TYPE=${2:-debug}

echo "🏗️ Building iOS app for flavor: $FLAVOR, build type: $BUILD_TYPE"

# Set environment variable for flavor
export FLAVOR=$FLAVOR

# Build the app
flutter build ios --flavor $FLAVOR --$BUILD_TYPE

echo "✅ Build completed for $FLAVOR ($BUILD_TYPE)"
