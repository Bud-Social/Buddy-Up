import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/wizard_widgets.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../providers/marketplace_provider.dart';

const _disclaimerText = "This meal plan isn't medical advice — consult a professional.";
const _reminderFrequencies = ['15m', '30m', '1h'];
const _timings = ['morning', 'midday', 'afternoon', 'evening', 'anytime'];
const _mealSlots = ['breakfast', 'lunch', 'dinner', 'snack'];

class CreateMealPlanScreen extends ConsumerStatefulWidget {
  final String? shopHandle;
  final String? editId;
  const CreateMealPlanScreen({super.key, this.shopHandle, this.editId});

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

  // Meal blocks: one entry per meal, serialised into full_plan[week_N][day_M].
  final List<Map<String, dynamic>> _mealBlocks = [
    {'week': 1, 'day': 1, 'slot': 'breakfast', 'title': '', 'duration_mins': 15, 'timing': 'morning', 'photo_url': '', 'alternatives': '', 'side_effects': ''},
  ];
  String? _uploadingPhotoKey; // block index whose photo is uploading

  final _shoppingListController = TextEditingController();
  final _nutritionGoalsController = TextEditingController();
  final Map<String, int> _priceArtifacts = {'dumbbell': 10};

  bool _reminderEnabled = true;
  String _reminderTiming = 'morning';
  String _reminderFrequency = '1h';
  final _reminderMessageController = TextEditingController(
      text: "Hey Buddy! Here is your meal plan for today. Let's hit those macros!");
  bool _disclaimerAccepted = false;

  final List<String> _dietTypes = [
    'balanced', 'keto', 'vegan', 'vegetarian', 'paleo', 'mediterranean', 'high-protein'
  ];
  final List<String> _calorieRanges = [
    '1200-1500', '1500-1800', '1800-2200', '2200-2600', '2600+'
  ];
  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']; // ignore: unused_field

  int get _mealTotalMins => _mealBlocks.fold(0, (sum, b) => sum + ((b['duration_mins'] ?? 15) as num).toInt());

  @override
  void initState() {
    super.initState();
    if (widget.editId != null) {
      Future.microtask(_loadExisting);
    }
  }

