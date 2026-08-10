import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/analytics.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/analytics_provider.dart';
import '../utils/analytics_format.dart';
import '../widgets/analytics_widgets.dart';

const List<({String key, String label, IconData icon})> _activityTypes = [
  (key: 'walk', label: 'Walk', icon: Icons.directions_walk),
  (key: 'run', label: 'Run', icon: Icons.directions_run),
  (key: 'hike', label: 'Hike', icon: Icons.terrain),
  (key: 'cycle', label: 'Cycle', icon: Icons.directions_bike),
];

class ActivityTab extends ConsumerStatefulWidget {
  final ActivitySummary? summary;

  const ActivityTab({super.key, this.summary});

  @override
  ConsumerState<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends ConsumerState<ActivityTab> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _caloriesController = TextEditingController();
  String _activityType = 'walk';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _durationController.dispose();
    _distanceController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final duration = int.tryParse(_durationController.text) ?? 0;
    final distanceMeters =
        (double.tryParse(_distanceController.text) ?? 0) * 1000;
    final calories = double.tryParse(_caloriesController.text);
    final avgPace = duration > 0 && distanceMeters > 0
        ? duration / (distanceMeters / 1000)
        : null;

    final data = <String, dynamic>{
      'activity_type': _activityType,
      'source': 'manual',
      'duration_seconds': duration,
      'distance_meters': distanceMeters,
      'avg_pace': avgPace,
      'calories_burned': ?calories,
    };

    final created = await ref
        .read(analyticsLogProvider.notifier)
        .logActivity(data);
    setState(() => _isSubmitting = false);
    if (!mounted) return;
    if (created != null) {
      _formKey.currentState!.reset();
      _durationController.clear();
      _distanceController.clear();
      _caloriesController.clear();
      await ref.read(analyticsSummaryProvider.notifier).refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not log activity. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    if (s == null) {
      return const EmptyState(
        icon: Icons.directions_run,
        title: 'No activity data',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(analyticsSummaryProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              StatCard(
                label: 'Distance',
                value: '${formatNumber(s.totalDistanceKm, decimals: 1)} km',
                icon: Icons.route,
              ),
              StatCard(
                label: 'Time Active',
                value: formatDuration(s.totalDurationSeconds),
                icon: Icons.timer_outlined,
              ),
              StatCard(
                label: 'Calories',
                value: formatNumber(s.totalCaloriesBurned),
                icon: Icons.local_fire_department,
                accent: BuddyColors.red,
              ),
              StatCard(
                label: 'Steps',
                value: formatNumber(s.totalSteps.toDouble()),
                icon: Icons.directions_walk,
                accent: BuddyColors.gold,
              ),
            ],
          ),
          if (s.avgPace != null) ...[
            const SizedBox(height: 12),
            StatCard(
              label: 'Avg Pace',
              value: formatPace(s.avgPace),
              icon: Icons.speed,
            ),
          ],
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Log Activity',
            icon: Icons.add_circle_outline,
          ),
          const SizedBox(height: 12),
          _buildLogForm(),
          if (s.byType.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionHeader(
              title: 'By Type',
              icon: Icons.pie_chart_outline,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in s.byType)
                  Chip(
                    label: Text(
                      '${t.label} · ${formatNumber(t.distanceKm, decimals: 1)}km',
                    ),
                    backgroundColor: BuddyColors.surface,
                    side: const BorderSide(color: BuddyColors.surfaceRaised),
                    labelStyle: const TextStyle(
                      color: BuddyColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
          if (s.recent.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionHeader(title: 'Recent', icon: Icons.history),
            const SizedBox(height: 8),
            for (final a in s.recent) _activityTile(a),
          ],
        ],
      ),
    );
  }

  Widget _buildLogForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BuddyColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (final t in _activityTypes)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ChoiceChip(
                        label: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(t.icon, size: 16),
                            const SizedBox(width: 4),
                            Text(t.label),
                          ],
                        ),
                        selected: _activityType == t.key,
                        onSelected: (_) =>
                            setState(() => _activityType = t.key),
                        selectedColor: BuddyColors.green.withValues(
                          alpha: 0.25,
                        ),
                        labelStyle: TextStyle(
                          color: _activityType == t.key
                              ? BuddyColors.green
                              : BuddyColors.textPrimary,
                          fontSize: 12,
                        ),
                        backgroundColor: BuddyColors.surfaceRaised,
                        side: const BorderSide(
                          color: BuddyColors.surfaceRaised,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Minutes'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _distanceController,
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Km'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _caloriesController,
              style: const TextStyle(color: BuddyColors.textPrimary),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Calories (optional)',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(_isSubmitting ? 'Logging…' : 'Log Activity'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityTile(ActivityRecent a) {
    final type = _activityTypes.firstWhere(
      (t) => t.key == a.activityType,
      orElse: () => (
        key: a.activityType,
        label: a.activityType,
        icon: Icons.directions_run,
      ),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BuddyColors.border),
      ),
      child: Row(
        children: [
          Icon(type.icon, size: 18, color: BuddyColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: const TextStyle(
                    color: BuddyColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatNumber(a.distanceKm, decimals: 1)} km · ${formatDuration(a.durationSeconds)}',
                  style: const TextStyle(
                    color: BuddyColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatDate(a.startedAt),
            style: const TextStyle(
              color: BuddyColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
