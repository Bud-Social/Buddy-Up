import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/marketplace.dart';
import 'package:buddy_up_flutter/features/marketplace/providers/organiser_provider.dart';
import 'package:buddy_up_flutter/features/marketplace/utils/organiser.dart';

/// Fixtures shaped from `OrganiserEventListView`, `EventAttendeeSerializer` and
/// `OrganiserEventStatsView` in `backend/apps/marketplace/views.py`.
void main() {
  Map<String, dynamic> attendeeJson({
    String id = 't1',
    String ticketCode = '11111111-2222-3333-4444-555555555555',
    bool checkedIn = false,
    String? displayName,
    String username = 'karen',
  }) {
    return {
      'id': id,
      'ticket_code': ticketCode,
      'tier': 'Early bird',
      'status': 'valid',
      'is_checked_in': checkedIn,
      'checked_in_at': checkedIn ? '2026-04-01T06:41:00Z' : null,
      'price_paid_artifacts': {'dumbbell': 50},
      if (displayName != null) 'display_name': displayName,
      'username': username,
      'created_at': '2026-03-20T11:00:00Z',
    };
  }

  group('a missing or renamed field cannot crash decoding', () {
    test('an empty event row still parses', () {
      final event = OrganiserEvent.fromJson({'id': 'x'});
      expect(event.title, '');
      expect(event.capacity, 0);
      expect(event.ticketTiers, isEmpty);
      expect(event.isOrganizer, isFalse);
    });

    test('an empty attendee row still parses', () {
      final attendee = EventAttendee.fromJson({'id': 'x'});
      expect(attendee.ticketCode, '');
      expect(attendee.isCheckedIn, isFalse);
      expect(attendee.pricePaidArtifacts, isEmpty);
    });

    test('an empty stats row still parses', () {
      final stats = EventStats.fromJson(<String, dynamic>{});
      expect(stats.capacityIsUnlimited, isFalse);
      expect(stats.soldByTier, isEmpty);
      expect(stats.grossArtifacts, isEmpty);
    });

    test('gross artifacts sent as strings still parse', () {
      final stats = EventStats.fromJson({
        'gross_artifacts': {'dumbbell': '4500', 'squat': null},
      });
      expect(stats.grossArtifacts, {'dumbbell': 4500});
    });

    test('a sold-by-tier row with a missing count reads as zero', () {
      final stats = EventStats.fromJson({
        'sold_by_tier': [
          {'tier': 'Early bird'},
        ],
      });
      expect(stats.soldByTier.single.count, 0);
      expect(stats.soldByTier.single.grossArtifacts, isEmpty);
    });
  });

  group('the attendee name is flat, not nested', () {
    test('a flat display name is read', () {
      final attendee =
          EventAttendee.fromJson(attendeeJson(displayName: 'Karen W'));
      expect(attendee.label, 'Karen W');
    });

    test('with no display name the handle is used, not a blank row', () {
      final attendee = EventAttendee.fromJson(attendeeJson());
      expect(attendee.label, '@karen');
    });

    test('neither is an empty label — never a synthesised "Attendee 7"', () {
      final attendee =
          EventAttendee.fromJson({'id': 't9', 'ticket_code': 'abc'});
      expect(attendee.label, '');
    });

    test('a nested holder_data block is not mistaken for the flat fields', () {
      // The marketplace convention is a nested `*_data` object; this serializer
      // is the exception, and reading the nested shape would render every
      // attendee as nameless.
      final attendee = EventAttendee.fromJson({
        ...attendeeJson(),
        'holder_data': {'display_name': 'Someone Else'},
      });
      expect(attendee.label, '@karen');
    });
  });

  group('a 403 is "not an organiser", not "you have no events"', () {
    DioException status(int code, {String? message}) => DioException(
          requestOptions: RequestOptions(path: '/marketplace/events/mine/'),
          response: Response(
            requestOptions: RequestOptions(path: '/marketplace/events/mine/'),
            statusCode: code,
            data: message == null ? null : {'success': false, 'message': message},
          ),
        );

    test('403 is the organiser gate', () {
      expect(isOrganiserForbidden(status(403)), isTrue);
    });

    test('a 404 and a 500 are failures, not the gate', () {
      expect(isOrganiserForbidden(status(404)), isFalse);
      expect(isOrganiserForbidden(status(500)), isFalse);
    });

    test('the fallback names the cause rather than implying an empty list', () {
      final message = organiserForbiddenMessage(status(403));
      expect(message.toLowerCase(), contains('organiser'));
      expect(message.toLowerCase(), isNot(contains('have not created')));
    });

    test('the server’s own wording is used when it sent one', () {
      final message = organiserForbiddenMessage(
        status(403, message: 'Only event organisers may manage attendees.'),
      );
      expect(message, 'Only event organisers may manage attendees.');
    });
  });

  group('attendee filters travel as the API expects', () {
    test('the requestable statuses are the server choice list', () {
      expect(
        kOrganiserStatusFilters.map((f) => f.value),
        ['', 'valid', 'used', 'cancelled', 'refunded'],
      );
    });

    test('an untouched filter set is not "filtered"', () {
      expect(const AttendeeFilters().isFiltered, isFalse);
    });

    test('"not checked in" is a real filter and must not be dropped', () {
      const filters = AttendeeFilters(checkedIn: false);
      expect(filters.isFiltered, isTrue);
      expect(filters.checkedIn, isFalse);
    });

    test('clearing the checked-in filter returns it to null, not to false', () {
      const start = AttendeeFilters(checkedIn: true);
      expect(start.copyWith(clearCheckedIn: true).checkedIn, isNull);
    });

    test('the tier is trimmed so a stray space is not a silent no-match filter',
        () {
      final filters = const AttendeeFilters().copyWith(tier: '  Early bird  ');
      expect(filters.tier, 'Early bird');
    });

    test('two filters are equal only when every part matches', () {
      expect(const AttendeeFilters(), const AttendeeFilters());
      expect(
        const AttendeeFilters(checkedIn: true),
        isNot(const AttendeeFilters(checkedIn: false)),
      );
      expect(
        const AttendeeFilters(status: 'valid'),
        isNot(const AttendeeFilters(status: 'used')),
      );
    });
  });

  group('station application status', () {
    test('the review-queue states all read as pending', () {
      for (final status in ['pending', 'submitted', 'under_review', 'PENDING']) {
        expect(isPendingApplicationStatus(status), isTrue, reason: status);
      }
    });

    test('a decision is not pending', () {
      expect(isPendingApplicationStatus('approved'), isFalse);
      expect(isPendingApplicationStatus('rejected'), isFalse);
      expect(isPendingApplicationStatus('draft'), isFalse);
      expect(isPendingApplicationStatus(null), isFalse);
    });

    test('the label collapses the queue states to one word', () {
      expect(stationApplicationStatusLabel('submitted'), 'pending');
      expect(stationApplicationStatusLabel('approved'), 'approved');
      expect(stationApplicationStatusLabel(null), 'pending');
    });

    test('a pending application says the user can keep working', () {
      final hint = stationApplicationHint(status: 'submitted');
      expect(hint, contains('awaiting review'));
    });

    test('a rejection surfaces the reviewer’s reason', () {
      expect(
        stationApplicationHint(
          status: 'rejected',
          rejectionReason: 'Site address could not be verified.',
        ),
        'Site address could not be verified.',
      );
    });

    test('a rejection with no reason still says something', () {
      expect(
        stationApplicationHint(status: 'rejected'),
        'This application was not approved.',
      );
    });
  });

  group('event stats', () {
    test('an unlimited capacity is its own flag, not a zero', () {
      final stats = EventStats.fromJson({
        'capacity': 0,
        'capacity_is_unlimited': true,
        'spots_remaining': 999,
      });
      expect(stats.capacityIsUnlimited, isTrue);
      expect(stats.spotsRemaining, 999);
    });
  });
}