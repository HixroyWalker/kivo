# KiVo Global

High-Efficiency Fintech for Santa Cruz.

## Deployment Instructions

1. Upload the individual files/folders (`lib/`, `backend/`, `android/`, `codemagic.yaml`, etc.) to your GitHub repository `kivo-core`.
2. Do **NOT** upload any `.zip` file to GitHub.
3. Go to [Codemagic.io](https://codemagic.io) and click **Start Build**.
4. For Google Cloud deployment, use `cloudbuild.yaml` with Google Cloud Build.

## Project Structure

```
KiVo_Final/
├── lib/
│   ├── main.dart                  # Flutter app entry point
│   └── services/
│       ├── shipping_config.dart   # Shipping tier configuration
│       └── shipping_service.dart  # Shipping fee calculator
├── backend/
│   ├── Dockerfile                 # Cloud Run container build
│   └── storage_rules.json        # GCS lifecycle rules (archive after 30d)
├── android/
│   ├── app/
│   │   ├── build.gradle          # App build config + signing
│   │   ├── proguard-rules.pro    # R8 obfuscation rules
│   │   └── src/main/
│   │       └── AndroidManifest.xml
│   ├── build.gradle              # Project-level Gradle
│   ├── gradle.properties
│   ├── key.properties.example    # Keystore config template
│   └── settings.gradle
├── scripts/
│   ├── archive_sync.py           # GCS archive lifecycle sync
│   ├── gov_verify.js             # TRN / government verification
│   └── image_optimizer.sh        # WebP conversion for assets
├── pubspec.yaml                  # Flutter dependencies
├── codemagic.yaml                # Codemagic CI/CD (Cloud Run deploy)
├── codemagic-playstore.yaml      # Codemagic CI/CD (Play Store)
├── cloudbuild.yaml               # Google Cloud Build config
├── CODEMAGIC_SETUP.md            # Step-by-step Codemagic guide
└── SECURITY.md                   # Security policies
```

## Quick Start

```bash
flutter pub get
flutter run
```

## Version

v3.3 – Full consolidated build.
