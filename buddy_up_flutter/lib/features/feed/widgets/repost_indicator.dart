import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';
import '../../../shared/widgets/avatar.dart';

class RepostIndicator extends StatefulWidget {
  final List<ReposterData> reposters;
  final String username;
     final String? quoteBody;

  /// Set when the viewer reposted: their avatar pops into the stack with a
  /// scale/fade entrance (AnimatedSwitcher) and animates out on unrepost.
  final bool viewerReposted;
  final String? viewerAvatarUrl;
  final String? viewerDisplayName;

  /// View count from the original post, displayed when this is a repost row.
  final int? viewCount;

  const RepostIndicator({
    super.key,
    this.reposters = const [],
    required this.username,
        this.quoteBody,
    this.viewerReposted = false,
    this.viewerAvatarUrl,
    this.viewerDisplayName,
    this.viewCount,
  });

  @override
  State<RepostIndicator> createState() => _RepostIndicatorState();
}

class _RepostIndicatorState extends State<RepostIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.viewerReposted) {
      _pulseController.repeat(reverse: true);
    }
  }

    @override
  void didUpdateWidget(RepostIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-trigger pulse whenever the viewer repost state changes.
    if (widget.viewerReposted != oldWidget.viewerReposted) {
      if (widget.viewerReposted) {
        _pulseController
          ..duration = const Duration(milliseconds: 1500)
          ..repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final people = widget.reposters;
    // When the viewer reposted but the backend hasn't echoed them back yet,
    // still show the stack so the pop-in has a home.
    final showStack = people.isNotEmpty || widget.viewerReposted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: AnimatedSwitcher(
        // Use a stable key based ONLY on viewerReposted — the reposter count
        // changing is a normal data update, not a structural swap that should
        // reset the viewer's pulse animation.
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        ),
        // Stable key: only re-animates when viewerReposted toggles,
        // not when the reposters list updates.
        child: Row(
          key: ValueKey('repost-${widget.viewerReposted}'),
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: const Icon(
                  Icons.repeat,
                  size: 14,
                  color: BuddyColors.green,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (showStack) ...[
                                                _buildStackedAvatars(context, people),
                        const SizedBox(width: 8),
                      ],
                                            Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${widget.username} reposted',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: BuddyColors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.viewCount != null && widget.viewCount! > 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.visibility_outlined,
                                      size: 12,
                                      color: BuddyColors.textSecondary,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      _formatCount(widget.viewCount!),
                                      style: const TextStyle(
                                        color: BuddyColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.quoteBody != null && widget.quoteBody!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        widget.quoteBody!,
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
      ),
    );
  }

  Widget _buildStackedAvatars(BuildContext context, List<ReposterData> people) {
    final viewerSlot = (widget.viewerAvatarUrl ?? '').isNotEmpty;
    // Skip a backend echo of the viewer — the animated slot below owns it.
    final visible = people
        .where((r) =>
            !viewerSlot ||
            r.avatarUrl != widget.viewerAvatarUrl)
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
                scale: widget.viewerReposted ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: widget.viewerReposted ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    key: const ValueKey('viewer-repost-avatar'),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: BuddyColors.green, width: 1.5),
                    ),
                    child: Avatar(
                      src: widget.viewerAvatarUrl,
                      alt: widget.viewerDisplayName ?? '?',
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

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '${(count / 1000000).toStringAsFixed(1)}m';
  }
}
