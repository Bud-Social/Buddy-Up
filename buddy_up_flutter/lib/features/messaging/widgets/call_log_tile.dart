import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/messaging.dart';
import '../../../core/theme/app_theme.dart';

class CallLogTile extends StatelessWidget {
  final CallLog log;

  const CallLogTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final isAudio = log.callType == 'audio';
    final isMissed = log.status == 'missed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            isAudio ? Icons.phone : Icons.videocam,
            color: isMissed ? BuddyColors.red : BuddyColors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMissed ? 'Missed ${isAudio ? "call" : "video call"}' : isAudio ? 'Call' : 'Video call',
                  style: TextStyle(
                    color: isMissed ? BuddyColors.red : BuddyColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatDuration(log.durationSeconds),
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(log.createdAt),
            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return 'No answer';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return DateFormat.jm().format(dt);
  }
}
