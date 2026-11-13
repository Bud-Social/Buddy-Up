import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Golden gift burst — a shower of gift icons arcing upward plus a rising
/// sender chip, for every settled gift in the room (including your own).
class GiftBurstOverlay extends StatefulWidget {
  final Widget child;

  const GiftBurstOverlay({super.key, required this.child});

  @override
  State<GiftBurstOverlay> createState() => GiftBurstOverlayState();
}

class GiftBurstOverlayState extends State<GiftBurstOverlay> with TickerProviderStateMixin {
  final List<_GiftBurst> _bursts = [];
  final Random _rng = Random();

  /// Fire a burst. Call from the room whenever a `live_gift` lands.
  void burst(String artifactType, int quantity, String senderName, int total) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    final burst = _GiftBurst(
      artifactType: artifactType,
      quantity: quantity,
      senderName: senderName,
      total: total,
      controller: controller,
      particles: List.generate(
        12,
        (_) => _Particle(
          // Upper half-plane so the shower arcs upward.
          angle: _rng.nextDouble() * pi,
          distance: 60 + _rng.nextDouble() * 110,
          size: 18 + _rng.nextDouble() * 14,
          delay: _rng.nextDouble() * 0.25,
        ),
      ),
    );
    setState(() => _bursts.add(burst));
    controller.forward().whenComplete(() {
      if (mounted) setState(() => _bursts.remove(burst));
      controller.dispose();
    });
  }

  static IconData _artifactIcon(String artifact) {
    switch (artifact.toLowerCase()) {
      case 'fire':
      case 'flame':
        return Icons.local_fire_department;
      case 'heart':
        return Icons.favorite;
      case 'trophy':
        return Icons.emoji_events;
      case 'rocket':
        return Icons.rocket_launch;
      case 'diamond':
        return Icons.diamond;
      case 'crown':
        return Icons.workspace_premium;
      default:
        return Icons.card_giftcard;
    }
  }

  static String _artifactLabel(String artifact) {
    if (artifact.isEmpty) return 'Gift';
    return artifact[0].toUpperCase() + artifact.substring(1).replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._bursts.map(_buildBurst),
      ],
    );
  }

  Widget _buildBurst(_GiftBurst burst) {
    final progress = burst.controller.value;
    final chipOpacity = (1 - progress).clamp(0.0, 1.0);
    final chipLift = progress * 140;

    return AnimatedBuilder(
      animation: burst.controller,
      builder: (_, _) {
        return Stack(
          children: [
            // Particle shower — each shard travels along its own vector.
            for (final p in burst.particles) _buildParticle(burst, p, progress),
            // Rising sender chip.
            Positioned(
              left: 0,
              right: 0,
              bottom: 180 + chipLift,
              child: Opacity(
                opacity: chipOpacity,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: BuddyColors.gold.withValues(alpha: 0.7)),
                      boxShadow: [
                        BoxShadow(
                          color: BuddyColors.gold.withValues(alpha: 0.35),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _artifactIcon(burst.artifactType),
                          color: BuddyColors.gold,
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${burst.senderName} sent ${_artifactLabel(burst.artifactType)}'
                          '${burst.quantity > 1 ? ' ×${burst.quantity}' : ''}'
                          '${burst.total > 0 ? ' (+${burst.total})' : ''}',
                          style: const TextStyle(
                            color: Color(0xFFFDE68A),
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildParticle(_GiftBurst burst, _Particle p, double progress) {
    final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
    if (t <= 0) return const SizedBox.shrink();
    final eased = Curves.easeOutCubic.transform(t);
    // Angle is upper-half plane (0..π): radial shower upward.
    final angle = p.angle; // 0..π, upper half-plane
    final dx = cos(angle) * p.distance * eased;
    final vertical = sin(angle) * p.distance * eased + progress * 40;
    final opacity = (1 - t).clamp(0.0, 1.0);
    final rotation = t * (angle > pi / 2 ? 2.5 : -2.5);

    return Positioned(
      left: MediaQuery.of(context).size.width / 2 + dx - 12,
      bottom: 210 + vertical,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: rotation,
          child: Icon(
            _artifactIcon(burst.artifactType),
            size: p.size,
            color: Color.lerp(BuddyColors.gold, const Color(0xFFFFE9A8), t),
            shadows: const [
              Shadow(color: Colors.black87, blurRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _GiftBurst {
  final String artifactType;
  final int quantity;
  final String senderName;
  final int total;
  final AnimationController controller;
  final List<_Particle> particles;

  const _GiftBurst({
    required this.artifactType,
    required this.quantity,
    required this.senderName,
    required this.total,
    required this.controller,
    required this.particles,
  });
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final double delay;

  const _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });
}
