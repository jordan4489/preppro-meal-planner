# PrepPro App Design Document

## 1. System Architecture

**Frontend:**
- Flutter (Dart)
- Cross-platform: Android, iOS, Web, Desktop (Windows, macOS)

**Backend/Cloud:**
- Firebase (Google Cloud)
  - Authentication (Email/Password)
  - Firestore (NoSQL database)
  - Hosting (for privacy policy, app-ads.txt, etc.)
  - Analytics (optional, if enabled)
  - Cloud Storage (for assets, if needed)
- Sentry (Error/Crash reporting, with user consent)
- Google Mobile Ads (AdMob)

**Other Integrations:**
- Zoho Mail (support@preppromeal.co.uk)
- Custom domain: preppromeal.co.uk (for support, privacy policy, and hosting)

**Namespace:**
- com.preppro.app (iOS/macOS)
- com.example.preppro (Android)

---

## 2. Third-Party Integrations

### Firebase
- **Authentication:**
  - Email/password login and registration
  - User profile management
- **Firestore:**
  - User data (profile, plans, preferences)
  - Recipes (read-only for users)
  - Weight tracking
- **Hosting:**
  - Privacy policy, app-ads.txt, and static files
- **Analytics:**
  - Optional, based on user consent
- **Cloud Storage:**
  - For images/assets if needed

### AdMob (Google Mobile Ads)
- Banner ads (with test and production IDs)
- Uses advertising ID (see privacy policy)

### Sentry
- Error and crash reporting (only if user consents to telemetry)

### Zoho Mail
- Used for support email (support@preppromeal.co.uk)
- Linked from privacy policy and app support

### Domain/Namespace
- Domain: preppromeal.co.uk
- Used for support, privacy, and Play Store listing
- App namespace: com.preppro.app (iOS/macOS), com.example.preppro (Android)

---

## 3. Data Flow & User Journey

1. **User installs and opens the app**
2. **Authentication:**
   - User signs up or logs in (Firebase Auth)
   - User profile created in Firestore
3. **Profile Setup:**
   - User enters weight, goals, preferences
   - Data saved to Firestore
4. **Meal Plan Generation:**
   - User taps "Generate Meal Plan"
   - Plan saved to Firestore
5. **Recipe Browsing:**
   - Recipes loaded from Firestore (read-only)
6. **Shopping List & Tracking:**
   - User views shopping list, checks off items
   - Calories and progress tracked locally and in Firestore
7. **Ads & Analytics:**
   - Banner ads shown (AdMob)
   - Analytics/events sent if user consents
8. **Support:**
   - User can email support@preppromeal.co.uk (Zoho Mail)

---

## 4. Security, Privacy, and Compliance

- **Privacy Policy:**
  - Minimal data collection (see docs/privacy_policy.md)
  - No data sold; only shared with service providers (Firebase, AdMob, Sentry)
  - Data deletion on request (via support email)
- **GDPR/Compliance:**
  - Users can request data deletion
  - Data stored securely in Firebase (Google Cloud)
- **Advertising ID:**
  - Used by AdMob for ads (see Play Store disclosure)
- **User Consent:**
  - Telemetry/analytics only if user opts in

---

## 5. File/Code Structure (Key Files)
- `lib/main.dart`: App entry, Firebase/AdMob/Sentry init
- `lib/firebase_options.dart`: Firebase config
- `lib/core/services/auth_service.dart`: Auth logic
- `lib/core/providers/auth_provider.dart`: Auth state
- `lib/widgets/ad_banner.dart`: AdMob integration
- `docs/privacy_policy.md`: Privacy policy
- `FIREBASE_SETUP.md`: Firebase setup and security rules

---

## 6. Future Enhancements
- Push notifications (Firebase Cloud Messaging)
- Social login (Google, Apple)
- In-app purchases (if monetizing)
- More analytics/engagement tracking

---

## 7. Contacts
- Support: support@preppromeal.co.uk (Zoho Mail)
- Domain: preppromeal.co.uk

---

*This document summarizes the technical design, integrations, and compliance for PrepPro. For more details, see the codebase and documentation files.*
