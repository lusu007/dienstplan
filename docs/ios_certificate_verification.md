# iOS Certificate and Provisioning Profile Verification

## Current Issue

The app upload is failing because the code signing certificate doesn't match the one in the provisioning profile. This means either:

1. The distribution certificate in your GitHub secrets doesn't match the one in your provisioning profile
2. The provisioning profile was created for a different certificate
3. The certificate has expired or been revoked

## How to Verify Your Setup

### 1. Check Your Distribution Certificate

**From Apple Developer Portal:**
1. Go to [developer.apple.com](https://developer.apple.com)
2. Navigate to "Certificates, Identifiers & Profiles"
3. Click on "Certificates" in the left sidebar
4. Look for your "Apple Distribution" certificate
5. Check if it's valid and not expired

**From Xcode (if available):**
1. Open Xcode
2. Go to Xcode → Preferences → Accounts
3. Select your Apple ID
4. Click "Manage Certificates"
5. Look for "Apple Distribution" certificate

### 2. Check Your Provisioning Profile

**From Apple Developer Portal:**
1. Go to "Certificates, Identifiers & Profiles"
2. Click on "Profiles" in the left sidebar
3. Find your App Store distribution profile for `io.scelus.dienstplan`
4. Check which certificate it's associated with
5. Verify the App ID matches your bundle identifier

### 3. Verify Certificate and Profile Match

The certificate used to sign the app must be the same one that's embedded in the provisioning profile. You can verify this by:

1. **Downloading your current provisioning profile** from Apple Developer Portal
2. **Opening it in a text editor** and looking for the `DeveloperCertificates` section
3. **Comparing the certificate hash** with your distribution certificate

### 4. Common Issues and Solutions

#### Issue: Certificate Mismatch
**Solution:** Regenerate your provisioning profile to include the correct certificate

#### Issue: Expired Certificate
**Solution:** Create a new distribution certificate and update your GitHub secrets

#### Issue: Wrong Certificate Type
**Solution:** Make sure you're using "Apple Distribution" certificate, not "Apple Development"

## Updating Your GitHub Secrets

If you need to update your certificate or provisioning profile:

### 1. Export New Distribution Certificate
```bash
# From Xcode or Keychain Access
# Export as .p12 file with a password
```

### 2. Convert to Base64
```bash
base64 -i your_certificate.p12 | pbcopy
```

### 3. Update GitHub Secrets
- `DIS_CERTIFICATE_BASE64`: The base64-encoded certificate
- `DIS_CERTIFICATE_PASSWORD`: The password for the .p12 file
- `PROVISIONING_PROFILE`: The base64-encoded provisioning profile

### 4. Regenerate Provisioning Profile
1. Go to Apple Developer Portal
2. Create a new App Store distribution profile
3. Select the correct certificate
4. Download and convert to base64

## Testing Locally (Optional)

If you have access to a Mac, you can test the signing process locally:

```bash
# Install certificate and profile
security import certificate.p12 -k login.keychain -P password
cp profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/

# Test signing
codesign --force --sign "iPhone Distribution" --entitlements entitlements.plist app.app
```

## Next Steps

1. Verify your certificate and provisioning profile match
2. Update GitHub secrets if necessary
3. Re-run the workflow
4. Check the workflow logs for the new debugging information

The updated workflow will now show:
- The exact signing identity being used
- Provisioning profile details
- Certificate verification information 