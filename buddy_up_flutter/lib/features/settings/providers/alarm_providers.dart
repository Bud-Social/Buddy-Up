import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/alarm.dart';
import '../../../data/repositories/alarm_repository.dart';
import '../services/alarm_sound_cache.dart';

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  final dio = ref.watch(alarmApiClientProvider).dio;
  return AlarmRepository(dio);
});

final alarmApiClientProvider = Provider<ApiClient>((_) => ApiClient());

final alarmsProvider = FutureProvider<List<Alarm>>((ref) async {
  try {
    final raw = await ref.watch(alarmRepositoryProvider).getAlarms();
    final alarms = (raw['data'] as List)
        .map((e) => Alarm.fromJson(e as Map<String, dynamic>))
        .toList();
    await _saveCached('alarms', alarms.map((e) => e.toJson()).toList());
    return alarms;
  } catch (_) {
    return _readCached('alarms', (e) => Alarm.fromJson(e));
  }
});

final alarmSoundsProvider = FutureProvider<List<AlarmSound>>((ref) async {
  try {
    final raw = await ref.watch(alarmRepositoryProvider).getSounds();
    final sounds = (raw['data'] as List)
        .map((e) => AlarmSound.fromJson(e as Map<String, dynamic>))
        .toList();
    for (final sound in sounds) {
      if (sound.isMine || sound.visibility != 'private') {
        AlarmSoundCache.cache(sound);
      }
    }
    await _saveCached('sounds', sounds.map((e) => e.toJson()).toList());
    return sounds;
  } catch (_) {
    return _readCached('sounds', (e) => AlarmSound.fromJson(e));
  }
});

Future<void> _saveCached(String key, List<Map<String, dynamic>> rows) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('alarm_cache_$key', jsonEncode(rows));
}

Future<List<T>> _readCached<T>(
  String key,
  T Function(Map<String, dynamic>) parse,
) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('alarm_cache_$key');
  if (raw == null) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [
      for (final item in decoded)
        if (item is Map) parse(Map<String, dynamic>.from(item)),
    ];
  } catch (_) {
    return const [];
  }
}

final alarmSharesInboxProvider = FutureProvider<List<AlarmShare>>((ref) async {
  final raw = await ref.watch(alarmRepositoryProvider).getSharesInbox();
  return (raw['data'] as List)
      .map((e) => AlarmShare.fromJson(e as Map<String, dynamic>))
      .toList();
});

final alarmSuggestionsProvider = FutureProvider<List<AlarmSuggestion>>((
  ref,
) async {
  final raw = await ref.watch(alarmRepositoryProvider).getSuggestions();
  return (raw['data'] as List)
      .map((e) => AlarmSuggestion.fromJson(e as Map<String, dynamic>))
      .toList();
});

const alarmDayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String formatAlarmDays(int mask) {
  if (mask == 0) return 'Once';
  if (mask == 127) return 'Every day';
  if (mask == 31) return 'Weekdays';
  if (mask == 96) return 'Weekends';
  return [
    for (var i = 0; i < 7; i++)
      if (mask & (1 << i) != 0) alarmDayLabels[i],
  ].join(', ');
}
