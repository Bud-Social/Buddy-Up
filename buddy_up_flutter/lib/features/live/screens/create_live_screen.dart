import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/live_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/widgets/input.dart';

class CreateLiveScreen extends ConsumerStatefulWidget {
  const CreateLiveScreen({super.key});

  @override
  ConsumerState<CreateLiveScreen> createState() => _CreateLiveScreenState();
}

class _CreateLiveScreenState extends ConsumerState<CreateLiveScreen> {
  final _titleController = TextEditingController();
  final _feeController = TextEditingController();
  String _liveType = 'open_sweat';
  String _category = 'strength';
  String _access = 'public';
  String _recordingConsent = 'auto_record';
  bool _isSubmitting = false;
  bool _scheduled = false;
  DateTime? _scheduleDate;
  TimeOfDay? _scheduleTime;

  @override
  void dispose() {
    _titleController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Live'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_scheduled ? 'Schedule' : 'Start'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instant vs planned lives — the backend accepts `scheduled_for`
            // and creates the live with status=scheduled (web parity).
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Start now'),
                    selected: !_scheduled,
                    onSelected: (_) => setState(() => _scheduled = false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Schedule for later'),
                    selected: _scheduled,
                    onSelected: (_) => setState(() => _scheduled = true),
                  ),
                ),
              ],
            ),
            if (_scheduled) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _scheduleDate ?? now,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 365)),
                        );
                        if (date != null) setState(() => _scheduleDate = date);
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _scheduleDate == null
                            ? 'Pick date'
                            : '${_scheduleDate!.day}/${_scheduleDate!.month}/${_scheduleDate!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _scheduleTime ?? TimeOfDay.now(),
                        );
                        if (time != null) setState(() => _scheduleTime = time);
                      },
                      icon: const Icon(Icons.access_time, size: 16),
                      label: Text(
                        _scheduleTime == null
                            ? 'Pick time'
                            : _scheduleTime!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            BuddyInput(
              label: 'Title',
              controller: _titleController,
              hint: 'Give your live a title...',
            ),
            const SizedBox(height: 20),
            const Text(
              'Live Type',
              style: TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _typeChip('open_sweat', 'Open Sweat'),
                _typeChip('buddy_circle', 'Buddy Circle'),
                _typeChip('gym_live', 'Gym Live'),
                _typeChip('pt_session_live', 'PT Session'),
                _typeChip('random_drop', 'Random Drop'),
                _typeChip('practitioner_live', 'Practitioner'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Category',
              style: TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: liveCategories
                  .map(
                    (c) => ChoiceChip(
                      label: Text(
                        c.replaceAll('_', ' ')[0].toUpperCase() +
                            c.replaceAll('_', ' ').substring(1),
                      ),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: _category == c
                            ? BuddyColors.green
                            : BuddyColors.textSecondary,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Access',
              style: TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['public', 'buddies', 'private'].map((t) {
                final isActive = _access == t;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(t[0].toUpperCase() + t.substring(1)),
                      selected: isActive,
                      onSelected: (_) => setState(() => _access = t),
                      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isActive
                            ? BuddyColors.green
                            : BuddyColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Entry Fee (optional)',
              style: TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _feeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: BuddyColors.textPrimary,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(color: BuddyColors.textSecondary),
                      labelStyle: TextStyle(color: BuddyColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Dumbbells',
                  style: TextStyle(
                    color: BuddyColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Recording Consent',
              style: TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _consentOption(
              'auto_record',
              'Publish the replay',
              'This live is recorded and saved as a replay everyone can watch.',
            ),
            const SizedBox(height: 8),
            _consentOption(
              'opt_out',
              'Staff archive only',
              'No public replay is published. Moderators keep a private recording to review this live — it is never shown to anyone.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _consentOption(String value, String title, String subtitle) {
    final isActive = _recordingConsent == value;
    return InkWell(
      onTap: () => setState(() => _recordingConsent = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? BuddyColors.green.withValues(alpha: 0.1)
              : BuddyColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? BuddyColors.green : BuddyColors.surfaceRaised,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? BuddyColors.green : BuddyColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label) {
    final isActive = _liveType == value;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isActive,
      onSelected: (_) => setState(() => _liveType = value),
      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isActive ? BuddyColors.green : BuddyColors.textSecondary,
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) return;
    DateTime? scheduledFor;
    if (_scheduled) {
      if (_scheduleDate == null || _scheduleTime == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pick a date and time for your live.'),
            ),
          );
        }
        return;
      }
      final d = _scheduleDate!;
      final t = _scheduleTime!;
      scheduledFor = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      if (scheduledFor.isBefore(DateTime.now())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pick a time in the future.')),
          );
        }
        return;
      }
    }
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(liveRepositoryProvider);
      final fee = int.tryParse(_feeController.text.trim()) ?? 0;
      final data = {
        'title': _titleController.text.trim(),
        'live_type': _liveType,
        'category': _category,
        'access': _access,
        'recording_consent': _recordingConsent,
        if (fee > 0) 'artifact_fee': {'dumbbell': fee},
        if (scheduledFor != null)
          'scheduled_for': scheduledFor.toUtc().toIso8601String(),
      };
      final raw = await repo.startLive(data);
      if (mounted) {
        final live = raw['data'] as Map<String, dynamic>;
        Navigator.of(context).pop();
        context.push('/lives/${live['live']['id']}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
