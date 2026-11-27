import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../device/device_id.dart';
import '../env/env.dart';
import '../../router.dart' show rootNavigatorKey;

class ApiClient {
  static Future<String?>? _refreshInFlight;
  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 45),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(_authInterceptor());
  }

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        // Media posts upload large payloads: the web gives /feed/create/ 120s.
        if (options.path.startsWith('/feed/create/')) {
          options.connectTimeout = const Duration(seconds: 30);
          options.sendTimeout = const Duration(seconds: 120);
          options.receiveTimeout = const Duration(seconds: 120);
        }
        // Device sessions: the backend stores this to attribute logins.
        options.headers['X-Device-Id'] = await DeviceId.get();
        handler.next(options);
      },
      onResponse: (response, handler) {
        // The backend wraps payloads in a {success, data, message} envelope.
        // Typed repositories parse the body directly, so unwrap the envelope
        // for the auth + onboarding namespaces — other screens read the
        // envelope themselves (res.data['data']) and must stay untouched.
        final path = response.requestOptions.path;
        final data = response.data;
        if (data is Map &&
            data.containsKey('data') &&
            (path.startsWith('/auth/') ||
                path.startsWith('/profiles/onboarding/'))) {
          response.data = data['data'];
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        // Stale-consent / incomplete-onboarding gate: the backend blocks
        // app-data calls with 403 consent_required. Send the user to
        // onboarding where acceptance happens (mirrors the web client).
        // Covers cold starts where the router gate can't see the profile yet.
        final bodyData = error.response?.data is Map
            ? (error.response!.data as Map)['data']
            : null;
        if (error.response?.statusCode == 403 &&
            bodyData is Map &&
            bodyData['consent_required'] == true) {
          final navContext = rootNavigatorKey.currentContext;
          if (navContext != null) {
            GoRouter.of(navContext).go('/onboarding');
          }
          handler.next(error);
          return;
        }
        if (error.response?.statusCode == 401) {
          final refreshToken = await _storage.read(key: 'refresh_token');
          if (refreshToken != null) {
            try {
              final newAccess = await (_refreshInFlight ??= _refresh(
                refreshToken,
              ));
              _refreshInFlight = null;
              if (newAccess == null) {
                throw StateError('Token refresh returned no access token');
              }
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccess';
              final retry = await dio.fetch(error.requestOptions);
              handler.resolve(retry);
              return;
            } catch (_) {
              _refreshInFlight = null;
              await _storage.deleteAll();
            }
          }
        }
        handler.next(error);
      },
    );
  }

  Future<String?> _refresh(String refreshToken) async {
    final response = await Dio(
      BaseOptions(baseUrl: Env.apiBaseUrl),
    ).post('/auth/token/refresh/', data: {'refresh': refreshToken});
    final raw = response.data;
    final body = (raw is Map && raw['data'] is Map)
        ? raw['data'] as Map<String, dynamic>
        : raw as Map<String, dynamic>;
    final newAccess = body['access'] as String?;
    if (newAccess == null) return null;
    await _storage.write(key: 'access_token', value: newAccess);
    await _storage.write(
      key: 'refresh_token',
      value: body['refresh'] as String? ?? refreshToken,
    );
    return newAccess;
  }
}
