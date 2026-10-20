import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/alarm.dart';
import '../../../data/repositories/alarm_repository.dart';

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  final dio = ref.watch(alarmApiClientProvider).dio;
  return AlarmRepository(dio);
});

final alarmApiClientProvider = Provider<ApiClient>((_) => ApiClient());

final alarmsProvider = FutureProvider<List<Alarm>>((ref) async {
  final raw = await ref.watch(alarmRepositoryProvider).getAlarms();
  return (raw['data'] as List)
      .map((e) => Alarm.fromJson(e as Map<String, dynamic>))
      .toList();
});

final alarmSoundsProvider = FutureProvider<List<AlarmSound>>((ref) async {
  final raw = await ref.watch(alarmRepositoryProvider).getSounds();
  return (raw['data'] as List)
      .map((e) => AlarmSound.fromJson(e as Map<String, dynamic>))
      .toList();
});

final alarmSharesInboxProvider = FutureProvider<List<AlarmShare>>((ref) async {
  final raw = await ref.watch(alarmRepositoryProvider).getSharesInbox();
  return (raw['data'] as List)
      .map((e) => AlarmShare.fromJson(e as Map<String, dynamic>))
      .toList();
});

final alarmSuggestionsProvider =
    FutureProvider<List<AlarmSuggestion>>((ref) async {
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
