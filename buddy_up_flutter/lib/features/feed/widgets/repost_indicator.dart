import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';
import '../../../shared/widgets/avatar.dart';

class RepostIndicator extends StatelessWidget {
  final List<ReposterData> reposters;
  final String username;
  final String? quoteBody;

  const RepostIndicator({
    super.key,
    this.reposters = const [],
    required this.username,
    this.quoteBody,
  });

  @override
  Widget build(BuildContext context) {
    final people = reposters.length > 1 ? reposters : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.repeat, size: 14, color: BuddyColors.green),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (people != null) ...[
                      _buildStackedAvatars(context, people),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        people == null ? '$username reposted' : '$username reposted',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BuddyColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (quoteBody != null && quoteBody!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      quoteBody!,
                      style: const TextStyle(
                        color: BuddyColors.textSecondary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedAvatars(BuildContext context, List<ReposterData> people) {
    final visible = people.take(3).toList();
    final overflow = people.length - visible.length;
    return SizedBox(
      height: 24,
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * 14.0,
              child: Avatar(
                src: visible[i].avatarUrl,
                alt: visible[i].displayName,
                size: AvatarSize.xs,
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: visible.length * 14.0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: BuddyColors.surfaceRaised,
                  shape: BoxShape.circle,
                  border: Border.all(color: BuddyColors.green.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$overflow',
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 9, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
