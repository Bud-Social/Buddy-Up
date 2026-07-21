import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart' show BuddyInput;
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../core/cache/with_cache.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String trainerUsername;
  const BookingScreen({super.key, required this.trainerUsername});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '09:00');
  final _durationCtrl = TextEditingController(text: '60');
  final _notesCtrl = TextEditingController();
  final _sessionTypeCtrl = TextEditingController(text: 'one_on_one');
  bool _isBooking = false;

  @override
  void dispose() {
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _durationCtrl.dispose();
    _notesCtrl.dispose();
    _sessionTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) _dateCtrl.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _book() async {
    if (_dateCtrl.text.trim().isEmpty || _timeCtrl.text.trim().isEmpty) return;
    setState(() => _isBooking = true);
    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.createBooking(widget.trainerUsername, {
        'trainer_username': widget.trainerUsername,
        'scheduled_date': _dateCtrl.text.trim(),
        'scheduled_time': _timeCtrl.text.trim(),
        'duration_minutes': int.tryParse(_durationCtrl.text.trim()) ?? 60,
        'session_type': _sessionTypeCtrl.text.trim(),
        if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session booked successfully!')),
        );
        invalidateCache(ref, 'my_sessions');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availAsync = ref.watch(trainerAvailabilityProvider(widget.trainerUsername));
    return Scaffold(
      appBar: AppBar(title: const Text('Book Session')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Session Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(child: BuddyInput(label: 'Date', controller: _dateCtrl, hint: 'YYYY-MM-DD')),
            ),
            const SizedBox(height: 12),
            BuddyInput(label: 'Time', controller: _timeCtrl, hint: 'HH:MM (24h)'),
            const SizedBox(height: 12),
            BuddyInput(label: 'Duration (minutes)', controller: _durationCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            BuddyInput(label: 'Session Type', controller: _sessionTypeCtrl, hint: 'one_on_one, group, online'),
            const SizedBox(height: 12),
            BuddyInput(label: 'Notes (optional)', controller: _notesCtrl, maxLines: 3),
            const SizedBox(height: 24),
            const Text('Trainer Availability', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            availAsync.when(
              data: (slots) {
                if (slots.isEmpty) return const Text('No availability set', style: TextStyle(color: BuddyColors.textSecondary));
                final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Column(
                  children: slots.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      Text('${dayNames[s.dayOfWeek % 7]}: ', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('${s.startTime} - ${s.endTime}'),
                    ]),
                  )).toList(),
                );
              },
              loading: () => const ShimmerList(itemCount: 3, itemHeight: 24),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 24),
            BuddyButton(
              label: 'Confirm Booking',
              fullWidth: true,
              isLoading: _isBooking,
              icon: Icons.check,
              onPressed: _book,
            ),
          ],
        ),
      ),
    );
  }
}
