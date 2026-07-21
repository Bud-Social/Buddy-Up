import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../providers/live_provider.dart';
import '../../../core/theme/app_theme.dart';

class RandomDropScreen extends ConsumerStatefulWidget {
  const RandomDropScreen({super.key});

  @override
  ConsumerState<RandomDropScreen> createState() => _RandomDropScreenState();
}

class _RandomDropScreenState extends ConsumerState<RandomDropScreen>
    with TickerProviderStateMixin {
  String? _activityType;
  int _duration = 15;
  bool _isSearching = false;
  String? _statusMessage;
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  void _startSearch() async {
    if (_activityType == null) return;
    setState(() => _isSearching = true);
    _pulseController?.repeat(reverse: true);

    try {
      final repo = ref.read(liveRepositoryProvider);
      final raw = await repo.startRandomDrop({
        'activity_type': _activityType,
        'duration': _duration,
      });
      final data = raw['data'] as Map<String, dynamic>;
      setState(() => _statusMessage = 'Searching... (${data['timeout_seconds']}s)');

      _pollStatus();
    } catch (e) {
      setState(() {
        _isSearching = false;
        _statusMessage = 'Failed: $e';
      });
      _pulseController?.stop();
    }
  }

  void _pollStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    try {
      final repo = ref.read(liveRepositoryProvider);
      final raw = await repo.getRandomDropStatus();
      final data = raw['data'] as Map<String, dynamic>;
      final status = data['status'] as String?;

      if (status == 'matched') {
        setState(() {
          _isSearching = false;
          _statusMessage = 'Match found!';
        });
        _pulseController?.stop();
        final liveId = data['live_id'] as String?;
        if (liveId != null && mounted) {
          context.push('/lives/$liveId');
        }
      } else if (status == 'searching') {
        _pollStatus();
      } else {
        setState(() {
          _isSearching = false;
          _statusMessage = 'No match found';
        });
        _pulseController?.stop();
      }
    } catch (_) {
      setState(() {
        _isSearching = false;
        _statusMessage = 'Search cancelled';
      });
      _pulseController?.stop();
    }
  }

  void _cancelSearch() async {
    final repo = ref.read(liveRepositoryProvider);
    await repo.cancelRandomDrop();
    setState(() {
      _isSearching = false;
      _statusMessage = null;
    });
    _pulseController?.stop();
  }

  @override
  Widget build(BuildContext context) {
    final activities = ['cardio', 'strength', 'yoga', 'hiit', 'dance', 'boxing', 'meditation', 'running', 'cycling'];

    return Scaffold(
      appBar: AppBar(title: const Text('Random Drop')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shuffle, size: 64, color: BuddyColors.green),
              const SizedBox(height: 16),
              const Text('Find a Random Workout Buddy', style: TextStyle(color: BuddyColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Match with someone for an impromptu session', style: TextStyle(color: BuddyColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              if (!_isSearching) ...[
                const Text('Select activity', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: activities.map((a) {
                    final isActive = _activityType == a;
                    return ChoiceChip(
                      label: Text(a[0].toUpperCase() + a.substring(1)),
                      selected: isActive,
                      onSelected: (_) => setState(() => _activityType = a),
                      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                      labelStyle: TextStyle(color: isActive ? BuddyColors.green : BuddyColors.textSecondary),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('Duration (minutes)', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Slider(
                  value: _duration.toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 23,
                  label: '$_duration min',
                  activeColor: BuddyColors.green,
                  onChanged: (v) => setState(() => _duration = v.toInt()),
                ),
                Text('$_duration minutes', style: const TextStyle(color: BuddyColors.textPrimary)),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _activityType != null ? _startSearch : null,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Find Match'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                ),
              ],
              if (_isSearching) ...[
                AnimatedBuilder(
                  animation: _pulseController!,
                  builder: (_, _) {
                    return Transform.scale(
                      scale: 1 + (_pulseController?.value ?? 0) * 0.1,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: BuddyColors.green.withValues(alpha: 0.15),
                        ),
                        child: const Icon(Icons.shuffle, size: 48, color: BuddyColors.green),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(_statusMessage ?? 'Searching...', style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 16)),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _cancelSearch,
                  child: const Text('Cancel', style: TextStyle(color: BuddyColors.red)),
                ),
              ],
              if (_statusMessage != null && !_isSearching && _statusMessage != 'Match found!') ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _statusMessage = null;
                    _activityType = null;
                  }),
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
