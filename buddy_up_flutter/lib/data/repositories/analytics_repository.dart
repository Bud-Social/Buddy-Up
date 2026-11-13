import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'analytics_repository.g.dart';

@RestApi()
abstract class AnalyticsRepository {
  factory AnalyticsRepository(Dio dio, {String baseUrl}) = _AnalyticsRepository;

  @GET('/analytics/summary/')
  Future<dynamic> getSummary({@Query('period') String? period});

  @GET('/analytics/activities/')
  Future<dynamic> getActivities({
    @Query('activity_type') String? activityType,
    @Query('start') String? start,
    @Query('end') String? end,
  });

  @POST('/analytics/activities/')
  Future<dynamic> createActivity(
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/analytics/activities/{id}/')
  Future<void> deleteActivity(@Path('id') String id);

  @GET('/analytics/workouts/')
  Future<dynamic> getWorkouts();

  @POST('/analytics/workouts/')
  Future<dynamic> createWorkout(@Body() Map<String, dynamic> data);

  @DELETE('/analytics/workouts/{id}/')
  Future<void> deleteWorkout(@Path('id') String id);

  @GET('/analytics/body/')
  Future<dynamic> getBodyMetrics();

  @POST('/analytics/body/')
  @MultiPart()
  Future<dynamic> createBodyMetric(
    @Part() Map<String, dynamic> data,
  );

  @POST('/analytics/body/read-weight/')
  @MultiPart()
  Future<dynamic> readBodyWeight(
    @Part() Map<String, dynamic> data,
  );

  @DELETE('/analytics/body/{id}/')
  Future<void> deleteBodyMetric(@Path('id') String id);

  @GET('/analytics/report/')
  Future<dynamic> generateReport({
    @Query('period') String? period,
  });

  /// Prepare a share draft server-side (draft_id + prefilled caption/tags).
  /// Lives are shared as `long_video`; the server writes the Draft row.
  @POST('/analytics/share/prepare/')
  Future<dynamic> sharePrepare(@Body() Map<String, dynamic> body);

  /// Publish a prepared draft — rarely called directly; the composer uses
  /// its own create path and deletes the server draft afterwards.
  @POST('/analytics/share/draft/{id}/publish/')
  Future<dynamic> sharePublish(
    @Path('id') String draftId,
    @Body() Map<String, dynamic> body,
  );

  @GET('/analytics/report/download/')
  Future<dynamic> downloadReport({
    @Query('period') String? period,
    @Query('id') String? id,
  });

  @POST('/analytics/report/share/')
  Future<dynamic> shareReport(@Body() Map<String, dynamic> data);

  @POST('/analytics/{kind}/{id}/share/')
  Future<dynamic> shareActivity(
    @Path('kind') String kind,
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  /// Correct grammar in a social caption via the AI microservice.
  @POST('/analytics/caption/correct/')
  Future<dynamic> correctCaption(@Body() Map<String, dynamic> data);
}
