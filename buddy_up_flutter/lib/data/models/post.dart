import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
abstract class AuthorData with _$AuthorData {
  const factory AuthorData({
    String? userId,
    required String username,
    required String displayName,
    required String avatarUrl,
    @Default('none') String verificationStatus,
  }) = _AuthorData;

  factory AuthorData.fromJson(Map<String, dynamic> json) =>
      _$AuthorDataFromJson(json);
}

@freezed
abstract class PollOption with _$PollOption {
  const factory PollOption({
    required String id,
    required String text,
    @Default(0) int order,
    @Default(0) int voteCount,
    @Default(false) bool userVoted,
  }) = _PollOption;

  factory PollOption.fromJson(Map<String, dynamic> json) =>
      _$PollOptionFromJson(json);
}

@freezed
abstract class Poll with _$Poll {
  const factory Poll({
    required String id,
    required String question,
    String? closesAt,
    @Default(false) bool allowMultiple,
    @Default(0) int totalVotes,
    @Default(false) bool isClosed,
    required List<PollOption> options,
    @Default(<String>[]) List<String> userVotedOptionIds,
  }) = _Poll;

  factory Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);
}

@freezed
abstract class OriginalPostData with _$OriginalPostData {
  const factory OriginalPostData({
    required String id,
    required AuthorData authorData,
    required String body,
    @Default(<String>[]) List<String> mediaUrls,
    @Default('text') String postType,
    String? locationLabel,
    Map<String, dynamic>? workoutLogData,
    Map<String, dynamic>? mealData,
    Map<String, dynamic>? progressData,
    Poll? poll,
    @Default(0) int commentCount,
    String? gymTagName,
    required String createdAt,
  }) = _OriginalPostData;

  factory OriginalPostData.fromJson(Map<String, dynamic> json) =>
      _$OriginalPostDataFromJson(json);
}

@freezed
abstract class Post with _$Post {
  const factory Post({
    required String id,
    required AuthorData authorData,
    @Default('text') String postType,
    @Default('') String body,
    @Default(false) bool isAnonymous,
    @Default(<String>[]) List<String> mediaUrls,
    @Default(<String>[]) List<String> tags,
    Map<String, dynamic>? workoutLogData,
    Map<String, dynamic>? mealData,
    Map<String, dynamic>? progressData,
    @Default('') String locationLabel,
    @Default(0) int viewCount,
    @Default(<String, int>{}) Map<String, int> reactionCounts,
    String? userReaction,
    @Default(0) int commentCount,
    @Default(0) int repostCount,
    @Default(false) bool isRepost,
    String? originalPostId,
    @Default('') String quoteBody,
    @Default(false) bool isSaved,
    @Default(false) bool isPinned,
    @Default('public') String visibility,
    @Default('clean') String moderationStatus,
    String? gymTagId,
    String? gymTagName,
    Poll? poll,
    OriginalPostData? originalPostData,
    required String createdAt,
    String? updatedAt,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String postId,
    required AuthorData authorData,
    required String body,
    String? parentId,
    @Default(false) bool isAnonymous,
    @Default(0) int replyCount,
    @Default(<String, int>{}) Map<String, int> reactionCounts,
    String? userReaction,
    required String createdAt,
    String? updatedAt,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
}

@freezed
abstract class FeedFilter with _$FeedFilter {
  const factory FeedFilter({
    @Default('for_you') String tab,
    String? cursor,
  }) = _FeedFilter;

  factory FeedFilter.fromJson(Map<String, dynamic> json) =>
      _$FeedFilterFromJson(json);
}

@freezed
abstract class CreatePostPayload with _$CreatePostPayload {
  const factory CreatePostPayload({
    required String postType,
    String? body,
    @Default('public') String visibility,
    String? gymTag,
    String? locationLabel,
    @Default(<String>[]) List<String> mediaUrls,
    @Default(<String>[]) List<String> tags,
    @Default(false) bool isAnonymous,
    String? pollQuestion,
    @Default(<String>[]) List<String> pollOptions,
    String? pollClosesAt,
    @Default(false) bool pollAllowMultiple,
    @Default(<String>[]) List<String> mentionedUsers,
  }) = _CreatePostPayload;

  factory CreatePostPayload.fromJson(Map<String, dynamic> json) =>
      _$CreatePostPayloadFromJson(json);
}

@freezed
abstract class ReactionInput with _$ReactionInput {
  const factory ReactionInput({
    required String reactionType,
  }) = _ReactionInput;

  factory ReactionInput.fromJson(Map<String, dynamic> json) =>
      _$ReactionInputFromJson(json);
}

@freezed
abstract class CommentCreateInput with _$CommentCreateInput {
  const factory CommentCreateInput({
    required String body,
    String? parentId,
    @Default(false) bool isAnonymous,
  }) = _CommentCreateInput;

  factory CommentCreateInput.fromJson(Map<String, dynamic> json) =>
      _$CommentCreateInputFromJson(json);
}

@freezed
abstract class RepostPayload with _$RepostPayload {
  const factory RepostPayload({
    @Default('') String quoteBody,
  }) = _RepostPayload;

  factory RepostPayload.fromJson(Map<String, dynamic> json) =>
      _$RepostPayloadFromJson(json);
}

@freezed
abstract class SavePayload with _$SavePayload {
  const factory SavePayload({
    String? collection,
  }) = _SavePayload;

  factory SavePayload.fromJson(Map<String, dynamic> json) =>
      _$SavePayloadFromJson(json);
}

@freezed
abstract class Draft with _$Draft {
  const factory Draft({
    String? id,
    @Default('text') String postType,
    @Default('') String body,
    @Default('public') String visibility,
    String? gymTag,
    String? locationLabel,
    @Default(<String>[]) List<String> mediaUrls,
    @Default(<String>[]) List<String> tags,
    @Default('') String pollQuestion,
    @Default(<String>[]) List<String> pollOptions,
    @Default(false) bool pollAllowMultiple,
    @Default(<String>[]) List<String> mentionedUserIds,
    @Default(false) bool isAnonymous,
  }) = _Draft;

  factory Draft.fromJson(Map<String, dynamic> json) => _$DraftFromJson(json);
}
