import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../shared/widgets/wizard_widgets.dart';
import '../providers/marketplace_provider.dart';

class CreateMealPlanScreen extends ConsumerStatefulWidget {
  final String? shopHandle;
  const CreateMealPlanScreen({super.key, this.shopHandle});

  @override
  ConsumerState<CreateMealPlanScreen> createState() => _CreateMealPlanScreenState();
}

class _CreateMealPlanScreenState extends ConsumerState<CreateMealPlanScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _loading = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _dietType = 'balanced';
  int _durationWeeks = 4;
  String _calorieRange = '1800-2200';
  XFile? _coverFile;

  final Map<int, Map<String, String>> _weekSchedule = {};
  final _shoppingListController = TextEditingController();
  final _nutritionGoalsController = TextEditingController();
  final Map<String, int> _priceArtifacts = {'dumbbell': 10};

  bool _dailyReminders = true;
  bool _weeklyReminders = true;
  final List<String> _reminderTimes = ['08:00'];

  final List<String> _dietTypes = [
    'balanced', 'keto', 'vegan', 'vegetarian', 'paleo', 'mediterranean', 'high-protein'
  ];
  final List<String> _calorieRanges = [
    '1200-1500', '1500-1800', '1800-2200', '2200-2600', '2600+'
  ];
  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _shoppingListController.dispose();
    _nutritionGoalsController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) setState(() => _coverFile = file);
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      String? coverUrl;
      if (_coverFile != null) {
        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(_coverFile!.path, filename: 'cover.jpg'),
        });
        final result = await repo.uploadImage(formData);
        coverUrl = result['data']['url'] as String?;
      }

      final data = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'diet_type': _dietType,
        'duration_weeks': _durationWeeks,
        'calorie_range': _calorieRange,
        'price_artifacts': _priceArtifacts,
        'full_plan': _weekSchedule,
        'shopping_list': _shoppingListController.text
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'notification_config': {
          'daily_reminder': _dailyReminders,
          'weekly_reminder': _weeklyReminders,
          'reminder_times': _reminderTimes,
        },
        if (coverUrl != null) 'cover_image_url': coverUrl,
        if (widget.shopHandle != null) 'shop_handle': widget.shopHandle,
      };

      await repo.createMealPlan(data);
      ref.invalidate(mealPlansProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🥗 Meal plan created!'), backgroundColor: BuddyColors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const stepLabels = ['Basics', 'Schedule', 'Nutrition', 'Pricing', 'Reminders'];
    return Scaffold(
      backgroundColor: BuddyColors.black,
      appBar: AppBar(
        backgroundColor: BuddyColors.surface,
        title: Text('Meal Plan — ${stepLabels[_currentStep]}'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          WizardStepIndicator(current: _currentStep, total: 5),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStepBasics(),
                _buildStepSchedule(),
                _buildStepNutrition(),
                _buildStepPricing(),
                _buildStepReminders(),
              ],
            ),
          ),
          WizardNavButtons(
            currentStep: _currentStep,
            total: 5,
            loading: _loading,
            onNext: _nextStep,
            onBack: _prevStep,
            onSubmit: _submit,
            submitLabel: 'Create Meal Plan',
          ),
        ],
      ),
    );
  }

  Widget _buildStepBasics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Plan Basics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _pickCover,
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: BuddyColors.surfaceRaised,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: _coverFile != null ? BuddyColors.green : BuddyColors.surfaceRaised, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: _coverFile != null
                ? Image.file(File(_coverFile!.path), fit: BoxFit.cover)
                : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 36, color: BuddyColors.textSecondary),
                    SizedBox(height: 6),
                    Text('Upload cover image', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
                  ]),
          ),
        ),
        const SizedBox(height: 16),
        WizardTextField('Title', _titleController, hint: 'e.g. 4-Week Lean Bulk Plan'),
        const SizedBox(height: 14),
        WizardTextField('Description', _descriptionController,
            hint: 'What makes this plan special?', maxLines: 3),
        const SizedBox(height: 14),
        const Text('Diet Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _dietTypes
              .map((d) => ChoiceChip(
                    label: Text(d),
                    selected: _dietType == d,
                    onSelected: (_) => setState(() => _dietType = d),
                    selectedColor: BuddyColors.green,
                  ))
              .toList(),
        ),
        const SizedBox(height: 14),
        Row(children: [
          const Expanded(
              child: Text('Duration (weeks)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => setState(() => _durationWeeks = (_durationWeeks - 1).clamp(1, 52))),
          Text('$_durationWeeks', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
              icon: const Icon(Icons.add_circle_outline, color: BuddyColors.green),
              onPressed: () => setState(() => _durationWeeks = (_durationWeeks + 1).clamp(1, 52))),
        ]),
        const SizedBox(height: 14),
        const Text('Calorie Range', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _calorieRanges
              .map((r) => ChoiceChip(
                    label: Text(r),
                    selected: _calorieRange == r,
                    onSelected: (_) => setState(() => _calorieRange = r),
                    selectedColor: BuddyColors.green,
                  ))
              .toList(),
        ),
      ]),
    );
  }

  Widget _buildStepSchedule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Weekly Schedule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
            'Outline meals for each day. Expand each week to fill in the details.',
            style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        ...List.generate(_durationWeeks.clamp(1, 4), (weekIdx) {
          return Card(
            color: BuddyColors.surface,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ExpansionTile(
              title: Text('Week ${weekIdx + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              children: _days.map((day) {
                final key = 'w${weekIdx}_$day';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(children: [
                    SizedBox(
                        width: 90,
                        child: Text(day,
                            style: const TextStyle(
                                fontSize: 12, color: BuddyColors.textSecondary))),
                    Expanded(
                      child: TextFormField(
                        initialValue: _weekSchedule[weekIdx]?[day] ?? '',
                        decoration: InputDecoration(
                          hintText: 'e.g. Oatmeal, Chicken Salad, Salmon',
                          hintStyle: const TextStyle(fontSize: 11),
                          filled: true,
                          fillColor: BuddyColors.surfaceRaised,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: const TextStyle(fontSize: 12),
                        onChanged: (v) {
                          _weekSchedule[weekIdx] ??= {};
                          _weekSchedule[weekIdx]![day] = v;
                        },
                      ),
                    ),
                  ]),
                );
              }).toList(),
            ),
          );
        }),
        if (_durationWeeks > 4) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: BuddyColors.surfaceRaised, borderRadius: BorderRadius.circular(12)),
            child: const Text(
                'Weeks 1–4 shown. Remaining weeks follow the same pattern.',
                style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
          ),
        ],
      ]),
    );
  }

  Widget _buildStepNutrition() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Nutrition Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        WizardTextField('Shopping List', _shoppingListController,
            hint: 'One item per line:\nchicken breast\nquinoa\nbroccoli', maxLines: 8),
        const SizedBox(height: 14),
        WizardTextField('Nutrition Goals & Notes', _nutritionGoalsController,
            hint: 'e.g. Aim for 30g protein per meal. Low sugar...', maxLines: 4),
      ]),
    );
  }

  Widget _buildStepPricing() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Pricing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Set artifact pricing for subscribers.',
            style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        ..._priceArtifacts.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(
                    child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: '${e.value}',
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (v) => _priceArtifacts[e.key] = int.tryParse(v) ?? e.value,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: BuddyColors.surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => setState(() => _priceArtifacts.remove(e.key)),
                ),
              ]),
            )),
        TextButton.icon(
          icon: const Icon(Icons.add, color: BuddyColors.green),
          label: const Text('Add Tier', style: TextStyle(color: BuddyColors.green)),
          onPressed: _showAddPriceTierDialog,
        ),
      ]),
    );
  }

  Widget _buildStepReminders() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Subscriber Reminders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Keep subscribers on track with push notifications.',
            style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        SwitchListTile(
          value: _dailyReminders,
          onChanged: (v) => setState(() => _dailyReminders = v),
          title: const Text('Daily Meal Reminders'),
          subtitle: const Text("Remind subscribers about today's meals"),
          activeThumbColor: BuddyColors.green,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        SwitchListTile(
          value: _weeklyReminders,
          onChanged: (v) => setState(() => _weeklyReminders = v),
          title: const Text('Weekly Summary'),
          subtitle: const Text('Send a recap at the start of each week'),
          activeThumbColor: BuddyColors.green,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        const Text('Reminder Times', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _reminderTimes
              .map((t) => Chip(
                    label: Text(t),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => setState(() => _reminderTimes.remove(t)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.add_alarm, color: BuddyColors.green),
          label: const Text('Add Time', style: TextStyle(color: BuddyColors.green)),
          onPressed: () async {
            final t = await showTimePicker(
                context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
            if (t != null) {
              final formatted =
                  '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
              setState(() => _reminderTimes.add(formatted));
            }
          },
        ),
      ]),
    );
  }

  void _showAddPriceTierDialog() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Price Tier'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Artifact name')),
          const SizedBox(height: 8),
          TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final amount = int.tryParse(amountCtrl.text) ?? 0;
              if (name.isNotEmpty && amount > 0) {
                setState(() => _priceArtifacts[name] = amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
