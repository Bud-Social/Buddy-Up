import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GiftPicker extends StatelessWidget {
  final void Function(String artifact, int quantity, int total)? onSendGift;

  const GiftPicker({super.key, this.onSendGift});

  static const _gifts = [
    {'name': 'Fire', 'icon': Icons.local_fire_department, 'cost': 10},
    {'name': 'Heart', 'icon': Icons.favorite, 'cost': 25},
    {'name': 'Trophy', 'icon': Icons.emoji_events, 'cost': 50},
    {'name': 'Rocket', 'icon': Icons.rocket_launch, 'cost': 100},
    {'name': 'Diamond', 'icon': Icons.diamond, 'cost': 250},
    {'name': 'Crown', 'icon': Icons.workspace_premium, 'cost': 500},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: BuddyColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Send a Gift', style: TextStyle(color: BuddyColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: _gifts.length,
            itemBuilder: (_, i) {
              final gift = _gifts[i];
              return GestureDetector(
                onTap: () => onSendGift?.call(
                  gift['name'] as String,
                  1,
                  gift['cost'] as int,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: BuddyColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(gift['icon'] as IconData, color: BuddyColors.green, size: 28),
                      const SizedBox(height: 6),
                      Text(gift['name'] as String, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 12)),
                      Text('${gift['cost']}', style: const TextStyle(color: BuddyColors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
