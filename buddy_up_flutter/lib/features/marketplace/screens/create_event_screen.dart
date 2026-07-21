import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/marketplace_provider.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart' show BuddyInput;

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _coverCtrl = TextEditingController();
  final _eventTypeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _onlineUrlCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _startTimeCtrl = TextEditingController(text: '09:00');
  final _endDateCtrl = TextEditingController();
  final _endTimeCtrl = TextEditingController(text: '17:00');
  final _timezoneCtrl = TextEditingController(text: 'UTC');
  final _capacityCtrl = TextEditingController(text: '50');
  final _gymIdCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _coverCtrl.dispose();
    _eventTypeCtrl.dispose();
    _locationCtrl.dispose();
    _onlineUrlCtrl.dispose();
    _startDateCtrl.dispose();
    _startTimeCtrl.dispose();
    _endDateCtrl.dispose();
    _endTimeCtrl.dispose();
    _timezoneCtrl.dispose();
    _capacityCtrl.dispose();
    _gymIdCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) ctrl.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final data = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'cover_image_url': _coverCtrl.text.trim(),
        'event_type': _eventTypeCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'online_url': _onlineUrlCtrl.text.trim().isEmpty ? null : _onlineUrlCtrl.text.trim(),
        'start_datetime': '${_startDateCtrl.text.trim()}T${_startTimeCtrl.text.trim()}:00Z',
        'end_datetime': '${_endDateCtrl.text.trim()}T${_endTimeCtrl.text.trim()}:00Z',
        'timezone': _timezoneCtrl.text.trim(),
        'capacity': int.parse(_capacityCtrl.text.trim()),
        'gym_id': _gymIdCtrl.text.trim().isEmpty ? null : _gymIdCtrl.text.trim(),
        'tags': _tagsCtrl.text.trim().isEmpty ? <String>[] : _tagsCtrl.text.trim().split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
      };
      await repo.createEvent(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BuddyInput(label: 'Title', controller: _titleCtrl, validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 12),
              BuddyInput(label: 'Description', controller: _descCtrl, maxLines: 3, validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 12),
              BuddyInput(label: 'Cover Image URL', controller: _coverCtrl),
              const SizedBox(height: 12),
              BuddyInput(label: 'Event Type', controller: _eventTypeCtrl, hint: 'e.g. competition, workshop, social'),
              const SizedBox(height: 12),
              BuddyInput(label: 'Location', controller: _locationCtrl, hint: 'Physical address or venue'),
              const SizedBox(height: 12),
              BuddyInput(label: 'Online URL', controller: _onlineUrlCtrl, hint: 'https://...'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => _pickDate(_startDateCtrl),
                  child: AbsorbPointer(child: BuddyInput(label: 'Start Date', controller: _startDateCtrl, hint: 'YYYY-MM-DD')),
                )),
                const SizedBox(width: 8),
                Expanded(child: BuddyInput(label: 'Start Time', controller: _startTimeCtrl, hint: 'HH:MM')),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => _pickDate(_endDateCtrl),
                  child: AbsorbPointer(child: BuddyInput(label: 'End Date', controller: _endDateCtrl, hint: 'YYYY-MM-DD')),
                )),
                const SizedBox(width: 8),
                Expanded(child: BuddyInput(label: 'End Time', controller: _endTimeCtrl, hint: 'HH:MM')),
              ]),
              const SizedBox(height: 12),
              BuddyInput(label: 'Timezone', controller: _timezoneCtrl),
              const SizedBox(height: 12),
              BuddyInput(label: 'Capacity', controller: _capacityCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              BuddyInput(label: 'Gym ID (optional)', controller: _gymIdCtrl),
              const SizedBox(height: 12),
              BuddyInput(label: 'Tags (comma separated)', controller: _tagsCtrl, hint: 'e.g. strength, cardio, beginner'),
              const SizedBox(height: 24),
              BuddyButton(
                label: 'Create Event',
                fullWidth: true,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
