import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/gym.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';

class SchedulePostCard extends StatelessWidget {
  final GymSchedulePost post;
  final VoidCallback? onEnroll;
  final bool showEnroll;

  const SchedulePostCard({
    super.key,
    required this.post,
    this.onEnroll,
    this.showEnroll = true,
  });

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
              Avatar(src: post.authorData.avatarUrl, alt: post.authorData.displayName, size: AvatarSize.sm),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  post.authorData.displayName,
                  style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BuddyColors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  post.activityType.replaceAll('_', ' '),
                  style: const TextStyle(color: BuddyColors.green, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          if (post.title.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(post.title, style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
          if (post.content.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(post.content, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
          ],
          if (post.startTime != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: BuddyColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatTime(post.startTime!),
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                ),
                if (post.endTime != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.schedule, size: 14, color: BuddyColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(post.endTime!),
                    style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${post.enrollmentCount}/${post.maxSlots} slots',
                style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              if (showEnroll)
                ElevatedButton(
                  onPressed: post.isEnrolled ? null : onEnroll,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: post.isEnrolled ? BuddyColors.surfaceRaised : BuddyColors.green,
                    foregroundColor: post.isEnrolled ? BuddyColors.textSecondary : BuddyColors.black,
                  ),
                  child: Text(post.isEnrolled ? 'Enrolled' : 'Enroll'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return DateFormat.MMMd().add_jm().format(dt);
  }
}
