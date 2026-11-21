import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/emoji_utils.dart';

/// Reaction picker used on feed cards. Values are emoji glyphs (the format the
/// API stores and the web client sends); legacy short names are normalized so
/// older rows still display and toggle correctly.
class ReactionBar extends StatelessWidget {
  final Map<String, int> counts;
  final String? userReaction;
  final void Function(String reaction)? onReact;
  final void Function()? onUnreact;

  const ReactionBar({
    super.key,
    required this.counts,
    this.userReaction,
    this.onReact,
    this.onUnreact,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = normalizeReactionCounts(counts);
    final active = userReaction == null ? null : toReactionEmoji(userReaction!);
    final emojis = <String>[
      ...reactionEmojis,
      for (final key in normalized.keys)
        if (!reactionEmojis.contains(key) && (normalized[key] ?? 0) > 0) key,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final emoji in emojis)
            _ReactionChip(
              emoji: emoji,
              count: normalized[emoji] ?? 0,
              isActive: active == emoji,
              onTap: () {
                if (active == emoji) {
                  onUnreact?.call();
                } else {
                  onReact?.call(emoji);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final String emoji;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _ReactionChip({
    required this.emoji,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: isActive
            ? BuddyColors.green.withValues(alpha: 0.15)
            : BuddyColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    _formatCount(count),
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive
                          ? BuddyColors.green
                          : BuddyColors.textSecondary,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '${(count / 1000000).toStringAsFixed(1)}m';
  }
}
