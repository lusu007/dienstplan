#!/bin/bash

# iOS Code Signing Verification Script
# Run this on a Mac to verify your certificate and provisioning profile

echo "🔍 iOS Code Signing Verification Script"
echo "======================================"

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script must be run on macOS"
    exit 1
fi

# Function to decode base64 and save to file
decode_base64() {
    local secret_name=$1
    local output_file=$2
    echo "Please paste the base64 content for $secret_name (press Ctrl+D when done):"
    cat > temp_base64.txt
    base64 -d temp_base64.txt > "$output_file"
    rm temp_base64.txt
    echo "✅ Decoded $secret_name to $output_file"
}

# Function to verify certificate
verify_certificate() {
    local cert_file=$1
    echo "🔐 Verifying certificate: $cert_file"
    
    if [ ! -f "$cert_file" ]; then
        echo "❌ Certificate file not found: $cert_file"
        return 1
    fi
    
    # Check certificate type and validity
    security pkcs12 -info -in "$cert_file" -noout -passin pass:"$CERT_PASSWORD" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Certificate file is valid PKCS12"
    else
        echo "❌ Certificate file is invalid or password is wrong"
        return 1
    fi
    
    # Extract certificate info
    echo "📋 Certificate Details:"
    openssl pkcs12 -in "$cert_file" -nokeys -passin pass:"$CERT_PASSWORD" 2>/dev/null | openssl x509 -noout -subject -issuer -dates
    
    # Extract certificate hash
    CERT_HASH=$(openssl pkcs12 -in "$cert_file" -nokeys -passin pass:"$CERT_PASSWORD" 2>/dev/null | openssl x509 -noout -fingerprint -sha1 | cut -d= -f2 | tr -d ':')
    echo "Certificate SHA1 hash: $CERT_HASH"
}

# Function to verify provisioning profile
verify_provisioning_profile() {
    local profile_file=$1
    echo "📱 Verifying provisioning profile: $profile_file"
    
    if [ ! -f "$profile_file" ]; then
        echo "❌ Provisioning profile file not found: $profile_file"
        return 1
    fi
    
    # Extract profile info
    echo "📋 Provisioning Profile Details:"
    security cms -D -i "$profile_file" | grep -E "(Name|TeamIdentifier|TeamName|AppIDName|UUID|ExpirationDate)" | head -10
    
    # Check certificates in profile
    echo "🔐 Certificates in Profile:"
    PROFILE_CERT_HASH=$(security cms -D -i "$profile_file" | grep -A 10 "DeveloperCertificates" | grep -o '[A-F0-9]\{40\}' | head -1)
    echo "Profile certificate hash: $PROFILE_CERT_HASH"
    
    # Show full certificate data for manual verification
    echo "📄 Full certificate data in profile:"
    security cms -D -i "$profile_file" | grep -A 20 "DeveloperCertificates" | head -25
}

# Function to verify certificate-profile match
verify_certificate_profile_match() {
    local cert_hash=$1
    local profile_hash=$2
    
    echo "🔍 Verifying Certificate-Profile Match:"
    echo "   Certificate hash: $cert_hash"
    echo "   Profile hash: $profile_hash"
    
    if [ "$cert_hash" = "$profile_hash" ]; then
        echo "✅ Certificate hash matches provisioning profile"
        return 0
    else
        echo "❌ Certificate hash mismatch!"
        echo "   This will cause App Store Connect upload to fail"
        return 1
    fi
}

# Function to test signing
test_signing() {
    echo "🔏 Testing code signing..."
    
    # Create a test app structure
    mkdir -p test_app/Frameworks/TestFramework.framework
    echo "test" > test_app/Frameworks/TestFramework.framework/TestFramework
    
    # Create test entitlements
    cat > test_entitlements.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>application-identifier</key>
    <string>${TEAM_ID}.io.scelus.dienstplan</string>
    <key>com.apple.developer.team-identifier</key>
    <string>${TEAM_ID}</string>
    <key>keychain-access-groups</key>
    <array>
        <string>${TEAM_ID}.io.scelus.dienstplan</string>
    </array>
</dict>
</plist>
EOF
    
    # Import certificate to temporary keychain
    security create-keychain -p "" test.keychain
    security default-keychain -s test.keychain
    security unlock-keychain -p "" test.keychain
    security import "$CERT_FILE" -k test.keychain -P "$CERT_PASSWORD" -T /usr/bin/codesign
    
    # Get signing identity
    SIGNING_IDENTITY=$(security find-identity -v test.keychain | grep "iPhone Distribution" | head -1 | sed 's/.*"\(.*\)".*/\1/')
    echo "Using signing identity: $SIGNING_IDENTITY"
    
    if [ -z "$SIGNING_IDENTITY" ]; then
        echo "❌ No iPhone Distribution certificate found"
        security delete-keychain test.keychain
        return 1
    fi
    
    # Test signing
    codesign --force --sign "$SIGNING_IDENTITY" --entitlements test_entitlements.plist test_app
    if [ $? -eq 0 ]; then
        echo "✅ Code signing test successful"
    else
        echo "❌ Code signing test failed"
    fi
    
    # Cleanup
    security delete-keychain test.keychain
    rm -rf test_app test_entitlements.plist
}

