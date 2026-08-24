import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/post.dart';

part 'feed_repository.g.dart';

@RestApi()
abstract class FeedRepository {
  factory FeedRepository(Dio dio, {String baseUrl}) = _FeedRepository;

  @GET('/feed/')
  Future<Map<String, dynamic>> getFeed({
    @Query('tab') String? tab,
    @Query('cursor') String? cursor,
    @Query('exclude_post_types') String? excludePostTypes,
  });

  @GET('/feed/{id}/')
  Future<Map<String, dynamic>> getPost(@Path('id') String postId);

  @POST('/feed/create/')
  @MultiPart()
  Future<Map<String, dynamic>> createPost(@Part() Map<String, dynamic> data);

  @DELETE('/feed/{id}/')
  Future<void> deletePost(@Path('id') String postId);

  @POST('/feed/{id}/react/')
  Future<Map<String, dynamic>> react(
    @Path('id') String postId,
    @Body() ReactionInput input,
  );

  @DELETE('/feed/{id}/react/')
  Future<void> unreact(@Path('id') String postId);

  @GET('/feed/{id}/comments/')
  Future<Map<String, dynamic>> getComments(@Path('id') String postId);

  @POST('/feed/{id}/comments/')
  Future<Map<String, dynamic>> addComment(
    @Path('id') String postId,
    @Body() CommentCreateInput input,
  );

  @DELETE('/feed/{id}/comments/{cid}/')
  Future<void> deleteComment(
    @Path('id') String postId,
    @Path('cid') String commentId,
  );

  @POST('/feed/{id}/repost/')
  Future<Map<String, dynamic>> repost(
    @Path('id') String postId,
    @Body() RepostPayload payload,
  );

  @POST('/feed/{id}/save/')
  Future<Map<String, dynamic>> save(
    @Path('id') String postId,
    @Body() SavePayload payload,
  );

  @DELETE('/feed/{id}/save/')
  Future<void> unsave(@Path('id') String postId);

  @POST('/feed/{id}/poll/vote/')
  Future<Map<String, dynamic>> voteOnPoll(
    @Path('id') String postId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/feed/{id}/pin/')
  Future<Map<String, dynamic>> pin(@Path('id') String postId);

  @GET('/feed/saved/')
  Future<Map<String, dynamic>> getSavedPosts({
    @Query('collection') String? collection,
  });

  @GET('/feed/drafts/')
  Future<Map<String, dynamic>> getDrafts();

  @POST('/feed/drafts/')
  Future<Map<String, dynamic>> saveDraft(@Body() Draft draft);

  @DELETE('/feed/drafts/{id}/')
  Future<void> deleteDraft(@Path('id') String draftId);

  @GET('/feed/workout/analyze/')
  Future<Map<String, dynamic>> analyzeWorkout();

  @GET('/feed/health-insights/')
  Future<Map<String, dynamic>> getHealthInsights({
    @Query('period') String? period,
  });

  @POST('/feed/workout-form/')
  @MultiPart()
  Future<Map<String, dynamic>> analyzeWorkoutForm(
    @Part() Map<String, dynamic> data,
  );
}
