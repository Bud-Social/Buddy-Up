import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/feed_provider.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../core/theme/app_theme.dart';

const List<({String key, String label})> _workoutCategories = [
  (key: 'upper', label: 'Upper'),
  (key: 'lower', label: 'Lower'),
  (key: 'legs', label: 'Legs'),
  (key: 'push', label: 'Push'),
  (key: 'pull', label: 'Pull'),
  (key: 'core', label: 'Core'),
  (key: 'arms', label: 'Arms'),
  (key: 'full', label: 'Full'),
];

const List<int> _timerPresets = [15, 30, 45, 60];

/// Category → detector exercise hint.
const Map<String, String> _categoryExerciseHint = {
  'upper': 'Overhead Press',
  'lower': 'Squat',
  'legs': 'Lunge',
  'push': 'Bench Press',
  'pull': 'Deadlift',
  'core': 'Push Up',
  'arms': 'Bicep Curl',
  'full': '',
};

class WorkoutFormScreen extends ConsumerStatefulWidget {
  const WorkoutFormScreen({super.key});

  @override
  ConsumerState<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends ConsumerState<WorkoutFormScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _exercise;
  final TextEditingController _exerciseController = TextEditingController();
  String _category = '';
  Map<String, dynamic>? _result;
  bool _isAnalyzing = false;
  String? _error;
  // Timer-only mode (no camera / no audio plugin — HapticFeedback only).
  int _timerPresetMin = 30;
  int? _timerSecsLeft;
  bool _timerRunning = false;
  bool _timerFinished = false;
  bool _timerLogged = false;
  bool _loggingTimer = false;
  Timer? _countdown;

  @override
  void dispose() {
    _countdown?.cancel();
    _exerciseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() { _image = picked; _isVideo = false; _result = null; _error = null; });
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() { _image = picked; _isVideo = true; _result = null; _error = null; });
    }
  }

  bool _isVideo = false;

  Future<void> _analyze() async {
    if (_image == null) return;
    setState(() { _isAnalyzing = true; _error = null; });
    try {
      final repo = ref.read(feedRepositoryProvider);
      final data = <String, dynamic>{_isVideo ? 'video' : 'image': _image!.path};
      if (_exercise != null) data['exercise'] = _exercise;
      final raw = await repo.analyzeWorkoutForm(data);
      setState(() { _result = raw['data'] as Map<String, dynamic>?; _isAnalyzing = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isAnalyzing = false; });
    }
  }

  void _selectCategory(String key) {
    setState(() {
      _category = _category == key ? '' : key;
      final hint = _categoryExerciseHint[_category];
      if (hint != null && hint.isNotEmpty) {
        _exercise = hint;
        _exerciseController.text = hint;
      } else if (_category.isEmpty) {
        _exercise = null;
        _exerciseController.clear();
      }
    });
  }

  void _startTimerCountdown() {
    _countdown?.cancel();
    setState(() {
      _timerFinished = false;
      _timerLogged = false;
      _error = null;
      _timerSecsLeft = _timerPresetMin * 60;
      _timerRunning = true;
    });
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        final left = (_timerSecsLeft ?? 0) - 1;
        if (left <= 0) {
          _timerSecsLeft = 0;
          _timerRunning = false;
          _timerFinished = true;
          t.cancel();
          // No audioplayers dependency — system alert beep + haptic finish alert.
          SystemSound.play(SystemSoundType.alert);
          HapticFeedback.vibrate();
        } else {
          _timerSecsLeft = left;
        }
      });
    });
  }

  void _stopTimerCountdown() {
    _countdown?.cancel();
    setState(() => _timerRunning = false);
  }

  Future<void> _logTimerWorkout() async {
    setState(() => _loggingTimer = true);
    try {
      final data = <String, dynamic>{
        'workout_type': 'strength',
        'exercise': (_exercise?.isNotEmpty ?? false) ? _exercise : (_category.isNotEmpty ? _category : 'workout'),
        'duration_minutes': _timerPresetMin,
      };
      if (_category.isNotEmpty) data['category'] = _category;
      final created = await ref.read(analyticsLogProvider.notifier).logWorkout(data);
      if (!mounted) return;
      if (created != null) {
        setState(() {
          _timerLogged = true;
          _loggingTimer = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timer workout logged')),
        );
      } else {
        setState(() => _loggingTimer = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not log workout. Please try again.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loggingTimer = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not log workout. Please try again.')),
      );
    }
  }

  String get _timerText {
    final s = _timerSecsLeft ?? _timerPresetMin * 60;
    final m = s ~/ 60;
    final rest = (s % 60).toString().padLeft(2, '0');
    return '$m:$rest';
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
                      if (_isVideo)
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: BuddyColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.videocam, color: BuddyColors.green, size: 40),
                                SizedBox(height: 8),
                                Text('Workout clip ready — analyze to count reps',
                                    style: TextStyle(color: BuddyColors.textSecondary)),
                              ],
                            ),
                          ),
                        )
                      else
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
                                Text('Tap for image, or pick a workout clip below',
                                    style: TextStyle(color: BuddyColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (_image == null)
                      OutlinedButton.icon(
                        onPressed: _pickVideo,
                        icon: const Icon(Icons.videocam, size: 16),
                        label: const Text('Pick workout video (counts reps)'),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Category',
                      style: TextStyle(
                        color: BuddyColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in _workoutCategories)
                          ChoiceChip(
                            label: Text(c.label),
                            selected: _category == c.key,
                            onSelected: (_) => _selectCategory(c.key),
                          ),
                      ],
                    ),
                    if (_category.isNotEmpty && (_categoryExerciseHint[_category]?.isNotEmpty ?? false))
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Detector hint: ${_categoryExerciseHint[_category]}',
                          style: const TextStyle(
                            color: BuddyColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _exerciseController,
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
                          const Row(
                            children: [
                              Icon(Icons.timer_outlined, size: 18, color: BuddyColors.green),
                              SizedBox(width: 8),
                              Text(
                                'Timer-only (no camera)',
                                style: TextStyle(
                                  color: BuddyColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final m in _timerPresets)
                                ChoiceChip(
                                  label: Text('$m min'),
                                  selected: _timerPresetMin == m,
                                  onSelected: _timerRunning
                                      ? null
                                      : (_) => setState(() {
                                            _timerPresetMin = m;
                                            _timerSecsLeft = null;
                                            _timerFinished = false;
                                            _timerLogged = false;
                                          }),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              _timerText,
                              style: const TextStyle(
                                color: BuddyColors.textPrimary,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _timerRunning
                                    ? OutlinedButton.icon(
                                        onPressed: _stopTimerCountdown,
                                        icon: const Icon(Icons.stop),
                                        label: const Text('Cancel'),
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: _startTimerCountdown,
                                        icon: const Icon(Icons.play_arrow),
                                        label: Text('Start $_timerPresetMin min timer'),
                                      ),
                              ),
                            ],
                          ),
                          if (_timerFinished) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Time! Photo capture needs a camera — analyze above, or log this session directly.',
                              style: TextStyle(
                                color: BuddyColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: _timerLogged
                                  ? const Text(
                                      'Logged to analytics.',
                                      style: TextStyle(color: BuddyColors.green),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: _loggingTimer ? null : _logTimerWorkout,
                                      icon: _loggingTimer
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.save_outlined),
                                      label: Text('Log $_timerPresetMin min workout'),
                                    ),
                            ),
                          ],
                        ],
                      ),
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
