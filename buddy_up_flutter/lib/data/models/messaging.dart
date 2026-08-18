import 'package:freezed_annotation/freezed_annotation.dart';

part 'messaging.freezed.dart';
part 'messaging.g.dart';

@freezed
abstract class ParticipantData with _$ParticipantData {
  const factory ParticipantData({
    required String userId,
    required String username,
    required String displayName,
    required String avatarUrl,
    @Default('none') String verificationStatus,
    @Default('') String role,
  }) = _ParticipantData;

  factory ParticipantData.fromJson(Map<String, dynamic> json) =>
      _$ParticipantDataFromJson(json);
}

@freezed
abstract class LastMessageData with _$LastMessageData {
  const factory LastMessageData({
    @Default('') String body,
    @Default('text') String messageType,
    @Default('') String mediaUrl,
    @Default('') String senderName,
  }) = _LastMessageData;

  factory LastMessageData.fromJson(Map<String, dynamic> json) =>
      _$LastMessageDataFromJson(json);
}

@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    @Default(false) bool isGroup,
    @Default(false) bool isCommunity,
    @Default('') String groupName,
    @Default('') String groupAvatarUrl,
    String? groupGymId,
    @Default('') String subChannel,
    @Default(false) bool callInProgress,
    @Default('') String description,
    @Default('') String coverUrl,
    @Default('') String inviteCode,
    @Default(false) bool isPublic,
    @Default(<ParticipantData>[]) List<ParticipantData> participantsData,
    @Default(0) int unreadCount,
    String? membershipRole,
    LastMessageData? lastMessage,
    String? lastMessageAt,
    required String createdAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
abstract class CommunityMember with _$CommunityMember {
  const factory CommunityMember({
    required String userId,
    required String username,
    required String displayName,
    @Default('') String avatarUrl,
    @Default('none') String verificationStatus,
    @Default('member') String role,
    required String createdAt,
  }) = _CommunityMember;

  factory CommunityMember.fromJson(Map<String, dynamic> json) =>
      _$CommunityMemberFromJson(json);
}

@freezed
abstract class CommunityPostComment with _$CommunityPostComment {
  const factory CommunityPostComment({
    required String id,
    required String postId,
    required String body,
    String? replyToId,
    @Default(0) int replyCount,
    required ProfileBrief authorData,
    required String createdAt,
  }) = _CommunityPostComment;

  factory CommunityPostComment.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostCommentFromJson(json);
}

@freezed
abstract class ProfileBrief with _$ProfileBrief {
  const factory ProfileBrief({
    required String userId,
    required String username,
    required String displayName,
    @Default('') String avatarUrl,
    @Default('') String role,
  }) = _ProfileBrief;

  factory ProfileBrief.fromJson(Map<String, dynamic> json) =>
      _$ProfileBriefFromJson(json);
}

@freezed
abstract class CommunityPost with _$CommunityPost {
  const factory CommunityPost({
    required String id,
    required String conversationId,
    required String authorId,
    @Default('') String body,
    @Default('') String mediaUrl,
    @Default('') String mediaMime,
    @Default(false) bool isPinned,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    required ProfileBrief authorData,
    @Default(false) bool isLiked,
    @Default(<CommunityPostComment>[]) List<CommunityPostComment> comments,
    required String createdAt,
  }) = _CommunityPost;

  factory CommunityPost.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostFromJson(json);
}

@freezed
abstract class CommunityListData with _$CommunityListData {
  const factory CommunityListData({
    @Default(<Conversation>[]) List<Conversation> mine,
    @Default(<Conversation>[]) List<Conversation> discover,
  }) = _CommunityListData;

  factory CommunityListData.fromJson(Map<String, dynamic> json) =>
      _$CommunityListDataFromJson(json);
}

@freezed
abstract class CommunityDetail with _$CommunityDetail {
  const factory CommunityDetail({
    required String id,
    @Default(false) bool isGroup,
    @Default(true) bool isCommunity,
    @Default('') String groupName,
    @Default('') String groupAvatarUrl,
    String? groupGymId,
    @Default('') String subChannel,
    @Default(false) bool callInProgress,
    @Default('') String description,
    @Default('') String coverUrl,
    @Default('') String inviteCode,
    @Default(false) bool isPublic,
    String? membershipRole,
    String? myRole,
    @Default(0) int memberCount,
    @Default(<ParticipantData>[]) List<ParticipantData> participantsData,
    @Default(<CommunityMember>[]) List<CommunityMember> members,
    @Default(0) int unreadCount,
    LastMessageData? lastMessage,
    String? lastMessageAt,
    required String createdAt,
  }) = _CommunityDetail;

  factory CommunityDetail.fromJson(Map<String, dynamic> json) =>
      _$CommunityDetailFromJson(json);
}

