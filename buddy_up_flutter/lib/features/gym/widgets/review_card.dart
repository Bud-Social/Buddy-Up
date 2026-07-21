import 'package:flutter/material.dart';
import '../../../data/models/gym.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';

class ReviewCard extends StatelessWidget {
  final GymReview review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(src: review.reviewerData.avatarUrl, alt: review.reviewerData.displayName, size: AvatarSize.sm),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerData.displayName,
                      style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < review.rating ? Icons.star : Icons.star_border,
                        size: 14,
                        color: BuddyColors.green,
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14)),
          ],
          if (review.replyText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BuddyColors.surfaceRaised,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reply from ${review.repliedByData?.displayName ?? 'gym'}',
                    style: const TextStyle(color: BuddyColors.green, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(review.replyText, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
