import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../feed/providers/feed_provider.dart';

/// Per-post performance for the signed-in creator: views, likes, comments,
/// reposts, saves and shares. Mirrors the web CreatorInsights panel.
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await ref.read(feedRepositoryProvider).getCreatorInsights();
      final data = (raw['data'] as Map<String, dynamic>?) ?? {};
      final items = data['items'];
      final totals = <String, int>{};
      final parsed = <Map<String, dynamic>>[];
      if (items is List) {
        for (final item in items) {
          if (item is! Map) continue;
          final row = Map<String, dynamic>.from(item);
          parsed.add(row);
          for (final key in [
            'views',
            'likes',
            'comments',
            'reposts',
            'saves',
            'shares'
          ]) {
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
                                  '${item['saves'] ?? 0} saves · ${item['shares'] ?? 0} shares',
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

  const _Total(this.label, this.value, this.icon);

  static String _count(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '${(n / 1000000).toStringAsFixed(1)}m';
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
            _count(value),
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
