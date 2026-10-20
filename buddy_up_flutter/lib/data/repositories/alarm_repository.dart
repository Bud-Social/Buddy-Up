import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'alarm_repository.g.dart';

@RestApi()
abstract class AlarmRepository {
  factory AlarmRepository(Dio dio, {String baseUrl}) = _AlarmRepository;

  // ── Alarms ─────────────────────────────────────────────────────────────
  @GET('/alarms/')
  Future<dynamic> getAlarms();

  @POST('/alarms/')
  Future<dynamic> createAlarm(@Body() Map<String, dynamic> data);

  @PATCH('/alarms/{id}/')
  Future<dynamic> updateAlarm(
    @Path('id') String alarmId,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/alarms/{id}/')
  Future<void> deleteAlarm(@Path('id') String alarmId);

  // ── Sounds ─────────────────────────────────────────────────────────────
  @GET('/alarms/sounds/')
  Future<dynamic> getSounds();

  @POST('/alarms/sounds/')
  @MultiPart()
  Future<dynamic> uploadSound(
    @Part(name: 'audio') MultipartFile audio,
    @Part(name: 'name') String name,
    @Part(name: 'visibility') String visibility,
  );

  @POST('/alarms/sounds/{id}/share/')
  Future<dynamic> shareSound(
    @Path('id') String soundId,
    @Body() Map<String, dynamic> data,
  );

  // ── Shares inbox ───────────────────────────────────────────────────────
  @GET('/alarms/shares/inbox/')
  Future<dynamic> getSharesInbox();

  @POST('/alarms/shares/{id}/respond/')
  Future<dynamic> respondToShare(
    @Path('id') String shareId,
    @Body() Map<String, dynamic> data,
  );

  // ── Suggestions ────────────────────────────────────────────────────────
  @GET('/alarms/suggestions/')
  Future<dynamic> getSuggestions();

  @POST('/alarms/suggestions/')
  Future<dynamic> sendSuggestion(@Body() Map<String, dynamic> data);

  @POST('/alarms/suggestions/{id}/respond/')
  Future<dynamic> respondToSuggestion(
    @Path('id') String suggestionId,
    @Body() Map<String, dynamic> data,
  );
}
