import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'session_repository.g.dart';

@RestApi()
abstract class SessionRepository {
  factory SessionRepository(Dio dio, {String baseUrl}) = _SessionRepository;

  @GET('/sessions/trainers/')
  Future<dynamic> getTrainers(
    @Query('offset') int offset,
    @Query('limit') int limit,
  );

  @GET('/sessions/trainers/{username}/')
  Future<dynamic> getTrainer(@Path('username') String username);

  @GET('/sessions/trainers/{username}/availability/')
  Future<dynamic> getTrainerAvailability(@Path('username') String username);

  @GET('/sessions/trainers/{username}/reviews/')
  Future<dynamic> getTrainerReviews(@Path('username') String username);

  @GET('/sessions/my/')
  Future<dynamic> getMySessions(
    @Query('offset') int offset,
    @Query('limit') int limit,
  );

  @POST('/sessions/book/{username}/')
  Future<dynamic> createBooking(
    @Path('username') String username,
    @Body() Map<String, dynamic> data,
  );

  @GET('/sessions/bookings/{id}/')
  Future<dynamic> getBooking(@Path('id') String bookingId);

  @POST('/sessions/bookings/{id}/review/')
  Future<dynamic> reviewBooking(
    @Path('id') String bookingId,
    @Body() Map<String, dynamic> data,
  );

  @GET('/sessions/my-availability/')
  Future<dynamic> getMyAvailability();

  @POST('/sessions/my-availability/')
  Future<dynamic> createAvailabilitySlot(@Body() Map<String, dynamic> data);

  @PUT('/sessions/my-availability/{id}/')
  Future<dynamic> updateAvailabilitySlot(
    @Path('id') String slotId,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/sessions/my-availability/{id}/')
  Future<void> deleteAvailabilitySlot(@Path('id') String slotId);

  @GET('/sessions/programmes/{pid}/weeks/')
  Future<dynamic> getProgrammeWeeks(@Path('pid') String programmeId);

  @POST('/sessions/programmes/{pid}/enroll/')
  Future<dynamic> enrollProgramme(@Path('pid') String programmeId);

  @POST('/sessions/programmes/{pid}/weeks/{wn}/complete/')
  Future<dynamic> completeWeek(
    @Path('pid') String programmeId,
    @Path('wn') int weekNumber,
  );

  @GET('/sessions/my-enrollments/')
  Future<dynamic> getMyEnrollments();
}
