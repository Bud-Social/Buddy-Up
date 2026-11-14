import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Verified-gym marker.
///
/// Filled circle — regular white, midlevel blue, executive gold — dumbbell
/// inside. Mirrors the web `VerifiedGymBadge` so both platforms agree.
class VerifiedGymBadge extends StatelessWidget {
  final bool verified;
  final String tier;
  final double size;

  const VerifiedGymBadge({
    super.key,
    required this.verified,
    this.tier = 'regular',
    this.size = 16,
  });

  Color get _fill => switch (tier) {
        'midlevel' => BuddyColors.blue,
        'executive' => BuddyColors.gold,
        _ => Colors.white,
      };

  Color get _iconColor => switch (tier) {
        'midlevel' => Colors.white,
        'executive' => BuddyColors.black,
        _ => BuddyColors.black,
      };

  @override
  Widget build(BuildContext context) {
    if (!verified) return const SizedBox.shrink();
    return Tooltip(
      message: 'Verified gym ($tier)',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _fill,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.fitness_center,
          size: size * 0.65,
          color: _iconColor,
        ),
      ),
    );
  }
}
