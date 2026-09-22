import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

Map<String, dynamic>? _readAiAnalysis(Map<dynamic, dynamic> json, String? key) {
  final value = json['ai_analysis'] ?? json['aiAnalysis'];
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return null;
}

bool _readCommentsDisabled(Map<dynamic, dynamic> json, String key) {
  final value = json['comments_disabled'] ?? json['commentsDisabled'];
  return value == true || value == 'true' || value == 1 || value == '1';
}

/// Normalises backend keys so generated parsers can stay camelCase while the
/// API contract uses snake_case (`media_type`, `poster_url`, `duration_ms`…).
Map<String, dynamic> _normalizeMediaJson(Map<dynamic, dynamic> json) {
  final map = Map<String, dynamic>.from(json);
  const aliases = <String, String>{
    'media_type': 'mediaType',
    'poster_url': 'posterUrl',
    'duration_ms': 'durationMs',
    'trim_start_ms': 'trimStartMs',
    'trim_end_ms': 'trimEndMs',
    'sound_id': 'soundId',
    'sound_volume': 'soundVolume',
    'sound_audio_url': 'soundAudioUrl',
    'edit_meta': 'editMeta',
    'alt_text': 'altText',
    'start_ms': 'startMs',
    'end_ms': 'endMs',
  };
  for (final entry in aliases.entries) {
    if (map.containsKey(entry.key) && !map.containsKey(entry.value)) {
      map[entry.value] = map[entry.key];
    }
  }
  return map;
}

@freezed
abstract class CaptionSegment with _$CaptionSegment {
  const factory CaptionSegment({
    @Default(0) int startMs,
    @Default(0) int endMs,
    @Default('') String text,
  }) = _CaptionSegment;

  factory CaptionSegment.fromJson(Map<String, dynamic> json) =>
      _$CaptionSegmentFromJson(_normalizeMediaJson(json));
}

@freezed
abstract class PostMedia with _$PostMedia {
  const factory PostMedia({
    required String url,
    @Default('image') String mediaType,
    int? width,
    int? height,
    int? durationMs,
    String? posterUrl,
    int? trimStartMs,
    int? trimEndMs,
    String? soundId,
    double? soundVolume,
    String? soundAudioUrl,
    Map<String, dynamic>? editMeta,
    String? altText,
    @Default(<CaptionSegment>[]) List<CaptionSegment> captions,
  }) = _PostMedia;

  factory PostMedia.fromJson(Map<String, dynamic> json) =>
      _$PostMediaFromJson(_withNormalizedCaptions(_normalizeMediaJson(json)));
}

Map<String, dynamic> _withNormalizedCaptions(Map<String, dynamic> map) {
  final captions = map['captions'];
  if (captions is List) {
    map['captions'] = captions
        .whereType<Map>()
        .map((c) => _normalizeMediaJson(c))
        .toList();
  }
  return map;
}

extension PostMediaX on PostMedia {
  bool get isVideo => mediaType == 'video';
}

@freezed
abstract class AuthorData with _$AuthorData {
  const factory AuthorData({
    @JsonKey(name: 'user_id') String? userId,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') required String avatarUrl,
    @JsonKey(name: 'verification_status') @Default('none') String verificationStatus,
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
    @JsonKey(name: 'vote_count') @Default(0) int voteCount,
    @JsonKey(name: 'user_voted') @Default(false) bool userVoted,
  }) = _PollOption;

  factory PollOption.fromJson(Map<String, dynamic> json) =>
      _$PollOptionFromJson(json);
}

@freezed
abstract class Poll with _$Poll {
  const factory Poll({
    required String id,
    required String question,
    @JsonKey(name: 'closes_at') String? closesAt,
    @JsonKey(name: 'allow_multiple') @Default(false) bool allowMultiple,
    @JsonKey(name: 'min_selections') @Default(1) int minSelections,
    @JsonKey(name: 'max_selections') @Default(1) int maxSelections,
    @JsonKey(name: 'total_votes') @Default(0) int totalVotes,
    @JsonKey(name: 'is_closed') @Default(false) bool isClosed,
    required List<PollOption> options,
    @JsonKey(name: 'user_voted_option_ids') @Default(<String>[]) List<String> userVotedOptionIds,
  }) = _Poll;

