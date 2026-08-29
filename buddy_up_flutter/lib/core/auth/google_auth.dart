import 'package:google_sign_in/google_sign_in.dart';
import '../env/env.dart';

/// Real Google sign-in on top of google_sign_in v7.
///
/// v7 API notes:
///  - `GoogleSignIn.instance` is a singleton and must be `initialize()`d
///    exactly once before any other call.
///  - Interactive sign-in is `authenticate()`, which throws
///    [GoogleSignInException] (including user-cancel) instead of returning
///    null like the old v6 `signIn()`.
///  - ID tokens come from `account.authentication.idToken` (sync getter).
class GoogleAuth {
  GoogleAuth._();

  static bool _initialized = false;

  /// Returns the Google OIDC ID token for the signed-in account, or null if
  /// the user cancelled the flow. Throws on configuration/failure errors —
  /// callers must surface those via their own error UI.
  static Future<String?> getIdToken() async {
    final signIn = GoogleSignIn.instance;
    if (!_initialized) {
      // serverClientId (web client id) is required on Android so the issued
      // ID token has an audience the backend can verify; see README.
      final serverClientId = Env.googleServerClientId;
      await signIn.initialize(
        serverClientId: serverClientId.isNotEmpty ? serverClientId : null,
      );
      _initialized = true;
    }
    if (!signIn.supportsAuthenticate()) {
      throw Exception('Google Sign-In is not supported on this platform.');
    }
    final account = await signIn.authenticate(
      scopeHint: const ['email', 'profile'],
    );
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Failed to get Google authentication token');
    }
    return idToken;
  }

  /// True when the exception means the user backed out of the sign-in flow.
  static bool isCancelled(Object error) {
    return error is GoogleSignInException &&
        error.code == GoogleSignInExceptionCode.canceled;
  }
}
