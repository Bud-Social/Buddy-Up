import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/analytics.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/analytics_provider.dart';
import '../utils/analytics_format.dart';
import '../widgets/analytics_widgets.dart';

const List<({String key, String label})> _workoutTypes = [
  (key: 'strength', label: 'Strength'),
  (key: 'cardio', label: 'Cardio'),
  (key: 'hiit', label: 'HIIT'),
  (key: 'yoga', label: 'Yoga'),
  (key: 'mobility', label: 'Mobility'),
  (key: 'sport', label: 'Sport'),
  (key: 'other', label: 'Other'),
];

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
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  String _workoutType = 'strength';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _exerciseController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final data = <String, dynamic>{
      'workout_type': _workoutType,
      'exercise': _exerciseController.text.trim(),
    };
    final sets = int.tryParse(_setsController.text);
    final reps = int.tryParse(_repsController.text);
    final weight = double.tryParse(_weightController.text);
    final duration = int.tryParse(_durationController.text);
    final calories = double.tryParse(_caloriesController.text);
    if (sets != null) data['sets'] = sets;
    if (reps != null) data['reps'] = reps;
    if (weight != null) data['weight_kg'] = weight;
    if (duration != null) data['duration_minutes'] = duration;
    if (calories != null) data['calories_burned'] = calories;

    final created = await ref
        .read(analyticsLogProvider.notifier)
        .logWorkout(data);
    setState(() => _isSubmitting = false);
    if (!mounted) return;
    if (created != null) {
      _formKey.currentState!.reset();
      _exerciseController.clear();
      _setsController.clear();
      _repsController.clear();
      _weightController.clear();
      _durationController.clear();
      _caloriesController.clear();
      setState(() => _workoutType = 'strength');
      await ref.read(analyticsSummaryProvider.notifier).refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not log workout. Please try again.'),
        ),
      );
    }
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

    return RefreshIndicator(
      onRefresh: () => ref.read(analyticsSummaryProvider.notifier).refresh(),
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
          const SectionHeader(
            title: 'Log Workout',
            icon: Icons.add_circle_outline,
          ),
          const SizedBox(height: 12),
          _buildLogForm(),
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
                color: BuddyColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BuddyColors.border),
              ),
              child: Text(
                s.mostTrained!,
                style: const TextStyle(
                  color: BuddyColors.textPrimary,
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
            for (final w in s.recent) _workoutTile(w),
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
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in _workoutTypes)
                  ChoiceChip(
                    label: Text(t.label),
                    selected: _workoutType == t.key,
                    onSelected: (_) => setState(() => _workoutType = t.key),
                    selectedColor: BuddyColors.green.withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      color: _workoutType == t.key
                          ? BuddyColors.green
                          : BuddyColors.textPrimary,
                      fontSize: 12,
                    ),
                    backgroundColor: BuddyColors.surfaceRaised,
                    side: const BorderSide(color: BuddyColors.surfaceRaised),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _exerciseController,
              style: const TextStyle(color: BuddyColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Exercise'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _setsController,
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Sets'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _repsController,
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Kg'),
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
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _caloriesController,
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Calories'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(_isSubmitting ? 'Logging…' : 'Log Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _workoutTile(WorkoutRecent w) {
    final title = w.exercise.isNotEmpty ? w.exercise : titleCase(w.workoutType);
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
          const Icon(Icons.fitness_center, size: 18, color: BuddyColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: BuddyColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${w.durationMinutes}m${w.caloriesBurned != null ? ' · ${formatNumber(w.caloriesBurned!)} kcal' : ''}',
                  style: const TextStyle(
                    color: BuddyColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatDate(w.performedAt),
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
