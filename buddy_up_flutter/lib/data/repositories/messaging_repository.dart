import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'messaging_repository.g.dart';

@RestApi()
abstract class MessagingRepository {
  factory MessagingRepository(Dio dio, {String baseUrl}) = _MessagingRepository;

  @GET('/messaging/conversations/')
  Future<dynamic> getConversations();

  @POST('/messaging/conversations/start/')
  Future<dynamic> startConversation(@Body() Map<String, dynamic> body);

  @GET('/messaging/conversations/{id}/')
  Future<dynamic> getConversation(@Path('id') String conversationId);

  @GET('/messaging/conversations/{id}/messages/')
  Future<dynamic> getMessages(
    @Path('id') String conversationId, {
    @Query('before') String? before,
    @Query('attachment_type') String? attachmentType,
  });

  @POST('/messaging/conversations/{id}/messages/')
  Future<dynamic> sendMessage(
    @Path('id') String conversationId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/conversations/{id}/read/')
  Future<dynamic> markRead(@Path('id') String conversationId);

  @POST('/messaging/messages/{mid}/react/')
  Future<dynamic> reactToMessage(
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
  Future<dynamic> uploadAttachment(@Part() Map<String, dynamic> file);

  @GET('/messaging/conversations/{id}/calls/')
  Future<dynamic> getCallLogs(@Path('id') String conversationId);

  @POST('/messaging/conversations/{id}/calls/')
  Future<dynamic> logCall(
    @Path('id') String conversationId,
    @Body() Map<String, dynamic> body,
  );

  // ── Multi-party LiveKit calls ────────────────────────────────────────────
  @POST('/messaging/conversations/{id}/calls/session/')
  Future<dynamic> startOrJoinCallSession(
    @Path('id') String conversationId,
    @Body() Map<String, dynamic> body,
  );

  @GET('/messaging/conversations/{id}/calls/session/')
  Future<dynamic> getActiveCallSession(@Path('id') String conversationId);

  @DELETE('/messaging/conversations/{id}/calls/session/')
  Future<dynamic> leaveCallSession(@Path('id') String conversationId);

  @POST('/messaging/messages/{mid}/forward/')
  Future<dynamic> forwardMessage(
    @Path('mid') String messageId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/link-preview/')
  Future<dynamic> getLinkPreview(@Body() Map<String, dynamic> body);

  // ── Communities ──────────────────────────────────────────────────────────
  @GET('/messaging/communities/')
  Future<dynamic> getCommunities();

  @POST('/messaging/communities/')
  Future<dynamic> createCommunity(@Body() Map<String, dynamic> body);

  @GET('/messaging/communities/{id}/')
  Future<dynamic> getCommunity(@Path('id') String communityId);

  @PATCH('/messaging/communities/{id}/')
  Future<dynamic> updateCommunity(
    @Path('id') String communityId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/communities/join/')
  Future<dynamic> joinCommunityByCode(@Body() Map<String, dynamic> body);

  @POST('/messaging/communities/{id}/join/')
  Future<dynamic> joinCommunity(
    @Path('id') String communityId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/communities/{id}/leave/')
  Future<dynamic> leaveCommunity(@Path('id') String communityId);

  @POST('/messaging/communities/{id}/members/')
  Future<dynamic> addCommunityMembers(
    @Path('id') String communityId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/messaging/communities/{id}/members/{uid}/')
  Future<dynamic> removeCommunityMember(
    @Path('id') String communityId,
    @Path('uid') String userId,
  );

  @PATCH('/messaging/communities/{id}/members/{uid}/role/')
  Future<dynamic> setCommunityRole(
    @Path('id') String communityId,
    @Path('uid') String userId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/communities/{id}/transfer/')
  Future<dynamic> transferCommunityOwnership(
    @Path('id') String communityId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/communities/{id}/invite/')
  Future<dynamic> rotateInviteCode(@Path('id') String communityId);

  @GET('/messaging/communities/{id}/posts/')
  Future<dynamic> getCommunityPosts(
    @Path('id') String communityId, {
    @Query('author_id') String? authorId,
    @Query('pinned') bool? pinned,
  });

  @POST('/messaging/communities/{id}/posts/')
  Future<dynamic> createCommunityPost(
    @Path('id') String communityId,
    @Body() Map<String, dynamic> body,
  );

  @GET('/messaging/communities/{id}/posts/{pid}/')
  Future<dynamic> getCommunityPost(
    @Path('id') String communityId,
    @Path('pid') String postId,
  );

  @PATCH('/messaging/communities/{id}/posts/{pid}/')
  Future<dynamic> updateCommunityPost(
    @Path('id') String communityId,
    @Path('pid') String postId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/messaging/communities/{id}/posts/{pid}/')
  Future<dynamic> deleteCommunityPost(
    @Path('id') String communityId,
    @Path('pid') String postId,
  );

  @POST('/messaging/communities/{id}/posts/{pid}/like/')
  Future<dynamic> togglePostLike(
    @Path('id') String communityId,
    @Path('pid') String postId,
  );

  @GET('/messaging/communities/{id}/posts/{pid}/comments/')
  Future<dynamic> getPostComments(
    @Path('id') String communityId,
    @Path('pid') String postId,
  );

  @POST('/messaging/communities/{id}/posts/{pid}/comments/')
  Future<dynamic> addPostComment(
    @Path('id') String communityId,
    @Path('pid') String postId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/messaging/communities/{id}/posts/{pid}/comments/{cid}/')
  Future<dynamic> deletePostComment(
    @Path('id') String communityId,
    @Path('pid') String postId,
    @Path('cid') String commentId,
  );
}
