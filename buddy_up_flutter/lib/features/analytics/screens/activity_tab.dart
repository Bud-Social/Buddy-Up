import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/analytics.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/analytics_provider.dart';
import '../utils/analytics_format.dart';
import '../utils/analytics_share.dart';
import '../widgets/analytics_widgets.dart';
import '../widgets/activity_route_map.dart';
import '../widgets/activity_queue_banner.dart';
import 'gps_tracker_screen.dart';

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
  Set<String> _savedIds = {};
  Set<String> _highlightIds = {};
  String _activityView = 'recent';

  String _activityId(ActivityRecent a) => a.id.isNotEmpty
      ? a.id
      : '${a.activityType}:${a.startedAt ?? a.durationSeconds}';

  @override
  void initState() {
    super.initState();
    _loadActivityCollections();
    if (widget.summary == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(analyticsSummaryProvider.notifier).load();
      });
    }
  }

  Future<void> _loadActivityCollections() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _savedIds = (prefs.getStringList('activity_saved_ids') ?? []).toSet();
      _highlightIds = (prefs.getStringList('activity_highlight_ids') ?? [])
          .toSet();
    });
  }

  Future<void> _toggleActivityCollection(
    ActivityRecent a, {
    required bool highlight,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final id = _activityId(a);
    final next = Set<String>.from(highlight ? _highlightIds : _savedIds);
    next.contains(id) ? next.remove(id) : next.add(id);
    await prefs.setStringList(
      highlight ? 'activity_highlight_ids' : 'activity_saved_ids',
      next.toList(),
    );
    if (!mounted) return;
    setState(() {
      if (highlight) {
        _highlightIds = next;
      } else {
        _savedIds = next;
      }
    });
  }

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
    final durationMinutes = int.tryParse(_durationController.text) ?? 0;
    final duration = durationMinutes * 60;
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
      if (created['queued'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Saved on this device — it uploads when you reconnect.',
            ),
          ),
        );
      }
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
    final summaryState = ref.watch(analyticsSummaryProvider);
    final s = widget.summary ?? summaryState.summary?.activity;
    if (s == null) {
      return summaryState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const EmptyState(
                    icon: Icons.directions_run,
                    title: 'No activity data',
                  ),
                  if (summaryState.error != null)
                    FilledButton(
                      onPressed: () =>
                          ref.read(analyticsSummaryProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                ],
              ),
            );
    }

    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () => ref.read(analyticsSummaryProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ActivityQueueBanner(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'recent',
                  label: Text('Recent'),
                  icon: Icon(Icons.history),
                ),
                ButtonSegment(
                  value: 'saved',
                  label: Text('Saved'),
                  icon: Icon(Icons.bookmark_outline),
                ),
                ButtonSegment(
                  value: 'highlights',
                  label: Text('Highlights'),
                  icon: Icon(Icons.auto_awesome_outlined),
                ),
              ],
              selected: {_activityView},
              onSelectionChanged: (value) =>
                  setState(() => _activityView = value.first),
            ),
          ),
          // GPS tracker entry — hybrid keyless tracking, parity with web.
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder: (_) =>
                      GpsTrackerScreen(initialActivityType: _activityType),
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.gps_fixed, size: 18, color: Colors.black),
              label: Text(
                'Track with GPS',
                style: TextStyle(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
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
              title: 'Activity metrics',
              icon: Icons.pie_chart_outline,
            ),
            const SizedBox(height: 8),
            for (final t in s.byType) _typeMetricCard(t, s),
          ],
          if (s.recent.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionHeader(
              title: switch (_activityView) {
                'saved' => 'Saved activities',
                'highlights' => 'Activity highlights',
                _ => 'Recent',
              },
              icon: switch (_activityView) {
                'saved' => Icons.bookmark,
                'highlights' => Icons.auto_awesome,
                _ => Icons.history,
              },
            ),
            const SizedBox(height: 8),
            for (final a in s.recent)
              if (_activityView == 'recent' ||
                  (_activityView == 'saved' &&
                      _savedIds.contains(_activityId(a))) ||
                  (_activityView == 'highlights' &&
                      _highlightIds.contains(_activityId(a))))
                _activityTile(a),
          ],
        ],
      ),
    );
  }

  Widget _typeMetricCard(ActivityTypeBreakdown metric, ActivitySummary s) {
    final cs = Theme.of(context).colorScheme;
    final key = metric.label.toLowerCase();
    final detail = switch (key) {
      'walk' || 'walking' =>
        '${formatNumber(metric.distanceKm, decimals: 1)} km · ${formatDuration(metric.duration.round() * 60)} · ${s.totalSteps} steps total',
      'run' || 'running' =>
        '${formatNumber(metric.distanceKm, decimals: 1)} km · ${formatDuration(metric.duration.round() * 60)} · ${s.avgPace == null ? 'pace unavailable' : formatPace(s.avgPace)}',
      'cycle' || 'cycling' =>
        '${formatNumber(metric.distanceKm, decimals: 1)} km · ${formatDuration(metric.duration.round() * 60)} · ${metric.duration > 0 ? (metric.distanceKm / (metric.duration / 60)).toStringAsFixed(1) : '0.0'} km/h',
      'hike' || 'hiking' =>
        '${formatNumber(metric.distanceKm, decimals: 1)} km · ${formatDuration(metric.duration.round() * 60)} · ${metric.calories.round()} kcal',
      _ =>
        '${metric.count} sessions · ${formatDuration(metric.duration.round() * 60)} · ${metric.calories.round()} kcal',
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: cs.surface,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: BuddyColors.green.withValues(alpha: 0.14),
          child: Icon(_iconForActivity(key), color: BuddyColors.green),
        ),
        title: Text(
          metric.label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(detail, style: TextStyle(color: cs.onSurfaceVariant)),
        trailing: Text(
          '${metric.count}×',
          style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  IconData _iconForActivity(String type) => switch (type) {
    'walk' || 'walking' => Icons.directions_walk,
    'run' || 'running' => Icons.directions_run,
    'cycle' || 'cycling' => Icons.directions_bike,
    'hike' || 'hiking' => Icons.terrain,
    _ => Icons.fitness_center,
  };

  Widget _buildLogForm() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
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
                              : cs.onSurface,
                          fontSize: 12,
                        ),
                        backgroundColor: cs.surfaceContainerHighest,
                        side: BorderSide(color: cs.outlineVariant),
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
                    style: TextStyle(color: cs.onSurface),
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
                    style: TextStyle(color: cs.onSurface),
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
              style: TextStyle(color: cs.onSurface),
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
    final cs = Theme.of(context).colorScheme;
    final type = _activityTypes.firstWhere(
      (t) => t.key == a.activityType,
      orElse: () => (
        key: a.activityType,
        label: titleCase(a.activityType),
        icon: Icons.directions_run,
      ),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(type.icon, size: 18, color: BuddyColors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatNumber(a.distanceKm, decimals: 1)} km · ${formatDuration(a.durationSeconds)}'
                      '${a.steps > 0 ? ' · ${a.steps} steps' : ''}'
                      '${a.avgPace != null ? ' · ${formatPace(a.avgPace)}' : ''}',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatDate(a.startedAt),
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              Builder(
                builder: (anchor) => IconButton(
                  icon: const Icon(Icons.share_outlined, size: 18),
                  tooltip: 'Share activity',
                  color: BuddyColors.green,
                  onPressed: () => _share(a, type.label, anchor),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, size: 18),
                onSelected: (value) => _toggleActivityCollection(
                  a,
                  highlight: value == 'highlight',
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'saved',
                    child: Text(
                      _savedIds.contains(_activityId(a))
                          ? 'Remove from saved'
                          : 'Save activity',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'highlight',
                    child: Text(
                      _highlightIds.contains(_activityId(a))
                          ? 'Remove highlight'
                          : 'Add to highlights',
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (a.route.isNotEmpty) ...[
            const SizedBox(height: 10),
            ActivityRouteMap(route: a.route, height: 140),
          ],
        ],
      ),
    );
  }

  /// OS share sheet, falling back to copying the link — never throws.
  Future<void> _share(
    ActivityRecent a,
    String label,
    BuildContext anchor,
  ) async {
    await shareAnalyticsItem(
      context: context,
      sharePositionOrigin: shareOriginFor(anchor),
      title: '$label on BuddyUp',
      text: buildShareText(
        ShareFacts(
          label: label,
          durationMinutes: (a.durationSeconds / 60).round(),
          distanceKm: a.distanceKm,
          calories: a.caloriesBurned,
        ),
      ),
    );
  }
}
