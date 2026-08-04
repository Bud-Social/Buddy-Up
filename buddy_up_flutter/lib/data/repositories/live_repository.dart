import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'live_repository.g.dart';

@RestApi()
abstract class LiveRepository {
  factory LiveRepository(Dio dio, {String baseUrl}) = _LiveRepository;

  @GET('/lives/browse/')
  Future<Map<String, dynamic>> browse({
    @Query('tab') String? tab,
    @Query('category') String? category,
    @Query('cursor') String? cursor,
  });

  @GET('/lives/{id}/')
  Future<Map<String, dynamic>> getLive(@Path('id') String liveId);

  @POST('/lives/start/')
  Future<Map<String, dynamic>> startLive(@Body() Map<String, dynamic> data);

  @POST('/lives/{id}/end/')
  Future<void> endLive(
    @Path('id') String liveId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/lives/{id}/join/')
  Future<Map<String, dynamic>> joinLive(@Path('id') String liveId);

  @GET('/lives/{id}/credentials/')
  Future<Map<String, dynamic>> getCredentials(@Path('id') String liveId);

  @POST('/lives/{id}/rsvp/')
  Future<Map<String, dynamic>> rsvp(@Path('id') String liveId);

  @POST('/lives/random-drop/start/')
  Future<Map<String, dynamic>> startRandomDrop(
    @Body() Map<String, dynamic> data,
  );

  @GET('/lives/random-drop/status/')
  Future<Map<String, dynamic>> getRandomDropStatus();

  @DELETE('/lives/random-drop/status/')
  Future<void> cancelRandomDrop();

  @GET('/lives/gym/{gymId}/schedule/')
  Future<Map<String, dynamic>> getGymSchedule(@Path('gymId') String gymId);

  @GET('/lives/profile/{username}/')
  Future<Map<String, dynamic>> getUserLives(
    @Path('username') String username, {
    @Query('tab') String? tab,
    @Query('cursor') String? cursor,
  });

  @POST('/lives/{id}/refund-gift/{txId}/')
  Future<void> refundGift(
    @Path('id') String liveId,
    @Path('txId') String txId,
  );

  @POST('/lives/{id}/co-host/')
  Future<void> addCoHost(
    @Path('id') String liveId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/lives/{id}/co-host/')
  Future<void> removeCoHost(
    @Path('id') String liveId,
    @Body() Map<String, dynamic> body,
  );
}
