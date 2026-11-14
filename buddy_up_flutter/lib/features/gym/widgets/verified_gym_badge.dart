import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Verified-gym marker: a dumbbell inside a blue tick circle.
///
/// Mirrors the web `VerifiedGymBadge` so the two platforms agree on what
/// "registered and verified business" looks like.
class VerifiedGymBadge extends StatelessWidget {
  final bool verified;
  final double size;

  const VerifiedGymBadge({super.key, required this.verified, this.size = 16});

  @override
  Widget build(BuildContext context) {
    if (!verified) return const SizedBox.shrink();
    return Tooltip(
      message: 'Verified gym',
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: BuddyColors.blue,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.fitness_center,
          size: size * 0.65,
          color: Colors.white,
        ),
      ),
    );
  }
}
