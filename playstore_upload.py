#!/usr/bin/env python3
"""KiVo - Upload AAB to Google Play Store.
Called by codemagic-playstore.yaml CI workflow.

Required env vars:
  PLAYSTORE_SERVICE_ACCOUNT_KEY  - JSON key (Codemagic secure var)
  PACKAGE_NAME                   - e.g. com.kivo.global
  RELEASE_TRACK                  - internal | production
  AAB_PATH                       - path to the .aab file
"""

import json
import os
import sys

try:
    from google.oauth2 import service_account
    from googleapiclient.discovery import build
    from googleapiclient.http import MediaFileUpload
except ImportError:
    print("Error: Install deps: pip3 install google-auth-oauthlib google-auth-httplib2 google-api-python-client")
    sys.exit(1)

KEY_FILE = "/tmp/playstore_key.json"
PACKAGE_NAME = os.environ["PACKAGE_NAME"]
RELEASE_TRACK = os.getenv("RELEASE_TRACK", "internal")
AAB_PATH = os.getenv("AAB_PATH", "build/app/outputs/bundle/release/app-release.aab")


def main():
    credentials = service_account.Credentials.from_service_account_file(
        KEY_FILE,
        scopes=["https://www.googleapis.com/auth/androidpublisher"],
    )
    service = build("androidpublisher", "v3", credentials=credentials)

    print(f"Uploading {AAB_PATH} to '{RELEASE_TRACK}' track for {PACKAGE_NAME}...")

    # Create edit
    edit_id = service.edits().insert(body={}, packageName=PACKAGE_NAME).execute()["id"]
    print(f"Edit created: {edit_id}")

    # Upload bundle
    media = MediaFileUpload(AAB_PATH, mimetype="application/octet-stream")
    version_code = service.edits().bundles().upload(
        editId=edit_id,
        packageName=PACKAGE_NAME,
        media_body=media,
    ).execute()["versionCode"]
    print(f"Bundle uploaded, version code: {version_code}")

    # Assign to track
    service.edits().tracks().update(
        editId=edit_id,
        track=RELEASE_TRACK,
        packageName=PACKAGE_NAME,
        body={
            "releases": [{
                "versionCodes": [version_code],
                "status": "completed",
                "releaseNotes": [{"language": "en-US", "text": "Automated release via Codemagic"}],
            }]
        },
    ).execute()
    print(f"Assigned to '{RELEASE_TRACK}' track")

    # Commit
    service.edits().commit(editId=edit_id, packageName=PACKAGE_NAME).execute()
    print(f"Successfully published to '{RELEASE_TRACK}' track!")


if __name__ == "__main__":
    main()
