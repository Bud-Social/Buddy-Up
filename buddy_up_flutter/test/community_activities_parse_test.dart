import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/messaging.dart';

/// The activity endpoints return their rows bare (not wrapped in an envelope),
/// so the freezed models must tolerate the exact payloads the web clients see.
void main() {
  test('community event parses with optional fields missing', () {
    final event = CommunityEvent.fromJson(const {
      'id': 'e1',
      'title': 'Fun run',
      'start_datetime': '2026-11-22T04:00:00Z',
      'end_datetime': '2026-11-22T06:00:00Z',
      'is_free': false,
      'capacity': 40,
      'spots_remaining': 12,
    });
    expect(event.id, 'e1');
    expect(event.isFree, isFalse);
    expect(event.spotsRemaining, 12);
    expect(event.coverImageUrl, '');
  });

  test('community live defaults sunrise-access and scheduled status', () {
    final live = CommunityLive.fromJson(const {
      'id': 'l1',
      'title': 'Mobility Q&A',
      'live_type': 'audio',
      'scheduled_for': '2026-11-22T07:30:00Z',
    });
    expect(live.liveType, 'audio');
    expect(live.access, 'public');
    expect(live.status, 'scheduled');
  });

  test('community schedule carries slot fields', () {
    final slot = CommunitySchedule.fromJson(const {
      'id': 's1',
      'title': 'Tempo session',
      'activity_type': 'live_stream',
      'location_mode': 'online',
      'start_time': '2026-11-22T07:30:00Z',
      'recurrence': 'weekly',
      'recurrence_days': [0, 3],
      'max_slots': 12,
      'enrollment_count': 3,
    });
    expect(slot.activityType, 'live_stream');
    expect(slot.recurrenceDays, [0, 3]);
    expect(slot.enrollmentCount, 3);
  });
}
