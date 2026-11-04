import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../core/api/api_client.dart';
import '../models/countdown_models.dart';

part 'countdown_repository.g.dart';

@RestApi()
abstract class CountdownRepository {
  factory CountdownRepository(Dio dio, {String baseUrl}) = _CountdownRepository;

  /// List active countdown templates offered to all users.
  @GET('/countdowns/templates/')
  Future<List<CountdownTemplate>> listTemplates();

  /// Seed default countdown templates (staff only).
  @POST('/countdowns/templates/seed/')
  Future<dynamic> seedTemplates();

  /// List the authenticated user's countdowns.
  @GET('/countdowns/')
  Future<List<UserCountdown>> listCountdowns({@Query('is_active') bool? isActive});

  /// Create a new countdown.
  @POST('/countdowns/')
  Future<UserCountdown> createCountdown(@Body() dynamic data);

  /// Get a single countdown.
  @GET('/countdowns/{id}/')
  Future<UserCountdown> getCountdown(@Path('id') String id);

  /// Update a countdown.
  @PATCH('/countdowns/{id}/')
  Future<UserCountdown> updateCountdown(
    @Path('id') String id,
    @Body() dynamic data,
  );

  /// Delete a countdown.
  @DELETE('/countdowns/{id}/')
  Future<void> deleteCountdown(@Path('id') String id);

  /// Manual check-in: advance a manual countdown by one unit.
  @POST('/countdowns/{id}/checkin/')
  Future<UserCountdown> checkIn(@Path('id') String id);

  /// Reset a countdown to zero.
  @POST('/countdowns/{id}/reset/')
  Future<UserCountdown> reset(@Path('id') String id);

  /// Server endpoint for automatic signals to advance a countdown.
  @POST('/countdowns/auto-advance/')
  Future<dynamic> autoAdvance(@Body() dynamic data);
}
