import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/admin_portal.dart';
import 'package:buddy_up_flutter/features/admin/providers/admin_provider.dart';

/// Fixtures shaped from `apps/admin_portal/serializers.py` and the
/// `{success, data, message, errors, pagination}` envelope `PortalView.ok`
/// returns.
void main() {
  group('envelope handling', () {
    test('a bare array is the documented list shape', () {
      final rows = portalListItems([
        {'id': '1'},
        {'id': '2'},
      ]);
      expect(rows, hasLength(2));
    });

    test('a paginated body does not crash a table', () {
      expect(portalListItems({
        'results': [
          {'id': '1'},
        ],
      }), hasLength(1));
    });

    test('an `items` body is tolerated too', () {
      expect(portalListItems({
        'items': [
          {'id': '1'},
        ],
      }), hasLength(1));
    });

    test('a null or non-list body is an empty list, not an error', () {
      expect(portalListItems(null), isEmpty);
      expect(portalListItems('nonsense'), isEmpty);
      expect(portalListItems(42), isEmpty);
    });

    test('non-map rows are dropped rather than crashing the row parser', () {
      expect(portalListItems([
        {'id': '1'},
        'garbage',
        null,
      ]), hasLength(1));
    });

    test('pagination reads count and the page links', () {
      final pagination = portalPagination({
        'count': 137,
        'next': 'https://api.example.com/portal/users/?page=3',
        'previous': null,
      }, 0);
      expect(pagination.count, 137);
      expect(pagination.next, contains('page=3'));
      expect(pagination.previous, isNull);
    });

    test('a missing pagination block falls back to the row count', () {
      expect(portalPagination(null, 4).count, 4);
    });
  });

  group('PortalQuery', () {
    test('nulls, blanks and the "all" sentinel never reach the query string', () {
      final query = PortalQuery.of(2, {
        'q': 'sam',
        'role': 'all',
        'is_active': null,
        'verification_status': '',
      });
      expect(query.page, 2);
      expect(query.params, {'q': 'sam'});
    });

    test('a false flag is a real filter, not a dropped one', () {
      // "Not active" is a meaningful query; only null means "no filter".
      final query = PortalQuery.of(1, {'is_active': false});
      expect(query.params.containsKey('is_active'), isTrue);
      expect(query.params['is_active'], isFalse);
    });

    test('identity covers both the page and the filters', () {
      expect(PortalQuery.of(1, {'q': 'a'}) == PortalQuery.of(1, {'q': 'a'}),
          isTrue);
      expect(PortalQuery.of(1, {'q': 'a'}) == PortalQuery.of(2, {'q': 'a'}),
          isFalse);
      expect(PortalQuery.of(1, {'q': 'a'}) == PortalQuery.of(1, {'q': 'b'}),
          isFalse);
    });
  });

  group('portalMessage', () {
    test('prefers the envelope message, which is what the web console shows', () {
      expect(
        portalMessage({'message': 'Application reviewed: approved.'}),
        'Application reviewed: approved.',
      );
    });

    test('an empty or missing message falls back rather than printing blank',
        () {
      expect(portalMessage({'message': '   '}, fallback: 'Done.'), 'Done.');
      expect(portalMessage(null, fallback: 'Done.'), 'Done.');
    });
  });

  group('gyms and communities expose a count, never a roster', () {
    test('a gym row parses with member_count and no members key at all', () {
      final gym = PortalGym.fromJson({
        'id': 'g1',
        'name': 'Iron Foundry',
        'handle': 'iron-foundry',
        'access_type': 'private',
        'is_verified': true,
        'is_deleted': false,
        'member_count': 42,
        'location_city': 'Nairobi',
        'location_country': 'Kenya',
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(gym.memberCount, 42);
      expect(gym.isVerified, isTrue);
      expect(gym.isDeleted, isFalse);
    });

    test('a missing member_count defaults to zero, never to a negative', () {
      expect(PortalGym.fromJson({'id': 'g1'}).memberCount, 0);
      expect(PortalCommunity.fromJson({'id': 'c1'}).memberCount, 0);
      expect(PortalCommunity.fromJson({'id': 'c1'}).postCount, 0);
    });

    test('a community row reads member_count, not participants_data', () {
      final community = PortalCommunity.fromJson({
        'id': 'c1',
        'group_name': 'Westlands Runners',
        'is_community': true,
        'is_public': false,
        'member_count': 128,
        'post_count': 900,
        'created_by_username': 'sam',
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(community.memberCount, 128);
      expect(community.isPublic, isFalse);
      expect(community.gymHandle, isNull);
    });
  });

  group('order rows', () {
    test('allowed_next_statuses drives the status actions', () {
      final order = PortalOrder.fromJson({
        'id': 'o1',
        'order_number': 'BU-0001',
        'status': 'paid',
        'status_label': 'Paid',
        'allowed_next_statuses': ['processing', 'shipped', 'cancelled'],
        'fulfillment_type': 'delivery',
        'payment_status': 'paid',
        'payment_method': 'artifacts',
        'total_artifacts': {'dumbbell': 100},
        'spent_usd': '25.00',
        'items': [
          {
            'item_type': 'product',
            'title': 'Mat',
            'quantity': 1,
          },
        ],
      });
      expect(order.allowedNextStatuses, contains('shipped'));
      expect(order.spentUsd, 25.0);
      expect(order.items, hasLength(1));
    });

    test('a missing spent_usd reads as zero, not as a crash', () {
      final order = PortalOrder.fromJson({'id': 'o1'});
      expect(order.spentUsd, 0.0);
      expect(order.status, isEmpty);
      expect(order.allowedNextStatuses, isEmpty);
    });
  });

  group('reconciliation is read-only by construction', () {
    test('writes_ledger is false and stays false', () {
      final report = PortalReconciliationReport.fromJson({
        'provider': {'checked': 10, 'matched': 9, 'mismatched': 1},
        'local': {'mismatched': 2},
        'window_days': 30,
        'writes_ledger': false,
      });
      expect(report.writesLedger, isFalse);
      expect(report.windowDays, 30);
      expect(report.provider['checked'], 10);
      expect(report.local['mismatched'], 2);
    });
  });
}