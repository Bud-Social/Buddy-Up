import 'package:flutter/material.dart';
import '../../../data/models/gym.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';
import 'verified_gym_badge.dart';

class GymCard extends StatelessWidget {
  final Gym gym;
  final VoidCallback? onTap;

  const GymCard({super.key, required this.gym, this.onTap});

  (String icon, String text, bool highlight)? _locationInfo() {
    final summary = gym.locationSummary;
    final cities = summary?.cities ??
        (gym.locationCity.isNotEmpty ? [gym.locationCity] : <String>[]);
    final nearest = summary?.nearestKm ?? gym.distanceKm;
    final count = summary?.venueCount ?? 0;

    if (count > 1) {
      final where = cities.isNotEmpty
          ? cities.take(2).join(' · ')
          : '$count locations';
      final text = nearest != null ? '$where · nearest ${_fmtKm(nearest)}' : where;
      return ('multi', text, nearest != null);
    }
    if (cities.isNotEmpty) return ('single', cities.first, false);
    return null;
  }

  String _fmtKm(double km) =>
      km < 10 ? '${km.toStringAsFixed(1)} km' : '${km.round()} km';

  @override
  Widget build(BuildContext context) {
    final followed = gym.followedMembers;
    final followedCount = gym.followedMembersCount;
    final shown = followed.take(4).toList();
    final location = _locationInfo();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: BuddyColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Avatar(
              src: gym.logoUrl.isNotEmpty ? gym.logoUrl : null,
              alt: gym.name,
              size: AvatarSize.lg,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          gym.name,
                          style: const TextStyle(
                            color: BuddyColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      VerifiedGymBadge(verified: gym.isVerified, tier: gym.tier),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 14, color: BuddyColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${gym.memberCount} members',
                        style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                      ),
                      if (gym.averageRating != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.star, size: 14, color: BuddyColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          gym.averageRating!.toStringAsFixed(1),
                          style: const TextStyle(color: BuddyColors.gold, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  if (location != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.place,
                          size: 12,
                          color: location.$3 ? BuddyColors.green : BuddyColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location.$2,
                            style: TextStyle(
                              color: location.$3 ? BuddyColors.green : BuddyColors.textSecondary,
                              fontSize: 12,
                              fontWeight: location.$3 ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (gym.deliveryModes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final mode in gym.deliveryModes)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: BuddyColors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              mode.replaceAll('_', ' '),
                              style: const TextStyle(color: BuddyColors.green, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (followedCount > 0) ...[
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 28,
                    child: Stack(
                      children: [
                        for (var i = 0; i < shown.length; i++)
                          Padding(
                            padding: EdgeInsets.only(left: i * 18.0),
                            child: Avatar(
                              src: shown[i].avatarUrl.isNotEmpty ? shown[i].avatarUrl : null,
                              alt: shown[i].displayName.isNotEmpty ? shown[i].displayName : shown[i].username,
                              size: AvatarSize.sm,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    followedCount > 1
                        ? '${shown.first.displayName.isNotEmpty ? shown.first.displayName : shown.first.username} +${followedCount - 1} others'
                        : (followed.first.displayName.isNotEmpty ? followed.first.displayName : followed.first.username),
                    style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 10),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ] else
              const Icon(Icons.chevron_right, color: BuddyColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
