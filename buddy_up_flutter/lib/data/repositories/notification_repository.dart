import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'notification_repository.g.dart';

@RestApi()
abstract class NotificationRepository {
  factory NotificationRepository(Dio dio, {String baseUrl}) = _NotificationRepository;

  @GET('/notifications/')
  Future<Map<String, dynamic>> getNotifications();

  @GET('/notifications/unread-count/')
  Future<Map<String, dynamic>> getUnreadCount();

  @GET('/notifications/preferences/')
  Future<Map<String, dynamic>> getPreferences();

  @PUT('/notifications/preferences/')
  Future<Map<String, dynamic>> updatePreferences(@Body() Map<String, dynamic> data);

  @POST('/notifications/{id}/read/')
  Future<void> markRead(@Path('id') String notificationId);

  @POST('/notifications/')
  Future<Map<String, dynamic>> markAllRead();
}
