import 'package:flutter_test/flutter_test.dart';

import 'package:buddy_up_flutter/data/models/alarm.dart';
import 'package:buddy_up_flutter/features/settings/providers/alarm_providers.dart';

void main() {
  group('Alarm model', () {
    test('parses the nested sound object the API returns', () {
      final alarm = Alarm.fromJson({
        'id': 'a-1',
        'time': '07:30',
        'days_mask': 31,
        'label': 'Leg day',
        'enabled': true,
        'snooze_minutes': 10,
        'sound': {
          'id': 's-1',
          'name': 'Sunrise',
          'audio_url': 'https://cdn.example.com/sunrise.mp3',
          'duration_ms': 12000,
          'visibility': 'private',
          'is_mine': true,
        },
      });

      expect(alarm.time, '07:30');
      expect(alarm.daysMask, 31);
      expect(alarm.snoozeMinutes, 10);
      expect(alarm.sound?.name, 'Sunrise');
      expect(alarm.sound?.durationMs, 12000);
      expect(alarm.sound?.isMine, isTrue);
    });

    test('tolerates a missing sound and default fields', () {
      final alarm = Alarm.fromJson({'id': 'a-2', 'time': '06:00'});

      expect(alarm.enabled, isTrue);
      expect(alarm.daysMask, 0);
      expect(alarm.snoozeMinutes, 5);
      expect(alarm.sound, isNull);
    });
  });

  group('formatAlarmDays', () {
    test('summarises common masks and one-offs', () {
      expect(formatAlarmDays(0), 'Once');
      expect(formatAlarmDays(127), 'Every day');
      expect(formatAlarmDays(31), 'Weekdays');
      expect(formatAlarmDays(96), 'Weekends');
      expect(formatAlarmDays(1 | 8), 'Mon, Thu');
    });
  });

  group('AlarmShare / AlarmSuggestion', () {
    test('parses sender and sound', () {
      final share = AlarmShare.fromJson({
        'id': 'sh-1',
        'status': 'pending',
        'sound': {'id': 's-2', 'name': 'Buddy beat'},
        'sender': {
          'profile_id': 'p-1',
          'username': 'sam',
          'display_name': 'Sam',
        },
      });

      expect(share.sound.name, 'Buddy beat');
      expect(share.sender?.displayName, 'Sam');
    });

    test('parses a suggestion with no note', () {
      final suggestion = AlarmSuggestion.fromJson({
        'id': 'sg-1',
        'title': 'Try this',
        'status': 'pending',
      });

      expect(suggestion.title, 'Try this');
      expect(suggestion.note, isNull);
    });
  });
}
