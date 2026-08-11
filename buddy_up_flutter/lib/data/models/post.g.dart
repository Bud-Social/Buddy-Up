// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthorData _$AuthorDataFromJson(Map<String, dynamic> json) => _AuthorData(
  userId: json['userId'] as String?,
  username: json['username'] as String,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatarUrl'] as String,
  verificationStatus: json['verificationStatus'] as String? ?? 'none',
);

Map<String, dynamic> _$AuthorDataToJson(_AuthorData instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'verificationStatus': instance.verificationStatus,
    };

_PollOption _$PollOptionFromJson(Map<String, dynamic> json) => _PollOption(
  id: json['id'] as String,
  text: json['text'] as String,
  order: (json['order'] as num?)?.toInt() ?? 0,
  voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
  userVoted: json['userVoted'] as bool? ?? false,
);

Map<String, dynamic> _$PollOptionToJson(_PollOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'order': instance.order,
      'voteCount': instance.voteCount,
      'userVoted': instance.userVoted,
    };

_Poll _$PollFromJson(Map<String, dynamic> json) => _Poll(
  id: json['id'] as String,
  question: json['question'] as String,
  closesAt: json['closesAt'] as String?,
  allowMultiple: json['allowMultiple'] as bool? ?? false,
  totalVotes: (json['totalVotes'] as num?)?.toInt() ?? 0,
  isClosed: json['isClosed'] as bool? ?? false,
  options: (json['options'] as List<dynamic>)
      .map((e) => PollOption.fromJson(e as Map<String, dynamic>))
      .toList(),
  userVotedOptionIds:
      (json['userVotedOptionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$PollToJson(_Poll instance) => <String, dynamic>{
  'id': instance.id,
  'question': instance.question,
  'closesAt': instance.closesAt,
  'allowMultiple': instance.allowMultiple,
  'totalVotes': instance.totalVotes,
  'isClosed': instance.isClosed,
  'options': instance.options,
  'userVotedOptionIds': instance.userVotedOptionIds,
};

_OriginalPostData _$OriginalPostDataFromJson(
  Map<String, dynamic> json,
) => _OriginalPostData(
  id: json['id'] as String,
  authorData: AuthorData.fromJson(json['authorData'] as Map<String, dynamic>),
  body: json['body'] as String,
  mediaUrls:
      (json['mediaUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  postType: json['postType'] as String? ?? 'text',
  locationLabel: json['locationLabel'] as String?,
  workoutLogData: json['workoutLogData'] as Map<String, dynamic>?,
  mealData: json['mealData'] as Map<String, dynamic>?,
  progressData: json['progressData'] as Map<String, dynamic>?,
  poll: json['poll'] == null
      ? null
      : Poll.fromJson(json['poll'] as Map<String, dynamic>),
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  gymTagName: json['gymTagName'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$OriginalPostDataToJson(_OriginalPostData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorData': instance.authorData,
      'body': instance.body,
      'mediaUrls': instance.mediaUrls,
      'postType': instance.postType,
      'locationLabel': instance.locationLabel,
      'workoutLogData': instance.workoutLogData,
      'mealData': instance.mealData,
      'progressData': instance.progressData,
      'poll': instance.poll,
      'commentCount': instance.commentCount,
      'gymTagName': instance.gymTagName,
      'createdAt': instance.createdAt,
    };

_Post _$PostFromJson(Map<String, dynamic> json) => _Post(
  id: json['id'] as String,
  authorData: AuthorData.fromJson(json['authorData'] as Map<String, dynamic>),
  postType: json['postType'] as String? ?? 'text',
  body: json['body'] as String? ?? '',
  isAnonymous: json['isAnonymous'] as bool? ?? false,
  mediaUrls:
      (json['mediaUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  workoutLogData: json['workoutLogData'] as Map<String, dynamic>?,
  mealData: json['mealData'] as Map<String, dynamic>?,
  progressData: json['progressData'] as Map<String, dynamic>?,
  locationLabel: json['locationLabel'] as String? ?? '',
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  reactionCounts:
      (json['reactionCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  userReaction: json['userReaction'] as String?,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  repostCount: (json['repostCount'] as num?)?.toInt() ?? 0,
  isRepost: json['isRepost'] as bool? ?? false,
  originalPostId: json['originalPostId'] as String?,
  quoteBody: json['quoteBody'] as String? ?? '',
  isSaved: json['isSaved'] as bool? ?? false,
  isPinned: json['isPinned'] as bool? ?? false,
  visibility: json['visibility'] as String? ?? 'public',
  contentRating: json['content_rating'] as String? ?? 'general',
  moderationStatus: json['moderationStatus'] as String? ?? 'clean',
  aiAnalysis: _readAiAnalysis(json, 'aiAnalysis') as Map<String, dynamic>?,
  gymTagId: json['gymTagId'] as String?,
  gymTagName: json['gymTagName'] as String?,
  poll: json['poll'] == null
      ? null
      : Poll.fromJson(json['poll'] as Map<String, dynamic>),
  originalPostData: json['originalPostData'] == null
      ? null
      : OriginalPostData.fromJson(
          json['originalPostData'] as Map<String, dynamic>,
        ),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$PostToJson(_Post instance) => <String, dynamic>{
  'id': instance.id,
  'authorData': instance.authorData,
  'postType': instance.postType,
  'body': instance.body,
  'isAnonymous': instance.isAnonymous,
  'mediaUrls': instance.mediaUrls,
  'tags': instance.tags,
  'workoutLogData': instance.workoutLogData,
  'mealData': instance.mealData,
  'progressData': instance.progressData,
  'locationLabel': instance.locationLabel,
  'viewCount': instance.viewCount,
  'reactionCounts': instance.reactionCounts,
  'userReaction': instance.userReaction,
  'commentCount': instance.commentCount,
  'repostCount': instance.repostCount,
  'isRepost': instance.isRepost,
  'originalPostId': instance.originalPostId,
  'quoteBody': instance.quoteBody,
  'isSaved': instance.isSaved,
  'isPinned': instance.isPinned,
  'visibility': instance.visibility,
  'content_rating': instance.contentRating,
  'moderationStatus': instance.moderationStatus,
  'aiAnalysis': instance.aiAnalysis,
  'gymTagId': instance.gymTagId,
  'gymTagName': instance.gymTagName,
  'poll': instance.poll,
  'originalPostData': instance.originalPostData,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  id: json['id'] as String,
  postId: json['postId'] as String,
  authorData: AuthorData.fromJson(json['authorData'] as Map<String, dynamic>),
  body: json['body'] as String,
  parentId: json['parentId'] as String?,
  isAnonymous: json['isAnonymous'] as bool? ?? false,
  replyCount: (json['replyCount'] as num?)?.toInt() ?? 0,
  reactionCounts:
      (json['reactionCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  userReaction: json['userReaction'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'id': instance.id,
  'postId': instance.postId,
  'authorData': instance.authorData,
  'body': instance.body,
  'parentId': instance.parentId,
  'isAnonymous': instance.isAnonymous,
  'replyCount': instance.replyCount,
  'reactionCounts': instance.reactionCounts,
  'userReaction': instance.userReaction,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

_FeedFilter _$FeedFilterFromJson(Map<String, dynamic> json) => _FeedFilter(
  tab: json['tab'] as String? ?? 'for_you',
  cursor: json['cursor'] as String?,
);

Map<String, dynamic> _$FeedFilterToJson(_FeedFilter instance) =>
    <String, dynamic>{'tab': instance.tab, 'cursor': instance.cursor};

_CreatePostPayload _$CreatePostPayloadFromJson(Map<String, dynamic> json) =>
    _CreatePostPayload(
      postType: json['postType'] as String,
      body: json['body'] as String?,
      visibility: json['visibility'] as String? ?? 'public',
      contentRating: json['content_rating'] as String? ?? 'general',
      gymTag: json['gymTag'] as String?,
      locationLabel: json['locationLabel'] as String?,
      mediaUrls:
          (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      pollQuestion: json['pollQuestion'] as String?,
      pollOptions:
          (json['pollOptions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      pollClosesAt: json['pollClosesAt'] as String?,
      pollAllowMultiple: json['pollAllowMultiple'] as bool? ?? false,
      mentionedUsers:
          (json['mentionedUsers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$CreatePostPayloadToJson(_CreatePostPayload instance) =>
    <String, dynamic>{
      'postType': instance.postType,
      'body': instance.body,
      'visibility': instance.visibility,
      'content_rating': instance.contentRating,
      'gymTag': instance.gymTag,
      'locationLabel': instance.locationLabel,
      'mediaUrls': instance.mediaUrls,
      'tags': instance.tags,
      'isAnonymous': instance.isAnonymous,
      'pollQuestion': instance.pollQuestion,
      'pollOptions': instance.pollOptions,
      'pollClosesAt': instance.pollClosesAt,
      'pollAllowMultiple': instance.pollAllowMultiple,
      'mentionedUsers': instance.mentionedUsers,
    };

_ReactionInput _$ReactionInputFromJson(Map<String, dynamic> json) =>
    _ReactionInput(reactionType: json['reactionType'] as String);

Map<String, dynamic> _$ReactionInputToJson(_ReactionInput instance) =>
    <String, dynamic>{'reactionType': instance.reactionType};

_CommentCreateInput _$CommentCreateInputFromJson(Map<String, dynamic> json) =>
    _CommentCreateInput(
      body: json['body'] as String,
      parentId: json['parentId'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );

Map<String, dynamic> _$CommentCreateInputToJson(_CommentCreateInput instance) =>
    <String, dynamic>{
      'body': instance.body,
      'parentId': instance.parentId,
      'isAnonymous': instance.isAnonymous,
    };

_RepostPayload _$RepostPayloadFromJson(Map<String, dynamic> json) =>
    _RepostPayload(quoteBody: json['quoteBody'] as String? ?? '');

Map<String, dynamic> _$RepostPayloadToJson(_RepostPayload instance) =>
    <String, dynamic>{'quoteBody': instance.quoteBody};

_SavePayload _$SavePayloadFromJson(Map<String, dynamic> json) =>
    _SavePayload(collection: json['collection'] as String?);

Map<String, dynamic> _$SavePayloadToJson(_SavePayload instance) =>
    <String, dynamic>{'collection': instance.collection};

_Draft _$DraftFromJson(Map<String, dynamic> json) => _Draft(
  id: json['id'] as String?,
  postType: json['postType'] as String? ?? 'text',
  body: json['body'] as String? ?? '',
  visibility: json['visibility'] as String? ?? 'public',
  gymTag: json['gymTag'] as String?,
  locationLabel: json['locationLabel'] as String?,
  mediaUrls:
      (json['mediaUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  pollQuestion: json['pollQuestion'] as String? ?? '',
  pollOptions:
      (json['pollOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  pollAllowMultiple: json['pollAllowMultiple'] as bool? ?? false,
  mentionedUserIds:
      (json['mentionedUserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  isAnonymous: json['isAnonymous'] as bool? ?? false,
);

Map<String, dynamic> _$DraftToJson(_Draft instance) => <String, dynamic>{
  'id': instance.id,
  'postType': instance.postType,
  'body': instance.body,
  'visibility': instance.visibility,
  'gymTag': instance.gymTag,
  'locationLabel': instance.locationLabel,
  'mediaUrls': instance.mediaUrls,
  'tags': instance.tags,
  'pollQuestion': instance.pollQuestion,
  'pollOptions': instance.pollOptions,
  'pollAllowMultiple': instance.pollAllowMultiple,
  'mentionedUserIds': instance.mentionedUserIds,
  'isAnonymous': instance.isAnonymous,
};
