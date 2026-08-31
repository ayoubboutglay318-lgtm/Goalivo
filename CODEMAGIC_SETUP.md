# Codemagic Setup Guide for App Store Release

## Overview
This guide explains how to configure Codemagic for automated iOS builds and App Store submission.

## Prerequisites

1. **Codemagic Account**
   - Sign up at https://codemagic.io
   - Connect your GitHub repository

2. **Apple Developer Account**
   - Active Apple Developer Program membership
   - App Store Connect access
   - Created App ID for "Goalivo" (Bundle: `com.goalivo.app`)

3. **App Store Connect API Key**
   - Go to App Store Connect → Users and Access → Keys (Integrations)
   - Create a new API Key with "App Manager" access
   - Save the Key ID, Issuer ID, and private key (.p8 file)

## Configuration Steps

### Step 1: Upload API Key to Codemagic

1. Go to **Codemagic Dashboard**
2. Click **Settings** (top right)
3. Select **Teams** → Your Team → **Integrations**
4. Find **App Store Connect** → Click **Connect**
5. Paste your API Key details:
   - **Key ID**: From App Store Connect
   - **Issuer ID**: From App Store Connect  
   - **Private Key**: Contents of the .p8 file

### Step 2: Create Environment Variables in Codemagic

1. Go to your project settings
2. Click **Environment Variables**
3. Create a new group called `ios_credentials` with:

```
APPSTORE_KEY_ID=<Your Key ID>
APPSTORE_ISSUER_ID=<Your Issuer ID>
APPSTORE_PRIVATE_KEY=<Full contents of .p8 file>
```

### Step 3: Connect Repository to Codemagic

1. In Codemagic, click **Add Application**
2. Select **GitHub** and authenticate
3. Select the **Goalivo** repository
4. Choose **iOS App Store Release** workflow
5. Click **Start/Build**

### Step 4: First Build

1. Codemagic will:
   - Pull your code from GitHub
   - Run `flutter pub get`
   - Build the iOS app for release
   - Generate the IPA file
   - Auto-sign with your Apple certificate
   - Submit to TestFlight

2. Check build progress in the Codemagic dashboard

### Step 5: TestFlight and App Store

**First Time:**
1. Build will auto-submit to TestFlight
2. Accept the app in TestFlight (check your Apple ID email)
3. Test on device through TestFlight

**Release to App Store:**
1. In Codemagic workflow, change `submit_to_testflight` to false
2. Set `submit_to_app_store` to true
3. Trigger a new build
4. App will be submitted for Apple review

## codemagic.yaml Workflow

The `codemagic.yaml` in this repo contains:

```yaml
ios-release:
  name: iOS App Store Release
  environment:
    flutter: stable
    xcode: latest
  scripts:
    - Set up keychain
    - Fetch signing certificates
    - Get Flutter packages
    - Build iOS app
    - Package IPA
  publishing:
    app_store_connect:
      submit_to_testflight: true
```

## Troubleshooting

### Build Fails: "Certificate not found"
- Verify API Key is correctly set in Codemagic
- Ensure Bundle ID matches App Store Connect (`com.goalivo.app`)
- Check App Store Connect → Certificates, IDs & Profiles → Identifiers

### Build Fails: "Provisioning profile issue"
- Go to App Store Connect → Certificates, IDs & Profiles
- Regenerate provisioning profiles
- Delete and recreate if necessary

### TestFlight Build Not Appearing
- Wait 10-15 minutes after successful build
- Check email for TestFlight build notifications
- Verify app version numbers don't conflict with previous builds

### Can't Access TestFlight
- Add testers in App Store Connect → TestFlight → Testers
- Send TestFlight link to testers
- Testers must install TestFlight app from App Store first

## Manual Upload (Alternative)

If automated submission fails, you can manually upload:

1. Download IPA from Codemagic build artifacts
2. Open Transporter app (Mac App Store)
3. Sign in with your Apple ID
4. Drag & drop IPA file
5. Click "Deliver"

## Useful Links

- **Codemagic Documentation**: https://docs.codemagic.io
- **App Store Connect**: https://appstoreconnect.apple.com
- **Apple Developer**: https://developer.apple.com
- **TestFlight**: https://testflight.apple.com

## Security Notes

⚠️ **Important:**
- Never commit `.p8` files or API keys to Git
- Store sensitive data in Codemagic environment variables only
- Rotate API keys periodically
- Use unique app-specific passwords if needed

## Next Steps

1. ✅ Set up Apple Developer Account and App Store Connect
2. ✅ Generate App Store Connect API Key
3. ✅ Create Codemagic account and link GitHub
4. ✅ Configure environment variables in Codemagic
5. ✅ Trigger first build
6. ✅ Test on TestFlight
7. ✅ Submit to App Store for review

Good luck! 🚀
