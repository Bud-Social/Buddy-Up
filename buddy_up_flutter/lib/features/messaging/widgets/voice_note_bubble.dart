import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class VoiceNoteBubble extends StatelessWidget {
  final int durationMs;
  final bool isMine;

  const VoiceNoteBubble({super.key, required this.durationMs, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final seconds = (durationMs / 1000).floor();
    final formatted = '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMine ? Icons.play_arrow : Icons.play_arrow,
          color: BuddyColors.green, size: 20,
        ),
        const SizedBox(width: 8),
        Container(
          width: 100, height: 30,
          decoration: BoxDecoration(
            color: BuddyColors.surfaceRaised,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        const SizedBox(width: 8),
        Text(formatted, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}
