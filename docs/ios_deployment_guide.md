# iOS Deployment Guide for Dienstplan

This guide covers the complete setup for iOS app deployment using GitHub Actions and Codemagic CLI.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup Steps](#setup-steps)
3. [GitHub Secrets Configuration](#github-secrets-configuration)
4. [iOS Flavor Configuration](#ios-flavor-configuration)
5. [Code Signing Setup](#code-signing-setup)
6. [App Store Connect Setup](#app-store-connect-setup)
7. [GitHub Actions Workflow](#github-actions-workflow)
8. [Testing the Setup](#testing-the-setup)
9. [Troubleshooting](#troubleshooting)

## Prerequisites

Before setting up iOS deployment, ensure you have:

- [ ] Apple Developer Account ($99/year)
- [ ] Xcode installed on a Mac
- [ ] Flutter SDK installed
- [ ] GitHub repository with admin access
- [ ] App Store Connect access

## Setup Steps

### 1. iOS Flavor Configuration

The project uses flavors to distinguish between development and production builds. Run the setup script:

```bash
./scripts/setup_ios_flavors.sh
```

This script will:
- Create flavor-specific directories and configurations
- Set up Xcode schemes for dev and prod flavors
- Create build scripts for easy flavor management

### 2. Xcode Project Configuration

After running the setup script, open the project in Xcode:

```bash
open ios/Runner.xcworkspace
```

In Xcode, you need to:

1. **Configure Build Configurations**:
   - Go to Project Settings → Info
   - Add new configurations: `Debug-dev`, `Release-dev`, `Debug-prod`, `Release-prod`
   - Set the appropriate xcconfig files for each configuration

2. **Set up Code Signing**:
   - Select the Runner target
   - Go to Signing & Capabilities
   - Configure signing for each build configuration
   - Set up provisioning profiles for each flavor

3. **Configure Bundle Identifiers**:
   - Dev: `io.scelus.dienstplan.dev`
   - Prod: `io.scelus.dienstplan`

## GitHub Secrets Configuration

The following secrets need to be configured in your GitHub repository:

### Required Secrets

| Secret Name | Description | Format |
|-------------|-------------|---------|
| `APP_STORE_CONNECT_PRIVATE_KEY` | App Store Connect API private key | Base64 encoded .p8 file |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect issuer ID | String (UUID) |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | App Store Connect key identifier | String |
| `APP_STORE_APP_ID` | App Store Connect app ID | String |
| `DISTRIBUTION_CERTIFICATE` | iOS distribution certificate | Base64 encoded .p12 file |
| `DISTRIBUTION_CERTIFICATE_PASSWORD` | Distribution certificate password | String |
| `PROVISIONING_PROFILE` | iOS provisioning profile | Base64 encoded .mobileprovision file |

### How to Get These Values

#### App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to Users and Access → Keys
3. Click the "+" button to create a new key
4. Give it a name and select "App Manager" role
5. Download the .p8 file
6. Convert to base64: `base64 -i AuthKey_XXXXXXXXXX.p8`

#### Distribution Certificate

1. Open Xcode → Preferences → Accounts
2. Select your Apple ID → Manage Certificates
3. Create a new iOS Distribution certificate
4. Export the certificate as .p12 file
5. Convert to base64: `base64 -i distribution_cert.p12`

#### Provisioning Profile

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Navigate to Certificates, Identifiers & Profiles
3. Create a new App Store provisioning profile
4. Download the .mobileprovision file
5. Convert to base64: `base64 -i profile.mobileprovision`

## Code Signing Setup

### Manual Setup (if not using the script)

1. **Create Entitlements File**:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>com.apple.developer.team-identifier</key>
       <string>$(DEVELOPMENT_TEAM)</string>
       <key>keychain-access-groups</key>
       <array>
           <string>$(AppIdentifierPrefix)io.scelus.dienstplan</string>
       </array>
   </dict>
   </plist>
   ```

2. **Configure Xcode Project**:
   - Add the entitlements file to your target
   - Set up code signing identity for each configuration
   - Configure provisioning profiles

## App Store Connect Setup

1. **Create App Record**:
   - Go to App Store Connect
   - Click "+" to create a new app
   - Fill in the app information
   - Note the App ID for the GitHub secret

2. **Configure App Information**:
   - Set up app metadata
   - Configure pricing and availability
   - Set up app review information

## GitHub Actions Workflow

The workflow file `.github/workflows/ios-release.yml` is already configured and includes:

- Flutter setup and dependency installation
- Codemagic CLI installation
- iOS code signing setup
- App building and signing
- IPA creation
- App Store Connect deployment

### Workflow Triggers

The workflow is triggered when:
- A new release is published on GitHub
- The release tag matches the version in `pubspec.yaml`

### Workflow Steps

1. **Setup**: Install Flutter and dependencies
2. **Code Signing**: Set up certificates and provisioning profiles
3. **Build**: Build the iOS app with the prod flavor
4. **Sign**: Code sign the app bundle
5. **Package**: Create IPA file
6. **Upload**: Upload to GitHub release
7. **Deploy**: Deploy to App Store Connect

## Testing the Setup

### Local Testing

1. **Test Dev Flavor**:
   ```bash
   flutter run --flavor dev
   ```

2. **Test Prod Flavor**:
   ```bash
   flutter run --flavor prod
   ```

3. **Build for Release**:
   ```bash
   flutter build ios --flavor prod --release
   ```

### GitHub Actions Testing

1. Create a test release on GitHub
2. Monitor the workflow execution
3. Check the generated artifacts
4. Verify App Store Connect upload

## Troubleshooting

### Common Issues

#### 1. Code Signing Errors

**Error**: `Code signing is required for product type 'Application' in SDK 'iOS'`

**Solution**: Ensure all secrets are properly configured and the certificates are valid.

#### 2. Provisioning Profile Issues

**Error**: `No provisioning profile found`

**Solution**: Check that the provisioning profile matches the bundle identifier and is properly encoded.

#### 3. App Store Connect API Errors

**Error**: `Invalid API key`

**Solution**: Verify the API key, issuer ID, and key identifier are correct.

#### 4. Flavor Configuration Issues

**Error**: `Could not find flavor configuration`

**Solution**: Run the setup script and ensure Xcode configurations are properly set up.

### Debug Steps

1. **Check Secrets**: Verify all GitHub secrets are set correctly
2. **Validate Certificates**: Ensure certificates haven't expired
3. **Check Bundle IDs**: Verify bundle identifiers match across all configurations
4. **Review Logs**: Check GitHub Actions logs for detailed error messages

### Getting Help

If you encounter issues:

1. Check the [GitHub Actions logs](https://github.com/lusu007/dienstplan/actions)
2. Review the [Codemagic CLI documentation](https://docs.codemagic.io/cli/)
3. Consult the [Apple Developer documentation](https://developer.apple.com/documentation/)
4. Open an issue in the repository

## Security Considerations

- Never commit certificates or private keys to the repository
- Use GitHub secrets for all sensitive information
- Regularly rotate API keys and certificates
- Monitor GitHub Actions usage and costs

## Maintenance

### Regular Tasks

1. **Certificate Renewal**: iOS certificates expire annually
2. **Provisioning Profile Updates**: Update when adding new devices
3. **API Key Rotation**: Rotate App Store Connect API keys periodically
4. **Flutter Updates**: Keep Flutter SDK and dependencies updated

### Monitoring

- Monitor GitHub Actions execution times and costs
- Track App Store Connect API usage
- Review deployment success rates
- Monitor app review times and feedback

---

For additional support or questions, please refer to the project documentation or open an issue in the repository. 