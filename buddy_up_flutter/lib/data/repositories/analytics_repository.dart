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

  @GET('/analytics/meals/')
  Future<dynamic> getMeals();

  @POST('/analytics/meals/')
  Future<dynamic> createMeal(@Body() Map<String, dynamic> data);

  @POST('/analytics/meals/')
  @MultiPart()
  Future<dynamic> createMealWithPhoto(
    @Part() Map<String, dynamic> data,
  );

  @POST('/analytics/meals/analyze/')
  @MultiPart()
  Future<dynamic> analyzeMealPhoto(
    @Part() Map<String, dynamic> data,
  );

  @DELETE('/analytics/meals/{id}/')
  Future<void> deleteMeal(@Path('id') String id);

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

  @GET('/analytics/report/download/')
  Future<dynamic> downloadReport({
    @Query('period') String? period,
    @Query('id') String? id,
  });

  @POST('/analytics/report/share/')
  Future<dynamic> shareReport(@Body() Map<String, dynamic> data);
}
