import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/gym.dart';

part 'gym_repository.g.dart';

@RestApi()
abstract class GymRepository {
  factory GymRepository(Dio dio, {String baseUrl}) = _GymRepository;

  @GET('/gyms/')
  Future<dynamic> getGyms({
    @Query('q') String? query,
    @Query('category') String? category,
    @Query('my') bool? my,
  });

  @GET('/gyms/{slug}/')
  Future<dynamic> getGym(@Path('slug') String slug);

  @POST('/gyms/create/')
  Future<dynamic> createGym(@Body() CreateGymPayload payload);

  @PATCH('/gyms/{slug}/')
  Future<dynamic> updateGym(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/gyms/{slug}/')
  Future<void> deleteGym(@Path('slug') String slug);

  @POST('/gyms/{slug}/join/')
  Future<dynamic> joinGym(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> body,
  );

  @POST('/gyms/{slug}/leave/')
  Future<void> leaveGym(@Path('slug') String slug);

  @GET('/gyms/{slug}/members/')
  Future<dynamic> getMembers(
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
  Future<dynamic> checkHandle(@Query('candidate') String candidate);

  @GET('/gyms/categories/')
  Future<dynamic> getCategories();

  @GET('/gyms/cities/')
  Future<dynamic> searchCities(@Query('q') String query);

  @GET('/gyms/{slug}/join-requests/')
  Future<dynamic> getJoinRequests(
    @Path('slug') String slug, {
    @Query('status') String? status,
  });

  @PATCH('/gyms/{slug}/join-requests/{requestId}/')
  Future<dynamic> manageJoinRequest(
    @Path('slug') String slug,
    @Path('requestId') String requestId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/gyms/{slug}/invite/')
  Future<dynamic> invite(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> payload,
  );

  @POST('/gyms/{slug}/invites/{inviteId}/{action}/')
  Future<dynamic> respondToInvite(
    @Path('slug') String slug,
    @Path('inviteId') String inviteId,
    @Path('action') String action,
  );

  @GET('/gyms/{slug}/schedule-posts/')
  Future<dynamic> getSchedulePosts(
    @Path('slug') String slug, {
    @Query('page') int? page,
  });

  @POST('/gyms/{slug}/schedule-posts/')
  Future<dynamic> createSchedulePost(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> data,
  );

  @POST('/gyms/{slug}/schedule-posts/{postId}/enroll/')
  Future<dynamic> enrollSlot(
    @Path('slug') String slug,
    @Path('postId') String postId,
  );

  @GET('/gyms/{slug}/my-enrollments/')
  Future<dynamic> getMyEnrollments(@Path('slug') String slug);

  @GET('/gyms/{slug}/reviews/')
  Future<dynamic> getReviews(
    @Path('slug') String slug, {
    @Query('page') int? page,
  });

  @POST('/gyms/{slug}/reviews/')
  Future<dynamic> createReview(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> data,
  );

  @POST('/gyms/{slug}/reviews/{reviewId}/reply/')
  Future<dynamic> replyToReview(
    @Path('slug') String slug,
    @Path('reviewId') String reviewId,
    @Body() Map<String, dynamic> body,
  );

  @GET('/gyms/{slug}/feed/')
  Future<dynamic> getGymFeed(
    @Path('slug') String slug, {
    @Query('page') int? page,
  });

  @POST('/gyms/{slug}/donate/')
  Future<dynamic> donate(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> data,
  );

  @GET('/gyms/{slug}/events/')
  Future<dynamic> getEvents(
    @Path('slug') String slug, {
    @Query('upcoming') bool? upcoming,
  });
}
