import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/features/marketplace/utils/order_transitions.dart';

/// Locks the client mirror of the backend's fulfillment-aware status machine to
/// `ORDER_TRANSITIONS_BY_FULFILLMENT` in
/// `backend/apps/marketplace/views.py`.
///
/// The seller screen used to carry a flat `_sellerForwardOk` map that treated
/// every order as a parcel: it offered "shipped" and "out for delivery" for a
/// `pickup` order and for a `digital` one, both of which the server rejects with
/// a 400. This test is the regression net for that divergence.
void main() {
  group('digital orders have no transport vocabulary', () {
    test('paid cannot move to shipped or out for delivery', () {
      final next = allowedOrderTransitions('paid', 'digital');
      expect(next, isNot(contains('shipped')));
      expect(next, isNot(contains('out_for_delivery')));
      expect(next, isNot(contains('ready_for_pickup')));
    });

    test('processing closes out through completed', () {
      expect(
        allowedOrderTransitions('processing', 'digital'),
        ['completed', 'cancelled'],
      );
    });

    test('completed only ever cancels', () {
      expect(allowedOrderTransitions('completed', 'digital'), ['cancelled']);
    });
  });

  group('pickup orders reject transport states', () {
    test('paid cannot be marked shipped', () {
      expect(
        allowedOrderTransitions('paid', 'pickup'),
        isNot(contains('shipped')),
      );
      expect(
        allowedOrderTransitions('paid', 'pickup'),
        isNot(contains('out_for_delivery')),
      );
    });

    test('paid may become ready for pickup', () {
      expect(
        allowedOrderTransitions('paid', 'pickup'),
        contains('ready_for_pickup'),
      );
    });

    test('ready_for_pickup closes out through delivered', () {
      expect(
        allowedOrderTransitions('ready_for_pickup', 'pickup'),
        containsAllInOrder(['delivered', 'completed', 'cancelled']),
      );
    });
  });

  group('delivery orders keep the transport chain', () {
    test('processing may ship or go out for delivery', () {
      final next = allowedOrderTransitions('processing', 'delivery');
      expect(next, contains('shipped'));
      expect(next, contains('out_for_delivery'));
    });

    test('shipped may still go out for delivery or be delivered', () {
      expect(
        allowedOrderTransitions('shipped', 'delivery'),
        ['out_for_delivery', 'delivered', 'cancelled'],
      );
    });
  });

  group('cancelled is legal from every non-terminal state', () {
    test('every fulfillment type allows cancelling except delivered', () {
      for (final fulfillment in const ['digital', 'pickup', 'delivery']) {
        for (final status in const ['pending', 'paid', 'processing']) {
          expect(
            allowedOrderTransitions(status, fulfillment),
            contains('cancelled'),
            reason: '$fulfillment/$status should be cancellable',
          );
        }
      }
    });
  });

  group('legacy rows still close out', () {
    test('a transport state under digital falls back to the legacy chain', () {
      // Orders placed before fulfillment_type was meaningful can sit in
      // `shipped` on a `digital` order. The table has no entry for that, so the
      // fallback has to allow closing the order out.
      final next = allowedOrderTransitions('shipped', 'digital');
      expect(next, contains('out_for_delivery'));
      expect(next, contains('delivered'));
      expect(next, contains('completed'));
    });

    test('the fallback still refuses to re-enter shipped', () {
      expect(allowedOrderTransitions('paid', 'digital'), isNot(contains('shipped')));
    });
  });

  group('isOrderTransitionAllowed', () {
    test('is the predicate the seller bulk actions filter on', () {
      expect(
        isOrderTransitionAllowed('paid', 'ready_for_pickup', 'pickup'),
        isTrue,
      );
      expect(
        isOrderTransitionAllowed('paid', 'out_for_delivery', 'pickup'),
        isFalse,
      );
      expect(
        isOrderTransitionAllowed('paid', 'processing', 'digital'),
        isTrue,
      );
    });

    test('an unknown fulfillment type falls back to digital', () {
      expect(isOrderTransitionAllowed('paid', 'processing', 'nonsense'), isTrue);
      expect(isOrderTransitionAllowed('paid', 'shipped', 'nonsense'), isFalse);
    });
  });

  group('labels', () {
    test('every status in the machine has a human label', () {
      const statuses = [
        'pending', 'paid', 'processing', 'shipped', 'out_for_delivery',
        'ready_for_pickup', 'delivered', 'completed', 'cancelled',
      ];
      for (final status in statuses) {
        expect(
          orderStatusLabel(status),
          isNot(contains('_')),
          reason: '$status should read as words',
        );
      }
    });

    test('an unknown status still reads as words rather than as itself', () {
      expect(orderStatusLabel('awaiting_courier'), 'Awaiting Courier');
    });
  });

  group('the flat map the admin portal validates against', () {
    test('is exposed for the portal screen to annotate, not to enforce', () {
      // `/portal/orders/<id>/status/` checks ORDER_FORWARD_STATES, so it is a
      // superset of the fulfillment-aware table. The admin screen unions the two
      // and annotates; it must never hide one of these.
      expect(kLegacyFlatTransitions['paid'], contains('ready_for_pickup'));
      expect(kLegacyFlatTransitions['shipped'], contains('delivered'));
      expect(kLegacyFlatTransitions['delivered'], ['completed']);
    });
  });
}