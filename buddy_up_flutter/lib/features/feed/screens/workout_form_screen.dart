import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/feed_provider.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../analytics/utils/workout_types.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../core/theme/app_theme.dart';

const List<int> _timerPresets = [15, 30, 45, 60];

/// Recording mode for a Start-workout session.
const String _modeCamera = 'camera';
const String _modeTimer = 'timer';

/// Category → detector exercise hint (strength muscle groups).
const Map<String, String> _categoryExerciseHint = {
  'upper': 'Overhead Press',
  'lower': 'Squat',
  'legs': 'Lunge',
  'push': 'Bench Press',
  'pull': 'Deadlift',
  'core': 'Push Up',
  'arms': 'Bicep Curl',
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

  // Start workout — the only choices are type, category and duration; the
  // recorder and the countdown run from here and the POST happens on finish.
  String _workoutType = 'strength';
  String _category = '';
  String _startMode = _modeTimer;
  bool _timerAutoLog = false;
  int? _elapsedMin;
  bool _isVideo = false;

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

  /// Categories come from the workout taxonomy — cardio and the distance sports
  /// have none, and a stale category from another type would be a 400.
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

  void _selectWorkoutType(String key, WorkoutTypeSpecs specs) {
    setState(() {
      _workoutType = key;
      _category = normalizeCategory(specs.specFor(key), _category);
      final hint = _categoryExerciseHint[_category];
      if (hint == null || hint.isEmpty) {
        _exercise = null;
        _exerciseController.clear();
      }
    });
  }

  Future<({ImageSource source, bool video})?> _startMediaSheet() {
    return showModalBottomSheet<({ImageSource source, bool video})>(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in const [
              (
                label: 'Take a photo',
                icon: Icons.photo_camera_outlined,
                source: ImageSource.camera,
                video: false,
              ),
              (
                label: 'Choose a photo',
                icon: Icons.photo_library_outlined,
                source: ImageSource.gallery,
                video: false,
              ),
              (
                label: 'Record a clip',
                icon: Icons.videocam_outlined,
                source: ImageSource.camera,
                video: true,
              ),
            ])
              ListTile(
                leading: Icon(option.icon, color: BuddyColors.green),
                title: Text(
                  option.label,
                  style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14),
                ),
                onTap: () => Navigator.of(sheetContext).pop((
                  source: option.source,
                  video: option.video,
                )),
              ),
          ],
        ),
      ),
    );
  }

  Future<XFile?> _captureStartMedia(ImageSource source, {required bool video}) async {
    final picked = video
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);
    if (picked == null) return null;
    if (!mounted) return null;
    setState(() { _image = picked; _isVideo = video; _result = null; _error = null; });
    return picked;
  }

  /// Start recording now: camera first (it needs a gesture), then the timer.
  Future<void> _startQuick() async {
    if (_timerRunning) return;
    if (_startMode == _modeCamera) {
      final choice = await _startMediaSheet();
      if (choice == null || !mounted) return;
      final picked = await _captureStartMedia(
        choice.source,
        video: choice.video,
      );
      if (picked == null) return;
    }
    _startTimerCountdown(autoLog: true);
  }

  void _startTimerCountdown({bool autoLog = false}) {
    _countdown?.cancel();
    setState(() {
      _timerFinished = false;
      _timerLogged = false;
      _error = null;
      _timerAutoLog = autoLog;
      _elapsedMin = null;
      _timerSecsLeft = _timerPresetMin * 60;
      _timerRunning = true;
    });
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      var done = false;
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
          done = true;
        } else {
          _timerSecsLeft = left;
        }
      });
      // Started from Start workout: post it the moment the timer runs out.
      if (done && _timerAutoLog) _logTimerWorkout();
    });
  }

  void _stopTimerCountdown() {
    _countdown?.cancel();
    // A quick session that gets stopped early still happened — offer to log the
    // minutes actually recorded rather than dropping the workout.
    final elapsedSecs = (_timerPresetMin * 60) - (_timerSecsLeft ?? 0);
    setState(() {
      _timerRunning = false;
      if (_timerAutoLog && !_timerFinished && elapsedSecs >= 60) {
        _elapsedMin = elapsedSecs ~/ 60;
        _timerFinished = true;
      }
    });
  }

  Future<void> _logTimerWorkout() async {
    setState(() => _loggingTimer = true);
    final spec = workoutTypesOrLocal(ref.read(workoutTypesProvider))
        .specFor(_workoutType);
    final minutes = _elapsedMin ?? _timerPresetMin;
    try {
      final data = <String, dynamic>{
        'workout_type': _workoutType,
        // Types without categories send '' — anything else is a 400.
        'category': normalizeCategory(spec, _category),
        'duration_minutes': minutes,
      };
      final exercise = (_exercise?.isNotEmpty ?? false) ? _exercise! : _category;
      if (spec.has('exercise') && exercise.isNotEmpty) data['exercise'] = exercise;
      final created = await ref.read(analyticsLogProvider.notifier).logWorkout(data);
      if (!mounted) return;
      if (created != null) {
        setState(() {
          _timerLogged = true;
          _loggingTimer = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${spec.label} workout logged')),
        );
        await ref.read(analyticsSummaryProvider.notifier).refresh();
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
    final specs = workoutTypesOrLocal(ref.watch(workoutTypesProvider));
    final spec = specs.specFor(_workoutType);
    return Scaffold(
      appBar: AppBar(title: const Text('Start workout')),
      body: _isAnalyzing
          ? const PageLoader()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _analyze)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _startWorkoutCard(specs, spec),
                    const SizedBox(height: 24),
                    _analyzeCard(),
                    if (_result != null) ...[
                      const SizedBox(height: 24),
                      _resultsCard(),
                    ],
                  ],
                ),
    );
  }

  /// Start workout: type + category + duration, then just record. Nothing to
  /// type — the countdown posts the log itself when it finishes.
  Widget _startWorkoutCard(WorkoutTypeSpecs specs, WorkoutTypeSpec spec) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No typing needed — pick what you did and start recording.',
            style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _chipLabel('What are you doing?'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final key in specs.order)
                ChoiceChip(
                  label: Text(specs.specFor(key).label),
                  selected: _workoutType == key,
                  onSelected: _timerRunning
                      ? null
                      : (_) => _selectWorkoutType(key, specs),
                  selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: _workoutType == key
                        ? BuddyColors.green
                        : BuddyColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          if (measuredNotice(spec) != null) ...[
            const SizedBox(height: 8),
            Text(
              measuredNotice(spec)!,
              style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11),
            ),
          ],
          if (spec.hasCategories) ...[
            const SizedBox(height: 16),
            _chipLabel('Category'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in spec.categories)
                  ChoiceChip(
                    label: Text(c.label),
                    selected: _category == c.key,
                    onSelected: _timerRunning
                        ? null
                        : (_) => _selectCategory(c.key),
                    selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: _category == c.key
                          ? BuddyColors.green
                          : BuddyColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _chipLabel('Duration'),
          const SizedBox(height: 6),
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
                            _elapsedMin = null;
                          }),
                  selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: _timerPresetMin == m
                        ? BuddyColors.green
                        : BuddyColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: _modeTimer,
                label: Text('Timer only'),
                icon: Icon(Icons.timer_outlined, size: 16),
              ),
              ButtonSegment(
                value: _modeCamera,
                label: Text('Camera'),
                icon: Icon(Icons.photo_camera_outlined, size: 16),
              ),
            ],
            selected: {_startMode},
            onSelectionChanged: _timerRunning
                ? null
                : (s) => setState(() => _startMode = s.first),
          ),
          const SizedBox(height: 16),
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
                        onPressed: _startQuick,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(
                          _startMode == _modeCamera
                              ? 'Record $_timerPresetMin min'
                              : 'Start $_timerPresetMin min',
                        ),
                      ),
              ),
            ],
          ),
          if (_timerFinished) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _timerLogged
                  ? const Text(
                      'Logged to analytics.',
                      textAlign: TextAlign.center,
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
                      label: Text('Log ${_elapsedMin ?? _timerPresetMin} min workout'),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  /// Form analyzer — camera capture / rep counting from a photo or clip.
  Widget _analyzeCard() {
    return Container(
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
              Icon(Icons.auto_awesome, size: 18, color: BuddyColors.green),
              SizedBox(width: 8),
              Text(
                'Form analysis',
                style: TextStyle(
                  color: BuddyColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_image != null)
            if (_isVideo)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: BuddyColors.surfaceRaised,
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
                  color: BuddyColors.surfaceRaised,
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
          const SizedBox(height: 12),
          TextField(
            controller: _exerciseController,
            style: const TextStyle(color: BuddyColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Exercise name (optional)',
              hintStyle: TextStyle(color: BuddyColors.textSecondary),
            ),
            onChanged: (v) => _exercise = v.isNotEmpty ? v : null,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _image != null ? _analyze : null,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Analyze Form'),
          ),
        ],
      ),
    );
  }

  Widget _resultsCard() {
    return Container(
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
    );
  }

  Widget _chipLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: BuddyColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}