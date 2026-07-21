import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/feed_provider.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../core/theme/app_theme.dart';

class WorkoutFormScreen extends ConsumerStatefulWidget {
  const WorkoutFormScreen({super.key});

  @override
  ConsumerState<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends ConsumerState<WorkoutFormScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _exercise;
  Map<String, dynamic>? _result;
  bool _isAnalyzing = false;
  String? _error;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() { _image = picked; _result = null; _error = null; });
    }
  }

  Future<void> _analyze() async {
    if (_image == null) return;
    setState(() { _isAnalyzing = true; _error = null; });
    try {
      final repo = ref.read(feedRepositoryProvider);
      final data = <String, dynamic>{'image': _image!.path};
      if (_exercise != null) data['exercise'] = _exercise;
      final raw = await repo.analyzeWorkoutForm(data);
      setState(() { _result = raw['data'] as Map<String, dynamic>?; _isAnalyzing = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isAnalyzing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Form Analysis')),
      body: _isAnalyzing
          ? const PageLoader()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _analyze)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image! as dynamic,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 250,
                            color: BuddyColors.surface,
                            child: const Center(
                              child: Icon(Icons.broken_image, color: BuddyColors.textSecondary, size: 48),
                            ),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: BuddyColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: BuddyColors.border, style: BorderStyle.solid),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_photo_alternate, color: BuddyColors.textSecondary, size: 48),
                                SizedBox(height: 8),
                                Text('Tap to select image', style: TextStyle(color: BuddyColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      style: const TextStyle(color: BuddyColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Exercise name (optional)',
                        hintStyle: TextStyle(color: BuddyColors.textSecondary),
                      ),
                      onChanged: (v) => _exercise = v.isNotEmpty ? v : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _image != null ? _analyze : null,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Analyze Form'),
                    ),
                    if (_result != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: BuddyColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Analysis Results',
                              style: TextStyle(
                                color: BuddyColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...(_result!.entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${e.key.replaceAll('_', ' ')}: ',
                                    style: const TextStyle(
                                      color: BuddyColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      e.value?.toString() ?? '',
                                      style: const TextStyle(color: BuddyColors.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}
