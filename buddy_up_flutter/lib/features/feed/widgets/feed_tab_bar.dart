import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';

class FeedTabBar extends StatelessWidget {
  final String activeTab;
  final List<String>? tabs;
  final void Function(String tab)? onTabChanged;

  const FeedTabBar({
    super.key,
    required this.activeTab,
    this.tabs,
    this.onTabChanged,
  });

  static const _tabLabels = {
    'for_you': 'For You',
    'following': 'Following',
    'communities': 'Communities',
    'videos': 'Bud Press',
  };

  @override
  Widget build(BuildContext context) {
    final effectiveTabs = tabs ?? feedTabs;
    // Web parity: a rounded surface rail of pill tabs. Active pill is solid
    // green with black text; inactive pills are secondary text on transparent.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: effectiveTabs.map((tab) {
            final isActive = tab == activeTab;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabChanged?.call(tab),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? BuddyColors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _tabLabels[tab] ?? tab,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive
                          ? BuddyColors.black
                          : BuddyColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
