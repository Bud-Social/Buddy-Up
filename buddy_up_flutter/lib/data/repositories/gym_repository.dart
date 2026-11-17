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
    @Query('city') String? city,
    @Query('verified') bool? verified,
    @Query('delivery') String? delivery,
    @Query('lat') double? lat,
    @Query('lng') double? lng,
    @Query('radius_km') double? radiusKm,
    @Query('ordering') String? ordering,
  });

  @GET('/gyms/{slug}/')
  Future<dynamic> getGym(@Path('slug') String slug);

  /// Respond to a pending "would you like to be listed as a coach?" invite.
  /// The gym sends this notification when they add you as an online coach;
  /// accepting makes your membership a `trainer` role and flips the coach
  /// row to `active`, which is what surfaces the coach badge on the member
  /// list and the Online Coaching tab.
  @POST('/gyms/{slug}/online-coaches/{coach_id}/respond/')
  Future<dynamic> respondCoachInvite(
    @Path('slug') String slug,
    @Path('coach_id') String coachId,
    @Body() Map<String, dynamic> body,
  );

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

  /// Append-only audit trail. Moderator/owner/co-owner only upstream; every
  /// row is a state delta from a privileged action inside the gym.
  @GET('/gyms/{slug}/action-logs/')
  Future<dynamic> getActionLogs(
    @Path('slug') String slug, {
    @Query('action') String? action,
    @Query('limit') int? limit,
  });

  /// Operator-facing analytics. Partner-only upstream (owner / co-owner /
  /// moderator); every figure carries its own window because there is no
  /// ambient "current period" to inherit. See `PartnerMetricsView`.
  @GET('/gyms/{slug}/partner-metrics/')
  Future<dynamic> getPartnerMetrics(@Path('slug') String slug);

  /// Bookings on gym-connected coaches + door check-ins.
  @GET('/gyms/{slug}/sessions/')
  Future<dynamic> getGymSessions(@Path('slug') String slug);

  /// Gym inbox: community chats, gym group chats and member DMs.
  @GET('/gyms/{slug}/messages/')
  Future<dynamic> getGymMessages(@Path('slug') String slug);

  /// Communities linked to (or discoverable for) this gym.
  @GET('/gyms/{slug}/communities/')
  Future<dynamic> getGymCommunities(@Path('slug') String slug);

  /// Create a gym-formed community, or link/join one by `community_id`.
  @POST('/gyms/{slug}/communities/')
  Future<dynamic> manageGymCommunity(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> body,
  );

  /// Unlink a community from the gym (the community itself stays).
  @DELETE('/gyms/{slug}/communities/')
  Future<dynamic> unlinkGymCommunity(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> body,
  );

  /// Rich analytics: KPIs, growth deltas, 30-day series, share card.
  @GET('/gyms/{slug}/analytics/')
  Future<dynamic> getGymAnalytics(@Path('slug') String slug);

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
