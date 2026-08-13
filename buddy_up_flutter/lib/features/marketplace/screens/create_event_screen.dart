import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/wizard_widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  final String? shopHandle;
  const CreateEventScreen({super.key, this.shopHandle});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _loading = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _onlineUrlController = TextEditingController();
  final _capacityController = TextEditingController(text: '50');
  final _tagsController = TextEditingController();

  String _eventType = 'in_person';
  String _category = 'fitness';
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  bool _isFree = false;
  Map<String, int> _ticketPrices = {'dumbbell': 5};
  XFile? _coverFile;
  String? _uploadedCoverUrl;

  final List<String> _eventTypes = ['in_person', 'online', 'hybrid'];
  final List<String> _categories = ['fitness', 'nutrition', 'wellness', 'workshop', 'seminar'];

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _onlineUrlController.dispose();
    _capacityController.dispose();
    _tagsController.dispose();
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

  Future<void> _createEvent() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);

      if (_coverFile != null) {
        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(_coverFile!.path, filename: 'cover.jpg'),
        });
        final result = await repo.uploadImage(formData);
        _uploadedCoverUrl = result['data']['url'] as String?;
      }

      final startDt = DateTime(
          _startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);
      final endDt = DateTime(
          _endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);

      final data = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'event_type': _eventType,
        'category': _category,
        'location': _locationController.text.trim(),
        'online_url': _onlineUrlController.text.trim(),
        'start_datetime': startDt.toIso8601String(),
        'end_datetime': endDt.toIso8601String(),
        'timezone': 'UTC',
        'capacity': int.tryParse(_capacityController.text) ?? 50,
        'is_free': _isFree,
        'ticket_price_artifacts': _ticketPrices,
        'tags': _tagsController.text
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
        if (_uploadedCoverUrl != null) 'cover_image_url': _uploadedCoverUrl,
        if (widget.shopHandle != null) 'shop_handle': widget.shopHandle,
      };

      await repo.createEvent(data);
      ref.invalidate(eventsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Event created!'), backgroundColor: BuddyColors.green),
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
    final stepLabels = ['Details', 'Date & Time', 'Location', 'Tickets', 'Review'];
    return Scaffold(
      backgroundColor: BuddyColors.black,
      appBar: AppBar(
        backgroundColor: BuddyColors.surface,
        title: Text('Create Event — ${stepLabels[_currentStep]}'),
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
                _StepDetails(),
                _StepDateTime(),
                _StepLocation(),
                _StepTickets(),
                _StepReview(),
              ],
            ),
          ),
          WizardNavButtons(
            currentStep: _currentStep,
            total: 5,
            loading: _loading,
            onNext: _nextStep,
            onBack: _prevStep,
            onSubmit: _createEvent,
            submitLabel: 'Create Event',
          ),
        ],
      ),
    );
  }

  Widget _StepDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Event Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        // Cover image
        GestureDetector(
          onTap: _pickCover,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
                color: BuddyColors.surfaceRaised,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _coverFile != null ? BuddyColors.green : BuddyColors.surfaceRaised,
                    width: 2)),
            clipBehavior: Clip.antiAlias,
            child: _coverFile != null
                ? Image.file(File(_coverFile!.path), fit: BoxFit.cover)
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 36, color: BuddyColors.textSecondary),
                    const SizedBox(height: 6),
                    const Text('Upload event cover',
                        style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
                  ]),
          ),
        ),
        const SizedBox(height: 20),
        _Field('Title', _titleController, hint: 'e.g. Morning HIIT Bootcamp'),
        const SizedBox(height: 14),
        _Field('Description', _descriptionController,
            hint: 'Describe the event...', maxLines: 4),
        const SizedBox(height: 14),
        const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _categories
              .map((c) => ChoiceChip(
                    label: Text(c),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                    selectedColor: BuddyColors.green,
                  ))
              .toList(),
        ),
        const SizedBox(height: 14),
        _Field('Tags', _tagsController, hint: 'hiit, cardio, beginners (comma separated)'),
      ]),
    );
  }

  Widget _StepDateTime() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Date & Time', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Text('Event Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _eventTypes
              .map((t) => ChoiceChip(
                    label: Text(t.replaceAll('_', ' ')),
                    selected: _eventType == t,
                    onSelected: (_) => setState(() => _eventType = t),
                    selectedColor: BuddyColors.green,
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        _DateTimePicker(
          label: 'Start',
          date: _startDate,
          time: _startTime,
          onDateTap: () async {
            final d = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)));
            if (d != null) setState(() => _startDate = d);
          },
          onTimeTap: () async {
            final t = await showTimePicker(context: context, initialTime: _startTime);
            if (t != null) setState(() => _startTime = t);
          },
        ),
        const SizedBox(height: 16),
        _DateTimePicker(
          label: 'End',
          date: _endDate,
          time: _endTime,
          onDateTap: () async {
            final d = await showDatePicker(
                context: context,
                initialDate: _endDate,
                firstDate: _startDate,
                lastDate: DateTime.now().add(const Duration(days: 365)));
            if (d != null) setState(() => _endDate = d);
          },
          onTimeTap: () async {
            final t = await showTimePicker(context: context, initialTime: _endTime);
            if (t != null) setState(() => _endTime = t);
          },
        ),
        const SizedBox(height: 20),
        _Field('Capacity (max attendees)', _capacityController,
            hint: '50', inputType: TextInputType.number),
      ]),
    );
  }

  Widget _StepLocation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Location', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        if (_eventType == 'in_person' || _eventType == 'hybrid') ...[
          _Field('Venue / Address', _locationController, hint: 'e.g. 123 Fitness St, Nairobi'),
          const SizedBox(height: 16),
        ],
        if (_eventType == 'online' || _eventType == 'hybrid') ...[
          _Field('Online Meeting URL', _onlineUrlController, hint: 'https://zoom.us/j/...'),
        ],
      ]),
    );
  }

  Widget _StepTickets() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tickets & Pricing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SwitchListTile(
          value: _isFree,
          onChanged: (v) => setState(() => _isFree = v),
          title: const Text('Free Event'),
          subtitle: const Text('No tickets required'),
          activeColor: BuddyColors.green,
          contentPadding: EdgeInsets.zero,
        ),
        if (!_isFree) ...[
          const SizedBox(height: 16),
          const Text('Ticket Price (Artifacts)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          ..._ticketPrices.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(e.key,
                            style: const TextStyle(fontWeight: FontWeight.w500))),
                    Text('${e.value}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () {
                        setState(() => _ticketPrices.remove(e.key));
                      },
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Ticket Tier'),
            onPressed: () => _showAddTierDialog(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: BuddyColors.green),
              foregroundColor: BuddyColors.green,
            ),
          ),
        ],
      ]),
    );
  }

  Widget _StepReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Review Event', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        if (_coverFile != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(File(_coverFile!.path), height: 140, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
        ],
        Card(
          color: BuddyColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _ReviewRow('Title', _titleController.text),
              _ReviewRow('Type', _eventType),
              _ReviewRow('Category', _category),
              _ReviewRow('Start', '${_startDate.day}/${_startDate.month}/${_startDate.year} at ${_startTime.format(context)}'),
              _ReviewRow('End', '${_endDate.day}/${_endDate.month}/${_endDate.year} at ${_endTime.format(context)}'),
              _ReviewRow('Capacity', _capacityController.text),
              _ReviewRow('Pricing', _isFree ? 'Free' : '${_ticketPrices}'),
              if (_locationController.text.isNotEmpty)
                _ReviewRow('Location', _locationController.text),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _ReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text(label, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13))),
          Expanded(
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _Field(String label, TextEditingController ctrl,
      {String? hint, int maxLines = 1, TextInputType? inputType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: inputType,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: BuddyColors.surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ]);
  }

  void _showAddTierDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Ticket Tier'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tier name (e.g. VIP)')),
          const SizedBox(height: 8),
          TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price in artifacts')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price = int.tryParse(priceCtrl.text) ?? 0;
              if (name.isNotEmpty && price > 0) {
                setState(() => _ticketPrices[name] = price);
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


class _DateTimePicker extends StatelessWidget {
  final String label;
  final DateTime date;
  final TimeOfDay time;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const _DateTimePicker({
    required this.label,
    required this.date,
    required this.time,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: onDateTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: BuddyColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today, size: 16, color: BuddyColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('${date.day}/${date.month}/${date.year}'),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onTimeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: BuddyColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.access_time, size: 16, color: BuddyColors.textSecondary),
                const SizedBox(width: 8),
                Text(time.format(context)),
              ]),
            ),
          ),
        ]),
      ],
    );
  }
}
