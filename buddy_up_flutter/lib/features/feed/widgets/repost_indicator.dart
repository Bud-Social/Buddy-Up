import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';
import '../../../shared/widgets/avatar.dart';

class RepostIndicator extends StatelessWidget {
  final List<ReposterData> reposters;
  final String username;
  final String? quoteBody;

  /// Set when the viewer reposted: their avatar pops into the stack with a
  /// scale/fade entrance (AnimatedSwitcher) and animates out on unrepost.
  final bool viewerReposted;
  final String? viewerAvatarUrl;
  final String? viewerDisplayName;

  const RepostIndicator({
    super.key,
    this.reposters = const [],
    required this.username,
    this.quoteBody,
    this.viewerReposted = false,
    this.viewerAvatarUrl,
    this.viewerDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    final people = reposters.length > 1 ? reposters : null;
    // When the viewer reposted but the backend hasn't echoed them back yet,
    // still show the stack so the pop-in has a home.
    final showStack = people != null || viewerReposted;
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
                    if (showStack) ...[
                      _buildStackedAvatars(context, people ?? const []),
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
    final viewerSlot = (viewerAvatarUrl ?? '').isNotEmpty;
    // Skip a backend echo of the viewer — the animated slot below owns it.
    final visible = people
        .where((r) =>
            !viewerSlot ||
            r.avatarUrl != viewerAvatarUrl)
        .take(3)
        .toList();
    final overflow = people.length - visible.length;
    // Width grows with the slot count; the viewer slot reserves space while
    // scaled to 0 so the exit animation doesn't reflow the row.
    final extra = (overflow > 0 ? 1 : 0) + (viewerSlot ? 1 : 0);
    final slotCount = visible.length + extra;
    return SizedBox(
      height: 24,
      width: (slotCount - 1) * 14.0 + 24,
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
          if (viewerSlot)
            Positioned(
              left: (visible.length + (overflow > 0 ? 1 : 0)) * 14.0,
              child: AnimatedScale(
                scale: viewerReposted ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: viewerReposted ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    key: const ValueKey('viewer-repost-avatar'),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: BuddyColors.green, width: 1.5),
                    ),
                    child: Avatar(
                      src: viewerAvatarUrl,
                      alt: viewerDisplayName ?? '?',
                      size: AvatarSize.xs,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
