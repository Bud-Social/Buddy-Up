import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/live.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';

class LiveCard extends StatelessWidget {
  final BuddyLive live;
  final VoidCallback? onTap;

  const LiveCard({super.key, required this.live, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLive = live.status == 'live';
    final isScheduled = live.status == 'scheduled';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: BuddyColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 180,
                    color: BuddyColors.surfaceRaised,
                    child: Center(
                      child: Icon(Icons.videocam, size: 48, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isLive ? BuddyColors.red : (isScheduled ? BuddyColors.green : BuddyColors.textSecondary),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isLive ? 'LIVE' : (isScheduled ? 'Scheduled' : 'Replay'),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (isLive)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.visibility, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('${live.viewerCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Avatar(src: live.host.avatarUrl, alt: live.host.displayName, size: AvatarSize.sm),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          live.title,
                          style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          live.host.displayName,
                          style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (isScheduled && live.scheduledFor != null)
                    Text(
                      DateFormat.MMMd().add_jm().format(DateTime.parse(live.scheduledFor!)),
                      style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
