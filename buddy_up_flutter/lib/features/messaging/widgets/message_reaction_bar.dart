import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MessageReactionBar extends StatelessWidget {
  final Map<String, int> reactions;
  final void Function(String emoji)? onReact;

  const MessageReactionBar({super.key, required this.reactions, this.onReact});

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.entries.map((e) {
          return Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: BuddyColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BuddyColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.key, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 2),
                Text(
                  '${e.value}',
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
