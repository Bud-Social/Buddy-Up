import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../feed/providers/feed_provider.dart';

/// Per-post performance for the signed-in creator: views, interactions,
/// watch time, average focus time, likes, comments, reposts, saves and
/// shares. Mirrors the web CreatorInsights panel.
class CreatorInsightsScreen extends ConsumerStatefulWidget {
  const CreatorInsightsScreen({super.key});

  @override
  ConsumerState<CreatorInsightsScreen> createState() =>
      _CreatorInsightsScreenState();
}

class _CreatorInsightsScreenState
    extends ConsumerState<CreatorInsightsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];
  Map<String, int> _totals = const {};

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  /// Human duration for watch/focus metrics: "1m 23s" / "12s" / "0s".
  static String _formatDuration(num ms) {
    final totalSec = (ms / 1000).round().clamp(0, 1 << 31);
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await ref.read(feedRepositoryProvider).getCreatorInsights();
      final data = (raw['data'] as Map<String, dynamic>?) ?? {};
      final items = data['items'];
      // Prefer the server account-level rollup; fall back to client totals.
      final summary = (data['summary'] as Map?) == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(data['summary'] as Map);
      final totals = <String, int>{};
      for (final key in summary.keys) {
        final v = summary[key];
        if (v is num) totals[key] = v.toInt();
      }
      final parsed = <Map<String, dynamic>>[];
      if (items is List) {
        for (final item in items) {
          if (item is! Map) continue;
          final row = Map<String, dynamic>.from(item);
          parsed.add(row);
          // Server rollup wins; otherwise accumulate per-row client-side.
          if (totals['interactions'] == null) {
            final rowInteractions = (row['interactions'] as num?)?.toInt() ??
                ((row['likes'] as num?)?.toInt() ?? 0) +
                    ((row['comments'] as num?)?.toInt() ?? 0) +
                    ((row['reposts'] as num?)?.toInt() ?? 0) +
                    ((row['saves'] as num?)?.toInt() ?? 0) +
                    ((row['shares'] as num?)?.toInt() ?? 0);
            totals['interactions'] =
                (totals['interactions'] ?? 0) + rowInteractions;
          }
          for (final key in [
            'views',
            'likes',
            'comments',
            'reposts',
            'saves',
            'shares',
            'watch_ms',
          ]) {
            if (totals[key] != null) continue; // server rollup wins
            totals[key] =
                (totals[key] ?? 0) + ((row[key] as num?)?.toInt() ?? 0);
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _items = parsed;
        _totals = totals;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load insights. Check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Content insights')),
      body: _loading
          ? const PageLoader()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _items.isEmpty
                  ? const Center(
                      child: Text(
                        'No posts yet — publish something to see performance.',
                        style: TextStyle(color: BuddyColors.textSecondary),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _Total('Views', _totals['views'] ?? 0, Icons.visibility_outlined),
                              _Total('Interactions', _totals['interactions'] ?? 0, Icons.bolt_outlined),
                              _Total('Watch time', _totals['watch_ms'] ?? 0, Icons.play_circle_outline, duration: true),
                              _Total('Avg focus', _totals['avg_focus_ms'] ?? 0, Icons.timer_outlined, duration: true),
                              _Total('Likes', _totals['likes'] ?? 0, Icons.favorite_border),
                              _Total('Comments', _totals['comments'] ?? 0, Icons.chat_bubble_outline),
                              _Total('Reposts', _totals['reposts'] ?? 0, Icons.repeat),
                              _Total('Saves', _totals['saves'] ?? 0, Icons.bookmark_border),
                              _Total('Shares', _totals['shares'] ?? 0, Icons.share_outlined),
                            ],
                          ),
                          const SizedBox(height: 16),
                          for (final item in _items)
                            Card(
                              color: BuddyColors.surface,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  'Post ${(item['post_id'] as String? ?? '').substring(0, 8)}…',
                                  style: const TextStyle(
                                    color: BuddyColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  '${item['views'] ?? 0} views · ${item['likes'] ?? 0} likes · '
                                  '${item['comments'] ?? 0} comments · ${item['reposts'] ?? 0} reposts · '
                                  '${item['saves'] ?? 0} saves · ${item['shares'] ?? 0} shares\n'
                                  'Focus ${_formatDuration((item['avg_focus_ms'] as num?) ?? 0)} · '
                                  'Watch ${_formatDuration((item['watch_ms'] as num?) ?? 0)}',
                                  style: const TextStyle(
                                    color: BuddyColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: BuddyColors.textSecondary,
                                ),
                                onTap: () => context.push(
                                  '/feed/${item['post_id']}',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }
}

class _Total extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  /// When true, [value] is a millisecond duration rendered as "1m 23s".
  final bool duration;

  const _Total(this.label, this.value, this.icon, {this.duration = false});

  static String _count(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '${(n / 1000000).toStringAsFixed(1)}m';
  }

  static String _duration(num ms) {
    final totalSec = (ms / 1000).round().clamp(0, 1 << 31);
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: BuddyColors.green),
          const SizedBox(height: 4),
          Text(
            duration ? _duration(value) : _count(value),
            style: const TextStyle(
              color: BuddyColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
