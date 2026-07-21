import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart' show BuddyInput;

class CreateMealPlanScreen extends ConsumerStatefulWidget {
  const CreateMealPlanScreen({super.key});

  @override
  ConsumerState<CreateMealPlanScreen> createState() => _CreateMealPlanScreenState();
}

class _CreateMealPlanScreenState extends ConsumerState<CreateMealPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _coverCtrl = TextEditingController();
  final _dietTypeCtrl = TextEditingController();
  final _calorieRangeCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '1');
  final _priceArtifactTypeCtrl = TextEditingController();
  final _priceArtifactQtyCtrl = TextEditingController(text: '1');
  final _priceArtifacts = <Map<String, dynamic>>[];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _coverCtrl.dispose();
    _dietTypeCtrl.dispose();
    _calorieRangeCtrl.dispose();
    _durationCtrl.dispose();
    _priceArtifactTypeCtrl.dispose();
    _priceArtifactQtyCtrl.dispose();
    super.dispose();
  }

  void _addPriceArtifact() {
    final type = _priceArtifactTypeCtrl.text.trim();
    final qty = int.tryParse(_priceArtifactQtyCtrl.text.trim()) ?? 1;
    if (type.isEmpty) return;
    setState(() => _priceArtifacts.add({'artifact_type': type, 'quantity': qty}));
    _priceArtifactTypeCtrl.clear();
    _priceArtifactQtyCtrl.text = '1';
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
        'diet_type': _dietTypeCtrl.text.trim(),
        'calorie_range': _calorieRangeCtrl.text.trim(),
        'duration_weeks': int.parse(_durationCtrl.text.trim()),
        'price_artifacts': {
          for (final a in _priceArtifacts) a['artifact_type'] as String: a['quantity'] as int,
        },
      };
      await repo.createMealPlan(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan created!')),
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
      appBar: AppBar(title: const Text('Create Meal Plan')),
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
              BuddyInput(label: 'Diet Type', controller: _dietTypeCtrl, hint: 'e.g. vegan, keto, balanced'),
              const SizedBox(height: 12),
              BuddyInput(label: 'Calorie Range', controller: _calorieRangeCtrl, hint: 'e.g. 1800-2200 kcal'),
              const SizedBox(height: 12),
              BuddyInput(label: 'Duration (weeks)', controller: _durationCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              const Text('Price Artifacts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: BuddyInput(label: 'Type', controller: _priceArtifactTypeCtrl, hint: 'e.g. dumbbell')),
                const SizedBox(width: 8),
                SizedBox(width: 80, child: BuddyInput(label: 'Qty', controller: _priceArtifactQtyCtrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                IconButton(onPressed: _addPriceArtifact, icon: const Icon(Icons.add_circle, color: BuddyColors.green)),
              ]),
              ..._priceArtifacts.asMap().entries.map((e) => Chip(
                label: Text('${e.value['quantity']} × ${e.value['artifact_type']}'),
                onDeleted: () => setState(() => _priceArtifacts.removeAt(e.key)),
                backgroundColor: BuddyColors.surfaceRaised,
              )),
              const SizedBox(height: 24),
              BuddyButton(
                label: 'Create Meal Plan',
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
