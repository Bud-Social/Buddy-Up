import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/models/notification.dart';
import '../../../core/api/api_client.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(apiClientProvider7).dio;
  return NotificationRepository(dio);
});

final apiClientProvider7 = Provider<ApiClient>((_) => ApiClient());

final notificationsProvider = FutureProvider<List<BuddyNotification>>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  final raw = await repo.getNotifications();
  return (raw['data'] as List)
      .map((e) => BuddyNotification.fromJson(e as Map<String, dynamic>))
      .toList();
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  final raw = await repo.getUnreadCount();
  return (raw['data'] as Map<String, dynamic>)['count'] as int;
});

final notificationPreferencesProvider = FutureProvider<NotificationPreference>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  final raw = await repo.getPreferences();
  return NotificationPreference.fromJson(raw['data'] as Map<String, dynamic>);
});
