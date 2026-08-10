import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'analytics_repository.g.dart';

@RestApi()
abstract class AnalyticsRepository {
  factory AnalyticsRepository(Dio dio, {String baseUrl}) = _AnalyticsRepository;

  @GET('/analytics/summary/')
  Future<Map<String, dynamic>> getSummary({@Query('period') String? period});

  @GET('/analytics/activities/')
  Future<Map<String, dynamic>> getActivities({
    @Query('activity_type') String? activityType,
    @Query('start') String? start,
    @Query('end') String? end,
  });

  @POST('/analytics/activities/')
  Future<Map<String, dynamic>> createActivity(
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/analytics/activities/{id}/')
  Future<void> deleteActivity(@Path('id') String id);

  @GET('/analytics/workouts/')
  Future<Map<String, dynamic>> getWorkouts();

  @POST('/analytics/workouts/')
  Future<Map<String, dynamic>> createWorkout(@Body() Map<String, dynamic> data);

  @DELETE('/analytics/workouts/{id}/')
  Future<void> deleteWorkout(@Path('id') String id);

  @GET('/analytics/meals/')
  Future<Map<String, dynamic>> getMeals();

  @POST('/analytics/meals/')
  Future<Map<String, dynamic>> createMeal(@Body() Map<String, dynamic> data);

  @POST('/analytics/meals/')
  @MultiPart()
  Future<Map<String, dynamic>> createMealWithPhoto(
    @Part() Map<String, dynamic> data,
  );

  @POST('/analytics/meals/analyze/')
  @MultiPart()
  Future<Map<String, dynamic>> analyzeMealPhoto(
    @Part() Map<String, dynamic> data,
  );

  @DELETE('/analytics/meals/{id}/')
  Future<void> deleteMeal(@Path('id') String id);

  @GET('/analytics/body/')
  Future<Map<String, dynamic>> getBodyMetrics();

  @POST('/analytics/body/')
  @MultiPart()
  Future<Map<String, dynamic>> createBodyMetric(
    @Part() Map<String, dynamic> data,
  );

  @POST('/analytics/body/read-weight/')
  @MultiPart()
  Future<Map<String, dynamic>> readBodyWeight(
    @Part() Map<String, dynamic> data,
  );

  @DELETE('/analytics/body/{id}/')
  Future<void> deleteBodyMetric(@Path('id') String id);

  @GET('/analytics/report/')
  Future<Map<String, dynamic>> generateReport({
    @Query('period') String? period,
  });

  @GET('/analytics/report/download/')
  Future<Map<String, dynamic>> downloadReport({
    @Query('period') String? period,
    @Query('id') String? id,
  });

  @POST('/analytics/report/share/')
  Future<Map<String, dynamic>> shareReport(@Body() Map<String, dynamic> data);
}