  factory Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);
}

@freezed
abstract class ReposterData with _$ReposterData {
  const factory ReposterData({
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    @JsonKey(name: 'avatar_url') @Default('') String avatarUrl,
  }) = _ReposterData;

  factory ReposterData.fromJson(Map<String, dynamic> json) =>
      _$ReposterDataFromJson(json);
}

@freezed
abstract class OriginalPostData with _$OriginalPostData {
  const factory OriginalPostData({
    required String id,
    @JsonKey(name: 'author_data') required AuthorData authorData,
    required String body,
    @JsonKey(name: 'media_urls') @Default(<String>[]) List<String> mediaUrls,
    @Default(<PostMedia>[]) List<PostMedia> media,
    @JsonKey(name: 'post_type') @Default('text') String postType,
    @JsonKey(name: 'location_label') String? locationLabel,
    @JsonKey(name: 'workout_log_data') Map<String, dynamic>? workoutLogData,
    Poll? poll,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'repost_count') @Default(0) int repostCount,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
    @JsonKey(name: 'share_count') @Default(0) int shareCount,
    @JsonKey(name: 'save_count') @Default(0) int saveCount,
    @JsonKey(name: 'reaction_counts') @Default(<String, int>{}) Map<String, int> reactionCounts,
    @JsonKey(name: 'user_reaction') String? userReaction,
    @JsonKey(name: 'gym_tag_name') String? gymTagName,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _OriginalPostData;

  factory OriginalPostData.fromJson(Map<String, dynamic> json) =>
      _$OriginalPostDataFromJson(json);
}

@freezed
abstract class Post with _$Post {
  const factory Post({
    required String id,
    @JsonKey(name: 'author_data') required AuthorData authorData,
    @JsonKey(name: 'post_type') @Default('text') String postType,
    @Default('') String body,
    @JsonKey(name: 'is_anonymous') @Default(false) bool isAnonymous,
    @JsonKey(name: 'media_urls') @Default(<String>[]) List<String> mediaUrls,
    @Default(<PostMedia>[]) List<PostMedia> media,
    @JsonKey(readValue: _readCommentsDisabled)
    @Default(false) bool commentsDisabled,
    @Default(<String>[]) List<String> tags,
    @JsonKey(name: 'workout_log_data') Map<String, dynamic>? workoutLogData,
    @JsonKey(name: 'location_label') @Default('') String locationLabel,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
    @JsonKey(name: 'reaction_counts') @Default(<String, int>{}) Map<String, int> reactionCounts,
    @JsonKey(name: 'user_reaction') String? userReaction,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'repost_count') @Default(0) int repostCount,
    @JsonKey(name: 'save_count') @Default(0) int saveCount,
    @JsonKey(name: 'share_count') @Default(0) int shareCount,
    @JsonKey(name: 'is_repost') @Default(false) bool isRepost,
    @JsonKey(name: 'is_reposted_by_me') @Default(false) bool isRepostedByMe,
    @JsonKey(name: 'original_post_id') String? originalPostId,
    @JsonKey(name: 'quote_body') @Default('') String quoteBody,
    @Default(<ReposterData>[]) List<ReposterData> reposters,
    @JsonKey(name: 'is_saved') @Default(false) bool isSaved,
    @JsonKey(name: 'is_pinned') @Default(false) bool isPinned,
    @Default('public') String visibility,
    @JsonKey(name: 'content_rating') @Default('general') String contentRating,
    @JsonKey(name: 'moderation_status') @Default('clean') String moderationStatus,
    @JsonKey(readValue: _readAiAnalysis) Map<String, dynamic>? aiAnalysis,
    @JsonKey(name: 'gym_tag_id') String? gymTagId,
    @JsonKey(name: 'gym_tag_name') String? gymTagName,
    Poll? poll,
    @JsonKey(name: 'original_post_data') OriginalPostData? originalPostData,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'author_data') required AuthorData authorData,
    required String body,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'is_anonymous') @Default(false) bool isAnonymous,
    @JsonKey(name: 'reply_count') @Default(0) int replyCount,
    @JsonKey(name: 'reaction_counts') @Default(<String, int>{}) Map<String, int> reactionCounts,
    @JsonKey(name: 'user_reaction') String? userReaction,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
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
    @JsonKey(name: 'post_type') required String postType,
    String? body,
    @Default('public') String visibility,
    @JsonKey(name: 'content_rating') @Default('general') String contentRating,
    @JsonKey(name: 'gym_tag') String? gymTag,
    @JsonKey(name: 'location_label') String? locationLabel,
    @JsonKey(name: 'media_urls') @Default(<String>[]) List<String> mediaUrls,
    @Default(<String>[]) List<String> tags,
    @JsonKey(name: 'is_anonymous') @Default(false) bool isAnonymous,
    @JsonKey(name: 'poll_question') String? pollQuestion,
    @JsonKey(name: 'poll_options') @Default(<String>[]) List<String> pollOptions,
    @JsonKey(name: 'poll_closes_at') String? pollClosesAt,
    @JsonKey(name: 'poll_allow_multiple') @Default(false) bool pollAllowMultiple,
    @JsonKey(name: 'mentioned_users') @Default(<String>[]) List<String> mentionedUsers,
  }) = _CreatePostPayload;

  factory CreatePostPayload.fromJson(Map<String, dynamic> json) =>
      _$CreatePostPayloadFromJson(json);
}

