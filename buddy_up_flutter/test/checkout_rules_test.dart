import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/marketplace.dart';
import 'package:buddy_up_flutter/features/marketplace/utils/checkout.dart';

/// Payload fixtures shaped from `CartItemSerializer` / `CartSerializer` in
/// `backend/apps/marketplace/serializers.py`, plus the checkout rules in
/// `frontend/src/pages/app/CheckoutPage.tsx`.
void main() {
  CartItem item(
    String type, {
    int quantity = 1,
    List<String> deliveryModes = const [],
    Map<String, int> totalArtifacts = const {},
  }) {
    return CartItem(
      id: 'row-$type-$quantity',
      itemType: type,
      quantity: quantity,
      itemTotalArtifacts: totalArtifacts,
      itemTotalUsd: 10,
      mealPlan: type == 'meal_plan' ? _mealPlan() : null,
      programme: type == 'programme' ? _programme() : null,
      product: type == 'product' ? _product(deliveryModes) : null,
      event: type == 'event_ticket' ? _event() : null,
    );
  }

  group('availableFulfillmentTypes', () {
    test('digital is always possible', () {
      expect(availableFulfillmentTypes([item('meal_plan')]), ['digital']);
    });

    test('a digital-only cart has no pickup or delivery at all', () {
      // Absent, not disabled: meal plans, programmes and event tickets are
      // digital by construction.
      final types = availableFulfillmentTypes([
        item('meal_plan'),
        item('programme'),
        item('event_ticket'),
      ]);
      expect(types, ['digital']);
    });

    test('a product listing pickup adds pickup', () {
      expect(
        availableFulfillmentTypes([item('product', deliveryModes: ['pickup'])]),
        ['digital', 'pickup'],
      );
    });

    test('a product listing delivery adds delivery', () {
      expect(
        availableFulfillmentTypes([item('product', deliveryModes: ['delivery'])]),
        ['digital', 'delivery'],
      );
    });

    test('the canonical order is digital, pickup, delivery', () {
      final types = availableFulfillmentTypes([
        item('product', deliveryModes: ['delivery']),
        item('product', deliveryModes: ['pickup']),
      ]);
      expect(types, ['digital', 'pickup', 'delivery']);
    });

    test('an unrecognised mode is ignored rather than offered', () {
      expect(
        availableFulfillmentTypes([item('product', deliveryModes: ['teleport'])]),
        ['digital'],
      );
    });

    test('a product with no declared modes unlocks nothing', () {
      // The list serializer reports `['digital']` for a legacy product, so an
      // empty list here means "never declared" and stays permissive rather than
      // becoming a checkout block.
      expect(availableFulfillmentTypes([item('product')]), ['digital']);
    });

    test('one physical item unlocks the modes for the whole cart', () {
      final types = availableFulfillmentTypes([
        item('meal_plan'),
        item('product', deliveryModes: ['pickup', 'delivery']),
      ]);
      expect(types, ['digital', 'pickup', 'delivery']);
    });

    test('hasPhysicalItem is true only for a product', () {
      expect(hasPhysicalItem([item('product')]), isTrue);
      expect(hasPhysicalItem([item('meal_plan')]), isFalse);
    });
  });

  group('deriveSavings', () {
    test('the gap between summed lines and the total is the discount', () {
      final items = [
        item('meal_plan', totalArtifacts: {'dumbbell': 100}),
        item('meal_plan', quantity: 2, totalArtifacts: {'dumbbell': 50}),
      ];
      // 150 gross, 120 charged → 30 saved.
      expect(deriveSavings(items, {'dumbbell': 120}), {'dumbbell': 30});
    });

    test('no discount means no savings row', () {
      final items = [item('meal_plan', totalArtifacts: {'dumbbell': 100})];
      expect(deriveSavings(items, {'dumbbell': 100}), isEmpty);
    });

    test('each token type is measured on its own', () {
      final items = [
        item('meal_plan', totalArtifacts: {'dumbbell': 100, 'protein': 20}),
      ];
      expect(
        deriveSavings(items, {'dumbbell': 90, 'protein': 20}),
        {'dumbbell': 10},
      );
    });
  });

  group('validateAddress', () {
    test('a complete address has no errors', () {
      final errors = validateAddress({
        'line1': 'Mombasa Road',
        'city': 'Nairobi',
        'country': 'Kenya',
        'phone': '+254 712 345 678',
      });
      expect(errors, isEmpty);
    });

    test('line1, city, country and phone are required', () {
      final errors = validateAddress(const {});
      expect(errors.keys, containsAll(['line1', 'city', 'country', 'phone']));
    });

    test('the optional fields never produce an error', () {
      final errors = validateAddress({
        'line1': 'Mombasa Road',
        'city': 'Nairobi',
        'country': 'Kenya',
        'phone': '0712345678',
      });
      expect(errors.containsKey('line2'), isFalse);
      expect(errors.containsKey('postal_code'), isFalse);
      expect(errors.containsKey('notes'), isFalse);
    });

    test('whitespace does not satisfy a required field', () {
      final errors = validateAddress({
        'line1': '   ',
        'city': 'Nairobi',
        'country': 'Kenya',
        'phone': '0712345678',
      });
      expect(errors['line1'], isNotNull);
    });
  });

  group('isValidPhone', () {
    test('accepts the shapes a buyer actually types', () {
      for (final phone in [
        '0712345678',
        '+254 712 345 678',
        '+254712345678',
        '+254 (712) 345-678',
        '712 345 678',
      ]) {
        expect(isValidPhone(phone), isTrue, reason: phone);
      }
    });

    test('rejects too short, too long and non-numeric input', () {
      for (final phone in [
        '12345',
        '1234567890123456',
        'call me',
        '',
        '+',
        // Brackets and dashes are only legal *after* a leading digit, which is
        // the same posture the web form takes.
        '(254) 712-345678',
      ]) {
        expect(isValidPhone(phone), isFalse, reason: phone);
      }
    });
  });

  group('artifactDisplay', () {
    test('drops zero and negative quantities', () {
      expect(
        artifactDisplay({'dumbbell': 10, 'protein': 0, 'cardio': -3}),
        '10 dumbbell',
      );
    });

    test('an empty or null map reads as empty, never as "null"', () {
      expect(artifactDisplay({}), '');
      expect(artifactDisplay(null), '');
    });

    test('accepts a JSON map whose values arrive as strings', () {
      expect(artifactDisplay({'dumbbell': '12'}), '12 dumbbell');
    });
  });

  group('paymentStatusLabel', () {
    test('maps the server statuses a receipt can show', () {
      expect(paymentStatusLabel('paid'), 'Paid');
      expect(paymentStatusLabel('succeeded'), 'Paid');
      expect(paymentStatusLabel('pending'), 'Awaiting provider confirmation');
      expect(paymentStatusLabel('awaiting_confirmation'),
          'Awaiting provider confirmation');
      expect(paymentStatusLabel('failed'), 'Failed');
      expect(paymentStatusLabel('refunded'), 'Refunded');
    });

    test('an unknown status still reads as words', () {
      expect(paymentStatusLabel('some_new_state'), 'some new state');
    });
  });

  group('discountLabel', () {
    test('a percentage discount names the percentage', () {
      final label = discountLabel(DiscountCode(
        id: 'c',
        creator: 'me',
        code: 'BUY10',
        discountType: 'percentage',
        discountPct: 10,
      ));
      expect(label, 'BUY10 — 10% off');
    });

    test('a fixed artifact discount says so', () {
      final label = discountLabel(DiscountCode(
        id: 'c',
        creator: 'me',
        code: 'SAVE5',
        discountType: 'fixed_artifacts',
      ));
      expect(label, 'SAVE5 — fixed artifact discount');
    });

    test('no discount is no label', () {
      expect(discountLabel(null), isNull);
    });
  });

  group('addressPayload', () {
    test('every documented key is present, blank rather than missing', () {
      final payload = addressPayload({'line1': ' Mombasa Road ', 'city': ''});
      for (final field in kAddressFields) {
        expect(payload.containsKey(field), isTrue, reason: field);
      }
      expect(payload['line1'], 'Mombasa Road');
      expect(payload['city'], '');
    });
  });

  group('pickupDetailsPayload', () {
    test('a chosen station names itself as the venue and the location', () {
      final payload = pickupDetailsPayload(
        stationName: 'Karura Fitness',
        manualLocation: 'ignored',
        instructions: 'Buzz 4B',
      );
      expect(payload['venue'], 'Karura Fitness');
      expect(payload['location'], 'Karura Fitness');
      expect(payload['instructions'], 'Buzz 4B');
    });

    test('a manual collection point only sets the location', () {
      final payload = pickupDetailsPayload(
        stationName: null,
        manualLocation: '  Karura Fitness  ',
      );
      expect(payload.containsKey('venue'), isFalse);
      expect(payload['location'], 'Karura Fitness');
    });
  });
}

