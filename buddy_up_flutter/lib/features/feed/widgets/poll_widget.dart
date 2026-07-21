import 'package:flutter/material.dart';
import '../../../data/models/post.dart';
import '../../../core/theme/app_theme.dart';

class PollWidget extends StatelessWidget {
  final Poll poll;
  final String? postId;
  final void Function(String postId, List<String> optionIds)? onVote;

  const PollWidget({
    super.key,
    required this.poll,
    this.postId,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final totalVotes = poll.totalVotes;
    final isClosed = poll.isClosed;
    final hasVoted = poll.userVotedOptionIds.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.question,
            style: const TextStyle(
              color: BuddyColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...poll.options.map((option) => _PollOptionBar(
            option: option,
            totalVotes: totalVotes,
            isClosed: isClosed || hasVoted,
            onTap: () {
              if (!isClosed && !hasVoted && postId != null) {
                onVote?.call(postId!, [option.id]);
              }
            },
          )),
          const SizedBox(height: 6),
          Text(
            '${_formatCount(totalVotes)} votes${isClosed ? ' · Closed' : ''}',
            style: const TextStyle(
              color: BuddyColors.textSecondary,
              fontSize: 12,
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

class _PollOptionBar extends StatelessWidget {
  final PollOption option;
  final int totalVotes;
  final bool isClosed;
  final VoidCallback? onTap;

  const _PollOptionBar({
    required this.option,
    required this.totalVotes,
    required this.isClosed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalVotes > 0 ? (option.voteCount / totalVotes) * 100 : 0.0;
    final isSelected = option.userVoted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isClosed ? null : onTap,
          child: Stack(
            children: [
              if (isClosed || option.userVoted)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: (percentage / 100) * MediaQuery.of(context).size.width * 0.85,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? BuddyColors.green.withValues(alpha: 0.2)
                              : BuddyColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.text,
                        style: TextStyle(
                          color: BuddyColors.textPrimary,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isClosed || option.userVoted)
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: isSelected ? BuddyColors.green : BuddyColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle, color: BuddyColors.green, size: 18),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
