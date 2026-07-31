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

class CreateProgrammeScreen extends ConsumerStatefulWidget {
  final String? shopHandle;
  const CreateProgrammeScreen({super.key, this.shopHandle});

  @override
  ConsumerState<CreateProgrammeScreen> createState() => _CreateProgrammeScreenState();
}

class _CreateProgrammeScreenState extends ConsumerState<CreateProgrammeScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _loading = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'strength';
  int _durationWeeks = 6;
  XFile? _coverFile;

  // week -> day -> session_type
  final Map<int, Map<String, String>> _schedule = {};

  // week -> day -> activities list
  final Map<int, Map<String, List<Map<String, dynamic>>>> _activities = {};

  final Map<String, int> _priceArtifacts = {'burpee': 5};

  final List<String> _categories = [
    'strength', 'cardio', 'yoga', 'pilates', 'hiit', 'crossfit', 'martial_arts', 'rehabilitation'
  ];

  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _sessionTypes = ['Morning', 'Midday', 'Evening', 'Rest'];

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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

      // Merge schedule + activities
      final mergedSchedule = <String, dynamic>{};
      for (final weekEntry in _schedule.entries) {
        final weekData = <String, dynamic>{};
        for (final dayEntry in weekEntry.value.entries) {
          weekData[dayEntry.key] = {
            'session_type': dayEntry.value,
            'activities': _activities[weekEntry.key]?[dayEntry.key] ?? [],
          };
        }
        mergedSchedule['${weekEntry.key}'] = weekData;
      }

      final data = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _category,
        'duration_weeks': _durationWeeks,
        'price_artifacts': _priceArtifacts,
        'schedule': mergedSchedule,
        if (coverUrl != null) 'cover_image_url': coverUrl,
        if (widget.shopHandle != null) 'shop_handle': widget.shopHandle,
      };

      await repo.createProgramme(data);
      ref.invalidate(programmesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('💪 Programme created!'), backgroundColor: BuddyColors.green),
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
    const stepLabels = ['Basics', 'Schedule', 'Activities', 'Pricing', 'Review'];
    return Scaffold(
      backgroundColor: BuddyColors.black,
      appBar: AppBar(
        backgroundColor: BuddyColors.surface,
        title: Text('Programme — ${stepLabels[_currentStep]}'),
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
                _buildStepActivities(),
                _buildStepPricing(),
                _buildStepReview(),
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
            submitLabel: 'Create Programme',
          ),
        ],
      ),
    );
  }

  Widget _buildStepBasics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Programme Basics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                  color: _coverFile != null ? BuddyColors.green : BuddyColors.surfaceRaised,
                  width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: _coverFile != null
                ? Image.file(File(_coverFile!.path), fit: BoxFit.cover)
                : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 36, color: BuddyColors.textSecondary),
                    SizedBox(height: 6),
                    Text('Upload cover image',
                        style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
                  ]),
          ),
        ),
        const SizedBox(height: 16),
        WizardTextField('Title', _titleController, hint: 'e.g. 6-Week Strength Builder'),
        const SizedBox(height: 14),
        WizardTextField('Description', _descriptionController,
            hint: 'Describe what this programme achieves...', maxLines: 3),
        const SizedBox(height: 14),
        const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _categories
              .map((c) => ChoiceChip(
                    label: Text(c.replaceAll('_', ' ')),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
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
              onPressed: () =>
                  setState(() => _durationWeeks = (_durationWeeks - 1).clamp(1, 52))),
          Text('$_durationWeeks',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
              icon: const Icon(Icons.add_circle_outline, color: BuddyColors.green),
              onPressed: () =>
                  setState(() => _durationWeeks = (_durationWeeks + 1).clamp(1, 52))),
        ]),
      ]),
    );
  }

  Widget _buildStepSchedule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Weekly Schedule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Set morning/evening/rest for each day.',
            style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        ...List.generate(_durationWeeks.clamp(1, 6), (weekIdx) {
          return Card(
            color: BuddyColors.surface,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ExpansionTile(
              title: Text('Week ${weekIdx + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              children: _days.map((day) {
                final current = _schedule[weekIdx]?[day] ?? 'Rest';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(children: [
                    SizedBox(
                        width: 90,
                        child: Text(day,
                            style: const TextStyle(
                                fontSize: 12, color: BuddyColors.textSecondary))),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: current,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: BuddyColors.surfaceRaised,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: const TextStyle(fontSize: 12),
                        items: _sessionTypes
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _schedule[weekIdx] ??= {};
                            _schedule[weekIdx]![day] = v ?? 'Rest';
                            if (v != 'Rest') {
                              _activities[weekIdx] ??= {};
                              _activities[weekIdx]![day] ??= [];
                            }
                          });
                        },
                      ),
                    ),
                  ]),
                );
              }).toList(),
            ),
          );
        }),
        if (_durationWeeks > 6)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: BuddyColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12)),
            child: const Text('Showing first 6 weeks. Remaining weeks repeat the pattern.',
                style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
          ),
      ]),
    );
  }

  Widget _buildStepActivities() {
    final trainingDays = <_DayKey>[];
    for (final weekEntry in _schedule.entries) {
      for (final dayEntry in weekEntry.value.entries) {
        if (dayEntry.value != 'Rest') {
          trainingDays.add(_DayKey(weekEntry.key, dayEntry.key));
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Activity Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Add exercises for each training day.',
            style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        if (trainingDays.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: BuddyColors.surface, borderRadius: BorderRadius.circular(12)),
            child: const Text(
                'Set your schedule in the previous step to see training days here.',
                style: TextStyle(color: BuddyColors.textSecondary)),
          ),
        ...trainingDays.map((dk) {
          final acts = _activities[dk.week]?[dk.day] ?? [];
          return Card(
            color: BuddyColors.surface,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ExpansionTile(
              title: Text('Week ${dk.week + 1} · ${dk.day}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('${acts.length} activities',
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
              children: [
                ...acts.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final act = entry.value;
                  return _ActivityEditor(
                    activity: act,
                    onUpdate: (updates) {
                      setState(() {
                        _activities[dk.week] ??= {};
                        _activities[dk.week]![dk.day] ??= [];
                        _activities[dk.week]![dk.day]![idx] = {
                          ..._activities[dk.week]![dk.day]![idx],
                          ...updates
                        };
                      });
                    },
                  );
                }),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Activity'),
                    onPressed: () {
                      setState(() {
                        _activities[dk.week] ??= {};
                        _activities[dk.week]![dk.day] ??= [];
                        _activities[dk.week]![dk.day]!.add({
                          'name': '',
                          'description': '',
                          'duration_minutes': 30,
                          'sets': 3,
                          'reps': 10,
                          'tips': '',
                          'cautions': '',
                          'video_url': '',
                        });
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: BuddyColors.green),
                      foregroundColor: BuddyColors.green,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildStepPricing() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Pricing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ..._priceArtifacts.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(
                    child:
                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600))),
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
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
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

  Widget _buildStepReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Review Programme',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        if (_coverFile != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(File(_coverFile!.path),
                height: 140, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
        ],
        Card(
          color: BuddyColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _reviewRow('Title', _titleController.text),
              _reviewRow('Category', _category.replaceAll('_', ' ')),
              _reviewRow('Duration', '$_durationWeeks weeks'),
              _reviewRow(
                'Pricing',
                _priceArtifacts.entries.map((e) => '${e.value} ${e.key}').join(', '),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(
                      color: BuddyColors.textSecondary, fontSize: 13))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
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

class _DayKey {
  final int week;
  final String day;
  const _DayKey(this.week, this.day);
}

class _ActivityEditor extends StatelessWidget {
  final Map<String, dynamic> activity;
  final void Function(Map<String, dynamic>) onUpdate;

  const _ActivityEditor({required this.activity, required this.onUpdate});

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: BuddyColors.surfaceRaised,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(),
        TextFormField(
          initialValue: activity['name'] as String? ?? '',
          decoration: _dec('Activity Name (e.g. Push-ups)'),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          onChanged: (v) => onUpdate({'name': v}),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: activity['description'] as String? ?? '',
          maxLines: 2,
          decoration: _dec('Description'),
          style: const TextStyle(fontSize: 12),
          onChanged: (v) => onUpdate({'description': v}),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextFormField(
              initialValue: '${activity['duration_minutes'] ?? 30}',
              keyboardType: TextInputType.number,
              decoration: _dec('Minutes'),
              onChanged: (v) => onUpdate({'duration_minutes': int.tryParse(v) ?? 30}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: '${activity['sets'] ?? 3}',
              keyboardType: TextInputType.number,
              decoration: _dec('Sets'),
              onChanged: (v) => onUpdate({'sets': int.tryParse(v) ?? 3}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: '${activity['reps'] ?? 10}',
              keyboardType: TextInputType.number,
              decoration: _dec('Reps'),
              onChanged: (v) => onUpdate({'reps': int.tryParse(v) ?? 10}),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: activity['tips'] as String? ?? '',
          decoration: _dec('Tips 💡'),
          style: const TextStyle(fontSize: 12),
          onChanged: (v) => onUpdate({'tips': v}),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: activity['cautions'] as String? ?? '',
          decoration: _dec('Cautions ⚠️'),
          style: const TextStyle(fontSize: 12),
          onChanged: (v) => onUpdate({'cautions': v}),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: activity['video_url'] as String? ?? '',
          decoration: _dec('Video URL (optional)'),
          style: const TextStyle(fontSize: 12),
          onChanged: (v) => onUpdate({'video_url': v}),
        ),
      ]),
    );
  }
}
