import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'live_repository.g.dart';

@RestApi()
abstract class LiveRepository {
  factory LiveRepository(Dio dio, {String baseUrl}) = _LiveRepository;

  @GET('/lives/browse/')
  Future<dynamic> browse({
    @Query('tab') String? tab,
    @Query('category') String? category,
    @Query('cursor') String? cursor,
  });

  @GET('/lives/{id}/')
  Future<dynamic> getLive(@Path('id') String liveId);

  @POST('/lives/start/')
  Future<dynamic> startLive(@Body() Map<String, dynamic> data);

  @POST('/lives/{id}/end/')
  Future<void> endLive(
    @Path('id') String liveId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/lives/{id}/join/')
  Future<dynamic> joinLive(@Path('id') String liveId);

  @GET('/lives/{id}/credentials/')
  Future<dynamic> getCredentials(@Path('id') String liveId);

  @POST('/lives/{id}/rsvp/')
  Future<dynamic> rsvp(@Path('id') String liveId);

  @POST('/lives/random-drop/start/')
  Future<dynamic> startRandomDrop(
    @Body() Map<String, dynamic> data,
  );

  @GET('/lives/random-drop/status/')
  Future<dynamic> getRandomDropStatus();

  @DELETE('/lives/random-drop/status/')
  Future<void> cancelRandomDrop();

  @GET('/lives/gym/{gymId}/schedule/')
  Future<dynamic> getGymSchedule(@Path('gymId') String gymId);

  @GET('/lives/profile/{username}/')
  Future<dynamic> getUserLives(
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