@freezed
abstract class ReplyData with _$ReplyData {
  const factory ReplyData({
    required String id,
    @Default('') String body,
    @Default('') String senderName,
    @Default('text') String messageType,
    @Default('') String mediaUrl,
  }) = _ReplyData;

  factory ReplyData.fromJson(Map<String, dynamic> json) =>
      _$ReplyDataFromJson(json);
}

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    @Default('text') String messageType,
    @Default('') String body,
    @Default('') String mediaUrl,
    @Default('') String mediaMime,
    @Default('') String fileName,
    String? replyToId,
    @Default(<String, dynamic>{}) Map<String, dynamic> metadata,
    @Default(false) bool isRead,
    @Default(<String>[]) List<String> deletedFor,
    required ParticipantData senderData,
    ReplyData? replyData,
    @Default(<String, int>{}) Map<String, int> reactions,
    required String createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}

@freezed
abstract class CallLog with _$CallLog {
  const factory CallLog({
    required String id,
    required String conversationId,
    @Default('audio') String callType,
    @Default('') String status,
    @Default(0) int durationSeconds,
    required Map<String, dynamic> callerData,
    required Map<String, dynamic> calleeData,
    required String createdAt,
    String? endedAt,
  }) = _CallLog;

  factory CallLog.fromJson(Map<String, dynamic> json) => _$CallLogFromJson(json);
}

@freezed
abstract class LinkPreviewData with _$LinkPreviewData {
  const factory LinkPreviewData({
    required String url,
    @Default('') String title,
    @Default('') String description,
    @Default('') String image,
    @Default('') String domain,
  }) = _LinkPreviewData;

  factory LinkPreviewData.fromJson(Map<String, dynamic> json) =>
      _$LinkPreviewDataFromJson(json);
}

@freezed
abstract class PendingCall with _$PendingCall {
  const factory PendingCall({
    required String conversationId,
    required String fromUserId,
    required String fromUsername,
    required String fromDisplayName,
    required String fromAvatarUrl,
    @Default('audio') String callType,
    @Default(<String, dynamic>{}) Map<String, dynamic> data,
  }) = _PendingCall;

  factory PendingCall.fromJson(Map<String, dynamic> json) =>
      _$PendingCallFromJson(json);
}

@freezed
abstract class SendMessagePayload with _$SendMessagePayload {
  const factory SendMessagePayload({
    @Default('text') String messageType,
    String? body,
    String? mediaUrl,
    String? mediaMime,
    String? fileName,
    String? replyToId,
    @Default(<String, dynamic>{}) Map<String, dynamic> metadata,
  }) = _SendMessagePayload;

  factory SendMessagePayload.fromJson(Map<String, dynamic> json) =>
      _$SendMessagePayloadFromJson(json);
}

@freezed
abstract class ForwardPayload with _$ForwardPayload {
  const factory ForwardPayload({
    required String conversationId,
  }) = _ForwardPayload;

  factory ForwardPayload.fromJson(Map<String, dynamic> json) =>
      _$ForwardPayloadFromJson(json);
}

@freezed
abstract class MessageReactionPayload with _$MessageReactionPayload {
  const factory MessageReactionPayload({
    required String emoji,
  }) = _MessageReactionPayload;

  factory MessageReactionPayload.fromJson(Map<String, dynamic> json) =>
      _$MessageReactionPayloadFromJson(json);
}

@freezed
sealed class ChatEvent with _$ChatEvent {
  const factory ChatEvent.message({
    required Map<String, dynamic> data,
  }) = ChatEventMessage;

  const factory ChatEvent.typingStart({
    required String userId,
    required String username,
    required String displayName,
    required String avatarUrl,
  }) = ChatEventTypingStart;

  const factory ChatEvent.typingStop({
    required String userId,
    required String username,
  }) = ChatEventTypingStop;

  const factory ChatEvent.read({
    required String conversationId,
    required String readerId,
    String? messageId,
    @Default(0) int count,
  }) = ChatEventRead;

  const factory ChatEvent.react({
    required String conversationId,
    required String messageId,
    @Default(<String, int>{}) Map<String, int> reactions,
  }) = ChatEventReact;

  const factory ChatEvent.callOffer({
    required String callType,
    required Map<String, dynamic> data,
  }) = ChatEventCallOffer;

  const factory ChatEvent.callAnswer({
    required String callType,
    required Map<String, dynamic> data,
  }) = ChatEventCallAnswer;

  const factory ChatEvent.callIce({
    required Map<String, dynamic> data,
  }) = ChatEventCallIce;

  const factory ChatEvent.callEnd() = ChatEventCallEnd;

  const factory ChatEvent.callDecline() = ChatEventCallDecline;

  const factory ChatEvent.callRinging({
    required Map<String, dynamic> data,
  }) = ChatEventCallRinging;

  factory ChatEvent.fromJson(Map<String, dynamic> json) =>
      _$ChatEventFromJson(json);
}
