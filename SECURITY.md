# Security Policy

## Reporting Security Issues

If you discover a security vulnerability, please email us at security@kivo.global instead of using the issue tracker.

Please include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

## Sensitive Data Protection

### Never Commit

The following should NEVER be committed to version control:

- ❌ `android/key.properties` (keystore passwords)
- ❌ `*.jks` files (signing keys)
- ❌ Service account JSON keys
- ❌ `.env` files with secrets
- ❌ API tokens or credentials
- ❌ Private keys

### Use Environment Variables

In CI/CD systems like Codemagic:

```bash
# Store sensitive data as environment variables in Codemagic
# Never in code or config files
PLAYSTORE_SERVICE_ACCOUNT_KEY="..."
DEVELOPER_EMAIL="..."
```

### .gitignore

Ensure your `.gitignore` includes:

```
# Signing keys
*.jks
*.keystore
key.properties

# Service accounts
*-service-account.json
alert-basis-*.json

# Environment files
.env
.env.local
```

## Code Security

### Dependencies

- Keep dependencies updated: `flutter pub upgrade`
- Check for vulnerabilities: `flutter pub outdated`
- Review dependency changes in pull requests

### API Security

- Use HTTPS only
- Validate SSL certificates
- Never hardcode API keys
- Use environment variables or secure storage
- Implement rate limiting
- Add request signing/HMAC

### Data Protection

- Hash passwords (never store plaintext)
- Encrypt sensitive data in transit
- Use secure storage for local data
- Implement proper authentication
- Add CSRF protection
- Sanitize user inputs

## Testing

- Run security linting: `flutter analyze`
- Use ProGuard/R8 minification for releases
- Enable code obfuscation
- Test on actual devices
- Use Firebase/Sentry for crash monitoring

## Deployment Security

- ✅ Sign all production builds with your keystore
- ✅ Use internal testing track first
- ✅ Monitor crash reports in Play Console
- ✅ Implement feature flags for gradual rollout
- ✅ Have a rollback plan
- ✅ Keep deployment credentials secure in Codemagic
- ✅ Never expose keystore passwords in logs
- ✅ Use Codemagic secure variables for secrets

## Third-Party Services

- **Google Cloud Platform (GCP)** - Backend infrastructure
- **Google Play Store** - App distribution
- **Codemagic** - CI/CD automation

Always review privacy policies and security practices of third-party services.

## Key Rotation

Rotate credentials regularly:

1. **Service Account Key**: Every 90 days
   - Delete old key in Google Cloud Console
   - Create new key
   - Update in Codemagic

2. **Keystore Password**: When team changes
   - Create new keystore
   - Update in Codemagic

3. **Google Play API Key**: If compromised
   - Delete immediately
   - Create new service account
   - Update everywhere

## Questions?

For security-related questions, contact: security@kivo.global
