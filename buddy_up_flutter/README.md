# buddy_up_flutter

Buddy-Up health & fitness social platform — Flutter client.

## Getting Started

```bash
cp .env.example .env   # local overrides go in .env.local (git-ignored)
flutter pub get
flutter run
```

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Google Sign-In setup (required for "Continue with Google")

The login and register screens authenticate via Google and POST the resulting
ID token to the backend `POST /auth/google/` endpoint. Two console-side steps
are required before the flow works — the app builds and runs fine without
them, but sign-in will fail with a configuration error.

### 1. Add your Android SHA-1 / SHA-256 fingerprints

The Google SDK only serves sign-in requests to apps whose signing
certificate fingerprint is registered:

- Get the fingerprints for your build:

  ```bash
  # debug keystore (local dev)
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
  # release keystore (see android/key.properties.example)
  keytool -list -v -keystore android/keys/buddyup-release.jks -alias buddyup
  ```

  For Play Store builds also copy the **App signing key certificate**
  SHA-1/SHA-256 from Play Console → Setup → App signing.

- Register them in the [Google Cloud Console](https://console.cloud.google.com/)
  → APIs & Services → Credentials → your OAuth 2.0 Android client (and in the
  Firebase console → Project settings → Your apps → Android app if you use
  Firebase). Add fingerprints for **every keystore** you ship (debug +
  release + Play App Signing).

### 2. Configure the Web client id (`GOOGLE_SERVER_CLIENT_ID`)

The ID token sent to the backend is issued with a **Web application** OAuth
client as its audience. On Android, google_sign_in needs that client id at
runtime:

- Set `GOOGLE_SERVER_CLIENT_ID=<web-client-id>.apps.googleusercontent.com`
  in `buddy_up_flutter/.env` (or `.env.local`). The app reads it via
  `Env.googleServerClientId` and passes it as `serverClientId` to
  `GoogleSignIn.instance.initialize()` (see `lib/core/auth/google_auth.dart`).
- The backend must be configured to accept that same web client id as the
  token audience. The root `.env.example` exposes it as `GOOGLE_CLIENT_ID`.
- iOS uses the bundle-id-based config (or a `GoogleService-Info.plist`) —
  see the [google_sign_in README](https://pub.dev/packages/google_sign_in)
  for the iOS setup details.

### Firebase / push notifications note

`google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are
intentionally **not** committed. The Android Gradle plugin only applies
`com.google.gms.google-services` when the file exists, and `main.dart` /
`PushNotificationService` treat Firebase init failure as a non-fatal
degradation (push service exposes `PushAvailability.unavailable`). Builds
without the file compile and run; push notifications are simply unavailable.

## Android release signing

Production signing is read from `android/key.properties` (git-ignored; see
`android/key.properties.example`) with `SIGNING_*` environment variables as a
CI fallback. If neither is present, release builds fall back to debug signing
so local `flutter run --release` still works. Use
`./scripts/build_apk.sh` for a release APK or
`flutter build appbundle --release` for a Play Store `.aab`.
