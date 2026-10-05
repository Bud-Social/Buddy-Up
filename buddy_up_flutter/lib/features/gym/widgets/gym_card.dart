import 'package:flutter/material.dart';
import '../../../data/models/gym.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';

class GymCard extends StatelessWidget {
  final Gym gym;
  final VoidCallback? onTap;

  const GymCard({super.key, required this.gym, this.onTap});

  @override
  Widget build(BuildContext context) {
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
                      if (gym.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.verified, color: BuddyColors.green, size: 16),
                        ),
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
                        const Icon(Icons.star, size: 14, color: BuddyColors.green),
                        const SizedBox(width: 4),
                        Text(
                          gym.averageRating!.toStringAsFixed(1),
                          style: const TextStyle(color: BuddyColors.green, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  if (gym.locationCity.isNotEmpty || gym.distanceKm != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 12, color: BuddyColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            gym.distanceKm != null
                                ? '${gym.distanceKm!.toStringAsFixed(gym.distanceKm! < 10 ? 1 : 0)} km away${gym.locationCity.isNotEmpty ? ' · ${gym.locationCity}' : ''}'
                                : gym.locationCity,
                            style: TextStyle(
                              color: gym.distanceKm != null ? BuddyColors.green : BuddyColors.textSecondary,
                              fontSize: 12,
                              fontWeight: gym.distanceKm != null ? FontWeight.w600 : FontWeight.normal,
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
            const Icon(Icons.chevron_right, color: BuddyColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
