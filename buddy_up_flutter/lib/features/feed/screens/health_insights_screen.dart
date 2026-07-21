import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../core/theme/app_theme.dart';

class HealthInsightsScreen extends ConsumerStatefulWidget {
  const HealthInsightsScreen({super.key});

  @override
  ConsumerState<HealthInsightsScreen> createState() => _HealthInsightsScreenState();
}

class _HealthInsightsScreenState extends ConsumerState<HealthInsightsScreen> {
  String _period = 'weekly';
  Map<String, dynamic>? _data;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = ref.read(feedRepositoryProvider);
      final raw = await repo.getHealthInsights(period: _period);
      setState(() { _data = raw['data'] as Map<String, dynamic>?; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Insights'),
        actions: [
          PopupMenuButton<String>(
            color: BuddyColors.surface,
            icon: const Icon(Icons.date_range),
            onSelected: (p) {
              _period = p;
              _load();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'weekly', child: Text('Weekly', style: TextStyle(color: BuddyColors.textPrimary))),
              const PopupMenuItem(value: 'monthly', child: Text('Monthly', style: TextStyle(color: BuddyColors.textPrimary))),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const PageLoader()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _data != null
                  ? _buildContent()
                  : const Center(child: Text('No data available', style: TextStyle(color: BuddyColors.textSecondary))),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard('Workouts', _data!['workouts']?.toString() ?? '0', Icons.fitness_center),
        _buildCard('Active Days', _data!['active_days']?.toString() ?? '0', Icons.calendar_today),
        _buildCard('Calories Burned', _data!['calories_burned']?.toString() ?? '0', Icons.local_fire_department),
        _buildCard('Streak', '${_data!['streak']?.toString() ?? '0'} days', Icons.whatshot),
      ],
    );
  }

  Widget _buildCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BuddyColors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: BuddyColors.green, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                  style: const TextStyle(
                    color: BuddyColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(title,
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