# Function to check Xcode project configuration
check_xcode_configuration() {
    echo "🔧 Checking Xcode Project Configuration:"
    
    if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
        echo "✅ Xcode project found"
        
        # Check code signing style
        CODE_SIGN_STYLE=$(grep -A 5 -B 5 "CODE_SIGN_STYLE" ios/Runner.xcodeproj/project.pbxproj | grep "CODE_SIGN_STYLE" | head -1 | sed 's/.*= \([^;]*\);.*/\1/')
        echo "   Code signing style: $CODE_SIGN_STYLE"
        
        # Check development team
        DEVELOPMENT_TEAM=$(grep -A 5 -B 5 "DEVELOPMENT_TEAM" ios/Runner.xcodeproj/project.pbxproj | grep "DEVELOPMENT_TEAM" | head -1 | sed 's/.*= \([^;]*\);.*/\1/')
        echo "   Development team: $DEVELOPMENT_TEAM"
        
        # Check entitlements file
        CODE_SIGN_ENTITLEMENTS=$(grep -A 5 -B 5 "CODE_SIGN_ENTITLEMENTS" ios/Runner.xcodeproj/project.pbxproj | grep "CODE_SIGN_ENTITLEMENTS" | head -1 | sed 's/.*= \([^;]*\);.*/\1/')
        echo "   Entitlements file: $CODE_SIGN_ENTITLEMENTS"
        
        if [ "$CODE_SIGN_STYLE" = "Manual" ]; then
            echo "✅ Xcode project is configured for manual signing"
        else
            echo "⚠️  Xcode project is not configured for manual signing"
            echo "   Consider updating to manual signing for better control"
        fi
    else
        echo "❌ Xcode project not found"
    fi
}

# Main script
echo "This script will help you verify your iOS code signing setup."
echo ""

# Get inputs
read -p "Enter your Apple Team ID (e.g., ABC123DEF4): " TEAM_ID
read -p "Enter your certificate password: " CERT_PASSWORD

echo ""
echo "📁 Setting up files..."

# Create temporary directory
mkdir -p temp_verification
cd temp_verification

# Decode certificate
echo "Please provide your distribution certificate (DIS_CERTIFICATE_BASE64):"
decode_base64 "DIS_CERTIFICATE_BASE64" "certificate.p12"
CERT_FILE="certificate.p12"

# Decode provisioning profile
echo "Please provide your provisioning profile (PROVISIONING_PROFILE):"
decode_base64 "PROVISIONING_PROFILE" "profile.mobileprovision"
PROFILE_FILE="profile.mobileprovision"

echo ""
echo "🔍 Starting verification..."

# Verify certificate
verify_certificate "$CERT_FILE"
if [ $? -ne 0 ]; then
    echo "❌ Certificate verification failed"
    exit 1
fi

# Extract certificate hash for comparison
CERT_HASH=$(openssl pkcs12 -in "$CERT_FILE" -nokeys -passin pass:"$CERT_PASSWORD" 2>/dev/null | openssl x509 -noout -fingerprint -sha1 | cut -d= -f2 | tr -d ':')

echo ""

# Verify provisioning profile
verify_provisioning_profile "$PROFILE_FILE"
if [ $? -ne 0 ]; then
    echo "❌ Provisioning profile verification failed"
    exit 1
fi

# Extract profile certificate hash
PROFILE_CERT_HASH=$(security cms -D -i "$PROFILE_FILE" | grep -A 10 "DeveloperCertificates" | grep -o '[A-F0-9]\{40\}' | head -1)

echo ""

# Verify certificate-profile match
verify_certificate_profile_match "$CERT_HASH" "$PROFILE_CERT_HASH"
MATCH_RESULT=$?

echo ""

# Check Xcode configuration
check_xcode_configuration

echo ""

# Test signing
test_signing

echo ""
echo "🧹 Cleaning up..."
cd ..
rm -rf temp_verification

echo ""
echo "✅ Verification complete!"
echo ""

if [ $MATCH_RESULT -eq 0 ]; then
    echo "🎉 Your certificate and provisioning profile are properly matched!"
    echo "   The GitHub Actions workflow should work correctly."
else
    echo "⚠️  Certificate and provisioning profile do not match."
    echo "   You need to:"
    echo "   1. Create a new provisioning profile that includes your current certificate"
    echo "   2. Or use a different certificate that matches your current provisioning profile"
    echo "   3. Update your GitHub secrets with the corrected files"
fi

echo ""
echo "📋 Next Steps:"
echo "   1. If verification passed, your workflow should work"
echo "   2. If verification failed, fix the certificate-profile mismatch"
echo "   3. Consider updating Xcode project to use manual signing for better control" 