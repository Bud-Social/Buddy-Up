import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/gym.dart';

part 'gym_repository.g.dart';

@RestApi()
abstract class GymRepository {
  factory GymRepository(Dio dio, {String baseUrl}) = _GymRepository;

  @GET('/gyms/')
  Future<Map<String, dynamic>> getGyms({
    @Query('q') String? query,
    @Query('category') String? category,
    @Query('my') bool? my,
  });

  @GET('/gyms/{slug}/')
  Future<Map<String, dynamic>> getGym(@Path('slug') String slug);

  @POST('/gyms/create/')
  Future<Map<String, dynamic>> createGym(@Body() CreateGymPayload payload);

  @PATCH('/gyms/{slug}/')
  Future<Map<String, dynamic>> updateGym(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/gyms/{slug}/')
  Future<void> deleteGym(@Path('slug') String slug);

  @POST('/gyms/{slug}/join/')
  Future<Map<String, dynamic>> joinGym(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> body,
  );

  @POST('/gyms/{slug}/leave/')
  Future<void> leaveGym(@Path('slug') String slug);

  @GET('/gyms/{slug}/members/')
  Future<Map<String, dynamic>> getMembers(
    @Path('slug') String slug, {
    @Query('role') String? role,
    @Query('q') String? query,
  });

  @POST('/gyms/{slug}/members/{userId}/')
  Future<void> manageMember(
    @Path('slug') String slug,
    @Path('userId') String userId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/gyms/{slug}/members/{userId}/')
  Future<void> removeMember(
    @Path('slug') String slug,
    @Path('userId') String userId,
  );

  @GET('/gyms/check-handle/')
  Future<Map<String, dynamic>> checkHandle(@Query('candidate') String candidate);

  @GET('/gyms/categories/')
  Future<Map<String, dynamic>> getCategories();

  @GET('/gyms/cities/')
  Future<Map<String, dynamic>> searchCities(@Query('q') String query);

  @GET('/gyms/{slug}/join-requests/')
  Future<Map<String, dynamic>> getJoinRequests(
    @Path('slug') String slug, {
    @Query('status') String? status,
  });

  @PATCH('/gyms/{slug}/join-requests/{requestId}/')
  Future<Map<String, dynamic>> manageJoinRequest(
    @Path('slug') String slug,
    @Path('requestId') String requestId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/gyms/{slug}/invite/')
  Future<Map<String, dynamic>> invite(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> payload,
  );

  @POST('/gyms/{slug}/invites/{inviteId}/{action}/')
  Future<Map<String, dynamic>> respondToInvite(
    @Path('slug') String slug,
    @Path('inviteId') String inviteId,
    @Path('action') String action,
  );

  @GET('/gyms/{slug}/schedule-posts/')
  Future<Map<String, dynamic>> getSchedulePosts(
    @Path('slug') String slug, {
    @Query('page') int? page,
  });

  @POST('/gyms/{slug}/schedule-posts/')
  Future<Map<String, dynamic>> createSchedulePost(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> data,
  );

  @POST('/gyms/{slug}/schedule-posts/{postId}/enroll/')
  Future<Map<String, dynamic>> enrollSlot(
    @Path('slug') String slug,
    @Path('postId') String postId,
  );

  @GET('/gyms/{slug}/my-enrollments/')
  Future<Map<String, dynamic>> getMyEnrollments(@Path('slug') String slug);

  @GET('/gyms/{slug}/reviews/')
  Future<Map<String, dynamic>> getReviews(
    @Path('slug') String slug, {
    @Query('page') int? page,
  });

  @POST('/gyms/{slug}/reviews/')
  Future<Map<String, dynamic>> createReview(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> data,
  );

  @POST('/gyms/{slug}/reviews/{reviewId}/reply/')
  Future<Map<String, dynamic>> replyToReview(
    @Path('slug') String slug,
    @Path('reviewId') String reviewId,
    @Body() Map<String, dynamic> body,
  );

  @GET('/gyms/{slug}/feed/')
  Future<Map<String, dynamic>> getGymFeed(
    @Path('slug') String slug, {
    @Query('page') int? page,
  });

  @POST('/gyms/{slug}/donate/')
  Future<Map<String, dynamic>> donate(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> data,
  );

  @GET('/gyms/{slug}/events/')
  Future<Map<String, dynamic>> getEvents(
    @Path('slug') String slug, {
    @Query('upcoming') bool? upcoming,
  });
}
