import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/analytics.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/analytics_provider.dart';
import '../utils/analytics_format.dart';

class ReportTab extends ConsumerStatefulWidget {
  final String period;

  const ReportTab({super.key, required this.period});

  @override
  ConsumerState<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends ConsumerState<ReportTab> {
  AnalyticsReportResult? _report;
  bool _isGenerating = false;
  bool _isSharing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_generate);
  }

  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });
    try {
      final repo = ref.read(analyticsRepositoryProvider);
      final raw = await repo.generateReport(period: widget.period);
      if (!mounted) return;
      setState(() {
        _report = AnalyticsReportResult.fromJson(
          raw['data'] as Map<String, dynamic>,
        );
        _isGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isGenerating = false;
      });
    }
  }

  Future<void> _share() async {
    setState(() => _isSharing = true);
    try {
      final repo = ref.read(analyticsRepositoryProvider);
      await repo.shareReport({'period': widget.period});
      if (!mounted) return;
      setState(() => _isSharing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report shared to your feed.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSharing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isGenerating) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: BuddyColors.green,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Generating report…',
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }
    if (_error != null && _report == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not generate report',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    final report = _report;
    if (report == null) {
      return const EmptyState(icon: Icons.bar_chart, title: 'No report yet');
    }

    final s = report.data;
    return RefreshIndicator(
      onRefresh: _generate,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.insights, color: BuddyColors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Progress Report',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      titleCase(widget.period),
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _reportStat('Workouts', '${s.workouts.count}'),
                _reportStat(
                  'Distance',
                  '${formatNumber(s.activity.totalDistanceKm, decimals: 1)} km',
                ),
                _reportStat(
                  'Calories Logged',
                  formatNumber(s.nutrition.totalCalories),
                ),
                _reportStat(
                  'Weight',
                  s.body.latestWeightKg != null
                      ? '${formatNumber(s.body.latestWeightKg!, decimals: 1)} kg'
                      : '—',
                ),
                _reportStat('Lives Joined', '${s.lives.joinedCount}'),
                _reportStat('Spent', '${s.spending.totalArtifactsSpent}'),
              ],
            ),
          ),
          if (report.imageUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                report.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 240,
                    color: cs.surface,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: BuddyColors.green,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, _, _) => Container(
                  height: 200,
                  color: cs.surface,
                  child: Center(
                    child: Text(
                      'Report image unavailable',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Regenerate'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _share,
                  icon: _isSharing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share),
                  label: Text(_isSharing ? 'Sharing…' : 'Share'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reportStat(String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
