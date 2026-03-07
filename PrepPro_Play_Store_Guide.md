# PrepPro Play Store Submission & Compliance Guide

_Last updated: February 9, 2026_

---

## 1. Project Preparation

- **Backup**: Ensure your project is backed up (e.g., zipped or pushed to GitHub).
- **Build**: Run `flutter build appbundle` to generate the release AAB.
- **Keystore**: Confirm `android/key.properties` and `android/app/build.gradle.kts` are set up for signing.
- **AdMob**: Confirm app-ads.txt is live on your domain (e.g., https://preppromeals.co.uk/app-ads.txt).

---

## 2. Privacy Policy & Data Safety

- **Privacy Policy**: Use [docs/privacy_policy.md](docs/privacy_policy.md) for Play Console and website.
- **Terms of Service**: Use [docs/terms_of_service.md](docs/terms_of_service.md).
- **Data Safety Form**:
  - Data collected: email, password, profile/plan data, optional diagnostics.
  - Data usage: provide/improve service, generate plans, maintain access/security, diagnose issues.
  - Sharing: only with Firebase and diagnostics if opted in.
  - User controls: update profile, opt out of telemetry, request deletion.

---

## 3. Play Console Listing

- **App Name**: PrepPro
- **Short Description**: Meal planning and shopping lists designed to reduce waste and save time.
- **Long Description**: [Expand from README.md or docs/privacy_policy.md]
- **Screenshots**: Take device screenshots (home, plan, recipes, shopping list).
- **App Icon**: Use your branded icon (see assets/images/PrepProBlue.png).
- **Privacy Policy URL**: Host privacy_policy.md or use a direct file link.
- **Contact Email**: support@preppro.app

---

## 4. Technical Checklist

- [x] No code errors (run `flutter analyze`)
- [x] Keystore and signing config correct
- [x] Release AAB built
- [x] app-ads.txt live
- [x] Privacy policy and terms included
- [x] Data Safety form filled accurately

---

## 5. Submission Steps

1. Log in to [Google Play Console](https://play.google.com/console).
2. Create a new app (or update existing).
3. Fill in app details (name, description, icon, screenshots).
4. Upload the AAB file.
5. Add privacy policy URL.
6. Complete Data Safety form.
7. Confirm app-ads.txt is live.
8. Submit for review.

---

## 6. Compliance Tips

- **AdMob**: No personal data used for ads; telemetry is opt-in.
- **Permissions**: Only standard internet/storage permissions; no sensitive permissions.
- **Firebase**: Only used for authentication, database, and hosting.
- **User Controls**: Users can update profile, opt out of telemetry, and request account deletion.

---

## 7. Useful Links

- [docs/privacy_policy.md](docs/privacy_policy.md)
- [docs/terms_of_service.md](docs/terms_of_service.md)
- [docs/Publishing.md](docs/Publishing.md)
- [Firebase Setup Guide](FIREBASE_SETUP.md)

---

## 8. Troubleshooting

- If build fails: Check keystore config and run `flutter clean`.
- If app-ads.txt not live: Check Firebase Hosting or domain setup.
- If Play Console flags issues: Review Data Safety, privacy policy, and permissions.

---

## 9. Contact

- Email: support@preppro.app

---

_This guide covers all steps for Play Store submission, compliance, and technical checks. Update as needed for future releases._
