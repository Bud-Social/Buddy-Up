import 'package:freezed_annotation/freezed_annotation.dart';

part 'messaging.freezed.dart';
part 'messaging.g.dart';

// Field names below are the DRF `Meta.fields` of the matching serializer —
// snake_case on the wire. Every key is annotated because the camelCase Dart
// name never matches the payload, and an unannotated *required* field throws
// on real data instead of quietly defaulting.

@freezed
abstract class ParticipantData with _$ParticipantData {
  const factory ParticipantData({
    // MessageSerializer.get_sender_data omits the id, so this must default.
    @JsonKey(name: 'user_id') @Default('') String userId,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') @Default('') String avatarUrl,
    @JsonKey(name: 'verification_status') @Default('none') String verificationStatus,
    @Default('') String role,
  }) = _ParticipantData;

  factory ParticipantData.fromJson(Map<String, dynamic> json) =>
      _$ParticipantDataFromJson(json);
}

@freezed
abstract class LastMessageData with _$LastMessageData {
  const factory LastMessageData({
    @Default('') String body,
    @JsonKey(name: 'message_type') @Default('text') String messageType,
    @JsonKey(name: 'media_url') @Default('') String mediaUrl,
    @JsonKey(name: 'sender_name') @Default('') String senderName,
  }) = _LastMessageData;

  factory LastMessageData.fromJson(Map<String, dynamic> json) =>
      _$LastMessageDataFromJson(json);
}

@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    @JsonKey(name: 'is_group') @Default(false) bool isGroup,
    @JsonKey(name: 'is_community') @Default(false) bool isCommunity,
    @JsonKey(name: 'group_name') @Default('') String groupName,
    @JsonKey(name: 'group_avatar_url') @Default('') String groupAvatarUrl,
    @JsonKey(name: 'group_gym_id') String? groupGymId,
    @JsonKey(name: 'sub_channel') @Default('') String subChannel,
    @JsonKey(name: 'call_in_progress') @Default(false) bool callInProgress,
    @Default('') String description,
    @JsonKey(name: 'cover_url') @Default('') String coverUrl,
    @JsonKey(name: 'invite_code') @Default('') String inviteCode,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    @JsonKey(name: 'participants_data')
    @Default(<ParticipantData>[]) List<ParticipantData> participantsData,
    /// Roster size. Always exposed — it is the only member signal a non-member
    /// gets, because `participants_data` comes back empty for them. Never infer
    /// the count from `participantsData.length`.
    @JsonKey(name: 'member_count') @Default(0) int memberCount,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    @JsonKey(name: 'membership_role') String? membershipRole,
    @JsonKey(name: 'last_message') LastMessageData? lastMessage,
    @JsonKey(name: 'last_message_at') String? lastMessageAt,
    /// Where the thread came from: 'direct' | 'discovery' | 'buddy' |
    /// 'group' | 'community'.
    @Default('direct') String origin,
    /// Set once the thread has been promoted to a buddy relationship.
    @JsonKey(name: 'promoted_at') String? promotedAt,
    /// Whether the viewer may still turn this DM into a buddy relationship.
    @Default(false) bool promotable,
    /// Pending | accepted | declined — null when no promotion was ever asked for.
    @JsonKey(name: 'promotion_status') String? promotionStatus,
    @JsonKey(name: 'created_at') @Default('') String createdAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
abstract class CommunityMember with _$CommunityMember {
  const factory CommunityMember({
    @JsonKey(name: 'user_id') @Default('') String userId,
    @Default('') String username,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    @JsonKey(name: 'avatar_url') @Default('') String avatarUrl,
    @JsonKey(name: 'verification_status') @Default('none') String verificationStatus,
    @Default('member') String role,
    @JsonKey(name: 'created_at') @Default('') String createdAt,
  }) = _CommunityMember;

  factory CommunityMember.fromJson(Map<String, dynamic> json) =>
      _$CommunityMemberFromJson(json);
}

@freezed
abstract class CommunityPostComment with _$CommunityPostComment {
  const factory CommunityPostComment({
    required String id,
    @JsonKey(name: 'post_id') @Default('') String postId,
    @Default('') String body,
    @JsonKey(name: 'reply_to_id') String? replyToId,
    @JsonKey(name: 'reply_count') @Default(0) int replyCount,
    @JsonKey(name: 'author_data')
    @Default(ProfileBrief())
    ProfileBrief authorData,
    @JsonKey(name: 'created_at') @Default('') String createdAt,
  }) = _CommunityPostComment;

  factory CommunityPostComment.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostCommentFromJson(json);
}

/// The `author_data` of a community post or comment. The post serializer also
/// sends `role`; the comment serializer does not, so it defaults to ''.
@freezed
abstract class ProfileBrief with _$ProfileBrief {
  const factory ProfileBrief({
    @JsonKey(name: 'user_id') @Default('') String userId,
    @Default('') String username,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    @JsonKey(name: 'avatar_url') @Default('') String avatarUrl,
    @Default('') String role,
  }) = _ProfileBrief;

  factory ProfileBrief.fromJson(Map<String, dynamic> json) =>
      _$ProfileBriefFromJson(json);
}