  Future<void> _loadExisting() async {
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final raw = await repo.getMealPlan(widget.editId!);
      final data = raw['data'] as Map<String, dynamic>?;
      if (data == null || !mounted) return;
      setState(() {
        _titleController.text = (data['title'] ?? '') as String;
        _descriptionController.text = (data['description'] ?? '') as String;
        _dietType = (data['diet_type'] ?? 'balanced') as String;
        _durationWeeks = (data['duration_weeks'] as num?)?.toInt() ?? 4;
        _calorieRange = (data['calorie_range'] ?? '1800-2200') as String;
        final prices = data['price_artifacts'];
        if (prices is Map) {
          _priceArtifacts
            ..clear()
            ..addEntries(prices.entries.map((e) => MapEntry(e.key.toString(), (e.value as num?)?.toInt() ?? 0)));
        }
        final shopping = data['shopping_list'];
        if (shopping is List) _shoppingListController.text = shopping.join('\n');
        // Hydrate meal blocks from full_plan[week_N][day_M].
        final plan = data['full_plan'];
        if (plan is Map && plan.isNotEmpty) {
          final blocks = <Map<String, dynamic>>[];
          plan.forEach((weekKey, days) {
            if (days is! Map) return;
            days.forEach((dayKey, meals) {
              if (meals is! List) return;
              for (final m in meals) {
                if (m is! Map) continue;
                blocks.add({
                  'week': int.tryParse('$weekKey'.replaceAll('week_', '')) ?? 1,
                  'day': int.tryParse('$dayKey'.replaceAll('day_', '')) ?? 1,
                  'slot': (m['slot'] ?? 'breakfast') as String,
                  'title': (m['title'] ?? '') as String,
                  'duration_mins': (m['duration_mins'] as num?)?.toInt() ?? 15,
                  'timing': (m['timing'] ?? m['time_of_day'] ?? 'morning') as String,
                  'photo_url': (m['photo_url'] ?? '') as String,
                  'alternatives': (m['alternatives'] ?? '') as String,
                  'side_effects': (m['side_effects'] ?? '') as String,
                });
              }
            });
          });
          if (blocks.isNotEmpty) _mealBlocks..clear()..addAll(blocks);
        }
        final reminders = data['reminder_settings'];
        if (reminders is Map) {
          _reminderEnabled = (reminders['enabled'] as bool?) ?? _reminderEnabled;
          _reminderTiming = (reminders['timing'] as String?) ?? _reminderTiming;
          _reminderFrequency = (reminders['frequency'] as String?) ?? _reminderFrequency;
          final template = reminders['message_template'] as String?;
          if (template != null && template.isNotEmpty) {
            _reminderMessageController.text = template;
          }
        }
        _disclaimerAccepted = true;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _shoppingListController.dispose();
    _nutritionGoalsController.dispose();
    _reminderMessageController.dispose();
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

  void _addMealBlock() {
    setState(() => _mealBlocks.add({
      'week': 1, 'day': 1, 'slot': 'breakfast', 'title': '', 'duration_mins': 15,
      'timing': 'morning', 'photo_url': '', 'alternatives': '', 'side_effects': '',
    }));
  }

  void _removeMealBlock(int index) {
    setState(() => _mealBlocks.removeAt(index));
  }

  void _updateMealBlock(int index, String key, dynamic value) {
    setState(() => _mealBlocks[index][key] = value);
  }

  /// Picks a photo for a meal block and uploads it to /messaging/upload/
  /// (same endpoint the chat composer uses), storing the returned URL.
  Future<void> _pickBlockPhoto(int index) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    setState(() => _uploadingPhotoKey = '$index');
    try {
      final repo = ref.read(messagingRepositoryProvider);
      final response = await repo.uploadAttachment({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'attachment_type': 'photo',
      });
      final data = response['data'] as Map<String, dynamic>?;
      final url = data?['url'] as String?;
      if (url != null && url.isNotEmpty && mounted) {
        setState(() => _mealBlocks[index]['photo_url'] = url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhotoKey = null);
    }
  }

  Future<void> _submit() async {
    if (!_disclaimerAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(_disclaimerText), backgroundColor: Colors.red),
      );
      return;
    }
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

      // Serialise blocks into full_plan[week_N][day_M] (web-compatible shape).
      final fullPlan = <String, dynamic>{};
      for (final block in _mealBlocks) {
        final weekMap =
            fullPlan.putIfAbsent('week_${block['week'] ?? 1}', () => <String, dynamic>{})
                as Map<String, dynamic>;
        final dayList =
            (weekMap['day_${block['day'] ?? 1}'] as List?) ?? <Map<String, dynamic>>[];
        dayList.add({
          'slot': block['slot'] ?? 'breakfast',
          'title': block['title'] ?? '',
          'duration_mins': block['duration_mins'] ?? 15,
          'timing': block['timing'] ?? 'morning',
          'photo_url': block['photo_url'] ?? '',
          'alternatives': block['alternatives'] ?? '',
          'side_effects': block['side_effects'] ?? '',
        });
        weekMap['day_${block['day'] ?? 1}'] = dayList;
      }

      final data = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'diet_type': _dietType,
        'duration_weeks': _durationWeeks,
        'calorie_range': _calorieRange,
        'price_artifacts': _priceArtifacts,
        'full_plan': fullPlan,
        'shopping_list': _shoppingListController.text
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'reminder_settings': {
          'enabled': _reminderEnabled,
          'timing': _reminderTiming,
          'frequency': _reminderFrequency,
          'message_template': _reminderMessageController.text.trim(),
        },
        'cover_image_url': ?coverUrl,
        if (widget.shopHandle != null) 'shop_handle': widget.shopHandle,
      };

      final isEdit = widget.editId != null;
      if (isEdit) {
        await repo.updateMealPlan(widget.editId!, data);
      } else {
        await repo.createMealPlan(data);
      }
      ref.invalidate(mealPlansProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isEdit ? 'Meal plan updated!' : '🥗 Meal plan created!'),
              backgroundColor: BuddyColors.green),
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
        const Text('Meal Blocks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
            'Add each meal with a week, day, slot and timing. Every block becomes part of the weekly plan.',
            style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        Text(
          '${_mealBlocks.length} meals · $_mealTotalMins min total prep (${(_mealTotalMins / 60).toStringAsFixed(1)} hrs)',
          style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ..._mealBlocks.asMap().entries.map((entry) {
          final idx = entry.key;
          return _MealBlockEditor(
            key: ValueKey('meal-block-$idx-${entry.value.hashCode}'),
            block: entry.value,
            maxWeeks: _durationWeeks,
            isUploadingPhoto: _uploadingPhotoKey == '$idx',
            onUpdate: (key, value) => _updateMealBlock(idx, key, value),
            onPickPhoto: () => _pickBlockPhoto(idx),
            onRemove: _mealBlocks.length > 1 ? () => _removeMealBlock(idx) : null,
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add, color: BuddyColors.green),
          label: const Text('Add Meal Block', style: TextStyle(color: BuddyColors.green)),
          onPressed: _addMealBlock,
        ),
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
          value: _reminderEnabled,
          onChanged: (v) => setState(() => _reminderEnabled = v),
          title: const Text('Daily Meal Reminders'),
          subtitle: const Text("Remind subscribers about today's meals"),
          activeThumbColor: BuddyColors.green,
          contentPadding: EdgeInsets.zero,
        ),
        if (_reminderEnabled) ...[
          const SizedBox(height: 12),
          const Text('Default Timing', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _reminderTiming,
            decoration: InputDecoration(
              filled: true,
              fillColor: BuddyColors.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: _timings
                .map((t) => DropdownMenuItem(
                    value: t, child: Text(t[0].toUpperCase() + t.substring(1))))
                .toList(),
            onChanged: (v) => setState(() => _reminderTiming = v ?? 'morning'),
          ),
          const SizedBox(height: 14),
          const Text('Reminder Frequency', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _reminderFrequency,
            decoration: InputDecoration(
              filled: true,
              fillColor: BuddyColors.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: _reminderFrequencies
                .map((f) => DropdownMenuItem(
                    value: f,
                    child: Text(f == '15m'
                        ? 'Every 15 minutes'
                        : f == '30m'
                            ? 'Every 30 minutes'
                            : 'Hourly')))
                .toList(),
            onChanged: (v) => setState(() => _reminderFrequency = v ?? '1h'),
          ),
          const SizedBox(height: 6),
          const Text('Each meal block also carries its own timing.',
              style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 14),
          WizardTextField('Message Template', _reminderMessageController,
              hint: 'Motivational reminder message...', maxLines: 3),
        ],
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Checkbox(
            value: _disclaimerAccepted,
            onChanged: (v) => setState(() => _disclaimerAccepted = v ?? false),
            activeColor: BuddyColors.green,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _disclaimerAccepted = !_disclaimerAccepted),
              child: const Text(_disclaimerText,
                  style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
            ),
          ),
        ]),
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

class _MealBlockEditor extends StatelessWidget {
  final Map<String, dynamic> block;
  final int maxWeeks;
  final bool isUploadingPhoto;
  final void Function(String key, dynamic value) onUpdate;
  final VoidCallback onPickPhoto;
  final VoidCallback? onRemove;

  const _MealBlockEditor({
    super.key,
    required this.block,
    required this.maxWeeks,
    required this.isUploadingPhoto,
    required this.onUpdate,
    required this.onPickPhoto,
    this.onRemove,
  });

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: BuddyColors.surfaceRaised,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );

  @override
  Widget build(BuildContext context) {
    final photoUrl = (block['photo_url'] ?? '') as String;
    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.restaurant, size: 16, color: BuddyColors.green),
            const SizedBox(width: 6),
            const Text('Meal Block',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const Spacer(),
            if (onRemove != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: BuddyColors.textSecondary),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextFormField(
                initialValue: '${block['week'] ?? 1}',
                keyboardType: TextInputType.number,
                decoration: _dec('Week'),
                onChanged: (v) => onUpdate('week', int.tryParse(v) ?? 1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: '${block['day'] ?? 1}',
                keyboardType: TextInputType.number,
                decoration: _dec('Day'),
                onChanged: (v) => onUpdate('day', int.tryParse(v) ?? 1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: '${block['duration_mins'] ?? 15}',
                keyboardType: TextInputType.number,
                decoration: _dec('Prep (min)'),
                onChanged: (v) => onUpdate('duration_mins', int.tryParse(v) ?? 0),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: (block['slot'] ?? 'breakfast') as String,
                decoration: _dec('Slot'),
                items: _mealSlots
                    .map((s) => DropdownMenuItem(
                        value: s, child: Text(s[0].toUpperCase() + s.substring(1))))
                    .toList(),
                onChanged: (v) => onUpdate('slot', v ?? 'breakfast'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: (block['timing'] ?? 'morning') as String,
                decoration: _dec('Timing'),
                items: _timings
                    .map((t) => DropdownMenuItem(
                        value: t, child: Text(t[0].toUpperCase() + t.substring(1))))
                    .toList(),
                onChanged: (v) => onUpdate('timing', v ?? 'morning'),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: (block['title'] ?? '') as String,
            decoration: _dec('Meal title (e.g. Grilled chicken + quinoa)'),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            onChanged: (v) => onUpdate('title', v),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextFormField(
                initialValue: photoUrl,
                decoration: _dec('Photo URL (optional)'),
                style: const TextStyle(fontSize: 12),
                onChanged: (v) => onUpdate('photo_url', v),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: isUploadingPhoto
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_photo_alternate, size: 16),
              label: Text(isUploadingPhoto ? 'Uploading' : 'Photo',
                  style: const TextStyle(fontSize: 12)),
              onPressed: isUploadingPhoto ? null : onPickPhoto,
            ),
          ]),
          if (photoUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(photoUrl,
                  height: 90, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink()),
            ),
          ],
          const SizedBox(height: 10),
          TextFormField(
            initialValue: (block['alternatives'] ?? '') as String,
            decoration: _dec('Alternatives (e.g. Swap chicken for tofu)'),
            style: const TextStyle(fontSize: 12),
            onChanged: (v) => onUpdate('alternatives', v),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: (block['side_effects'] ?? '') as String,
            decoration: _dec('Side effects / notes (e.g. High fibre — hydrate well)'),
            style: const TextStyle(fontSize: 12),
            onChanged: (v) => onUpdate('side_effects', v),
          ),
        ]),
      ),
    );
  }
}
