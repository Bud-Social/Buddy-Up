import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'messaging_repository.g.dart';

@RestApi()
abstract class MessagingRepository {
  factory MessagingRepository(Dio dio, {String baseUrl}) = _MessagingRepository;

  @GET('/messaging/conversations/')
  Future<Map<String, dynamic>> getConversations();

  @POST('/messaging/conversations/start/')
  Future<Map<String, dynamic>> startConversation(@Body() Map<String, dynamic> body);

  @GET('/messaging/conversations/{id}/')
  Future<Map<String, dynamic>> getConversation(@Path('id') String conversationId);

  @GET('/messaging/conversations/{id}/messages/')
  Future<Map<String, dynamic>> getMessages(
    @Path('id') String conversationId, {
    @Query('before') String? before,
    @Query('attachment_type') String? attachmentType,
  });

  @POST('/messaging/conversations/{id}/messages/')
  Future<Map<String, dynamic>> sendMessage(
    @Path('id') String conversationId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/conversations/{id}/read/')
  Future<Map<String, dynamic>> markRead(@Path('id') String conversationId);

  @POST('/messaging/messages/{mid}/react/')
  Future<Map<String, dynamic>> reactToMessage(
    @Path('mid') String messageId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/messaging/messages/{mid}/delete/')
  Future<void> deleteMessage(
    @Path('mid') String messageId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/upload/')
  @MultiPart()
  Future<Map<String, dynamic>> uploadAttachment(@Part() Map<String, dynamic> file);

  @GET('/messaging/conversations/{id}/calls/')
  Future<Map<String, dynamic>> getCallLogs(@Path('id') String conversationId);

  @POST('/messaging/conversations/{id}/calls/')
  Future<Map<String, dynamic>> logCall(
    @Path('id') String conversationId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/messages/{mid}/forward/')
  Future<Map<String, dynamic>> forwardMessage(
    @Path('mid') String messageId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/link-preview/')
  Future<Map<String, dynamic>> getLinkPreview(@Body() Map<String, dynamic> body);

  // ── Communities ──────────────────────────────────────────────────────────
  @GET('/messaging/communities/')
  Future<Map<String, dynamic>> getCommunities();

  @POST('/messaging/communities/')
  Future<Map<String, dynamic>> createCommunity(@Body() Map<String, dynamic> body);

  @GET('/messaging/communities/{id}/')
  Future<Map<String, dynamic>> getCommunity(@Path('id') String communityId);

  @PATCH('/messaging/communities/{id}/')
  Future<Map<String, dynamic>> updateCommunity(
    @Path('id') String communityId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/communities/join/')
  Future<Map<String, dynamic>> joinCommunityByCode(@Body() Map<String, dynamic> body);

  @POST('/messaging/communities/{id}/join/')
  Future<Map<String, dynamic>> joinCommunity(
    @Path('id') String communityId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/communities/{id}/leave/')
  Future<Map<String, dynamic>> leaveCommunity(@Path('id') String communityId);

  @POST('/messaging/communities/{id}/members/')
  Future<Map<String, dynamic>> addCommunityMembers(
    @Path('id') String communityId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/messaging/communities/{id}/members/{uid}/')
  Future<Map<String, dynamic>> removeCommunityMember(
    @Path('id') String communityId,
    @Path('uid') String userId,
  );

  @PATCH('/messaging/communities/{id}/members/{uid}/role/')
  Future<Map<String, dynamic>> setCommunityRole(
    @Path('id') String communityId,
    @Path('uid') String userId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/communities/{id}/transfer/')
  Future<Map<String, dynamic>> transferCommunityOwnership(
    @Path('id') String communityId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/communities/{id}/invite/')
  Future<Map<String, dynamic>> rotateInviteCode(@Path('id') String communityId);

  @GET('/messaging/communities/{id}/posts/')
  Future<Map<String, dynamic>> getCommunityPosts(
    @Path('id') String communityId, {
    @Query('author_id') String? authorId,
    @Query('pinned') bool? pinned,
  });

  @POST('/messaging/communities/{id}/posts/')
  Future<Map<String, dynamic>> createCommunityPost(
    @Path('id') String communityId,
    @Body() Map<String, dynamic> body,
  );

  @GET('/messaging/communities/{id}/posts/{pid}/')
  Future<Map<String, dynamic>> getCommunityPost(
    @Path('id') String communityId,
    @Path('pid') String postId,
  );

  @PATCH('/messaging/communities/{id}/posts/{pid}/')
  Future<Map<String, dynamic>> updateCommunityPost(
    @Path('id') String communityId,
    @Path('pid') String postId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/messaging/communities/{id}/posts/{pid}/')
  Future<Map<String, dynamic>> deleteCommunityPost(
    @Path('id') String communityId,
    @Path('pid') String postId,
  );

  @POST('/messaging/communities/{id}/posts/{pid}/like/')
  Future<Map<String, dynamic>> togglePostLike(
    @Path('id') String communityId,
    @Path('pid') String postId,
  );

  @GET('/messaging/communities/{id}/posts/{pid}/comments/')
  Future<Map<String, dynamic>> getPostComments(
    @Path('id') String communityId,
    @Path('pid') String postId,
  );

  @POST('/messaging/communities/{id}/posts/{pid}/comments/')
  Future<Map<String, dynamic>> addPostComment(
    @Path('id') String communityId,
    @Path('pid') String postId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/messaging/communities/{id}/posts/{pid}/comments/{cid}/')
  Future<Map<String, dynamic>> deletePostComment(
    @Path('id') String communityId,
    @Path('pid') String postId,
    @Path('cid') String commentId,
  );
}
