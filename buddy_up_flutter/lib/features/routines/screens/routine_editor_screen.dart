import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/input.dart';
import '../providers/routines_provider.dart';

/// Create/edit a routine — mirrors the web's routine editor field-for-field:
/// the type picker, the day chips, reminder minutes, tracking source and the
/// target. A blank create is a rare case here; everything else edits.
class RoutineEditorScreen extends ConsumerStatefulWidget {
  final String? routineId;

  const RoutineEditorScreen({super.key, this.routineId});

  @override
  ConsumerState<RoutineEditorScreen> createState() =>
      _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  static const _types = [
    ('walk', 'Walk', Icons.directions_walk),
    ('run', 'Run', Icons.directions_run),
    ('cycle', 'Cycle', Icons.directions_bike),
    ('hike', 'Hike', Icons.terrain),
    ('workout', 'Workout', Icons.fitness_center),
    ('gym', 'Gym', Icons.warehouse_outlined),
    ('other', 'Other', Icons.more_horiz),
  ];

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  late final TextEditingController _nameController;
  late final TextEditingController _customNameController;
  late final TextEditingController _targetController;
  late final TextEditingController _unitController;
  late final TextEditingController _timeController;

  String _type = 'walk';
  List<int> _daysSelected = const [0, 2, 4]; // Mon, Wed, Fri
  List<int> _reminders = const [15];
  String _activation = 'week';
  String _tracking = 'app';
  int? _targetDay;

  bool get _isEditing => widget.routineId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _customNameController = TextEditingController();
    _targetController = TextEditingController(text: '30');
    _unitController = TextEditingController(text: 'min');
    _timeController = TextEditingController();

    if (_isEditing && ref.read(routinesProvider).routines.isEmpty) {
      Future.microtask(() => ref.read(routinesProvider.notifier).load());
    }
    if (_isEditing && ref.read(routinesProvider).routines.isNotEmpty) {
      _prefill();
    }
  }

  void _prefill() {
    final routine = ref.read(routinesProvider).routines.firstWhere(
          (r) => r.id == widget.routineId,
          orElse: () => throw StateError('Routine not in list'),
        );
    _type = routine.type;
    _customNameController.text = routine.customName;
    _nameController.text = routine.name;
    _targetController.text = '${routine.target}';
    _unitController.text = routine.unit;
    _daysSelected = List<int>.from(routine.days);
    _reminders = List<int>.from(routine.reminderMinutes);
    _activation = routine.activation;
    _tracking = routine.tracking;
    _targetDay = routine.targetDay;
    _timeController.text = routine.timeOfDay?.substring(0, 5) ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customNameController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final target = int.tryParse(_targetController.text.trim()) ?? 30;
    final time = _timeController.text.trim();
    final customName = _customNameController.text.trim();
    final name = _nameController.text.trim();

    final ok = await ref.read(routinesProvider.notifier).createOrUpdate(
          existingId: widget.routineId,
          type: _type,
          customName: _type == 'other' ? customName : '',
          name: name,
          target: target,
          unit: _unitController.text.trim().isEmpty
              ? 'min'
              : _unitController.text.trim(),
          days: _daysSelected,
          targetDay: _activation == 'holiday' ? _targetDay : null,
          timeOfDay: time.isEmpty ? null : time,
          reminderMinutes: _reminders,
          activation: _activation,
          tracking: _tracking,
        );
    if (ok && mounted) {
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save that routine.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canSave = _daysSelected.isNotEmpty &&
        (_type == 'other'
            ? _customNameController.text.trim().isNotEmpty
            : true);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit routine' : 'New routine'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await ref
                    .read(routinesProvider.notifier)
                    .deleteRoutine(widget.routineId!);
                if (context.mounted) context.pop();
              },
            ),
          TextButton(
            onPressed: canSave ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'What kind of session is this?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (type, label, icon) in _types)
                ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16),
                      const SizedBox(width: 6),
                      Text(label),
                    ],
                  ),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                  selectedColor: BuddyColors.green.withValues(alpha: 0.25),
                  labelPadding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (_type == 'other') ...[
            BuddyInput(
              label: 'Name',
              hint: 'e.g. Cold shower',
              controller: _customNameController,
            ),
            const SizedBox(height: 16),
          ] else ...[
            BuddyInput(
              label: 'Custom name (optional)',
              hint: 'Leave blank to use the type label',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: BuddyInput(
                  label: 'Target',
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BuddyInput(
                  label: 'Unit',
                  controller: _unitController,
                  hint: 'min / reps / km / sets',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Days',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 6 ? 0 : 6),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _daysSelected = _daysSelected.contains(i)
                            ? _daysSelected.where((d) => d != i).toList()
                            : [..._daysSelected, i]..sort();
                      }),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _daysSelected.contains(i)
                              ? BuddyColors.green
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _days[i],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _daysSelected.contains(i)
                                ? BuddyColors.black
                                : cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'When should it happen?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _choice(
                'Weekly',
                _activation == 'week',
                () => setState(() => _activation = 'week'),
              ),
              const SizedBox(width: 8),
              _choice(
                'Monthly',
                _activation == 'month',
                () => setState(() => _activation = 'month'),
              ),
              const SizedBox(width: 8),
              _choice(
                'Holiday',
                _activation == 'holiday',
                () => setState(() => _activation = 'holiday'),
              ),
            ],
          ),
          if (_activation == 'holiday') ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: _targetDay,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Day of the month',
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Every holiday')),
                for (var d = 1; d <= 31; d++)
                  DropdownMenuItem(
                    value: d,
                    child: Text('Day $d'),
                  ),
              ],
              onChanged: (v) => setState(() => _targetDay = v),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: BuddyInput(
                  label: 'Time of day (optional)',
                  controller: _timeController,
                  hint: '07:00',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReminderPicker(
                  selected: _reminders,
                  onChanged: (r) => setState(() => _reminders = r),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'How will you track it?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            title: const Text('Log manually'),
            subtitle: const Text(
              'For things the app cannot observe — cold showers, mobility, '
              'off-app training. Tap to check in by hand each time.',
            ),
            value: _tracking == 'manual',
            onChanged: (v) => setState(() => _tracking = v ? 'manual' : 'app'),
            activeThumbColor: BuddyColors.green,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: canSave ? _save : null,
            icon: const Icon(Icons.check_rounded),
            label: Text(_isEditing ? 'Save changes' : 'Create routine'),
            style: FilledButton.styleFrom(
              backgroundColor: BuddyColors.green,
              foregroundColor: BuddyColors.black,
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _choice(String label, bool selected, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: BuddyColors.green.withValues(alpha: 0.25),
      labelPadding: EdgeInsets.zero,
      backgroundColor: cs.surfaceContainerHighest,
    );
  }
}

class _ReminderPicker extends StatelessWidget {
  final List<int> selected;
  final ValueChanged<List<int>> onChanged;

  const _ReminderPicker({required this.selected, required this.onChanged});

  static const _options = [5, 15, 30, 60, 120];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Reminder',
          style: TextStyle(
            fontSize: 13,
            color: BuddyColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final minutes in _options)
              FilterChip(
                label: Text('${minutes}m'),
                selected: selected.contains(minutes),
                onSelected: (on) {
                  if (on) {
                    onChanged([...selected, minutes]..sort());
                  } else {
                    onChanged(selected.where((m) => m != minutes).toList());
                  }
                },
                selectedColor: BuddyColors.green.withValues(alpha: 0.25),
                labelPadding: EdgeInsets.zero,
                backgroundColor: cs.surfaceContainerHighest,
              ),
          ],
        ),
      ],
    );
  }
}
