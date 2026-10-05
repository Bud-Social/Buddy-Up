import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/analytics.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/analytics_provider.dart';
import '../utils/analytics_format.dart';
import '../utils/analytics_share.dart';
import '../utils/workout_types.dart';
import '../widgets/analytics_widgets.dart';

const List<int> _durationPresets = [15, 30, 45, 60];

/// A history row, from either the full workouts endpoint (preferred — carries
/// the category and distance a share needs) or the summary's recent list.
class _WorkoutRow {
  final String id;
  final String workoutType;
  final String category;
  final String exercise;
  final int durationMinutes;
  final double? distanceKm;
  final double? calories;
  final String? performedAt;

  const _WorkoutRow({
    required this.id,
    required this.workoutType,
    required this.category,
    required this.exercise,
    required this.durationMinutes,
    this.distanceKm,
    this.calories,
    this.performedAt,
  });

  factory _WorkoutRow.fromJson(Map<String, dynamic> json) {
    final meters = (json['distance_meters'] as num?)?.toDouble();
    final km = (json['distance_km'] as num?)?.toDouble() ??
        (meters != null && meters > 0 ? meters / 1000 : null);
    return _WorkoutRow(
      id: json['id'] as String? ?? '',
      workoutType: json['workout_type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      exercise: json['exercise'] as String? ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.round() ?? 0,
      distanceKm: km,
      calories: (json['calories_burned'] as num?)?.toDouble(),
      performedAt: json['performed_at'] as String?,
    );
  }

  factory _WorkoutRow.fromSummary(WorkoutRecent w) => _WorkoutRow(
        id: '',
        workoutType: w.workoutType,
        category: '',
        exercise: w.exercise,
        durationMinutes: w.durationMinutes,
        calories: w.caloriesBurned,
        performedAt: w.performedAt,
      );
}

class WorkoutsTab extends ConsumerStatefulWidget {
  final WorkoutSummary? summary;

  const WorkoutsTab({super.key, this.summary});

