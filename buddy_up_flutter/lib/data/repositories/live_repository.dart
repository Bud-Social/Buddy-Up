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

  // ── Replay ───────────────────────────────────────────────────────────
  /// The `replay` sub-object on a live detail is what the player reads; the
  /// viewer increments a unique-viewer counter for the host's stats.
  @POST('/lives/{id}/replay/view/')
  Future<dynamic> recordReplayView(@Path('id') String liveId);

  // ── Audience controls ────────────────────────────────────────────────
  @PATCH('/lives/{id}/visibility/')
  Future<dynamic> updateVisibility(
    @Path('id') String liveId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/lives/{id}/feedback/')
  Future<dynamic> submitFeedback(
    @Path('id') String liveId,
    @Body() Map<String, dynamic> body,
  );

  @GET('/lives/{id}/feedback/')
  Future<dynamic> getFeedback(@Path('id') String liveId);

  @POST('/lives/{id}/polls/')
  Future<dynamic> createPoll(
    @Path('id') String liveId,
    @Body() Map<String, dynamic> body,
  );

  @GET('/lives/{id}/polls/current/')
  Future<dynamic> getCurrentPoll(@Path('id') String liveId);

  @POST('/lives/{id}/polls/{pollId}/vote/')
  Future<dynamic> votePoll(
    @Path('id') String liveId,
    @Path('pollId') String pollId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/lives/{id}/not-interested/')
  Future<dynamic> toggleNotInterested(@Path('id') String liveId);

  /// "Never recommend this host again" — the feed mute list.
  @POST('/lives/{id}/mute-host/')
  Future<dynamic> toggleMuteHost(@Path('id') String liveId);

  @GET('/lives/{id}/attendees/')
  Future<dynamic> getAttendees(@Path('id') String liveId);

  // ── Co-host ladder (invite / request to speak) ───────────────────────
  @POST('/lives/{id}/co-host/invite/')
  Future<dynamic> inviteCohost(
    @Path('id') String liveId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/lives/{id}/co-host/invite/')
  Future<dynamic> cancelCohostInvite(
    @Path('id') String liveId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/lives/{id}/co-host/respond/')
  Future<dynamic> respondCohostInvite(
    @Path('id') String liveId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/lives/{id}/co-host/request/')
  Future<dynamic> requestToSpeak(@Path('id') String liveId);

  @GET('/lives/{id}/co-host/requests/')
  Future<dynamic> getCohostRequests(@Path('id') String liveId);

  @POST('/lives/{id}/co-host/respond-request/')
  Future<dynamic> respondToSpeakRequest(
    @Path('id') String liveId,
    @Body() Map<String, dynamic> body,
  );
}
