# Publishing Prep & Automation

This document describes what’s needed to publish the Android and iOS apps and how to use the included GitHub workflows.

## Android (fastest win)

### What the workflow does
- Builds a release AAB: `flutter build appbundle --release`
- If `ANDROID_KEYSTORE` secret is set (base64-encoded keystore), the workflow writes `android/keystore.jks` and `android/key.properties` and signs the build.
- If `GOOGLE_PLAY_SERVICE_ACCOUNT` secret is set (service account JSON content), the workflow uploads the AAB to the *internal* track of Google Play.

### Required repository secrets
- `ANDROID_KEYSTORE` — base64-encoded keystore (.jks). Example: `base64 keystore.jks | pbcopy` and paste the result.
- `ANDROID_KEYSTORE_PASSWORD` — keystore store password.
- `ANDROID_KEY_ALIAS` — alias name used when creating the keystore.
- `ANDROID_KEY_PASSWORD` — key password for the alias.
- `GOOGLE_PLAY_SERVICE_ACCOUNT` — JSON content of a Google Play service account that has the `Release Manager` role.

### Notes
- The build reads `android/key.properties` (created by the workflow) to find the keystore information. If you have a different signing setup, update `android/app/build.gradle.kts` accordingly.
- The workflow triggers on tags matching `v*.*.*` or can be started manually (`workflow_dispatch`).

---

## iOS (needs macOS runner & Apple credentials)

### What to provide
- An App Store Connect API key (private .p8 + issuer ID + key ID). These must be stored as repository secrets.
- A macOS runner is required to build and sign; GitHub Actions provides `macos-latest` runner support.

### Recommended flow
- Use Fastlane or `altool` with the App Store Connect API key for uploads.
- Keep certificates and provisioning profiles in a secure system (Fastlane match or GitHub Secrets) and provide instructions for adding them to the repo.

### Fastlane skeleton
A Fastlane skeleton is included to automate building and uploading to TestFlight. Files added:

- `fastlane/Fastfile` — lane `beta` builds the IPA and uploads to TestFlight using the App Store Connect API key.
- `fastlane/Appfile` — placeholder for `app_identifier` and `apple_id`.
- `Gemfile` — includes `fastlane` to be installed by Bundler.
- `.github/workflows/ios_release.yml` — macOS workflow to build and invoke the `beta` lane.

Required repository secrets for TestFlight uploads:
- `APP_STORE_CONNECT_API_KEY` — base64-encoded contents of the App Store Connect API key (.p8). Example: `base64 AuthKey_XXXXX.p8 | pbcopy`.
- `APP_STORE_CONNECT_KEY_ID` — the API key ID (e.g., `ABC123DEFG`).
- `APP_STORE_CONNECT_ISSUER_ID` — the issuer (your Team ID) from App Store Connect.
- `APP_IDENTIFIER` — (optional) the app bundle identifier; defaults to the value in `fastlane/Appfile`.

Notes:
- This workflow uses a macOS runner and requires an Apple developer account. Fastlane will use the provided API key to upload to TestFlight. If you prefer automatic provisioning management, consider adding Fastlane Match and storing the certs/profiles as secrets.
- I can extend the lane to run code signing via match or to automatically increment build numbers when a tag is pushed. Want me to add that next?

---

## Checklist before first publish
- [ ] Set repository secrets (Android keystore + Google Play service account). See above.
- [ ] Create Play Console listing (app name, short/long description, screenshots, privacy policy URL).
- [ ] Update `applicationId` in `android/app/build.gradle.kts` to your chosen package (e.g., `com.yourcompany.preppro`).
- [ ] Bump app version (`versionName` / `versionCode`) in `pubspec.yaml` and `android` project as needed.
- [ ] Prepare app icons and screenshots for all required sizes.

---

If you'd like, I can:
- Add an iOS workflow skeleton (macOS + Fastlane) and sample `Fastfile` entries, or
- Add a step that automatically bumps versions when tagging releases.

Tell me which of those you'd like next and I’ll add it. 🔧