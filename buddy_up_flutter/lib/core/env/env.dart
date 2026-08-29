import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment selector: set `--dart-define=APP_ENV=local` for local dev,
/// otherwise production (cloud) URLs are used.
///
/// Resolution order:
///   1. `--dart-define` value (highest priority)
///   2. `.env` file value
///   3. Built-in production fallback (cloud URLs)
class Env {
  static const String _envOverride = String.fromEnvironment('APP_ENV');

  static const String prodApiBaseUrl = 'https://api.buddyup.app/api/v1';
  static const String prodWsBaseUrl = 'wss://api.buddyup.app';
  static const String prodLivekitUrl = 'wss://buddy-up-hf40obqn.livekit.cloud';

  static const String localApiBaseUrl = 'http://localhost:8002/api/v1';
  static const String localWsBaseUrl = 'ws://localhost:8002';
  static const String localLivekitUrl = 'ws://localhost:7880';

  static bool get isLocal => _envOverride.toLowerCase() == 'local';

  static String get apiBaseUrl => _pick('API_BASE_URL', prodApiBaseUrl, localApiBaseUrl);
  static String get wsBaseUrl => _pick('WS_BASE_URL', prodWsBaseUrl, localWsBaseUrl);
  static String get agoraAppId => _get('AGORA_APP_ID', '');
  static String get livekitUrl => _pick('LIVEKIT_URL', prodLivekitUrl, localLivekitUrl);
  static String get googleMapsKey => _get('GOOGLE_MAPS_KEY', '');
  /// Web client id for Google Sign-In (audience of the issued ID token).
  /// Required on Android when no google-services.json ships with the build.
  static String get googleServerClientId => _get('GOOGLE_SERVER_CLIENT_ID', '');
  static String get cloudinaryCloudName => _get('CLOUDINARY_CLOUD_NAME', '');
  static String get firebaseConfig => _get('FIREBASE_CONFIG', '');

  /// If running with APP_ENV=local, default to the local URL; otherwise use
  /// the production fallback. An explicit value in the env file wins.
  static String _pick(String key, String prodFallback, String localFallback) {
    final value = dotenv.maybeGet(key);
    if (value != null && value.isNotEmpty) return value;
    return isLocal ? localFallback : prodFallback;
  }

  static String _get(String key, String fallback) {
    final value = dotenv.maybeGet(key);
    return (value == null || value.isEmpty) ? fallback : value;
  }
}
