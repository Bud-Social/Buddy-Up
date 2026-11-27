import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging.dart';
import '../../../data/models/post.dart';
import '../../feed/widgets/post_card.dart';

// Reused by community detail and the feed's Communities tab: the same
// community-tagged card, so both surfaces render identically.
extension CommunityPostToPost on CommunityPost {
  Post toPost() {
    return Post(
      id: id,
      authorData: AuthorData(
        userId: authorId,
        username: authorData.username,
        displayName: authorData.displayName.isNotEmpty
            ? authorData.displayName
            : authorData.username,
        avatarUrl: authorData.avatarUrl,
        verificationStatus: authorData.role,
      ),
      body: body,
      mediaUrls: mediaUrl.isNotEmpty ? [mediaUrl] : const [],
      // Community likes are surfaced as 💪 by the web client, matching the
      // backend payload (`like_count` -> reaction_counts['💪']).
      reactionCounts:
          likeCount > 0 ? {'💪': likeCount} : const <String, int>{},
      userReaction: isLiked ? '💪' : null,
      commentCount: commentCount,
      isPinned: isPinned,
      createdAt: createdAt,
      viewCount: viewCount,
      isRepostedByMe: isRepost,
      repostCount: repostCount,
      shareCount: shareCount,
      saveCount: saveCount,
    );
  }
}

class CommunityPostCardWithTag extends StatelessWidget {
  final Post post;
  final String communityName;
  final String? communityCoverUrl;
  final void Function(String)? onLike;
  final void Function(String)? onComment;
  final void Function(String)? onRepost;
  final void Function(String)? onSave;
  final void Function(String)? onShare;
  final void Function(String, String)? onReact;
  final void Function(String)? onPin;
  final void Function(String)? onDelete;

  const CommunityPostCardWithTag({
    super.key,
    required this.post,
    required this.communityName,
    this.communityCoverUrl,
    this.onLike,
    this.onComment,
    this.onRepost,
    this.onSave,
    this.onShare,
    this.onReact,
    this.onPin,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: BuddyColors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (communityCoverUrl != null && communityCoverUrl!.isNotEmpty)
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: BuddyColors.surfaceRaised,
                    shape: BoxShape.circle,
                    border: Border.all(color: BuddyColors.border, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      communityCoverUrl!,
                      width: 16,
                      height: 16,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (communityCoverUrl != null && communityCoverUrl!.isNotEmpty)
                const SizedBox(width: 6),
              Text(
                communityName,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: BuddyColors.green,
                ),
              ),
            ],
          ),
        ),
        PostCard(
          post: post,
          onLike: onLike,
          onComment: onComment,
          onRepost: onRepost,
          onSave: onSave,
          onShare: onShare,
          onReact: onReact,
          onPin: onPin,
          onDelete: onDelete,
        ),
      ],
    );
  }
}