// ─── model fixtures ──────────────────────────────────────────────────────────

CreatorData _creator() => const CreatorData(
      username: 'sam',
      displayName: 'Sam Rivera',
      avatarUrl: '',
    );

MealPlan _mealPlan() => MealPlan(
      id: 'plan',
      creatorId: 'p',
      title: 'Lean 12',
      description: 'A plan',
      coverImageUrl: '',
      dietType: 'balanced',
      durationWeeks: 4,
      calorieRange: '2000',
      priceArtifacts: const {'dumbbell': 50},
      previewDay: const {},
      creatorData: _creator(),
      createdAt: '2026-03-01T00:00:00Z',
    );

TrainingProgramme _programme() => TrainingProgramme(
      id: 'prog',
      creatorId: 'p',
      title: 'Strong 8',
      description: 'A programme',
      coverImageUrl: '',
      category: 'strength',
      durationWeeks: 8,
      priceArtifacts: const {'dumbbell': 80},
      creatorData: _creator(),
      createdAt: '2026-03-01T00:00:00Z',
    );

MarketplaceProduct _product(List<String> modes) => MarketplaceProduct(
      id: 'prod',
      name: 'Mat',
      brand: 'Acme',
      description: 'A mat',
      category: 'gear',
      imageUrl: '',
      affiliateUrl: 'https://example.com',
      priceDisplay: 'Free',
      deliveryModes: modes,
      createdAt: '2026-03-01T00:00:00Z',
    );

MarketplaceEvent _event() => MarketplaceEvent(
      id: 'evt',
      creatorData: _creator(),
      title: 'Sunrise Run',
      description: 'A run',
      coverImageUrl: '',
      eventType: 'in_person',
      location: 'Nairobi',
      onlineUrl: '',
      startDatetime: '2026-04-01T06:00:00Z',
      endDatetime: '2026-04-01T08:00:00Z',
      timezone: 'UTC',
      capacity: 50,
      ticketPriceArtifacts: const {'dumbbell': 5},
      createdAt: '2026-03-01T00:00:00Z',
    );