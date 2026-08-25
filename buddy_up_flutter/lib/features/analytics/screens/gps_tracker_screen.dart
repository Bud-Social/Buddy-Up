import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/analytics_provider.dart';

/// Hybrid cross-platform activity tracker (Flutter parity with web).
///
/// Keyless by design: uses on-device GPS via geolocator — no API keys, no
/// third-party tracking service. Route points are recorded as [lat, lng, ts]
/// triples and saved through the same `/analytics/activities/` endpoint the
/// web tracker uses, so sessions sync across devices.
class GpsTrackerScreen extends ConsumerStatefulWidget {
  final String initialActivityType;

  const GpsTrackerScreen({super.key, this.initialActivityType = 'run'});

  @override
  ConsumerState<GpsTrackerScreen> createState() => _GpsTrackerScreenState();
}

class _GpsTrackerScreenState extends ConsumerState<GpsTrackerScreen> {
  static const List<({String key, String label, IconData icon})> _types = [
    (key: 'walk', label: 'Walk', icon: Icons.directions_walk),
    (key: 'run', label: 'Run', icon: Icons.directions_run),
    (key: 'hike', label: 'Hike', icon: Icons.terrain),
    (key: 'cycle', label: 'Cycle', icon: Icons.directions_bike),
  ];

  StreamSubscription<Position>? _positionSub;
  Timer? _timer;

  bool _tracking = false;
  bool _saving = false;
  bool _gpsFix = false;
  double? _accuracyM;
  String _activityType = 'run';

  int _elapsedS = 0;
  double _distanceM = 0;
  final List<List<dynamic>> _route = [];
  Position? _lastPosition;
  String? _error;

  @override
  void initState() {
    super.initState();
    _activityType = widget.initialActivityType;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _error = null;
      _elapsedS = 0;
      _distanceM = 0;
      _route.clear();
      _lastPosition = null;
      _gpsFix = false;
    });

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _error = 'Location permission denied.');
      return;
    }

    // First fix immediately so zero-movement sessions still have a start pin.
    try {
      final first = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 15));
      _onPosition(first);
    } catch (_) {
      // Keep going — the stream may still deliver fixes.
    }

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(_onPosition, onError: (Object e) {
      if (mounted) setState(() => _error = 'GPS error: $e');
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedS += 1);
    });

    setState(() => _tracking = true);
  }

  void _onPosition(Position pos) {
    if (!mounted) return;
    setState(() {
      _gpsFix = true;
      _accuracyM = pos.accuracy;
      if (_lastPosition != null) {
        _distanceM += Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          pos.latitude,
          pos.longitude,
        );
      }
      _lastPosition = pos;
      _route.add([
        pos.latitude,
        pos.longitude,
        pos.timestamp.millisecondsSinceEpoch,
      ]);
    });
  }

  Future<void> _stopAndSave({required bool save}) async {
    _positionSub?.cancel();
    _timer?.cancel();
    setState(() => _tracking = false);

    if (!save || _elapsedS <= 0) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = true);
    try {
      final distanceKm = _distanceM / 1000.0;
      await ref.read(analyticsRepositoryProvider).createActivity({
        'activity_type': _activityType,
        'source': 'gps',
        'duration_seconds': _elapsedS,
        'distance_meters': _distanceM,
        'avg_pace': distanceKm > 0 ? _elapsedS / distanceKm : null,
        'calories_burned': _estimateCalories(),
        'route': _route,
        'started_at': DateTime.now()
            .subtract(Duration(seconds: _elapsedS))
            .toIso8601String(),
      });
      ref.read(analyticsSummaryProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity saved')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _error = 'Failed to save activity: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  double _estimateCalories() {
    const metPerType = {'walk': 3.5, 'run': 9.8, 'hike': 6.0, 'cycle': 7.5};
    final met = metPerType[_activityType] ?? 6.0;
    // 70 kg reference adult: kcal = MET * hours * kg.
    return met * (_elapsedS / 3600.0) * 70;
  }

  String get _paceText {
    if (_distanceM < 10 || _elapsedS == 0) return "--'--\"";
    final secPerKm = _elapsedS / (_distanceM / 1000);
    final m = (secPerKm / 60).floor();
    final s = (secPerKm % 60).round().toString().padLeft(2, '0');
    return "$m'$s\"";
  }

  String get _speedText {
    if (_elapsedS == 0) return '0.0';
    final kmh = (_distanceM / 1000) / (_elapsedS / 3600);
    return kmh.toStringAsFixed(1);
  }

  String get _elapsedText {
    final h = _elapsedS ~/ 3600;
    final m = (_elapsedS % 3600) ~/ 60;
    final s = (_elapsedS % 60).toString().padLeft(2, '0');
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isCycle = _activityType == 'cycle';
    return Scaffold(
      backgroundColor: BuddyColors.black,
      appBar: AppBar(
        title: const Text('Track Activity'),
        backgroundColor: BuddyColors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<String>(
                segments: [
                  for (final t in _types)
                    ButtonSegment(
                        value: t.key,
                        label: Text(t.label),
                        icon: Icon(t.icon, size: 16)),
                ],
                selected: {_activityType},
                onSelectionChanged: _tracking
                    ? null
                    : (s) => setState(() => _activityType = s.first),
              ),
              const SizedBox(height: 12),

              // GPS status chip — parity with the web tracker.
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: (_gpsFix ? BuddyColors.green : BuddyColors.gold)
                        .withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _gpsFix ? Icons.gps_fixed : Icons.gps_not_fixed,
                        size: 13,
                        color: _gpsFix ? BuddyColors.green : BuddyColors.gold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _gpsFix
                            ? 'GPS locked${_accuracyM != null ? ' ±${_accuracyM!.round()}m' : ''}'
                            : 'Acquiring GPS…',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _gpsFix ? BuddyColors.green : BuddyColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Live elapsed time
              Text(
                _elapsedText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: BuddyColors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _stat('Distance', '${(_distanceM / 1000).toStringAsFixed(2)} km'),
                  _stat(
                    isCycle ? 'Speed' : 'Pace',
                    isCycle ? '${_speedText}km/h' : _paceText,
                  ),
                  _stat('Points', '${_route.length}'),
                ],
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: BuddyColors.red, fontSize: 13),
                  ),
                ),

              const Spacer(),

              // Controls
              if (!_tracking)
                FilledButton.icon(
                  onPressed: _saving ? null : () => _start(),
                  style: FilledButton.styleFrom(backgroundColor: BuddyColors.green),
                  icon: const Icon(Icons.play_arrow, color: Colors.black),
                  label: const Text('Start', style: TextStyle(color: Colors.black)),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _saving ? null : () => _stopAndSave(save: false),
                        style: FilledButton.styleFrom(backgroundColor: BuddyColors.red),
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: (_saving || _elapsedS <= 0)
                            ? null
                            : () => _stopAndSave(save: true),
                        icon: _saving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save_outlined),
                        label: const Text('Save Activity'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: BuddyColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: BuddyColors.textSecondary)),
          ],
        ),
      );
}
