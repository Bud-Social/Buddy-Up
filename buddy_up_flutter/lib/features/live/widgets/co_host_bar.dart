import 'package:flutter/material.dart';
import '../../../data/models/live.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';

class CoHostBar extends StatelessWidget {
  final List<CoHost> coHosts;

  const CoHostBar({super.key, required this.coHosts});

  @override
  Widget build(BuildContext context) {
    if (coHosts.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Text('Co-hosts:', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: coHosts.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    Avatar(src: coHosts[i].avatarUrl, alt: coHosts[i].displayName, size: AvatarSize.xs),
                    const SizedBox(width: 4),
                    Text(
                      coHosts[i].displayName,
                      style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
