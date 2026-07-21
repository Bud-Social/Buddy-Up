import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gym_provider.dart';
import '../../../data/models/gym.dart';
import '../../../shared/widgets/input.dart';
import '../../../core/theme/app_theme.dart';

class CreateGymScreen extends ConsumerStatefulWidget {
  const CreateGymScreen({super.key});

  @override
  ConsumerState<CreateGymScreen> createState() => _CreateGymScreenState();
}

class _CreateGymScreenState extends ConsumerState<CreateGymScreen> {
  final _nameController = TextEditingController();
  final _handleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  String _accessType = 'public';
  String _subscriptionType = 'free';
  String _category = '';
  bool _isSubmitting = false;
  bool _handleAvailable = true;

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _checkHandle() async {
    final handle = _handleController.text.trim();
    if (handle.length < 3) return;
    try {
      final repo = ref.read(gymRepositoryProvider);
      final raw = await repo.checkHandle(handle);
      final data = raw['data'] as Map<String, dynamic>;
      setState(() => _handleAvailable = data['available'] as bool? ?? false);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(gymRepositoryProvider);
      final payload = CreateGymPayload(
        name: _nameController.text.trim(),
        handle: _handleController.text.trim().isNotEmpty
            ? _handleController.text.trim()
            : _nameController.text.trim().toLowerCase().replaceAll(' ', '_'),
        description: _descriptionController.text.trim(),
        category: _category,
        accessType: _accessType,
        subscriptionType: _subscriptionType,
        locationCity: _cityController.text.trim(),
        locationCountry: _countryController.text.trim(),
      );
      await repo.createGym(payload);
      if (mounted) {
        Navigator.of(context).pop();
        ref.read(gymListProvider.notifier).loadGyms();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(gymCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Gym'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuddyInput(label: 'Gym name', controller: _nameController, hint: 'e.g. Iron Paradise'),
            const SizedBox(height: 12),
            BuddyInput(
              label: 'Handle',
              controller: _handleController,
              hint: 'e.g. iron-paradise',
              onChanged: (_) => _checkHandle(),
              suffixIcon: _handleController.text.length >= 3
                  ? (_handleAvailable ? Icons.check_circle : Icons.cancel)
                  : null,
            ),
            if (_handleController.text.length >= 3 && !_handleAvailable)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Handle taken', style: TextStyle(color: BuddyColors.red, fontSize: 12)),
              ),
            const SizedBox(height: 12),
            BuddyInput(label: 'Description', controller: _descriptionController, hint: 'Tell us about your gym', maxLines: 3),
            const SizedBox(height: 16),
            const Text('Category', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            categoriesAsync.when(
              data: (categories) => Wrap(
                spacing: 8,
                runSpacing: 6,
                children: categories.map((c) => ChoiceChip(
                  label: Text(c.displayName),
                  selected: _category == c.name,
                  onSelected: (_) => setState(() => _category = c.name),
                  selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: _category == c.name ? BuddyColors.green : BuddyColors.textSecondary,
                  ),
                )).toList(),
              ),
              loading: () => const Text('Loading...', style: TextStyle(color: BuddyColors.textSecondary)),
              error: (e, _) => Text('$e', style: const TextStyle(color: BuddyColors.red)),
            ),
            const SizedBox(height: 16),
            const Text('Access Type', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Row(
              children: ['public', 'private', 'secret'].map((t) {
                final isActive = _accessType == t;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(t[0].toUpperCase() + t.substring(1)),
                      selected: isActive,
                      onSelected: (_) => setState(() => _accessType = t),
                      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isActive ? BuddyColors.green : BuddyColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Subscription', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Row(
              children: ['free', 'members_free', 'paid', 'tiered'].map((t) {
                final isActive = _subscriptionType == t;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ChoiceChip(
                      label: Text(t.replaceAll('_', ' '), style: const TextStyle(fontSize: 10)),
                      selected: isActive,
                      onSelected: (_) => setState(() => _subscriptionType = t),
                      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isActive ? BuddyColors.green : BuddyColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: BuddyInput(label: 'City', controller: _cityController)),
                const SizedBox(width: 12),
                Expanded(child: BuddyInput(label: 'Country', controller: _countryController)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
