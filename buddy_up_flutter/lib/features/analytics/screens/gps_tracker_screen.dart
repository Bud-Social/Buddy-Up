import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/navigation/main_header.dart';
import '../providers/analytics_provider.dart';
import '../services/activity_checkpoint_service.dart';
import '../widgets/activity_route_map.dart';

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

class _GpsTrackerScreenState extends ConsumerState<GpsTrackerScreen>
    with WidgetsBindingObserver {
  static const List<({String key, String label, IconData icon})> _types = [
    (key: 'walk', label: 'Walk', icon: Icons.directions_walk),
    (key: 'run', label: 'Run', icon: Icons.directions_run),
    (key: 'hike', label: 'Hike', icon: Icons.terrain),
    (key: 'cycle', label: 'Cycle', icon: Icons.directions_bike),
  ];

  final ActivityCheckpointService _checkpoints = ActivityCheckpointService();
  StreamSubscription<Position>? _positionSub;
  Timer? _timer;
  Timer? _checkpointTimer;

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
  String _startedAt = DateTime.now().toIso8601String();
  bool _resumeOffered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activityType = widget.initialActivityType;
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferResume());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionSub?.cancel();
    _timer?.cancel();
    _checkpointTimer?.cancel();
    if (_tracking) _saveCheckpoint();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _saveCheckpoint();
    }
  }

  String? _ownerIdCache;

  String? get _ownerId {
    if (_ownerIdCache != null) return _ownerIdCache;
    try {
      final auth = ref.read(authProvider);
      _ownerIdCache = auth.profile?.userId ?? auth.user?.id;
    } catch (_) {
      // The provider is gone during dispose — keep the last known owner.
    }
    return _ownerIdCache;
  }

  /// Offer to continue a session the OS interrupted (process kill, battery
  /// death, app force-close) instead of silently losing the route.
  Future<void> _maybeOfferResume() async {
    if (_resumeOffered || !mounted) return;
    final ownerId = _ownerId;
    // Auth may still be restoring the profile on a cold start; build() asks
    // again as soon as the owner is known.
    if (ownerId == null) return;
    _resumeOffered = true;
    final checkpoint = await _checkpoints.load(ownerId);
    if (checkpoint == null || !mounted || _tracking) return;
    final resume = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resume your ${checkpoint.activityType}?'),
        content: Text(
          '${(checkpoint.distanceM / 1000).toStringAsFixed(2)} km · '
          '${checkpoint.elapsedS ~/ 60} min · ${checkpoint.route.length} route points\n'
          'Last checkpoint ${checkpoint.ageLabel()}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (resume == true) {
      await _resume(checkpoint);
    } else {
      await _checkpoints.clear(_ownerId);
    }
  }

  Future<void> _resume(ActivityCheckpoint checkpoint) async {
    _activityType = checkpoint.activityType;
    _startedAt = checkpoint.startedAt;
    setState(() {
      _error = null;
      _elapsedS = checkpoint.elapsedS;
      _distanceM = checkpoint.distanceM;
      _route
        ..clear()
        ..addAll(checkpoint.route);
      _lastPosition = null;
      _gpsFix = false;
    });
    await _beginTracking();
  }

  Future<void> _start() async {
    _startedAt = DateTime.now().toIso8601String();
    setState(() {
      _error = null;
      _elapsedS = 0;
      _distanceM = 0;
      _route.clear();
      _lastPosition = null;
      _gpsFix = false;
    });
    await _beginTracking();
  }

  Future<void> _beginTracking() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      final isPermanent = permission == LocationPermission.deniedForever;
      setState(
        () => _error = isPermanent
            ? 'Location denied forever. Enable it in Settings to track a session.'
            : 'Location permission denied.',
      );
      return;
    }

    // First fix immediately so zero-movement sessions still have a start pin.
    try {
      final first = await Geolocator.getCurrentPosition(
        locationSettings: _currentLocationSettings(),
      ).timeout(const Duration(seconds: 15));
      _onPosition(first);
    } catch (_) {
      // Keep going — the stream may still deliver fixes.
    }

    _positionSub?.cancel();
    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: _streamLocationSettings(),
        ).listen(
          _onPosition,
          onError: (Object e) {
            if (mounted) setState(() => _error = 'GPS error: $e');
          },
        );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedS += 1);
    });

    // Checkpoint the live session every 10s so an OS kill cannot lose it.
    _checkpointTimer?.cancel();
    _checkpointTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _saveCheckpoint(),
    );

    setState(() => _tracking = true);
    _saveCheckpoint();
  }

  void _saveCheckpoint() {
    final ownerId = _ownerId;
    if (ownerId == null || (!_tracking && _elapsedS == 0 && _route.isEmpty)) {
      return;
    }
    _checkpoints.saveNow(
      ActivityCheckpoint(
        ownerId: ownerId,
        activityType: _activityType,
        startedAt: _startedAt,
        elapsedS: _elapsedS,
        distanceM: _distanceM,
        route: List<List<dynamic>>.from(_route),
        lastUpdatedMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Settings that keep the GPS alive when the screen is off/locked.
  /// Android: foreground service + persistent notification + wake lock.
  /// iOS: background location indicator (user must grant "Always" for
  /// fully-screen-locked tracking; "When In Use" still streams while the
  /// blue bar is lit).
  LocationSettings _currentLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'BuddyUp is tracking your session',
          notificationText: 'Screen can lock — GPS keeps running. Tap to open.',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
        activityType: ActivityType.fitness,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
        pauseLocationUpdatesAutomatically: false,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2,
    );
  }

  LocationSettings _streamLocationSettings() {
    if (Platform.isAndroid) return _currentLocationSettings();
    if (Platform.isIOS) return _currentLocationSettings();
    return const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2,
    );
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
    // Flush the final state before tearing the trackers down.
    _saveCheckpoint();
    _positionSub?.cancel();
    _timer?.cancel();
    _checkpointTimer?.cancel();
    setState(() => _tracking = false);

    if (!save || _elapsedS <= 0) {
      await _checkpoints.clear(_ownerId);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = true);
    try {
      final distanceKm = _distanceM / 1000.0;
      final created = await ref.read(analyticsLogProvider.notifier).logActivity(
        {
          'activity_type': _activityType,
          'source': 'gps',
          'duration_seconds': _elapsedS,
          'distance_meters': _distanceM,
          'avg_pace': distanceKm > 0 ? _elapsedS / distanceKm : null,
          'avg_speed_kmh': _elapsedS > 0
              ? double.parse(
                  (distanceKm / (_elapsedS / 3600)).toStringAsFixed(1),
                )
              : null,
          'calories_burned': _estimateCalories(),
          'steps': _activityType == 'walk' ? (_distanceM / 0.76).round() : null,
          'route': _route,
          'started_at': _startedAt,
        },
      );
      if (created == null) {
        setState(
          () => _error =
              'Failed to save activity. Your session is still here — try again.',
        );
        return;
      }
      final queued = created['queued'] == true;
      final activityId = created['id'] as String?;
      await _checkpoints.clear(_ownerId);
      ref.read(analyticsSummaryProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              queued
                  ? 'Saved on this device — it uploads when you reconnect.'
                  : 'Activity saved',
            ),
            action: !queued && activityId != null
                ? SnackBarAction(
                    label: 'Share',
                    onPressed: () async {
                      try {
                        await ref
                            .read(analyticsRepositoryProvider)
                            .shareActivity('activity', activityId, {});
                      } catch (_) {}
                    },
                  )
                : null,
          ),
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

  int get _steps {
    if (_activityType == 'cycle') return 0;
    return (_distanceM / (_activityType == 'run' ? 1.05 : 0.76)).round();
  }

  String get _caloriesText => _estimateCalories().round().toString();

  String get _elapsedText {
    final h = _elapsedS ~/ 3600;
    final m = (_elapsedS % 3600) ~/ 60;
    final s = (_elapsedS % 60).toString().padLeft(2, '0');
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    // Cold starts restore the token before the profile, so retry the resume
    // prompt once the signed-in account is known.
    final auth = ref.watch(authProvider);
    if (!_resumeOffered && (auth.profile?.userId ?? auth.user?.id) != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferResume());
    }
    final isCycle = _activityType == 'cycle';
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const MainAppBar(title: 'Track Activity'),
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
                      icon: Icon(t.icon, size: 16),
                    ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
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
              if (_tracking)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    Platform.isIOS
                        ? 'Lock the screen and GPS keeps working — allow "Always" location for best results.'
                        : 'Screen can lock — GPS keeps running in a pinned notification.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 10.5,
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
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _stat(
                    'Distance',
                    '${(_distanceM / 1000).toStringAsFixed(2)} km',
                  ),
                  _stat(
                    isCycle ? 'Speed' : 'Pace',
                    isCycle ? '${_speedText}km/h' : _paceText,
                  ),
                  _stat('Points', '${_route.length}'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _stat('Steps', _activityType == 'cycle' ? '—' : '$_steps'),
                  _stat('Calories', '$_caloriesText kcal'),
                  _stat('Avg speed', '$_speedText km/h'),
                ],
              ),
              if (_route.isNotEmpty) ...[
                const SizedBox(height: 14),
                ActivityRouteMap(route: _route, height: 190),
              ],

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: BuddyColors.red,
                      fontSize: 13,
                    ),
                  ),
                ),

              const Spacer(),

              // Controls
              if (!_tracking)
                if (_elapsedS > 0)
                  Column(
                    children: [
                      FilledButton.icon(
                        onPressed: _saving
                            ? null
                            : () => _stopAndSave(save: true),
                        style: FilledButton.styleFrom(
                          backgroundColor: BuddyColors.green,
                        ),
                        icon: _saving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.save_outlined,
                                color: Colors.black,
                              ),
                        label: const Text(
                          'Save Activity',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () => _stopAndSave(save: false),
                        child: const Text('Discard session'),
                      ),
                    ],
                  )
                else
                  FilledButton.icon(
                    onPressed: _saving ? null : () => _start(),
                    style: FilledButton.styleFrom(
                      backgroundColor: BuddyColors.green,
                    ),
                    icon: const Icon(Icons.play_arrow, color: Colors.black),
                    label: const Text(
                      'Start',
                      style: TextStyle(color: Colors.black),
                    ),
                  )
              else
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _saving
                            ? null
                            : () => _stopAndSave(save: false),
                        style: FilledButton.styleFrom(
                          backgroundColor: BuddyColors.red,
                        ),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
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
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}
