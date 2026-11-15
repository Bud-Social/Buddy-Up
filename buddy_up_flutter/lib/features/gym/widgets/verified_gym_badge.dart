import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Snapshot passed in so the badge can show its own tier explainer.
class GymTierCapacity {
  final int? cap;
  final int current;

  const GymTierCapacity({required this.cap, required this.current});
}

/// Verified-gym marker.
///
/// Filled circle — regular white, midlevel blue, executive gold — dumbbell
/// inside. Mirrors the web `VerifiedGymBadge` so both platforms agree.
///
/// When `capacity` is supplied, tapping the badge opens a bottom sheet
/// explaining what the tier means and how full the gym is.
class VerifiedGymBadge extends StatelessWidget {
  final bool verified;
  final String tier;
  final double size;
  final GymTierCapacity? capacity;

  const VerifiedGymBadge({
    super.key,
    required this.verified,
    this.tier = 'regular',
    this.size = 16,
    this.capacity,
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

  String get _label => switch (tier) {
        'midlevel' => 'Mid-Level gym',
        'executive' => 'Executive gym',
        _ => 'Regular gym',
      };

  String get _blurb => switch (tier) {
        'midlevel' =>
          'Established gym with a demonstrated track record hosting sessions and selling places.',
        'executive' =>
          'Flagship operation — top-tier facilities, staff and verification. Unlimited capacity.',
        _ => 'Standard verification — the gym exists, is real and is safe to host sessions.',
      };

  @override
  Widget build(BuildContext context) {
    if (!verified) return const SizedBox.shrink();

    final showDetails = capacity != null;
    final badge = Container(
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
    );

    if (!showDetails) {
      return Tooltip(
        message: 'Verified gym ($tier)',
        child: badge,
      );
    }

    return Tooltip(
      message: '$_label — tap for details',
      child: GestureDetector(
        onTap: () => _showExplainer(context),
        child: badge,
      ),
    );
  }

  void _showExplainer(BuildContext context) {
    final capacity = this.capacity!;
    final size = capacity.cap;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: _fill, shape: BoxShape.circle),
                    child: Icon(Icons.fitness_center, color: _iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _label,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _blurb,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_outlined, color: BuddyColors.gold, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: size == null
                          ? const Text(
                              'Unlimited members',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )
                          : Text(
                              '${capacity.current} of $size slots used',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
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
