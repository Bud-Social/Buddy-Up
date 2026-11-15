import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'routine_repository.g.dart';

/// Retrofit client for the countdowns `/routines/` endpoints.
///
/// Routines share the countdowns streak engine with the web app; expect the
/// same JSON shape the React app consumes (Rest envelopes, UUID keys,
/// Monday=0 weekdays).
@RestApi()
abstract class RoutineRepository {
  factory RoutineRepository(Dio dio, {String baseUrl}) = _RoutineRepository;

  @GET('/countdowns/routines/')
  Future<dynamic> getRoutines();

  @POST('/countdowns/routines/')
  Future<dynamic> createRoutine(@Body() Map<String, dynamic> data);

  @GET('/countdowns/routines/{id}/')
  Future<dynamic> getRoutine(@Path('id') String id);

  @PATCH('/countdowns/routines/{id}/')
  Future<dynamic> updateRoutine(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/countdowns/routines/{id}/')
  Future<void> deleteRoutine(@Path('id') String id);

  @POST('/countdowns/routines/reorder/')
  Future<dynamic> reorder(@Body() Map<String, dynamic> body);

  @POST('/countdowns/routines/{id}/checkin/')
  Future<dynamic> checkIn(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  @GET('/countdowns/routines/{id}/checkins/')
  Future<dynamic> getCheckIns(
    @Path('id') String id, {
    @Query('limit') String? limit,
  });

  @GET('/countdowns/routines/{id}/highlights/')
  Future<dynamic> getHighlights(@Path('id') String id);

  @POST('/countdowns/routines/{id}/highlights/')
  @MultiPart()
  Future<dynamic> uploadHighlight(
    @Path('id') String id,
    @Part(name: 'file') MultipartFile file,
    @Part(name: 'kind') String kind,
    @Part(name: 'caption') String caption,
    @Part(name: 'duration_ms') String durationMs,
  );

  @DELETE('/countdowns/routines/{id}/highlights/{highlight_id}/')
  Future<void> deleteHighlight(
    @Path('id') String id,
    @Path('highlight_id') String highlightId,
  );
}
