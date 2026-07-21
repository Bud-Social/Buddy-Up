import 'package:flutter/material.dart';
import '../../../data/models/gym.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';

class MemberTile extends StatelessWidget {
  final GymMembership membership;
  final bool isOwner;
  final void Function(String userId, String action)? onManage;

  const MemberTile({
    super.key,
    required this.membership,
    this.isOwner = false,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Avatar(
            src: membership.memberData.avatarUrl,
            alt: membership.memberData.displayName,
            size: AvatarSize.md,
            verificationStatus: membership.memberData.verificationStatus,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  membership.memberData.displayName,
                  style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
                ),
                Text(
                  '@${membership.memberData.username}',
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _roleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              membership.role.replaceAll('_', ' '),
              style: TextStyle(color: _roleColor, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
          if (isOwner && membership.role != 'owner')
            PopupMenuButton<String>(
              color: BuddyColors.surface,
              icon: const Icon(Icons.more_horiz, color: BuddyColors.textSecondary, size: 18),
              onSelected: (action) => onManage?.call(membership.memberId, action),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'change_role', child: Text('Change role', style: TextStyle(color: BuddyColors.textPrimary))),
                const PopupMenuItem(value: 'remove', child: Text('Remove', style: TextStyle(color: BuddyColors.red))),
              ],
            ),
        ],
      ),
    );
  }

  Color get _roleColor {
    switch (membership.role) {
      case 'owner':
        return BuddyColors.green;
      case 'co_owner':
        return Colors.amber;
      case 'trainer':
        return Colors.blue;
      case 'moderator':
        return Colors.purple;
      default:
        return BuddyColors.textSecondary;
    }
  }
}
