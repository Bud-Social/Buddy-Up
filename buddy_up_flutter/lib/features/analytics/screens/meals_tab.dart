import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/analytics.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/analytics_provider.dart';
import '../utils/analytics_format.dart';
import '../widgets/analytics_widgets.dart';

const List<({String key, String label})> _mealTypes = [
  (key: 'breakfast', label: 'Breakfast'),
  (key: 'lunch', label: 'Lunch'),
  (key: 'dinner', label: 'Dinner'),
  (key: 'snack', label: 'Snack'),
  (key: 'drink', label: 'Drink'),
  (key: 'other', label: 'Other'),
];

class MealsTab extends ConsumerStatefulWidget {
  final NutritionSummary? summary;

  const MealsTab({super.key, this.summary});

  @override
  ConsumerState<MealsTab> createState() => _MealsTabState();
}

class _MealsTabState extends ConsumerState<MealsTab> {
  final _formKey = GlobalKey<FormState>();
  final _foodController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String _mealType = 'breakfast';
  bool _isSubmitting = false;
  bool _isAnalyzing = false;
  XFile? _photo;

  @override
  void dispose() {
    _foodController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _photo = picked;
        _isAnalyzing = true;
      });
      await _analyzePhoto(picked);
    }
  }

  Future<void> _analyzePhoto(XFile file) async {
    final data = <String, dynamic>{
      'photo': MultipartFile.fromFileSync(file.path, filename: file.name),
    };
    final analyzed = await ref
        .read(analyticsLogProvider.notifier)
        .analyzeMealPhoto(data);
    if (!mounted) return;
    setState(() => _isAnalyzing = false);
    if (analyzed != null) {
      if (_foodController.text.trim().isEmpty &&
          analyzed['food_name'] is String) {
        _foodController.text = analyzed['food_name'] as String;
      }
      void fill(TextEditingController c, dynamic v) {
        if (v is num && c.text.trim().isEmpty) {
          c.text = v.toStringAsFixed(1);
        }
      }

      fill(_caloriesController, analyzed['calories']);
      fill(_proteinController, analyzed['protein_g']);
      fill(_carbsController, analyzed['carbs_g']);
      fill(_fatController, analyzed['fat_g']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nutrition detected — review before saving.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not analyze the meal photo. Enter details manually.',
          ),
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final data = <String, dynamic>{
      'meal_type': _mealType,
      'food_name': _foodController.text.trim(),
    };
    final calories = double.tryParse(_caloriesController.text);
    final protein = double.tryParse(_proteinController.text);
    final carbs = double.tryParse(_carbsController.text);
    final fat = double.tryParse(_fatController.text);
    if (calories != null) data['calories'] = calories;
    if (protein != null) data['protein_g'] = protein;
    if (carbs != null) data['carbs_g'] = carbs;
    if (fat != null) data['fat_g'] = fat;

    Map<String, dynamic>? created;
    if (_photo != null) {
      data['photo'] = MultipartFile.fromFileSync(
        _photo!.path,
        filename: _photo!.name,
      );
      created = await ref
          .read(analyticsLogProvider.notifier)
          .logMealWithPhoto(data);
    } else {
      created = await ref.read(analyticsLogProvider.notifier).logMeal(data);
    }
    setState(() => _isSubmitting = false);
    if (!mounted) return;
    if (created != null) {
      _formKey.currentState!.reset();
      _foodController.clear();
      _caloriesController.clear();
      _proteinController.clear();
      _carbsController.clear();
      _fatController.clear();
      setState(() {
        _mealType = 'breakfast';
        _photo = null;
      });
      await ref.read(analyticsSummaryProvider.notifier).refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not log meal. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    if (s == null) {
      return const EmptyState(
        icon: Icons.restaurant,
        title: 'No nutrition data',
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
                label: 'Meals',
                value: '${s.count}',
                icon: Icons.restaurant,
              ),
              StatCard(
                label: 'Calories',
                value: formatNumber(s.totalCalories),
                icon: Icons.local_fire_department,
                accent: BuddyColors.red,
              ),
              StatCard(
                label: 'Daily Avg',
                value: s.avgDailyCalories != null
                    ? formatNumber(s.avgDailyCalories!)
                    : '—',
                icon: Icons.calendar_view_day,
                accent: BuddyColors.gold,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'Macros',
            icon: Icons.pie_chart_outline,
            trailing: Text(
              '${formatNumber(s.totalCalories)} kcal',
              style: const TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BuddyColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BuddyColors.border),
            ),
            child: Column(
              children: [
                MacroBar(
                  label: 'Protein',
                  value: s.totalProteinG,
                  max: 120,
                  color: BuddyColors.green,
                ),
                const SizedBox(height: 12),
                MacroBar(
                  label: 'Carbs',
                  value: s.totalCarbsG,
                  max: 180,
                  color: BuddyColors.gold,
                ),
                const SizedBox(height: 12),
                MacroBar(
                  label: 'Fat',
                  value: s.totalFatG,
                  max: 70,
                  color: BuddyColors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Log Meal',
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
                      '${t.label} · ${formatNumber(t.calories)} kcal',
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
            for (final m in s.recent) _mealTile(m),
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
                for (final t in _mealTypes)
                  ChoiceChip(
                    label: Text(t.label),
                    selected: _mealType == t.key,
                    onSelected: (_) => setState(() => _mealType = t.key),
                    selectedColor: BuddyColors.green.withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      color: _mealType == t.key
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
              controller: _foodController,
              style: const TextStyle(color: BuddyColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Food'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            if (_photo != null)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_photo!.path),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 120,
                        color: BuddyColors.surfaceRaised,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: BuddyColors.textSecondary,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isAnalyzing)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: BuddyColors.green,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Analyzing meal…',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _photo = null),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                        padding: const EdgeInsets.all(3),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: _isAnalyzing ? null : _pickPhoto,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: BuddyColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BuddyColors.border),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        color: BuddyColors.textSecondary,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Snap a photo to auto-fill nutrition',
                        style: TextStyle(
                          color: BuddyColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _caloriesController,
              style: const TextStyle(color: BuddyColors.textPrimary),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Calories'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Protein (g)'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Carbs (g)'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Fat (g)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(_isSubmitting ? 'Logging…' : 'Log Meal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mealTile(MealRecent m) {
    final macroParts = <String>[
      if (m.proteinG != null) '${formatNumber(m.proteinG!)}g P',
      if (m.carbsG != null) '${formatNumber(m.carbsG!)}g C',
      if (m.fatG != null) '${formatNumber(m.fatG!)}g F',
    ];
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
          const Icon(Icons.restaurant, size: 18, color: BuddyColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.foodName.isEmpty ? titleCase(m.mealType) : m.foodName,
                  style: const TextStyle(
                    color: BuddyColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  macroParts.isEmpty
                      ? (m.calories != null
                            ? '${formatNumber(m.calories!)} kcal'
                            : '')
                      : (m.calories != null
                                ? '${formatNumber(m.calories!)} kcal · '
                                : '') +
                            macroParts.join(' · '),
                  style: const TextStyle(
                    color: BuddyColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatDate(m.loggedAt),
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
