# iOS Deployment Guide for Dienstplan

This guide covers the setup for iOS app deployment using GitHub Actions and Codemagic CLI, **without flavors**.

## Prerequisites

- Apple Developer Account ($99/year)
- Xcode installed on a Mac (only needed for initial certificate/provisioning profile export)
- Flutter SDK installed
- GitHub repository with admin access
- App Store Connect access

## Setup Steps

### 1. Xcode Project Configuration

No special configuration is needed for flavors. The default Runner target is used for all builds.

### 2. Certificates and Provisioning Profile

Follow the instructions to export your distribution certificate (.p12) and provisioning profile (.mobileprovision) as before. Add them as GitHub secrets.

## GitHub Secrets Configuration

The following secrets need to be configured in your GitHub repository:

| Secret Name | Description | Format |
|-------------|-------------|---------|
| `APP_STORE_CONNECT_PRIVATE_KEY` | App Store Connect API private key | Base64 encoded .p8 file |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect issuer ID | String (UUID) |
| `APPSTORE_CONNECT_KEY_IDENTIFIER` | App Store Connect key identifier | String |
| `APP_STORE_APP_ID` | App Store Connect app ID | String |
| `DIS_CERTIFICATE_BASE64` | iOS distribution certificate | Base64 encoded .p12 file |
| `DIS_CERTIFICATE_PASSWORD` | Distribution certificate password | String |
| `PROVISIONING_PROFILE` | iOS provisioning profile | Base64 encoded .mobileprovision file |

## Code Signing Setup

1. **Create Entitlements File** (if needed for push, keychain, etc.)
2. **Configure Xcode Project** (only for initial certificate export, not for flavors)

## App Store Connect Setup

1. **Create App Record** in App Store Connect
2. **Configure App Information**

## GitHub Actions Workflow

The workflow file `.github/workflows/ios-release.yml` is already configured and includes:

- Flutter setup and dependency installation
- Codemagic CLI installation
- iOS code signing setup
- App building and signing (no flavors)
- IPA creation
- App Store Connect deployment

### Workflow Triggers

The workflow is triggered when:
- A new release is published on GitHub
- The release tag matches the version in `pubspec.yaml`

### Workflow Steps

1. **Setup**: Install Flutter and dependencies
2. **Code Signing**: Set up certificates and provisioning profiles
3. **Build**: Build the iOS app (no flavor)
4. **Sign**: Code sign the app bundle
5. **Package**: Create IPA file
6. **Upload**: Upload to GitHub release
7. **Deploy**: Deploy to App Store Connect

## Testing the Setup

### Local Testing

```bash
flutter run
flutter build ios --release
```

### GitHub Actions Testing

1. Create a test release on GitHub
2. Monitor the workflow execution
3. Check the generated artifacts
4. Verify App Store Connect upload

## Troubleshooting

- Ensure all GitHub secrets are set correctly
- Certificates and provisioning profiles must match your bundle identifier
- Review GitHub Actions logs for detailed error messages

## Security Considerations

- Never commit certificates or private keys to the repository
- Use GitHub secrets for all sensitive information
- Regularly rotate API keys and certificates
- Monitor GitHub Actions usage and costs

## Maintenance

- Renew iOS certificates annually
- Update provisioning profiles as needed
- Rotate App Store Connect API keys periodically
- Keep Flutter SDK and dependencies updated

---

For additional support or questions, please refer to the project documentation or open an issue in the repository. 