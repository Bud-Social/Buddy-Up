import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../router.dart';

/// Lifecycle of the push stack. `unavailable` is a normal, non-fatal state
/// for builds without google-services.json (local/CI) — the UI can watch it
/// and degrade gracefully instead of failing silently.
enum PushAvailability { unknown, available, unavailable }

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ApiClient());
});

class PushNotificationService {
  final ApiClient _apiClient;

  PushNotificationService(this._apiClient);

  /// Observable availability; starts [PushAvailability.unknown].
  final ValueNotifier<PushAvailability> availability =
      ValueNotifier<PushAvailability>(PushAvailability.unknown);

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

        // Foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          // Foreground: no auto-navigation; badge will refresh via WebSocket/polling
        });

        // Background tap → app was in background, user tapped notification
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          _handleMessage(message);
        });

        // Cold start → app was terminated, user tapped notification to open it
        final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
        if (initialMessage != null) {
          // Delay until first frame so the router is ready
          Future.delayed(const Duration(milliseconds: 500), () {
            _handleMessage(initialMessage);
          });
        }
      }
      availability.value = PushAvailability.available;
    } catch (e) {
      // Explicit non-fatal degradation: no Firebase config in this build
      // (e.g. google-services.json absent on local/CI). Logged so failures
      // are visible in console; UI can watch `availability` and ignore.
      debugPrint('PUSH UNAVAILABLE (Firebase init failed): $e');
      availability.value = PushAvailability.unavailable;
    }
  }

  /// Maps an FCM [RemoteMessage] to the correct in-app route and navigates.
  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type']?.toString() ?? '';
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;

    String? route;

    // Prefer the route the server attached; the per-type switch is the fallback
    // for older payloads.
    final destination = data['destination'];
    if (destination is Map && destination['route'] is String) {
      route = destination['route'] as String;
    }

    // Only fall back to the per-type switch when the server sent no destination.
    if (route == null) {
    switch (type) {
      case 'live_starting':
      case 'live_reminder':
      case 'live_start':
        final liveId = data['live_id']?.toString() ?? '';
        if (liveId.isNotEmpty) route = '/lives/$liveId';

      case 'event_ticket_purchased':
        final eventId = data['event_id']?.toString() ?? '';
        if (eventId.isNotEmpty) route = '/marketplace/events/$eventId';

      case 'order_status_changed':
      case 'new_purchase':
        final orderId = data['order_id']?.toString() ?? '';
        // `/orders` has never existed; the order routes live under /marketplace.
        route = orderId.isNotEmpty
            ? '/marketplace/orders/$orderId'
            : '/marketplace/orders';

      case 'payout_processed':
      case 'withdrawal_processed':
      case 'payment_received':
        route = '/wallet';

      case 'community_join_approved':
      case 'community_post':
      case 'community_comment':
        final commId = data['community_id']?.toString() ?? '';
        // `/community/:id` has never existed -- the route is `/communities/:id`.
        if (commId.isNotEmpty) route = '/communities/$commId';

      case 'repost':
      case 'post_repost':
      case 'mention':
      case 'post_reaction':
      case 'comment':
      case 'comment_reply':
        final postId = data['post_id']?.toString() ?? '';
        // The post detail route is `/feed/:postId`; `/feed/post/:postId` was never
        // registered, so tapping a post notification went nowhere.
        if (postId.isNotEmpty) route = '/feed/$postId';

      case 'session_booked':
      case 'session_reminder':
        // `/sessions/my-sessions` was never registered; `/sessions` is the
        // bookings list this was reaching for.
        route = '/sessions';

      case 'follow':
      case 'new_follower':
      case 'buddy_request':
      case 'buddy_accepted':
        final username = data['username']?.toString() ?? '';
        if (username.isNotEmpty) route = '/$username';

      default:
        route = '/notifications';
    }
    }

    if (route != null) {
      // Navigation must go through go_router, not the raw NavigatorState.
      // `pushNamed` resolves names against the navigator's own route table,
      // which a go_router app does not populate -- so every one of these
      // notifications was a no-op even once the paths were correct.
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null) {
        GoRouter.of(ctx).go(route);
      }
    }
  }

  Future<void> _registerDeviceToken(String token) async {
    try {
      // `/notifications/device-token/` does not exist. The push device registry
      // is `POST /marketplace/push-devices/`, so every registration 404'd inside
      // this bare `catch` and the app silently had no registered device -- no
      // FCM delivery could ever be attempted for this user.
      await _apiClient.dio.post('/marketplace/push-devices/', data: {
        'token': token,
        'platform': 'android', // the only mobile platform this app ships
        'device_name': 'BuddyUp app',
      });
    } catch (_) {}
  }
}