@freezed
abstract class ReactionInput with _$ReactionInput {
  const factory ReactionInput({
    @JsonKey(name: 'reaction_type') required String reactionType,
  }) = _ReactionInput;

  factory ReactionInput.fromJson(Map<String, dynamic> json) =>
      _$ReactionInputFromJson(json);
}

@freezed
abstract class CommentCreateInput with _$CommentCreateInput {
  const factory CommentCreateInput({
    required String body,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'is_anonymous') @Default(false) bool isAnonymous,
  }) = _CommentCreateInput;

  factory CommentCreateInput.fromJson(Map<String, dynamic> json) =>
      _$CommentCreateInputFromJson(json);
}

@freezed
abstract class RepostPayload with _$RepostPayload {
  const factory RepostPayload({
    @JsonKey(name: 'quote_body') @Default('') String quoteBody,
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
    @JsonKey(name: 'post_type') @Default('text') String postType,
    @Default('') String body,
    @Default('public') String visibility,
    @JsonKey(name: 'gym_tag') String? gymTag,
    @JsonKey(name: 'location_label') @Default('') String locationLabel,
    @JsonKey(name: 'location_lat') double? locationLat,
    @JsonKey(name: 'location_lng') double? locationLng,
    @JsonKey(name: 'media_urls') @Default(<String>[]) List<String> mediaUrls,
    @Default(<String>[]) List<String> tags,
    @JsonKey(name: 'poll_question') @Default('') String pollQuestion,
    @JsonKey(name: 'poll_options') @Default(<String>[]) List<String> pollOptions,
    @JsonKey(name: 'poll_allow_multiple') @Default(false) bool pollAllowMultiple,
    @JsonKey(name: 'poll_min_selections') @Default(1) int pollMinSelections,
    @JsonKey(name: 'poll_max_selections') @Default(1) int pollMaxSelections,
    @JsonKey(name: 'mentioned_user_ids') @Default(<String>[]) List<String> mentionedUserIds,
    @JsonKey(name: 'is_anonymous') @Default(false) bool isAnonymous,
  }) = _Draft;

  factory Draft.fromJson(Map<String, dynamic> json) => _$DraftFromJson(json);
}
