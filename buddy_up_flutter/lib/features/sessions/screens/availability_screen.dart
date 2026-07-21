import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart' show BuddyInput;
import '../../../shared/widgets/shimmer_loader.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  final _dayCtrl = TextEditingController();
  final _startCtrl = TextEditingController(text: '09:00');
  final _endCtrl = TextEditingController(text: '17:00');
  bool _isSaving = false;

  @override
  void dispose() {
    _dayCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _addSlot() async {
    final day = int.tryParse(_dayCtrl.text.trim());
    final start = _startCtrl.text.trim();
    final end = _endCtrl.text.trim();
    if (day == null || day < 0 || day > 6 || start.isEmpty || end.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.createAvailabilitySlot({
        'day_of_week': day,
        'start_time': start,
        'end_time': end,
      });
      ref.invalidate(myAvailabilityProvider);
      _dayCtrl.clear();
      _startCtrl.text = '09:00';
      _endCtrl.text = '17:00';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability slot added')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteSlot(String slotId) async {
    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.deleteAvailabilitySlot(slotId);
      ref.invalidate(myAvailabilityProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Slot removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availAsync = ref.watch(myAvailabilityProvider);
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Scaffold(
      appBar: AppBar(title: const Text('My Availability')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Slot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            BuddyInput(label: 'Day of Week (0=Sun, 6=Sat)', controller: _dayCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            BuddyInput(label: 'Start Time', controller: _startCtrl, hint: 'HH:MM (24h)'),
            const SizedBox(height: 12),
            BuddyInput(label: 'End Time', controller: _endCtrl, hint: 'HH:MM (24h)'),
            const SizedBox(height: 12),
            BuddyButton(
              label: 'Add Slot',
              fullWidth: true,
              isLoading: _isSaving,
              icon: Icons.add,
              onPressed: _addSlot,
            ),
            const SizedBox(height: 32),
            const Text('Current Slots', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            availAsync.when(
              data: (slots) {
                if (slots.isEmpty) {
                  return const Text('No availability set', style: TextStyle(color: BuddyColors.textSecondary));
                }
                return Column(
                  children: slots.map((s) => Card(
                    color: BuddyColors.surface,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.schedule, color: BuddyColors.green),
                      title: Text('${dayNames[s.dayOfWeek % 7]}: ${s.startTime} - ${s.endTime}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: BuddyColors.red),
                        onPressed: () => _deleteSlot(s.id),
                      ),
                    ),
                  )).toList(),
                );
              },
              loading: () => const ShimmerList(itemCount: 3, itemHeight: 60),
              error: (e, _) => Text('$e'),
            ),
          ],
        ),
      ),
    );
  }
}
