import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ApiClient());
});

class PushNotificationService {
  final ApiClient _apiClient;
  
  PushNotificationService(this._apiClient);

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      
      final messaging = FirebaseMessaging.instance;
      
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await messaging.getToken();
        if (token != null) {
          await _registerDeviceToken(token);
        }

        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          _registerDeviceToken(newToken);
        });

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          // Handle foreground message
          print('Received foreground message: ${message.messageId}');
        });
      }
    } catch (e) {
      print('Failed to initialize push notifications: $e');
    }
  }

  Future<void> _registerDeviceToken(String token) async {
    try {
      await _apiClient.dio.post('/notifications/device-token/', data: {
        'token': token,
        'platform': 'flutter',
      });
    } catch (e) {
      print('Failed to register device token: $e');
    }
  }
}
