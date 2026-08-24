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
  Future<OnboardingPlan> saveOnboarding(@Body() OnboardingPayload payload);

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

  @POST('/profiles/{username}/block/')
  Future<void> blockUser(@Path('username') String username);

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
}
