# Firebase Setup Guide for PrepPro

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"**
3. Project name: `preppro-meal-planner`
4. Accept default settings and create

## 2. Enable Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. You can optionally enable additional providers (Google, Apple, etc.)

## 3. Create Firestore Database

1. Go to **Firestore Database** → **Create database**
2. Select **Production mode**
3. Choose a location (closest to your users)
4. Click **Create**

## 4. Configure Firestore Security Rules

Replace default rules with these (for development):

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own documents
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Plans are user-specific
    match /users/{userId}/plans/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Recipes can be read by anyone, written by admin
    match /recipes/{document=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

## 5. Get Firebase Configuration

### For Android:

1. In Firebase Console → **Project Settings** → **Your apps**
2. Click **Android** icon
3. Package name: `com.example.preppro` (update if different)
4. Download `google-services.json`
5. Place in `android/app/` directory

### For iOS:

1. Click **iOS** icon
2. Bundle ID: `com.example.preppro`
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into Xcode
6. Select **Copy items if needed** and **Runner** target

## 6. Update Firebase Options

Update `lib/firebase_options.dart` with your actual credentials from:
- Firebase Console → Project Settings → Web API keys and IDs

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase credentials.

## 7. Test Authentication

Run the app:

```bash
flutter pub get
flutter run
```

1. You should see the Login page
2. Click "Sign up" to create an account
3. After successful signup, you'll be redirected to Home page
4. User data is automatically saved to Firestore
5. Log out from Profile page, then log back in to test persistence

## 8. Next Steps

### Connect Plans to Firestore

Update `PlanStore` to sync with Firestore:

```dart
// In plan_store.dart
class PlanStore {
  static Future<void> savePlan(List<Map<String, dynamic>> plan) async {
    final user = AuthService.currentUser;
    if (user == null) return;
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('plans')
        .doc('current')
        .set({'recipes': plan, 'updatedAt': Timestamp.now()});
  }
}
```

### Connect Recipes to Firestore

1. Upload recipes to Firestore from your JSON file
2. Update `RecipeLoader` to fetch from Firestore instead of JSON

### Connect Weight Tracking

Similar to plans, sync weight entries to:
- `users/{uid}/weight/{entryId}`

## 9. Firebase Free Tier Limits

- **Users**: 3,000-5,000 DAU supported
- **Firestore**: 50,000 reads/day, 20,000 writes/day
- **Authentication**: Unlimited (paid after free tier)
- **Storage**: 5 GB included

## 10. Troubleshooting

### App crashes on startup:
- Check that `firebase_options.dart` has correct credentials
- Verify Firebase project exists and is active

### Login fails:
- Check Firestore security rules
- Verify email/password auth is enabled
- Check Firebase Console logs for errors

### UI doesn't show login:
- Ensure `AuthProvider` is wrapped around app in `main.dart`
- Check that `go_router` redirect logic is working

## Files Created/Updated

✅ `lib/core/services/auth_service.dart` - Firebase Auth logic
✅ `lib/core/providers/auth_provider.dart` - State management
✅ `lib/features/auth/login_page.dart` - Login UI
✅ `lib/features/auth/signup_page.dart` - Signup UI
✅ `lib/firebase_options.dart` - Firebase configuration
✅ `lib/main.dart` - Firebase initialization
✅ `lib/app_router.dart` - Auth-aware routing
✅ `pubspec.yaml` - Firebase dependencies

## Firebase Credential Placeholder Format

When you get credentials from Firebase Console, update:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',        // From Google-services.json
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'preppro-meal-planner',
  storageBucket: 'preppro-meal-planner.appspot.com',
);
```
