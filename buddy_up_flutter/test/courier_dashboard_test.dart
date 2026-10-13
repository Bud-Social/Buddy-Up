import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/marketplace.dart';
import 'package:buddy_up_flutter/features/marketplace/utils/courier.dart';

/// Fixtures shaped from `CourierSummaryView`, `CourierOrderSerializer` and
/// `CourierEarningsView` in `backend/apps/marketplace/views.py`.
void main() {
  Map<String, dynamic> summaryJson({
    String vehicleType = 'motorbike',
    List<String>? zones,
    Map<String, dynamic>? counts,
    double? commissionRate = 0.12,
  }) {
    return {
      'id': '7c1f1e8e-0000-4000-8000-000000000001',
      'vehicle_type': vehicleType,
      'vehicle_label': 'Motorbike',
      'service_zones': zones ?? ['Westlands', 'Kilimani'],
      'is_active': true,
      'rating': 4.5,
      'bio': 'Fast, careful, ID checked.',
      'commission_rate': commissionRate,
      'counts': counts ??
          {'processing': 1, 'shipped': 0, 'out_for_delivery': 2, 'delivered': 9},
      'total_assigned': 12,
      'active': true,
    };
  }

  Map<String, dynamic> orderJson({
    String status = 'out_for_delivery',
    List<String>? allowed,
    Map<String, dynamic>? address,
    Map<String, dynamic>? pickupStation,
  }) {
    return {
      'id': 'order-1',
      'order_number': 'BU-1042',
      'status': status,
      'status_label': 'Out for Delivery',
      'fulfillment_type': 'delivery',
      'fulfillment_status': 'out_for_delivery',
      'allowed_transitions': allowed ?? ['delivered', 'processing'],
      'items': [
        {
          'id': 'i1',
          'title': 'Iron Foundry Whey',
          'quantity': 2,
          'item_type': 'product',
          'creator_name': 'Iron Foundry',
        }
      ],
      'delivery_address': address ??
          {
            'line1': '12th Street',
            'line2': 'Apartment 4B',
            'city': 'Nairobi',
            'postal_code': '00100',
            'country': 'Kenya',
          },
      if (pickupStation != null) 'pickup_station': pickupStation,
      'delivery_personnel_name': 'Peter',
      'commission_artifacts': {'dumbbell': 240, 'squat': 8},
      'total_artifacts': {'dumbbell': 2000, 'squat': 80},
      'created_at': '2026-03-04T09:00:00Z',
      'paid_at': '2026-03-04T09:01:00Z',
    };
  }

  group('a missing or renamed field cannot crash decoding', () {
    test('an empty summary row still parses', () {
      final profile = CourierProfile.fromJson(<String, dynamic>{});
      expect(profile.vehicleType, '');
      expect(profile.serviceZones, isEmpty);
      expect(profile.isActive, isTrue);
      expect(profile.counts, isEmpty);
      expect(profile.commissionRate, isNull);
      expect(profile.active, isFalse);
    });

    test('an empty order row still parses', () {
      final order = CourierOrder.fromJson({
        'id': 'x',
      });
      expect(order.allowedTransitions, isEmpty);
      expect(order.items, isEmpty);
      expect(order.deliveryAddress, isEmpty);
      expect(order.pickupStation, isNull);
    });

    test('artifact maps tolerate string values and nulls', () {
      // `commission_artifacts` is computed server-side and has gone through a
      // Decimal-serialisation path; a null bucket must not take the row with it.
      final order = CourierOrder.fromJson({
        ...orderJson(),
        'commission_artifacts': {'dumbbell': '240', 'pr': null, 'barbell': 1.5},
      });
      expect(order.commissionArtifacts, {'dumbbell': 240, 'barbell': 1});
    });

    test('a non-numeric rating decodes as null rather than throwing', () {
      final profile = CourierProfile.fromJson({...summaryJson(), 'rating': 'n/a'});
      expect(profile.rating, isNull);
    });

    test('a commission rate sent as a Decimal string still parses', () {
      final profile =
          CourierProfile.fromJson({...summaryJson(), 'commission_rate': '0.085'});
      expect(profile.commissionRate, closeTo(0.085, 1e-9));
    });
  });

  group('the 404-means-not-registered rule', () {
    DioException status(int code) => DioException(
          requestOptions: RequestOptions(path: '/marketplace/delivery/summary/'),
          response: Response(
            requestOptions: RequestOptions(path: '/marketplace/delivery/summary/'),
            statusCode: code,
          ),
        );

    test('a 404 is "not a courier", because the endpoint takes no id', () {
      expect(isCourierNotRegistered(status(404)), isTrue);
    });

    test('no other failure is mistaken for "not registered"', () {
      for (final code in [400, 401, 403, 500, 502]) {
        expect(isCourierNotRegistered(status(code)), isFalse, reason: '$code');
      }
    });

    test('a network failure is not a registration signal', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/marketplace/delivery/summary/'),
        type: DioExceptionType.connectionError,
      );
      expect(isCourierNotRegistered(error), isFalse);
    });
  });

  group('buttons come from allowed_transitions, never a client map', () {
    test('a row with no legal moves offers no buttons', () {
      final order =
          CourierOrder.fromJson(orderJson(status: 'delivered', allowed: const []));
      expect(order.allowedTransitions, isEmpty);
    });

    test('a status the backend has not shipped yields no buttons either', () {
      // `allowed_transitions` is authoritative precisely so an unknown status
      // degrades to "nothing to offer" rather than to a guessed move.
      final order = CourierOrder.fromJson({
        ...orderJson(status: 'teleported', allowed: const []),
        'fulfillment_status': 'unknown',
        'status_label': '',
      });
      expect(order.allowedTransitions, isEmpty);
      // An unmapped status still reads as itself rather than as a blank or an
      // "Unknown" the operator has to decode.
      expect(courierFulfillmentLabel(order), 'Teleported');
    });

    test('both legal moves from out_for_delivery are rendered', () {
      final order = CourierOrder.fromJson(orderJson());
      expect(order.allowedTransitions, ['delivered', 'processing']);
      expect(
        order.allowedTransitions.map(courierActionLabel),
        ['Mark delivered', 'Return to processing'],
      );
    });

    test('processing and shipped both start the delivery', () {
      expect(courierActionLabel('out_for_delivery'), 'Start delivery');
    });
  });

  group('fulfillment vocabulary', () {
    test('the server mapping is preferred over the raw status', () {
      final order = CourierOrder.fromJson({
        ...orderJson(status: 'processing'),
        'fulfillment_status': 'ready_to_collect',
        'status_label': 'Processing',
      });
      expect(courierFulfillmentLabel(order), 'Ready to collect');
    });

    test('an unmapped fulfillment status falls back to the status label', () {
      final order = CourierOrder.fromJson({
        ...orderJson(),
        'fulfillment_status': '',
      });
      expect(courierFulfillmentLabel(order), 'Out for Delivery');
    });

    test('with neither, the raw status is title-cased rather than blank', () {
      final order = CourierOrder.fromJson({
        'id': 'x',
        'status': 'ready_for_pickup',
      });
      expect(courierFulfillmentLabel(order), 'Ready For Pickup');
    });
  });

  group('the delivery address is always readable', () {
    test('the canonical keys collapse into one line', () {
      final order = CourierOrder.fromJson(orderJson());
      expect(
        courierAddressLabel(order.deliveryAddress),
        '12th Street, Apartment 4B, Nairobi, 00100, Kenya',
      );
    });

    test('an empty address degrades to a placeholder, never an empty line', () {
      final order = CourierOrder.fromJson(orderJson(address: <String, dynamic>{}));
      expect(courierAddressLabel(order.deliveryAddress), noDeliveryAddressLabel);
    });

    test('missing keys do not leave stray separators', () {
      final order = CourierOrder.fromJson(orderJson(address: {
        'line1': '12th Street',
        'line2': '',
        'city': 'Nairobi',
      }));
      expect(courierAddressLabel(order.deliveryAddress), '12th Street, Nairobi');
    });

    test('a legacy address written with other key names is still shown', () {
      final order = CourierOrder.fromJson(
          orderJson(address: {'street_address': 'Karen, Nairobi'}));
      expect(courierAddressLabel(order.deliveryAddress), 'Karen, Nairobi');
    });

    test('an address sent as a bare string is treated as absent, not a crash',
        () {
      // `delivery_address` is a JSONField, but the web client tolerates a bare
      // string; the Dart decoder must not throw on one either.
      final order = CourierOrder.fromJson(
          {...orderJson(), 'delivery_address': '12th Street'});
      expect(courierAddressLabel(order.deliveryAddress), noDeliveryAddressLabel);
    });
  });

  group('the pickup point is in view', () {
    test('a station row reads as "name — address"', () {
      final order = CourierOrder.fromJson(orderJson(pickupStation: {
        'id': 's1',
        'name': 'Karura Fitness',
        'address': 'Mombasa Road',
        'city': 'Nairobi',
      }));
      expect(
        courierPickupLabel(order.pickupStation),
        'Karura Fitness — Mombasa Road',
      );
    });

    test('a door-to-door order has no pickup line at all', () {
      final order = CourierOrder.fromJson(orderJson());
      expect(courierPickupLabel(order.pickupStation), isNull);
    });

    test('a station with neither name nor address is not rendered', () {
      final order = CourierOrder.fromJson(
          orderJson(pickupStation: {'id': 's1', 'name': '', 'address': ''}));
      expect(courierPickupLabel(order.pickupStation), isNull);
    });
  });

  group('earnings are labelled as an estimate', () {
    test('the server note is preferred so the wording cannot drift', () {
      final earnings = CourierEarnings.fromJson({
        'delivered_count': 9,
        'delivered_value_artifacts': {'dumbbell': 2000},
        'commission_rate': 0.12,
        'commission_artifacts': {'dumbbell': 240},
        'window': {'from': '2026-01-01', 'to': '2026-03-31'},
        'is_payout': false,
        'note': 'Informational estimate only.',
      });
      expect(courierEarningsNote(earnings), 'Informational estimate only.');
      expect(earnings.isPayout, isFalse);
    });

    test('an absent note falls back to a disclaimer that says the same thing', () {
      expect(
        courierEarningsNote(CourierEarnings.fromJson(<String, dynamic>{})),
        courierEarningsFallbackNote,
      );
      expect(courierEarningsFallbackNote.toLowerCase(), contains('not a payable'));
    });

    test('the estimate itself is a number, not a promise of one', () {
      expect(artifactsUsd({'dumbbell': 240}), closeTo(24.0, 1e-9));
      expect(artifactsUsd(<String, int>{}), isNull);
      expect(artifactsUsd(null), isNull);
    });

    test('an unknown artifact bucket contributes zero, not a guess', () {
      expect(artifactsUsd({'platinum': 1000}), 0.0);
    });

    test('the echoed window is rendered, and omitted when absent', () {
      expect(
        earningsWindowLabel({'from': '2026-01-01T00:00:00Z', 'to': '2026-03-31'}),
        '2026-01-01 → 2026-03-31',
      );
      expect(earningsWindowLabel(<String, dynamic>{}), isNull);
    });
  });

  group('status filter chips', () {
    test('the filter list is the documented lifecycle set', () {
      expect(
        kCourierStatusFilters.map((f) => f.value),
        ['', 'processing', 'shipped', 'out_for_delivery', 'delivered'],
      );
    });

    test('a count is only shown for a real filter, never for All', () {
      final counts = CourierProfile.fromJson(summaryJson()).counts;
      expect(courierCountFor(counts, 'processing'), 1);
      expect(courierCountFor(counts, 'out_for_delivery'), 2);
      expect(courierCountFor(counts, ''), isNull);
    });

    test('a zero-filled count renders as 0, not as a missing chip', () {
      final counts = CourierProfile.fromJson(summaryJson()).counts;
      expect(courierCountFor(counts, 'shipped'), 0);
    });

    test('a count the server did not send is simply absent', () {
      final counts =
          CourierProfile.fromJson({...summaryJson(), 'counts': <String, dynamic>{}})
              .counts;
      expect(courierCountFor(counts, 'processing'), isNull);
    });
  });

  group('commission percentage', () {
    test('a rate is shown to one decimal place as a percentage', () {
      expect(courierCommissionLabel(0.12), '12.0%');
      expect(courierCommissionLabel(0.085), '8.5%');
    });

    test('an absent rate is a dash, not a misleading 0.0%', () {
      expect(courierCommissionLabel(null), '—');
    });
  });
}