@freezed
abstract class CommunityPost with _$CommunityPost {
  const factory CommunityPost({
    required String id,
    @JsonKey(name: 'conversation_id') @Default('') String conversationId,
    @JsonKey(name: 'author_id') @Default('') String authorId,
    @Default('') String body,
    @JsonKey(name: 'media_url') @Default('') String mediaUrl,
    @JsonKey(name: 'media_mime') @Default('') String mediaMime,
    @JsonKey(name: 'is_pinned') @Default(false) bool isPinned,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'author_data')
    @Default(ProfileBrief())
    ProfileBrief authorData,
    @JsonKey(name: 'is_liked') @Default(false) bool isLiked,
    /// `null` unless the request passed `include_comments`, so the default has
    /// to swallow an explicit null rather than throw.
    @Default(<CommunityPostComment>[]) List<CommunityPostComment> comments,
    @JsonKey(name: 'created_at') @Default('') String createdAt,
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

/// `ConversationDetailView` response: the full `ConversationSerializer` row
/// plus the three keys that view bolts on. `members`, `member_count` and
/// `my_role` only exist on GET detail — create/join/leave return the bare
/// conversation — so all three have to default.
@freezed
abstract class CommunityDetail with _$CommunityDetail {
  const factory CommunityDetail({
    required String id,
    @JsonKey(name: 'is_group') @Default(false) bool isGroup,
    @JsonKey(name: 'is_community') @Default(true) bool isCommunity,
    @JsonKey(name: 'group_name') @Default('') String groupName,
    @JsonKey(name: 'group_avatar_url') @Default('') String groupAvatarUrl,
    @JsonKey(name: 'group_gym_id') String? groupGymId,
    @JsonKey(name: 'sub_channel') @Default('') String subChannel,
    @JsonKey(name: 'call_in_progress') @Default(false) bool callInProgress,
    @Default('') String description,
    @JsonKey(name: 'cover_url') @Default('') String coverUrl,
    @JsonKey(name: 'invite_code') @Default('') String inviteCode,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    @JsonKey(name: 'membership_role') String? membershipRole,
    @JsonKey(name: 'my_role') String? myRole,
    @JsonKey(name: 'member_count') @Default(0) int memberCount,
    @JsonKey(name: 'participants_data')
    @Default(<ParticipantData>[]) List<ParticipantData> participantsData,
    @Default(<CommunityMember>[]) List<CommunityMember> members,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    @JsonKey(name: 'last_message') LastMessageData? lastMessage,
    @JsonKey(name: 'last_message_at') String? lastMessageAt,
    @JsonKey(name: 'created_at') @Default('') String createdAt,
  }) = _CommunityDetail;

  factory CommunityDetail.fromJson(Map<String, dynamic> json) =>
      _$CommunityDetailFromJson(json);
}

@freezed
abstract class ReplyData with _$ReplyData {
  const factory ReplyData({
    required String id,
    @Default('') String body,
    @JsonKey(name: 'sender_name') @Default('') String senderName,
    @JsonKey(name: 'message_type') @Default('text') String messageType,
    @JsonKey(name: 'media_url') @Default('') String mediaUrl,
  }) = _ReplyData;

  factory ReplyData.fromJson(Map<String, dynamic> json) =>
      _$ReplyDataFromJson(json);
}

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'sender_id') required String senderId,
    @JsonKey(name: 'message_type') @Default('text') String messageType,
    @Default('') String body,
    @JsonKey(name: 'media_url') @Default('') String mediaUrl,
    @JsonKey(name: 'media_mime') @Default('') String mediaMime,
    @JsonKey(name: 'file_name') @Default('') String fileName,
    @JsonKey(name: 'reply_to_id') String? replyToId,
    @Default(<String, dynamic>{}) Map<String, dynamic> metadata,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'deleted_for') @Default(<String>[]) List<String> deletedFor,
    @JsonKey(name: 'sender_data') required ParticipantData senderData,
    @JsonKey(name: 'reply_data') ReplyData? replyData,
    @Default(<String, int>{}) Map<String, int> reactions,
    @JsonKey(name: 'created_at') @Default('') String createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}

@freezed
abstract class CallLog with _$CallLog {
  const factory CallLog({
    required String id,
    @JsonKey(name: 'conversation_id') @Default('') String conversationId,
    @JsonKey(name: 'call_type') @Default('audio') String callType,
    @Default('') String status,
    @JsonKey(name: 'duration_seconds') @Default(0) int durationSeconds,
    /// `{username, display_name, avatar_url}` — a computed dict, not a
    /// nested serializer, so it stays a raw map.
    @JsonKey(name: 'caller_data')
    @Default(<String, dynamic>{})
    Map<String, dynamic> callerData,
    @JsonKey(name: 'callee_data')
    @Default(<String, dynamic>{})
    Map<String, dynamic> calleeData,
    @JsonKey(name: 'created_at') @Default('') String createdAt,
    @JsonKey(name: 'ended_at') String? endedAt,
  }) = _CallLog;

  factory CallLog.fromJson(Map<String, dynamic> json) => _$CallLogFromJson(json);
}

/// `LinkPreviewView` returns exactly these five lower-case keys, so the Dart
/// names already match the wire and need no `@JsonKey`. `url` is always
/// present — the view builds the preview dict as a literal that includes it.
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

/// The `incoming_call` notification pushed over the personal user channel by
/// `ConversationCallSessionView` (session start) and the chat consumer's
/// `call_offer` relay (signalling). The session-start variant carries no
/// `data`, hence the default.
@freezed
abstract class PendingCall with _$PendingCall {
  const factory PendingCall({
    @JsonKey(name: 'conversation_id') @Default('') String conversationId,
    @JsonKey(name: 'from_user_id') @Default('') String fromUserId,
    @JsonKey(name: 'from_username') @Default('') String fromUsername,
    @JsonKey(name: 'from_display_name') @Default('') String fromDisplayName,
    @JsonKey(name: 'from_avatar_url') @Default('') String fromAvatarUrl,
    @JsonKey(name: 'call_type') @Default('audio') String callType,
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

  factory ChatEvent.fromJson(Map<String, dynamic> json) =>
      _$ChatEventFromJson(json);
}
