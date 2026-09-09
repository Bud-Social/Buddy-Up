import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../device/device_id.dart';
import '../env/env.dart';

class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
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
        // Device sessions: the backend stores this to attribute logins.
        options.headers['X-Device-Id'] = await DeviceId.get();
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await _storage.read(key: 'refresh_token');
          if (refreshToken != null) {
            try {
              final response = await Dio(
                BaseOptions(baseUrl: Env.apiBaseUrl),
              ).post(
                '/auth/token/refresh/',
                data: {'refresh': refreshToken},
              );
              final newAccess = response.data['access'] as String;
              final newRefresh = response.data['refresh'] as String? ?? refreshToken;
              await _storage.write(key: 'access_token', value: newAccess);
              await _storage.write(key: 'refresh_token', value: newRefresh);
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
              final retry = await dio.fetch(error.requestOptions);
              handler.resolve(retry);
              return;
            } catch (_) {
              await _storage.deleteAll();
            }
          }
        }
        handler.next(error);
      },
    );
  }
}
