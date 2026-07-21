import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RepostIndicator extends StatelessWidget {
  final String username;
  final String? quoteBody;

  const RepostIndicator({
    super.key,
    required this.username,
    this.quoteBody,
  });

  @override
  Widget build(BuildContext context) {
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
                Text(
                  '$username reposted',
                  style: const TextStyle(
                    color: BuddyColors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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
}
