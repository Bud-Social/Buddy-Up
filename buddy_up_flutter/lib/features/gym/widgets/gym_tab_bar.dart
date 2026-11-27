import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GymTabBar extends StatelessWidget {
  final int activeIndex;
  final bool showReviews;
  final void Function(int index)? onTabChanged;

  const GymTabBar({
    super.key,
    required this.activeIndex,
    this.showReviews = true,
    this.onTabChanged,
  });

  static List<String> tabsFor(bool showReviews) => [
        'Feed',
        'Schedule',
        'Events',
        'Lives',
        'Members',
        if (showReviews) 'Reviews',
        'About',
      ];

  @override
  Widget build(BuildContext context) {
    final tabs = tabsFor(showReviews);
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (_, i) {
          final isActive = i == activeIndex;
          return GestureDetector(
            onTap: () => onTabChanged?.call(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? BuddyColors.green : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  color: isActive ? BuddyColors.textPrimary : BuddyColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
