#!/bin/bash

# iOS Flavor Setup Script for Dienstplan Flutter App
# This script sets up iOS flavors (dev and prod) similar to Android configuration

set -e

echo "🚀 Setting up iOS flavors for Dienstplan..."

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

# Create iOS flavor directories
echo "📁 Creating iOS flavor directories..."

# Create flavor-specific Info.plist files
mkdir -p ios/Runner/Flavors/dev
mkdir -p ios/Runner/Flavors/prod

# Create dev Info.plist
cat > ios/Runner/Flavors/dev/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDisplayName</key>
	<string>Dienstplan Dev</string>
	<key>CFBundleName</key>
	<string>Dienstplan Dev</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER).dev</string>
</dict>
</plist>
EOF

# Create prod Info.plist
cat > ios/Runner/Flavors/prod/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDisplayName</key>
	<string>Dienstplan</string>
	<key>CFBundleName</key>
	<string>Dienstplan</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
</dict>
</plist>
EOF

echo "✅ iOS flavor directories and Info.plist files created"

# Create flavor configuration file
cat > ios/FlavorConfig.xcconfig << 'EOF'
// Flavor Configuration for Dienstplan iOS App
// This file defines the flavor-specific settings

// Default flavor (can be overridden)
FLAVOR = dev

// Flavor-specific settings
#include "Flavors/$(FLAVOR).xcconfig"
EOF

# Create dev flavor config
cat > ios/Flavors/dev.xcconfig << 'EOF'
// Development Flavor Configuration
PRODUCT_BUNDLE_IDENTIFIER = io.scelus.dienstplan.dev
PRODUCT_NAME = Dienstplan Dev
DISPLAY_NAME = Dienstplan Dev
EOF

# Create prod flavor config
cat > ios/Flavors/prod.xcconfig << 'EOF'
// Production Flavor Configuration
PRODUCT_BUNDLE_IDENTIFIER = io.scelus.dienstplan
PRODUCT_NAME = Dienstplan
DISPLAY_NAME = Dienstplan
EOF

echo "✅ Flavor configuration files created"

# Create build script for flavors
cat > ios/build_flavor.sh << 'EOF'
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
EOF

chmod +x ios/build_flavor.sh

echo "✅ Build script created"

# Create Xcode scheme configuration
echo "📱 Creating Xcode schemes..."

# Create dev scheme
cat > ios/Runner.xcodeproj/xcshareddata/xcschemes/Dienstplan-Dev.xcscheme << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "97C146ED1CF9000F007C117D"
               BuildableName = "Runner.app"
               BlueprintName = "Runner"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug-dev"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug-dev"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release-prod"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug-dev">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release-prod"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
EOF

# Create prod scheme
cat > ios/Runner.xcodeproj/xcshareddata/xcschemes/Dienstplan-Prod.xcscheme << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "97C146ED1CF9000F007C117D"
               BuildableName = "Runner.app"
               BlueprintName = "Runner"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug-prod"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug-prod"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release-prod"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug-prod">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release-prod"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
EOF

echo "✅ Xcode schemes created"

echo ""
echo "🎉 iOS flavor setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Open the project in Xcode: open ios/Runner.xcworkspace"
echo "2. Configure build configurations for each flavor"
echo "3. Set up code signing for each flavor"
echo "4. Test the flavors: flutter run --flavor dev"
echo "5. Build for production: flutter build ios --flavor prod --release"
echo ""
echo "📚 For more information, see the iOS deployment guide in the project documentation." 