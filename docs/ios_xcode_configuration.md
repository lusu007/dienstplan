# iOS Xcode Configuration for Flutter Built-in Signing

## Overview

This guide explains how to configure your Xcode project to work optimally with Flutter's built-in signing while using manual certificates and provisioning profiles in your GitHub Actions workflow.

## Current Configuration

Your Xcode project is currently configured with:
- `CODE_SIGN_STYLE = Automatic` (for both Debug and Release)
- `CODE_SIGN_IDENTITY[sdk=iphoneos*] = "iPhone Developer"`

## Recommended Configuration

For better control and compatibility with your GitHub Actions workflow, we recommend switching to manual signing.

## Option 1: Keep Automatic Signing (Recommended for CI/CD)

If you want to keep automatic signing (which works well with Flutter's built-in signing), ensure your Xcode project has these settings:

### Debug Configuration
```
CODE_SIGN_STYLE = Automatic
DEVELOPMENT_TEAM = [Your Team ID]
CODE_SIGN_IDENTITY = "Apple Development"
```

### Release Configuration
```
CODE_SIGN_STYLE = Automatic
DEVELOPMENT_TEAM = [Your Team ID]
CODE_SIGN_IDENTITY = "Apple Distribution"
CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements
```

## Option 2: Switch to Manual Signing

If you prefer manual signing for more control:

### Debug Configuration
```
CODE_SIGN_STYLE = Manual
DEVELOPMENT_TEAM = [Your Team ID]
CODE_SIGN_IDENTITY = "iPhone Developer"
PROVISIONING_PROFILE_SPECIFIER = [Your Development Profile Name]
CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements
```

### Release Configuration
```
CODE_SIGN_STYLE = Manual
DEVELOPMENT_TEAM = [Your Team ID]
CODE_SIGN_IDENTITY = "iPhone Distribution"
PROVISIONING_PROFILE_SPECIFIER = [Your Distribution Profile Name]
CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements
```

## How to Update Your Xcode Project

### Method 1: Using Xcode (Recommended)

1. Open your project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Select the "Runner" project in the navigator

3. Select the "Runner" target

4. Go to the "Signing & Capabilities" tab

5. For each configuration (Debug/Release):
   - Choose "Manual" or "Automatic" signing
   - Set your Team ID
   - Select the appropriate provisioning profile
   - Ensure entitlements file is selected

### Method 2: Manual Project File Editing

You can manually edit `ios/Runner.xcodeproj/project.pbxproj`, but this is error-prone and not recommended.

## Flutter Build Configuration

With the updated workflow, Flutter will handle signing automatically when you run:

```bash
flutter build ios --release --build-number=12
```

The workflow will:
1. Set up certificates and provisioning profiles
2. Let Flutter handle the signing process
3. Verify the signing was done correctly
4. Create the IPA file

## Verification Steps

### 1. Local Testing

Test your configuration locally:

```bash
# Clean previous builds
flutter clean

# Build with signing
flutter build ios --release

# Verify the built app
codesign -dv --verbose=4 build/ios/iphoneos/Runner.app
```

### 2. Using the Verification Script

Run the verification script to check your setup:

```bash
chmod +x scripts/verify_ios_signing.sh
./scripts/verify_ios_signing.sh
```

### 3. GitHub Actions Testing

The updated workflow includes comprehensive verification:
- Certificate hash extraction and comparison
- Provisioning profile verification
- Built app signing verification
- Framework signing verification

## Troubleshooting

### Issue: "No provisioning profiles found"

**Solution**: Ensure your provisioning profile is properly installed and matches your bundle identifier.

### Issue: "Code signing is required for product type"

**Solution**: Make sure `CODE_SIGN_STYLE` is set to either `Automatic` or `Manual` (not `None`).

### Issue: "Entitlements file not found"

**Solution**: Ensure `CODE_SIGN_ENTITLEMENTS` points to the correct entitlements file path.

### Issue: "Certificate not found"

**Solution**: Verify that the certificate is properly installed in the keychain and matches the provisioning profile.

## Best Practices

1. **Use Automatic Signing for CI/CD**: This works well with Flutter's built-in signing and reduces configuration complexity.

2. **Keep Entitlements File**: Always include your entitlements file for proper app capabilities.

3. **Verify Before Deploying**: Use the verification script to catch issues early.

4. **Regular Certificate Rotation**: Keep your certificates up to date and rotate them before expiration.

5. **Test Locally First**: Always test your signing configuration locally before pushing to CI/CD.

## Migration Checklist

- [ ] Update Xcode project signing configuration
- [ ] Test local build with signing
- [ ] Run verification script
- [ ] Update GitHub Actions workflow (already done)
- [ ] Test GitHub Actions build
- [ ] Verify App Store Connect upload

## Support

If you encounter issues:
1. Check the GitHub Actions logs for detailed error messages
2. Run the verification script locally
3. Verify your certificates and provisioning profiles in Apple Developer Portal
4. Ensure your GitHub secrets are correctly set 