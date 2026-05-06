# Codemagic Setup Guide for KiVo Global

This guide walks you through setting up automated builds and Play Store deployments with Codemagic.

## Prerequisites

1. Codemagic account (free tier available)
2. GitHub repository with Flutter app
3. Google Play Developer account
4. Android keystore file (.jks)
5. Google Play service account JSON key

## Step 1: Connect GitHub Repository

1. Go to [Codemagic](https://codemagic.io/)
2. Click "Add Application"
3. Select GitHub and authorize
4. Select the `kivo-core` repository
5. Choose Flutter as the project type

## Step 2: Add Android Signing Key

1. In Codemagic, go to **Settings > Android Signing**
2. Click **Add keystore**
3. Upload your `key.jks` file
4. Enter keystore password
5. Select key alias: `upload`
6. Enter key password
7. Name it: `kivo_key`
8. Save

## Step 3: Create Environment Variable Groups

Create a group called `playstore_credentials`:

### Variables to add:

#### `PLAYSTORE_SERVICE_ACCOUNT_KEY`
- **Value**: Paste the entire contents of your service account JSON key
- **Type**: Secure environment variable (check the lock icon)
- **Example**:
  ```json
  {
    "type": "service_account",
    "project_id": "your-project-id",
    ...
  }
  ```

#### `DEVELOPER_EMAIL`
- **Value**: Your email address
- **Type**: Regular variable

## Step 4: Configure the Workflow

1. The `codemagic-playstore.yaml` file is already configured
2. Push it to your repository:
   ```bash
   git add codemagic-playstore.yaml
   git commit -m "Add Codemagic Play Store workflow"
   git push origin main
   ```
3. Codemagic should automatically detect the workflow

## Step 5: Test the Internal Testing Track

1. In Codemagic, find the "KiVo Global - Play Store Internal Test" workflow
2. Trigger it manually or push to `develop` branch
3. Monitor the build logs
4. If successful, the app will be uploaded to Google Play's internal testing track

## Step 6: Set Up Production Releases

1. Create a Git tag for your release:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
2. Codemagic will automatically:
   - Build the app
   - Run tests
   - Sign it with your keystore
   - Upload to Play Store production track

## Workflow Configuration

### Internal Testing Workflow
- **Trigger**: Push to `develop` branch
- **Upload Track**: `internal`
- **Use case**: Test builds before release

### Production Workflow
- **Trigger**: Git tag matching `v*.*.* ` (e.g., v1.0.0)
- **Upload Track**: `production`
- **Use case**: Official releases

## Troubleshooting

### "Invalid service account key"
- Verify the JSON is complete and valid
- Check that the service account has Play Publisher permissions
- Ensure it's pasted as a secure variable

### "Build failed: Keystore not found"
- Check that you've uploaded the keystore in Android Signing settings
- Verify the keystore file is valid
- Ensure the password is correct

### "Version code too low"
- Increment the version code in `pubspec.yaml`
- Each build must have a higher version code
- Example: change `1.0.0+1` to `1.0.0+2`

### "Bundle signing failed"
- Verify the keystore alias is correct (`upload`)
- Check the key password
- Ensure the keystore file is not corrupted

## Manual Build Steps (for local testing)

### Build APK locally:
```bash
# Create key.properties file
cp android/key.properties.example android/key.properties
# Edit with your actual passwords

# Build
flutter build apk --release
```

### Build App Bundle locally:
```bash
flutter build appbundle --release
```

## Security Best Practices

✅ **Do:**
- Store keystore passwords in Codemagic as secure variables
- Use strong passwords (16+ characters)
- Enable 2FA on Google Play account
- Rotate service account keys periodically
- Review build logs for sensitive data leaks
- Use internal testing before production releases

❌ **Don't:**
- Commit `key.jks` or `key.properties` to Git
- Share keystore passwords via email/chat
- Hardcode credentials in code
- Use the same password for multiple services
- Commit service account keys to version control

## Version Management

Update `pubspec.yaml` before each release:

```yaml
version: 1.0.0+1
#         │   │
#         │   └─ Build number (increment every build)
#         └───── Semantic version (public version)
```

### Version Numbering Examples:
- **v1.0.0**: Initial release
- **v1.0.1**: Bug fix
- **v1.1.0**: New feature
- **v2.0.0**: Major update

## Creating a Release

1. Update version in `pubspec.yaml`
2. Commit changes:
   ```bash
   git add pubspec.yaml
   git commit -m "Bump version to 1.0.0"
   ```
3. Create and push tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
4. Codemagic automatically builds and publishes

## Monitoring Builds

1. In Codemagic dashboard, click on a build to see:
   - Build logs
   - Artifacts
   - Test results
   - Code analysis

2. Subscribe to email notifications:
   - On build start
   - On build completion
   - On build failure

## References

- [Codemagic Documentation](https://docs.codemagic.io/)
- [Flutter Build for Android](https://flutter.dev/docs/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay)
- [Google Play API Documentation](https://developers.google.com/android-publisher)
