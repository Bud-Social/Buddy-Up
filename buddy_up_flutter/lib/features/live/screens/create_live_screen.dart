import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/live_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/input.dart';

class CreateLiveScreen extends ConsumerStatefulWidget {
  const CreateLiveScreen({super.key});

  @override
  ConsumerState<CreateLiveScreen> createState() => _CreateLiveScreenState();
}

class _CreateLiveScreenState extends ConsumerState<CreateLiveScreen> {
  final _titleController = TextEditingController();
  String _liveType = 'open_sweat';
  String _category = 'general';
  String _access = 'public';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
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
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Start'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuddyInput(label: 'Title', controller: _titleController, hint: 'Give your live a title...'),
            const SizedBox(height: 20),
            const Text('Live Type', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
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
            const Text('Category', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: ['general', 'cardio', 'strength', 'yoga', 'hiit', 'dance', 'boxing', 'meditation']
                  .map((c) => ChoiceChip(
                        label: Text(c[0].toUpperCase() + c.substring(1)),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                        selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                        labelStyle: TextStyle(color: _category == c ? BuddyColors.green : BuddyColors.textSecondary),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('Access', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
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
                      labelStyle: TextStyle(color: isActive ? BuddyColors.green : BuddyColors.textSecondary),
                    ),
                  ),
                );
              }).toList(),
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
      labelStyle: TextStyle(color: isActive ? BuddyColors.green : BuddyColors.textSecondary),
    );
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(liveRepositoryProvider);
      final data = {
        'title': _titleController.text.trim(),
        'live_type': _liveType,
        'category': _category,
        'access': _access,
      };
      final raw = await repo.startLive(data);
      if (mounted) {
        final live = raw['data'] as Map<String, dynamic>;
        Navigator.of(context).pop();
        context.push('/lives/${live['live']['id']}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
