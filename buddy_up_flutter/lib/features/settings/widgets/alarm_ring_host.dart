import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/alarm.dart';
import '../providers/alarm_providers.dart';

/// App-wide alarm scheduler. Wraps the router so an alarm rings no matter
/// which screen is open; one-off alarms disable themselves after firing.
class AlarmRingHost extends ConsumerStatefulWidget {
  const AlarmRingHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AlarmRingHost> createState() => _AlarmRingHostState();
}

class _AlarmRingHostState extends ConsumerState<AlarmRingHost> {
  Timer? _checkTimer;
  Timer? _ringTimer;
  Alarm? _ringing;
  Alarm? _snoozedAlarm;
  DateTime? _snoozeAt;
  String? _lastFiredKey;

  @override
  void initState() {
    super.initState();
    _checkTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _tick(),
    );
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _ringTimer?.cancel();
    super.dispose();
  }

  Future<void> _tick() async {
    if (!mounted) return;
    if (ref.read(authProvider).user == null) return;

    final now = DateTime.now();

    if (_snoozeAt != null && !now.isBefore(_snoozeAt!)) {
      final alarm = _snoozedAlarm;
      _snoozeAt = null;
      _snoozedAlarm = null;
      if (alarm != null) _ring(alarm);
      return;
    }
    if (_ringing != null) return;

    List<Alarm> alarms;
    final current = ref.read(alarmsProvider).asData?.value;
    if (current == null) {
      try {
        alarms = await ref.refresh(alarmsProvider.future);
      } catch (_) {
        return;
      }
    } else {
      alarms = current;
    }

    final hhmm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dayBit = 1 << (now.weekday - 1); // Mon=1 → bit 0

    for (final alarm in alarms) {
      if (!alarm.enabled) continue;
      if (alarm.time.length < 5 || alarm.time.substring(0, 5) != hhmm) continue;
      if (alarm.daysMask != 0 && alarm.daysMask & dayBit == 0) continue;

      final key =
          '${alarm.id}:${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}';
      if (_lastFiredKey == key) continue;
      _lastFiredKey = key;
      _ring(alarm);

      if (alarm.daysMask == 0) {
        // One-off: consume so it doesn't ring again tomorrow.
        try {
          await ref
              .read(alarmRepositoryProvider)
              .updateAlarm(alarm.id, {'enabled': false});
          ref.invalidate(alarmsProvider);
        } catch (_) {
          // Best effort — the user can still stop/delete it.
        }
      }
      break;
    }
  }

  void _ring(Alarm alarm) {
    if (!mounted) return;
    SystemSound.play(SystemSoundType.alert);
    _ringTimer?.cancel();
    _ringTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && _ringing != null) {
        SystemSound.play(SystemSoundType.alert);
      }
    });
    setState(() => _ringing = alarm);
  }

  void _stop() {
    _ringTimer?.cancel();
    _ringTimer = null;
    setState(() => _ringing = null);
  }

  void _snooze() {
    final alarm = _ringing;
    if (alarm == null) return;
    _stop();
    _snoozedAlarm = alarm;
    _snoozeAt = DateTime.now().add(
      Duration(minutes: alarm.snoozeMinutes < 1 ? 1 : alarm.snoozeMinutes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (auth.user == null) return widget.child;

    // Keep the alarm list warm so the timer has something to check.
    ref.watch(alarmsProvider);

    return Stack(
      children: [
        widget.child,
        if (_ringing != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 96,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BuddyColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: BuddyColors.green.withValues(alpha: 0.6)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 18),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.alarm, color: BuddyColors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alarm · ${_ringing!.time.substring(0, 5)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                _ringing!.label.isEmpty
                                    ? 'Time to rise and grind'
                                    : _ringing!.label,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: BuddyColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: _snooze,
                          child: Text('Snooze ${_ringing!.snoozeMinutes}m'),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: _stop,
                          child: const Text('Stop'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
