import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/constants.dart';

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

  static const _reactionIcons = {
    'pump': Icons.fitness_center,
    'fire': Icons.local_fire_department,
    'respect': Icons.emoji_events,
    'grind': Icons.repeat,
    'lets_go': Icons.rocket_launch,
    'haha': Icons.emoji_emotions,
    'too_hard': Icons.whatshot,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: reactionTypes.map((type) {
          final count = counts[type] ?? 0;
          final isActive = userReaction == type;
          return _ReactionChip(
            type: type,
            count: count,
            isActive: isActive,
            onTap: () {
              if (isActive) {
                onUnreact?.call();
              } else {
                onReact?.call(type);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final String type;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _ReactionChip({
    required this.type,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = ReactionBar._reactionIcons[type] ?? Icons.thumb_up;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: isActive ? BuddyColors.green.withValues(alpha: 0.15) : BuddyColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: isActive ? BuddyColors.green : BuddyColors.textSecondary),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    _formatCount(count),
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? BuddyColors.green : BuddyColors.textSecondary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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
