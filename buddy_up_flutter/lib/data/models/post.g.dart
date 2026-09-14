// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaptionSegment _$CaptionSegmentFromJson(Map<String, dynamic> json) =>
    _CaptionSegment(
      startMs: (json['startMs'] as num?)?.toInt() ?? 0,
      endMs: (json['endMs'] as num?)?.toInt() ?? 0,
      text: json['text'] as String? ?? '',
    );

Map<String, dynamic> _$CaptionSegmentToJson(_CaptionSegment instance) =>
    <String, dynamic>{
      'startMs': instance.startMs,
      'endMs': instance.endMs,
      'text': instance.text,
    };

_PostMedia _$PostMediaFromJson(Map<String, dynamic> json) => _PostMedia(
  url: json['url'] as String,
  mediaType: json['mediaType'] as String? ?? 'image',
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  durationMs: (json['durationMs'] as num?)?.toInt(),
  posterUrl: json['posterUrl'] as String?,
  trimStartMs: (json['trimStartMs'] as num?)?.toInt(),
  trimEndMs: (json['trimEndMs'] as num?)?.toInt(),
  soundId: json['soundId'] as String?,
  soundVolume: (json['soundVolume'] as num?)?.toDouble(),
  soundAudioUrl: json['soundAudioUrl'] as String?,
  editMeta: json['editMeta'] as Map<String, dynamic>?,
  altText: json['altText'] as String?,
  captions:
      (json['captions'] as List<dynamic>?)
          ?.map((e) => CaptionSegment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CaptionSegment>[],
);

Map<String, dynamic> _$PostMediaToJson(_PostMedia instance) =>
    <String, dynamic>{
      'url': instance.url,
      'mediaType': instance.mediaType,
      'width': instance.width,
      'height': instance.height,
      'durationMs': instance.durationMs,
      'posterUrl': instance.posterUrl,
      'trimStartMs': instance.trimStartMs,
      'trimEndMs': instance.trimEndMs,
      'soundId': instance.soundId,
      'soundVolume': instance.soundVolume,
      'soundAudioUrl': instance.soundAudioUrl,
      'editMeta': instance.editMeta,
      'altText': instance.altText,
      'captions': instance.captions,
    };

_AuthorData _$AuthorDataFromJson(Map<String, dynamic> json) => _AuthorData(
  userId: json['user_id'] as String?,
  username: json['username'] as String,
  displayName: json['display_name'] as String,
  avatarUrl: json['avatar_url'] as String,
  verificationStatus: json['verification_status'] as String? ?? 'none',
);

Map<String, dynamic> _$AuthorDataToJson(_AuthorData instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'verification_status': instance.verificationStatus,
    };

_PollOption _$PollOptionFromJson(Map<String, dynamic> json) => _PollOption(
  id: json['id'] as String,
  text: json['text'] as String,
  order: (json['order'] as num?)?.toInt() ?? 0,
  voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
  userVoted: json['user_voted'] as bool? ?? false,
);

Map<String, dynamic> _$PollOptionToJson(_PollOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'order': instance.order,
      'vote_count': instance.voteCount,
      'user_voted': instance.userVoted,
    };

_Poll _$PollFromJson(Map<String, dynamic> json) => _Poll(
  id: json['id'] as String,
  question: json['question'] as String,
  closesAt: json['closes_at'] as String?,
  allowMultiple: json['allow_multiple'] as bool? ?? false,
  minSelections: (json['min_selections'] as num?)?.toInt() ?? 1,
  maxSelections: (json['max_selections'] as num?)?.toInt() ?? 1,
  totalVotes: (json['total_votes'] as num?)?.toInt() ?? 0,
  isClosed: json['is_closed'] as bool? ?? false,
  options: (json['options'] as List<dynamic>)
      .map((e) => PollOption.fromJson(e as Map<String, dynamic>))
      .toList(),
  userVotedOptionIds:
      (json['user_voted_option_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$PollToJson(_Poll instance) => <String, dynamic>{
  'id': instance.id,
  'question': instance.question,
  'closes_at': instance.closesAt,
  'allow_multiple': instance.allowMultiple,
  'min_selections': instance.minSelections,
  'max_selections': instance.maxSelections,
  'total_votes': instance.totalVotes,
  'is_closed': instance.isClosed,
  'options': instance.options,
  'user_voted_option_ids': instance.userVotedOptionIds,
};

_ReposterData _$ReposterDataFromJson(Map<String, dynamic> json) =>
    _ReposterData(
      userId: json['user_id'] as String?,
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
    );

Map<String, dynamic> _$ReposterDataToJson(_ReposterData instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
    };

_OriginalPostData _$OriginalPostDataFromJson(Map<String, dynamic> json) =>
    _OriginalPostData(
      id: json['id'] as String,
      authorData: AuthorData.fromJson(
        json['author_data'] as Map<String, dynamic>,
      ),
      body: json['body'] as String,
      mediaUrls:
          (json['media_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      media:
          (json['media'] as List<dynamic>?)
              ?.map((e) => PostMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PostMedia>[],
      postType: json['post_type'] as String? ?? 'text',
      locationLabel: json['location_label'] as String?,
      workoutLogData: json['workout_log_data'] as Map<String, dynamic>?,
      mealData: json['meal_data'] as Map<String, dynamic>?,
      progressData: json['progress_data'] as Map<String, dynamic>?,
      poll: json['poll'] == null
          ? null
          : Poll.fromJson(json['poll'] as Map<String, dynamic>),
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      repostCount: (json['repost_count'] as num?)?.toInt() ?? 0,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      shareCount: (json['share_count'] as num?)?.toInt() ?? 0,
      saveCount: (json['save_count'] as num?)?.toInt() ?? 0,
      reactionCounts:
          (json['reaction_counts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      userReaction: json['user_reaction'] as String?,
      gymTagName: json['gym_tag_name'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$OriginalPostDataToJson(_OriginalPostData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_data': instance.authorData,
      'body': instance.body,
      'media_urls': instance.mediaUrls,
      'media': instance.media,
      'post_type': instance.postType,
      'location_label': instance.locationLabel,
      'workout_log_data': instance.workoutLogData,
      'meal_data': instance.mealData,
      'progress_data': instance.progressData,
      'poll': instance.poll,
      'comment_count': instance.commentCount,
      'repost_count': instance.repostCount,
      'view_count': instance.viewCount,
      'share_count': instance.shareCount,
      'save_count': instance.saveCount,
      'reaction_counts': instance.reactionCounts,
      'user_reaction': instance.userReaction,
      'gym_tag_name': instance.gymTagName,
      'created_at': instance.createdAt,
    };

_Post _$PostFromJson(Map<String, dynamic> json) => _Post(
  id: json['id'] as String,
  authorData: AuthorData.fromJson(json['author_data'] as Map<String, dynamic>),
  postType: json['post_type'] as String? ?? 'text',
  body: json['body'] as String? ?? '',
  isAnonymous: json['is_anonymous'] as bool? ?? false,
  mediaUrls:
      (json['media_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  media:
      (json['media'] as List<dynamic>?)
          ?.map((e) => PostMedia.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PostMedia>[],
  commentsDisabled:
      _readCommentsDisabled(json, 'commentsDisabled') as bool? ?? false,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  workoutLogData: json['workout_log_data'] as Map<String, dynamic>?,
  mealData: json['meal_data'] as Map<String, dynamic>?,
  progressData: json['progress_data'] as Map<String, dynamic>?,
  locationLabel: json['location_label'] as String? ?? '',
  viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
  reactionCounts:
      (json['reaction_counts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  userReaction: json['user_reaction'] as String?,
  commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
  repostCount: (json['repost_count'] as num?)?.toInt() ?? 0,
  saveCount: (json['save_count'] as num?)?.toInt() ?? 0,
  shareCount: (json['share_count'] as num?)?.toInt() ?? 0,
  isRepost: json['is_repost'] as bool? ?? false,
  isRepostedByMe: json['is_reposted_by_me'] as bool? ?? false,
  originalPostId: json['original_post_id'] as String?,
  quoteBody: json['quote_body'] as String? ?? '',
  reposters:
      (json['reposters'] as List<dynamic>?)
          ?.map((e) => ReposterData.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ReposterData>[],
  isSaved: json['is_saved'] as bool? ?? false,
  isPinned: json['is_pinned'] as bool? ?? false,
  visibility: json['visibility'] as String? ?? 'public',
  contentRating: json['content_rating'] as String? ?? 'general',
  moderationStatus: json['moderation_status'] as String? ?? 'clean',
  aiAnalysis: _readAiAnalysis(json, 'aiAnalysis') as Map<String, dynamic>?,
  gymTagId: json['gym_tag_id'] as String?,
  gymTagName: json['gym_tag_name'] as String?,
  poll: json['poll'] == null
      ? null
      : Poll.fromJson(json['poll'] as Map<String, dynamic>),
  originalPostData: json['original_post_data'] == null
      ? null
      : OriginalPostData.fromJson(
          json['original_post_data'] as Map<String, dynamic>,
        ),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$PostToJson(_Post instance) => <String, dynamic>{
  'id': instance.id,
  'author_data': instance.authorData,
  'post_type': instance.postType,
  'body': instance.body,
  'is_anonymous': instance.isAnonymous,
  'media_urls': instance.mediaUrls,
  'media': instance.media,
  'commentsDisabled': instance.commentsDisabled,
  'tags': instance.tags,
  'workout_log_data': instance.workoutLogData,
  'meal_data': instance.mealData,
  'progress_data': instance.progressData,
  'location_label': instance.locationLabel,
  'view_count': instance.viewCount,
  'reaction_counts': instance.reactionCounts,
  'user_reaction': instance.userReaction,
  'comment_count': instance.commentCount,
  'repost_count': instance.repostCount,
  'save_count': instance.saveCount,
  'share_count': instance.shareCount,
  'is_repost': instance.isRepost,
  'is_reposted_by_me': instance.isRepostedByMe,
  'original_post_id': instance.originalPostId,
  'quote_body': instance.quoteBody,
  'reposters': instance.reposters,
  'is_saved': instance.isSaved,
  'is_pinned': instance.isPinned,
  'visibility': instance.visibility,
  'content_rating': instance.contentRating,
  'moderation_status': instance.moderationStatus,
  'aiAnalysis': instance.aiAnalysis,
  'gym_tag_id': instance.gymTagId,
  'gym_tag_name': instance.gymTagName,
  'poll': instance.poll,
  'original_post_data': instance.originalPostData,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  id: json['id'] as String,
  postId: json['post_id'] as String,
  authorData: AuthorData.fromJson(json['author_data'] as Map<String, dynamic>),
  body: json['body'] as String,
  parentId: json['parent_id'] as String?,
  isAnonymous: json['is_anonymous'] as bool? ?? false,
  replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
  reactionCounts:
      (json['reaction_counts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  userReaction: json['user_reaction'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'id': instance.id,
  'post_id': instance.postId,
  'author_data': instance.authorData,
  'body': instance.body,
  'parent_id': instance.parentId,
  'is_anonymous': instance.isAnonymous,
  'reply_count': instance.replyCount,
  'reaction_counts': instance.reactionCounts,
  'user_reaction': instance.userReaction,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_FeedFilter _$FeedFilterFromJson(Map<String, dynamic> json) => _FeedFilter(
  tab: json['tab'] as String? ?? 'for_you',
  cursor: json['cursor'] as String?,
);

Map<String, dynamic> _$FeedFilterToJson(_FeedFilter instance) =>
    <String, dynamic>{'tab': instance.tab, 'cursor': instance.cursor};

_CreatePostPayload _$CreatePostPayloadFromJson(Map<String, dynamic> json) =>
    _CreatePostPayload(
      postType: json['post_type'] as String,
      body: json['body'] as String?,
      visibility: json['visibility'] as String? ?? 'public',
      contentRating: json['content_rating'] as String? ?? 'general',
      gymTag: json['gym_tag'] as String?,
      locationLabel: json['location_label'] as String?,
      mediaUrls:
          (json['media_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      pollQuestion: json['poll_question'] as String?,
      pollOptions:
          (json['poll_options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      pollClosesAt: json['poll_closes_at'] as String?,
      pollAllowMultiple: json['poll_allow_multiple'] as bool? ?? false,
      mentionedUsers:
          (json['mentioned_users'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$CreatePostPayloadToJson(_CreatePostPayload instance) =>
    <String, dynamic>{
      'post_type': instance.postType,
      'body': instance.body,
      'visibility': instance.visibility,
      'content_rating': instance.contentRating,
      'gym_tag': instance.gymTag,
      'location_label': instance.locationLabel,
      'media_urls': instance.mediaUrls,
      'tags': instance.tags,
      'is_anonymous': instance.isAnonymous,
      'poll_question': instance.pollQuestion,
      'poll_options': instance.pollOptions,
      'poll_closes_at': instance.pollClosesAt,
      'poll_allow_multiple': instance.pollAllowMultiple,
      'mentioned_users': instance.mentionedUsers,
    };

_ReactionInput _$ReactionInputFromJson(Map<String, dynamic> json) =>
    _ReactionInput(reactionType: json['reaction_type'] as String);

Map<String, dynamic> _$ReactionInputToJson(_ReactionInput instance) =>
    <String, dynamic>{'reaction_type': instance.reactionType};

_CommentCreateInput _$CommentCreateInputFromJson(Map<String, dynamic> json) =>
    _CommentCreateInput(
      body: json['body'] as String,
      parentId: json['parent_id'] as String?,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
    );

Map<String, dynamic> _$CommentCreateInputToJson(_CommentCreateInput instance) =>
    <String, dynamic>{
      'body': instance.body,
      'parent_id': instance.parentId,
      'is_anonymous': instance.isAnonymous,
    };

_RepostPayload _$RepostPayloadFromJson(Map<String, dynamic> json) =>
    _RepostPayload(quoteBody: json['quote_body'] as String? ?? '');

Map<String, dynamic> _$RepostPayloadToJson(_RepostPayload instance) =>
    <String, dynamic>{'quote_body': instance.quoteBody};

_SavePayload _$SavePayloadFromJson(Map<String, dynamic> json) =>
    _SavePayload(collection: json['collection'] as String?);

Map<String, dynamic> _$SavePayloadToJson(_SavePayload instance) =>
    <String, dynamic>{'collection': instance.collection};

_Draft _$DraftFromJson(Map<String, dynamic> json) => _Draft(
  id: json['id'] as String?,
  postType: json['post_type'] as String? ?? 'text',
  body: json['body'] as String? ?? '',
  visibility: json['visibility'] as String? ?? 'public',
  gymTag: json['gym_tag'] as String?,
  locationLabel: json['location_label'] as String? ?? '',
  locationLat: (json['location_lat'] as num?)?.toDouble(),
  locationLng: (json['location_lng'] as num?)?.toDouble(),
  mediaUrls:
      (json['media_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  pollQuestion: json['poll_question'] as String? ?? '',
  pollOptions:
      (json['poll_options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  pollAllowMultiple: json['poll_allow_multiple'] as bool? ?? false,
  pollMinSelections: (json['poll_min_selections'] as num?)?.toInt() ?? 1,
  pollMaxSelections: (json['poll_max_selections'] as num?)?.toInt() ?? 1,
  mentionedUserIds:
      (json['mentioned_user_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  isAnonymous: json['is_anonymous'] as bool? ?? false,
);

Map<String, dynamic> _$DraftToJson(_Draft instance) => <String, dynamic>{
  'id': instance.id,
  'post_type': instance.postType,
  'body': instance.body,
  'visibility': instance.visibility,
  'gym_tag': instance.gymTag,
  'location_label': instance.locationLabel,
  'location_lat': instance.locationLat,
  'location_lng': instance.locationLng,
  'media_urls': instance.mediaUrls,
  'tags': instance.tags,
  'poll_question': instance.pollQuestion,
  'poll_options': instance.pollOptions,
  'poll_allow_multiple': instance.pollAllowMultiple,
  'poll_min_selections': instance.pollMinSelections,
  'poll_max_selections': instance.pollMaxSelections,
  'mentioned_user_ids': instance.mentionedUserIds,
  'is_anonymous': instance.isAnonymous,
};