  @override
  ConsumerState<WorkoutsTab> createState() => _WorkoutsTabState();
}

class _WorkoutsTabState extends ConsumerState<WorkoutsTab> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _roundsController = TextEditingController();
  final _distanceController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _styleController = TextEditingController();
  final _focusController = TextEditingController();
  final _sportController = TextEditingController();
  final _durationController = TextEditingController();
  String _workoutType = 'strength';
  String _category = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadHistory);
  }

  Future<void> _loadHistory() {
    return ref.read(analyticsLogProvider.notifier).loadWorkouts();
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _roundsController.dispose();
    _distanceController.dispose();
    _caloriesController.dispose();
    _styleController.dispose();
    _focusController.dispose();
    _sportController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  /// Change type and immediately drop the fields the new type can't record, so
  /// a stale rep count can never ride along on a yoga log.
  void _selectType(String key, WorkoutTypeSpecs specs) {
    final spec = specs.specFor(key);
    setState(() {
      _workoutType = key;
      _category = normalizeCategory(spec, _category);
      if (!spec.has('exercise')) _exerciseController.clear();
      if (!spec.has('sets')) _setsController.clear();
      if (!spec.has('reps')) _repsController.clear();
      if (!spec.has('weight_kg')) _weightController.clear();
      if (!spec.has('rounds')) _roundsController.clear();
      if (!spec.has('distance_km')) _distanceController.clear();
      if (!spec.has('calories_burned')) _caloriesController.clear();
      if (!spec.has('style')) _styleController.clear();
      if (!spec.has('focus')) _focusController.clear();
      if (!spec.has('sport')) _sportController.clear();
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _exerciseController.clear();
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
    _roundsController.clear();
    _distanceController.clear();
    _caloriesController.clear();
    _styleController.clear();
    _focusController.clear();
    _sportController.clear();
    _durationController.clear();
    setState(() {
      _workoutType = 'strength';
      _category = '';
    });
  }

  Future<void> _submit(WorkoutTypeSpec spec) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    // Only what this type records goes on the wire.
    final data = <String, dynamic>{
      'workout_type': _workoutType,
      // Cardio and the distance sports have no categories: '' is valid, a
      // leftover category from another type would be a 400.
      'category': normalizeCategory(spec, _category),
    };
    final exercise = _exerciseController.text.trim();
    final sets = int.tryParse(_setsController.text);
    final reps = int.tryParse(_repsController.text);
    final weight = double.tryParse(_weightController.text);
    final rounds = int.tryParse(_roundsController.text);
    final distanceKm = double.tryParse(_distanceController.text);
    final calories = double.tryParse(_caloriesController.text);
    final duration = int.tryParse(_durationController.text);
    if (spec.has('exercise') && exercise.isNotEmpty) data['exercise'] = exercise;
    if (spec.has('sets') && sets != null) data['sets'] = sets;
    if (spec.has('reps') && reps != null) data['reps'] = reps;
    if (spec.has('weight_kg') && weight != null) data['weight_kg'] = weight;
    if (spec.has('rounds') && rounds != null) data['rounds'] = rounds;
    // The form collects kilometres; the API stores meters.
    if (spec.has('distance_km') && distanceKm != null && distanceKm > 0) {
      data['distance_meters'] = (distanceKm * 1000).round();
    }
    if (spec.has('calories_burned') && calories != null) {
      data['calories_burned'] = calories;
    }
    final style = _styleController.text.trim();
    if (spec.has('style') && style.isNotEmpty) data['style'] = style;
    final focus = _focusController.text.trim();
    if (spec.has('focus') && focus.isNotEmpty) data['focus'] = focus;
    final sport = _sportController.text.trim();
    if (spec.has('sport') && sport.isNotEmpty) data['sport'] = sport;
    if (duration != null) data['duration_minutes'] = duration;

    final created = await ref
        .read(analyticsLogProvider.notifier)
        .logWorkout(data);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (created != null) {
      _resetForm();
      await ref.read(analyticsSummaryProvider.notifier).refresh();
      await _loadHistory();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not log workout. Please try again.'),
        ),
      );
    }
  }

  Future<void> _share(
    _WorkoutRow r,
    BuildContext anchor,
    WorkoutTypeSpecs specs,
  ) async {
    final label = specs.specFor(r.workoutType).label;
    await shareAnalyticsItem(
      context: context,
      sharePositionOrigin: shareOriginFor(anchor),
      title: '$label on BuddyUp',
      text: buildShareText(
        ShareFacts(
          label: label,
          category: r.category,
          durationMinutes: r.durationMinutes,
          distanceKm: r.distanceKm,
          calories: r.calories,
          detail: r.exercise.isEmpty ? null : r.exercise,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    if (s == null) {
      return const EmptyState(
        icon: Icons.fitness_center,
        title: 'No workout data',
      );
    }

    final cs = Theme.of(context).colorScheme;
    final specs = workoutTypesOrLocal(ref.watch(workoutTypesProvider));
    final spec = specs.specFor(_workoutType);
    final history = ref.watch(analyticsLogProvider).items;
    // The workouts endpoint is unpaginated — keep the list to a screenful of
    // recent sessions rather than rendering a whole training archive.
    final rows = [
      for (final j in history.take(50)) _WorkoutRow.fromJson(j),
    ];
    final recent = rows.isEmpty
        ? s.recent.map(_WorkoutRow.fromSummary).toList()
        : rows;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(analyticsSummaryProvider.notifier).refresh();
        await _loadHistory();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.25,
            children: [
              StatCard(
                label: 'Workouts',
                value: '${s.count}',
                icon: Icons.fitness_center,
              ),
              StatCard(
                label: 'Calories',
                value: formatNumber(s.totalCaloriesBurned),
                icon: Icons.local_fire_department,
                accent: BuddyColors.red,
              ),
              StatCard(
                label: 'Volume',
                value: formatNumber(s.totalVolume, decimals: 0),
                icon: Icons.assessment,
                accent: BuddyColors.gold,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _startWorkoutCard(cs),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Log Workout',
            icon: Icons.add_circle_outline,
          ),
          const SizedBox(height: 12),
          _buildLogForm(specs, spec, cs),
          if (s.mostTrained != null) ...[
            const SizedBox(height: 16),
            const SectionHeader(
              title: 'Most Trained',
              icon: Icons.star_outline,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Text(
                s.mostTrained!,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
                    label: Text('${titleCase(t.label)} · ${t.count}'),
                    backgroundColor: cs.surface,
                    side: BorderSide(color: cs.outlineVariant),
                    labelStyle: TextStyle(
                      color: cs.onSurface,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
          if (recent.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionHeader(title: 'Recent', icon: Icons.history),
            const SizedBox(height: 8),
            for (final r in recent) _workoutTile(r, cs, specs),
          ],
        ],
      ),
    );
  }

  /// Keyless entry point: pick a type and start recording (camera or timer).
  Widget _startWorkoutCard(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start workout',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pick a type and hit record — camera or timer only, nothing to type.',
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () => context.push('/workout-form'),
            icon: const Icon(Icons.play_circle_outline, size: 18),
            label: const Text('Start'),
            style: FilledButton.styleFrom(
              backgroundColor: BuddyColors.green,
              foregroundColor: cs.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogForm(
    WorkoutTypeSpecs specs,
    WorkoutTypeSpec spec,
    ColorScheme cs,
  ) {
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
            Text(
              'Type',
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final key in specs.order)
                  ChoiceChip(
                    label: Text(specs.specFor(key).label),
                    selected: _workoutType == key,
                    onSelected: (_) => _selectType(key, specs),
                    selectedColor: BuddyColors.green.withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      color: _workoutType == key
                          ? BuddyColors.green
                          : cs.onSurface,
                      fontSize: 12,
                    ),
                    backgroundColor: cs.surfaceContainerHighest,
                    side: BorderSide(color: cs.outlineVariant),
                  ),
              ],
            ),
            if (measuredNotice(spec) != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  measuredNotice(spec)!,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            if (spec.hasCategories) ...[
              const SizedBox(height: 12),
              Text(
                'Category',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in spec.categories)
                    ChoiceChip(
                      label: Text(c.label),
                      selected: _category == c.key,
                      onSelected: (_) => setState(
                        () => _category = _category == c.key ? '' : c.key,
                      ),
                      selectedColor: BuddyColors.green.withValues(alpha: 0.25),
                      labelStyle: TextStyle(
                        color: _category == c.key
                            ? BuddyColors.green
                            : cs.onSurface,
                        fontSize: 12,
                      ),
                      backgroundColor: cs.surfaceContainerHighest,
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                ],
              ),
            ],
            if (spec.has('exercise')) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _exerciseController,
                style: TextStyle(color: cs.onSurface),
                decoration: const InputDecoration(labelText: 'Exercise'),
              ),
            ],
            if (spec.has('style')) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _styleController,
                style: TextStyle(color: cs.onSurface),
                decoration: const InputDecoration(
                  labelText: 'Style',
                  hintText: 'e.g. Vinyasa, Kickboxing',
                ),
              ),
            ],
            if (spec.has('focus')) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _focusController,
                style: TextStyle(color: cs.onSurface),
                decoration: const InputDecoration(
                  labelText: 'Focus',
                  hintText: 'e.g. Hips, Shoulders',
                ),
              ),
            ],
            if (spec.has('sport')) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _sportController,
                style: TextStyle(color: cs.onSurface),
                decoration: const InputDecoration(
                  labelText: 'Sport',
                  hintText: 'e.g. Football, Basketball',
                ),
              ),
            ],
            if (spec.has('sets') || spec.has('reps') || spec.has('weight_kg'))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    if (spec.has('sets')) ...[
                      Expanded(
                        child: TextFormField(
                          controller: _setsController,
                          style: TextStyle(color: cs.onSurface),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Sets'),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (spec.has('reps')) ...[
                      Expanded(
                        child: TextFormField(
                          controller: _repsController,
                          style: TextStyle(color: cs.onSurface),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Reps'),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (spec.has('weight_kg'))
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          style: TextStyle(color: cs.onSurface),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'Kg'),
                        ),
                      ),
                  ],
                ),
              ),
            if (spec.has('rounds')) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _roundsController,
                style: TextStyle(color: cs.onSurface),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rounds'),
              ),
            ],
            if (spec.has('distance_km') || spec.has('calories_burned'))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    if (spec.has('distance_km')) ...[
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
                      if (spec.has('calories_burned')) const SizedBox(width: 10),
                    ],
                    if (spec.has('calories_burned'))
                      Expanded(
                        child: TextFormField(
                          controller: _caloriesController,
                          style: TextStyle(color: cs.onSurface),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'Calories'),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'Duration preset',
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final m in _durationPresets)
                  ChoiceChip(
                    label: Text('$m min'),
                    selected: _durationController.text == '$m',
                    onSelected: (_) => setState(
                      () => _durationController.text = '$m',
                    ),
                    selectedColor: BuddyColors.green.withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      color: _durationController.text == '$m'
                          ? BuddyColors.green
                          : cs.onSurface,
                      fontSize: 12,
                    ),
                    backgroundColor: cs.surfaceContainerHighest,
                    side: BorderSide(color: cs.outlineVariant),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _durationController,
              style: TextStyle(color: cs.onSurface),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Minutes'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submit(spec),
                child: Text(_isSubmitting ? 'Logging…' : 'Log Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _workoutTile(_WorkoutRow r, ColorScheme cs, WorkoutTypeSpecs specs) {
    final spec = specs.specFor(r.workoutType);
    final title = r.exercise.isNotEmpty ? r.exercise : spec.label;
    final bits = <String>[
      if (r.durationMinutes > 0) '${r.durationMinutes}m',
      if (r.distanceKm != null && r.distanceKm! > 0)
        '${formatNumber(r.distanceKm, decimals: 1)} km',
      if (r.calories != null) '${formatNumber(r.calories!)} kcal',
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, size: 18, color: BuddyColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (r.category.isNotEmpty) titleCase(r.category),
                    bits.join(' · '),
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                if (!spec.measured) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Not measured — time and distance only',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            formatDate(r.performedAt),
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          Builder(
            builder: (anchor) => IconButton(
              icon: const Icon(Icons.share_outlined, size: 18),
              tooltip: 'Share workout',
              color: BuddyColors.green,
              onPressed: () => _share(r, anchor, specs),
            ),
          ),
        ],
      ),
    );
  }
}