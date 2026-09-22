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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: effectiveTabs.map((tab) {
          final isActive = tab == activeTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged?.call(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? BuddyColors.green : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _tabLabels[tab] ?? tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive ? BuddyColors.textPrimary : BuddyColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
