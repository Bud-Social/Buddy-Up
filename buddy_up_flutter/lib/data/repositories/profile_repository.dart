import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/profile.dart';
import '../models/buddy.dart';
import '../models/onboarding.dart';

part 'profile_repository.g.dart';

@RestApi()
abstract class ProfileRepository {
  factory ProfileRepository(Dio dio, {String baseUrl}) = _ProfileRepository;

  @GET('/profiles/me/')
  Future<Profile> getMyProfile();

  @PATCH('/profiles/me/')
  Future<Profile> updateProfile(@Body() ProfileUpdatePayload payload);

  @POST('/profiles/me/avatar/')
  Future<dynamic> uploadAvatar(@Body() FormData formData);

  @POST('/profiles/me/cover/')
  Future<dynamic> uploadCover(@Body() FormData formData);

  @GET('/profiles/search/')
  Future<dynamic> searchProfiles(
    @Query('q') String query,
    @Query('role') String? role,
    @Query('page') int? page,
  );

  @GET('/profiles/onboarding/')
  Future<OnboardingData> getOnboarding();

  @POST('/profiles/onboarding/')
  Future<dynamic> saveOnboarding(@Body() OnboardingPayload payload);

  @GET('/profiles/{username}/')
  Future<Profile> getProfile(@Path('username') String username);

  @GET('/profiles/{username}/posts/')
  Future<dynamic> getUserPosts(
    @Path('username') String username,
    @Query('page') int? page,
  );

  @POST('/profiles/{username}/buddy/')
  Future<void> sendBuddyRequest(@Path('username') String username);

  @POST('/profiles/{username}/buddy/accept/')
  Future<void> acceptBuddyRequest(@Path('username') String username);

  @POST('/profiles/{username}/buddy/decline/')
  Future<void> declineBuddyRequest(@Path('username') String username);

  @POST('/profiles/{username}/follow/')
  Future<void> followUser(@Path('username') String username);

  @DELETE('/profiles/{username}/follow/')
  Future<void> unfollowUser(@Path('username') String username);

  @POST('/profiles/{username}/block/')
  Future<void> blockUser(@Path('username') String username);

  @DELETE('/profiles/{username}/block/')
  Future<void> unblockUser(@Path('username') String username);

  @POST('/profiles/{username}/ping/')
  Future<void> pingUser(
    @Path('username') String username,
    @Body() PingPayload payload,
  );

  @GET('/profiles/{username}/buddies/')
  Future<dynamic> getBuddies(@Path('username') String username);

  @GET('/profiles/{username}/followers/')
  Future<dynamic> getFollowers(
    @Path('username') String username,
    @Query('page') int? page,
  );

  @GET('/profiles/{username}/following/')
  Future<dynamic> getFollowing(
    @Path('username') String username,
    @Query('page') int? page,
  );

  @GET('/profiles/blocked/')
  Future<dynamic> getBlockedList();

  @GET('/profiles/pending-requests/')
  Future<dynamic> getPendingBuddyRequests();

  @GET('/profiles/recommendations/')
  Future<dynamic> getBuddyRecommendations();

  @GET('/profiles/discover/trending/')
  Future<dynamic> getDiscoverTrending();

  @GET('/profiles/me/search-profile/')
  Future<dynamic> getSearchProfile();

  /// Buddy-search card for someone else. [lat]/[lng] are the *viewer's*
  /// coordinates — the server never discloses another user's location, it
  /// only bands a `distance_km` when both are passed.
  @GET('/profiles/{username}/search-profile/')
  Future<dynamic> getUserSearchProfile(
    @Path('username') String username, {
    @Query('lat') double? lat,
    @Query('lng') double? lng,
  });

  /// One-way buddy interest ("like"). POST creates, DELETE removes; both
  /// answer `{liked, username, liked_me}` — `liked_me` is the back-signal
  /// (has the target already liked me?). 400 on self-like, a block either
  /// way, or a target with no open search profile.
  @POST('/profiles/{username}/interest/')
  Future<dynamic> likeInterest(@Path('username') String username);

  @DELETE('/profiles/{username}/interest/')
  Future<dynamic> unlikeInterest(@Path('username') String username);

  /// Everyone who liked me (`received`) and everyone I liked (`sent`).
  @GET('/profiles/interests/')
  Future<dynamic> getInterests();

  /// Moderation report. [reason] must be one of the backend
  /// ModerationReport.REPORT_REASONS values (spam, harassment, hate_speech,
  /// nudity, adult_ungated, violence, misinformation, impersonation, other).
  @POST('/moderation/reports/')
  Future<dynamic> submitModerationReport(@Body() Map<String, dynamic> body);

  @PUT('/profiles/me/search-profile/')
  Future<dynamic> updateSearchProfile(@Body() Map<String, dynamic> body);

  @GET('/profiles/buddies/nearby/')
  Future<dynamic> getNearbyBuddies({
    @Query('intent') String? intent,
    @Query('mode') String? mode,
    @Query('lat') double? lat,
    @Query('lng') double? lng,
    @Query('radius_km') double? radiusKm,
    @Query('now') bool? now,
  });
}
