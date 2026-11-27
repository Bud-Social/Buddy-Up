import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';

/// Web parity: `AchievementsTab` from the profile page. Loads
/// `GET /achievements/?period=...` and renders the period picker, the
/// unlocked summary, then Earned / Locked grids.
class AchievementsTab extends StatefulWidget {
  const AchievementsTab({super.key});

  @override
  State<AchievementsTab> createState() => _AchievementsTabState();
}

class _AchievementsTabState extends State<AchievementsTab> {
  static const _periods = <String, String>{
    'daily': 'Daily',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'quarterly': 'Quarterly',
    'yearly': 'Yearly',
  };

  String _period = 'weekly';
  bool _loading = true;
  bool _error = false;
  List<Map<String, dynamic>> _items = const [];
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final res = await ApiClient().dio.get<dynamic>(
        '/achievements/',
        queryParameters: {'period': _period},
      );
      final body = res.data;
      final data = body is Map && body['data'] is Map
          ? body['data'] as Map
          : body;
      final map = data is Map ? data : const {};
      final items = (map['items'] as List?)
              ?.whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList() ??
          const <Map<String, dynamic>>[];
      if (!mounted) return;
      setState(() {
        _items = items;
        _summary = (map['summary'] as Map?)?.cast<String, dynamic>();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(color: BuddyColors.green),
      ));
    }
    if (_error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.trophy,
                size: 40,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Could not load achievements',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final earned = _items.where((i) => i['earned'] == true).toList();
    final locked = _items.where((i) => i['earned'] != true).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Period picker — rounded surface rail, active pill green.
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              for (final entry in _periods.entries)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_period == entry.key) return;
                      setState(() => _period = entry.key);
                      _load();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _period == entry.key
                            ? BuddyColors.green.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        entry.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _period == entry.key
                              ? BuddyColors.green
                              : BuddyColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_summary != null) _summaryCard(_summary!),
        const SizedBox(height: 16),
        if (_items.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'No achievements available yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          )
        else ...[
          if (earned.isNotEmpty) ...[
            _sectionLabel('Earned'),
            _grid(earned),
            const SizedBox(height: 20),
          ],
          if (locked.isNotEmpty) ...[
            _sectionLabel('Locked'),
            _grid(locked),
          ],
        ],
      ],
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      );

  Widget _grid(List<Map<String, dynamic>> items) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final item in items)
          SizedBox(width: 160, child: _achievementCard(item)),
      ],
    );
  }

  Widget _summaryCard(Map<String, dynamic> summary) {
    final total = (summary['total'] as num?)?.toInt() ?? 0;
    final unlocked = (summary['earned'] as num?)?.toInt() ?? 0;
    final ratio = total == 0 ? 0.0 : unlocked / total;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.trophy, size: 20, color: BuddyColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unlocked of $total unlocked',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor:
                        const AlwaysStoppedAnimation(BuddyColors.gold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievementCard(Map<String, dynamic> item) {
    final earned = item['earned'] == true;
    final tier = (item['tier'] as String?) ?? 'bronze';
    final tierColor = _tierColor(tier);
    final pct = ((item['progress_pct'] as num?)?.toDouble() ?? 0)
        .clamp(0.0, 100.0);
    final progress = (item['progress'] as num?)?.toInt() ?? 0;
    final threshold = (item['threshold'] as num?)?.toInt() ?? 0;
    final metricLabel = (item['metric_label'] as String?) ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: earned
              ? tierColor.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: earned
                  ? tierColor.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: earned
                ? Text(
                    (item['icon'] as String?) ?? '🏆',
                    style: const TextStyle(fontSize: 20),
                  )
                : Icon(
                    LucideIcons.lock,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            (item['title'] as String?) ?? '',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            (item['description'] as String?) ?? '',
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 10,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          if (earned)
            Text(
              '${_tierLabel(tier)} · Earned',
              style: TextStyle(
                color: tierColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 5,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(tierColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${pct >= 100 ? 'Ready to claim' : '${pct.floor()}%'} · '
              '${progress < threshold ? progress : threshold}/$threshold $metricLabel',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Color _tierColor(String tier) => switch (tier) {
        'silver' => const Color(0xFFCBD5E1),
        'gold' => BuddyColors.gold,
        'platinum' => const Color(0xFFA5F3FC),
        _ => const Color(0xFFD97706),
      };

  static String _tierLabel(String tier) => switch (tier) {
        'silver' => 'Silver',
        'gold' => 'Gold',
        'platinum' => 'Platinum',
        _ => 'Bronze',
      };
}
