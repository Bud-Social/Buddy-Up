import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/marketplace.dart';

/// Payload fixtures shaped from `backend/apps/marketplace/serializers.py` and
/// the literal dicts in `views.py` — DRF emits snake_case and `DecimalField`
/// columns serialise as strings, so these are the regression net for the
/// `@JsonKey` annotations on the checkout, courier and logistics models.
///
/// Before these keys existed, decoding a checkout receipt or a courier row
/// threw a `type 'Null' is not a subtype of type 'String'`.
void main() {
  group('CartItem reads the *detail keys, not the foreign keys', () {
    test('a product row exposes delivery_modes, which lives on the detail', () {
      // `CartItemSerializer` emits `product` (the UUID) next to `product_detail`
      // (the serialised object). Reading `product` would hand a bare UUID to the
      // product parser.
      final item = CartItem.fromJson({
        'id': 'row-1',
        'item_type': 'product',
        'product': '22222222-2222-2222-2222-222222222222',
        'product_detail': {
          'id': '22222222-2222-2222-2222-222222222222',
          'name': 'Yoga Mat',
          'brand': 'Acme',
          'description': 'A mat',
          'category': 'gear',
          'content_rating': 'general',
          'image_url': 'https://cdn.example.com/mat.jpg',
          'affiliate_url': 'https://example.com/mat',
          'price_display': 'Free',
          'recommended_by': null,
          'recommender_data': null,
          'click_count': 0,
          'delivery_modes': ['pickup', 'delivery'],
          'fulfillment_details': <String, dynamic>{},
          'created_at': '2026-03-01T00:00:00Z',
        },
        'quantity': 2,
        'item_total_artifacts': {'dumbbell': 60},
        'item_total_usd': 15.0,
      });
      expect(item.product?.name, 'Yoga Mat');
      expect(item.product?.deliveryModes, ['pickup', 'delivery']);
      expect(item.mealPlan, isNull);
    });

    test('a digital row has no detail at all and still parses', () {
      final item = CartItem.fromJson({
        'id': 'row-2',
        'item_type': 'meal_plan',
        'meal_plan': '33333333-3333-3333-3333-333333333333',
        'meal_plan_detail': null,
        'quantity': 1,
      });
      expect(item.mealPlan, isNull);
      expect(item.itemTotalArtifacts, isEmpty);
      expect(item.itemTotalUsd, 0);
    });

    test('a meal plan row parses from the detail despite the missing cover key', () {
      // `MealPlanSerializer` sends `cover`, never `cover_image_url`.
      final item = CartItem.fromJson({
        'id': 'row-3',
        'item_type': 'meal_plan',
        'meal_plan_detail': {
          'id': 'plan',
          'creator_id': 'p',
          'title': 'Lean 12',
          'description': 'A plan',
          'cover': 'https://cdn.example.com/lean.jpg',
          'diet_type': 'balanced',
          'duration_weeks': 4,
          'calorie_range': '2000',
          'price_artifacts': {'dumbbell': 50},
          'preview_day': <String, dynamic>{},
          'creator_data': {
            'username': 'sam',
            'display_name': 'Sam Rivera',
            'avatar_url': null,
            'verification_status': '',
          },
          'created_at': '2026-03-01T00:00:00Z',
        },
        'quantity': 1,
      });
      expect(item.mealPlan?.title, 'Lean 12');
      // The thumbnail key is absent, so it degrades to blank rather than
      // making the whole cart row unparseable.
      expect(item.mealPlan?.coverImageUrl, '');
    });
  });

  group('PickupStation', () {
    test('parses the documented list row, decimals included', () {
      final station = PickupStation.fromJson({
        'id': 's1',
        'name': 'Karura Fitness',
        'description': '',
        'address': 'Mombasa Road',
        'city': 'Nairobi',
        'country': 'Kenya',
        'latitude': '-1.286389',
        'longitude': '36.823608',
        'opening_hours': {
          'monday': {'open': '06:00', 'close': '22:00'},
        },
        'phone': '+254 712 345 678',
        'instructions': 'Buzz 4B',
        'is_active': true,
        'is_primary': true,
        'owner_type': 'shop',
        'owner_name': 'Iron Foundry',
        'shop': '11111111-1111-1111-1111-111111111111',
        'distance_km': 2.4,
        'created_at': '2026-03-01T00:00:00Z',
      });
      expect(station.name, 'Karura Fitness');
      expect(station.latitude, closeTo(-1.286389, 0.000001));
      expect(station.distanceKm, 2.4);
      expect(station.isPrimary, isTrue);
      expect(station.ownerType, 'shop');
    });

    test('an unmeasured row has no distance rather than a zero one', () {
      final station = PickupStation.fromJson({'id': 's1', 'name': 'Somewhere'});
      expect(station.distanceKm, isNull);
      expect(station.openingHours, isEmpty);
      expect(station.isActive, isTrue);
    });
  });

  group('OrderCourierList', () {
    test('parses the courier endpoint payload', () {
      final list = OrderCourierList.fromJson({
        'order_id': 'o1',
        'order_number': 'BU-0001',
        'fulfillment_type': 'delivery',
        'delivery_personnel': null,
        'origin': <String, dynamic>{'lat': -1.28, 'lng': 36.82},
        'couriers': [
          {
            'id': 'c1',
            'profile': 'p1',
            'username': 'jane',
            'display_name': 'Jane Doe',
            'avatar_url': null,
            'vehicle_type': 'motorbike',
            'vehicle_label': 'Motorbike',
            'service_zones': ['Westlands', 'Kilimani'],
            'is_active': true,
            'rating': '4.70',
            'bio': '',
          },
        ],
        'by_vehicle': [
          {
            'vehicle_type': 'motorbike',
            'vehicle_label': 'Motorbike',
            'count': 1,
            'couriers': [
              {
                'id': 'c1',
                'vehicle_type': 'motorbike',
                'service_zones': ['Westlands', 'Kilimani'],
              },
            ],
          },
        ],
      });
      expect(list.fulfillmentType, 'delivery');
      expect(list.couriers, hasLength(1));
      expect(list.couriers.first.vehicleLabel, 'Motorbike');
      // `rating` is a DecimalField, so it arrives as a string.
      expect(list.couriers.first.rating, closeTo(4.7, 0.001));
      expect(list.couriers.first.distanceKm, isNull);
      expect(list.byVehicle.first.count, 1);
    });

    test('an empty courier list is a state, not a failure', () {
      final list = OrderCourierList.fromJson({
        'order_id': 'o1',
        'couriers': [],
        'by_vehicle': [],
      });
      expect(list.couriers, isEmpty);
      expect(list.fulfillmentType, 'digital');
    });
  });

  group('CheckoutReceipt', () {
    /// The `data` block of `CheckoutCartView`'s 201, verbatim.
    final artifactsCheckout = <String, dynamic>{
      'order_id': 'o1',
      'order_number': 'BU-0001',
      'status': 'paid',
      'fulfillment_type': 'delivery',
      'pickup_station_id': null,
      'payment_method': 'artifacts',
      'payment_status': 'paid',
      'payment_required': false,
      'items': <Map<String, dynamic>>[
        {
          'item_type': 'meal_plan',
          'title': 'Lean 12',
          'quantity': 1,
          'price_artifacts': {'dumbbell': 120},
          'total_artifacts': {'dumbbell': 120},
          'paid_artifacts': {'dumbbell': 100},
          'creator_name': 'Sam Rivera',
        },
      ],
      'total_artifacts': {'dumbbell': 100},
      'original_artifacts': {'dumbbell': 120},
      'savings_artifacts': {'dumbbell': 20},
      'savings_usd': 5.0,
      'discount_code': 'BUY10',
      'spent_usd': 25.0,
      'new_balance': {'dumbbell': 900},
    };

    test('an artifacts checkout reads as paid and settled', () {
      final receipt = CheckoutReceipt.fromJson(artifactsCheckout);
      expect(receipt.orderId, 'o1');
      expect(receipt.orderNumber, 'BU-0001');
      expect(receipt.paymentStatus, 'paid');
      expect(receipt.paymentMethod, 'artifacts');
      expect(receipt.paymentRequired, isFalse);
      expect(receipt.totalArtifacts, {'dumbbell': 100});
      expect(receipt.savingsArtifacts, {'dumbbell': 20});
      expect(receipt.discountCode, 'BUY10');
      expect(receipt.spentUsd, 25.0);
      expect(receipt.items.first.paidArtifacts, {'dumbbell': 100});
      expect(receipt.items.first.title, 'Lean 12');
    });

    test('a real-money checkout is pending and needs confirmation', () {
      final receipt = CheckoutReceipt.fromJson({
        ...artifactsCheckout,
        'status': 'pending',
        'payment_method': 'mpesa',
        'payment_status': 'pending',
        'payment_required': true,
        'total_artifacts': {'dumbbell': 120},
        'original_artifacts': {'dumbbell': 120},
        'savings_artifacts': <String, dynamic>{},
        'items': <Map<String, dynamic>>[
          {
            'item_type': 'meal_plan',
            'title': 'Lean 12',
            'quantity': 1,
            'price_artifacts': <String, dynamic>{'dumbbell': 120},
            'total_artifacts': <String, dynamic>{'dumbbell': 120},
            'paid_artifacts': <String, dynamic>{},
            'creator_name': 'Sam Rivera',
          },
        ],
      });
      expect(receipt.status, 'pending');
      expect(receipt.paymentStatus, 'pending');
      expect(receipt.paymentRequired, isTrue);
      // Nothing was deducted, so the line shows gross, not paid.
      expect(receipt.items.first.paidArtifacts, isEmpty);
    });

    test('a pickup checkout carries the station id it was checked out against',
        () {
      final receipt = CheckoutReceipt.fromJson({
        ...artifactsCheckout,
        'fulfillment_type': 'pickup',
        'pickup_station_id': 's1',
      });
      expect(receipt.fulfillmentType, 'pickup');
      expect(receipt.pickupStationId, 's1');
    });

    test('a missing optional block never throws', () {
      final receipt = CheckoutReceipt.fromJson({'order_id': 'o1'});
      expect(receipt.orderNumber, isEmpty);
      expect(receipt.items, isEmpty);
      expect(receipt.newBalance, isEmpty);
      expect(receipt.spentUsd, 0.0);
    });
  });

  group('PaymentIntent', () {
    test('the unconfigured-rail response is a success with a caveat', () {
      final result = PaymentIntentResult.fromJson({
        'intent': {
          'id': 'pi1',
          'order': 'o1',
          'order_number': 'BU-0001',
          'provider': 'flutterwave',
          'method': 'mpesa',
          'method_label': 'M-Pesa',
          'amount': '25.00',
          'currency': 'KES',
          'provider_reference': 'pi-abc123',
          'status': 'initiated',
          'raw_response': <String, dynamic>{
            'skipped': 'provider_not_configured',
          },
          'created_at': '2026-03-01T00:00:00Z',
        },
        'rail_configured': false,
      });
      expect(result.railConfigured, isFalse);
      expect(result.intent?.providerReference, 'pi-abc123');
      expect(result.intent?.status, 'initiated');
      expect(result.intent?.amount, '25.00');
    });

    test('the hosted-checkout response hands back a public key', () {
      final result = PaymentIntentResult.fromJson({
        'intent': {'id': 'pi2', 'method': 'card'},
        'tx_ref': 'pi-def456',
        'public_key': 'FLWPUBK_TEST',
        'amount': '25.00',
        'currency': 'USD',
        'customer_email': 'sam@example.com',
        'customer_name': 'Sam Rivera',
      });
      expect(result.txRef, 'pi-def456');
      expect(result.publicKey, 'FLWPUBK_TEST');
      expect(result.customerEmail, 'sam@example.com');
    });

    test('a bare body with no intent at all still parses', () {
      final result = PaymentIntentResult.fromJson({});
      expect(result.intent, isNull);
      expect(result.railConfigured, isNull);
    });
  });

  group('Order', () {
    test('the seller projection carries the payment and logistics keys', () {
      final order = Order.fromJson({
        'id': 'o1',
        'order_number': 'BU-0001',
        'status': 'paid',
        'status_label': 'Paid',
        'fulfillment_type': 'delivery',
        'delivery_address': <String, dynamic>{'line1': 'Mombasa Road'},
        'pickup_details': <String, dynamic>{},
        'items_total_artifacts': {'dumbbell': 100},
        'discount_artifacts': <String, dynamic>{},
        'total_artifacts': {'dumbbell': 100},
        'total_usd': 25.0,
        'spent_usd': 25.0,
        'status_history': <Map<String, dynamic>>[
          {'status': 'paid', 'at': '2026-03-01T00:00:00Z', 'note': ''},
        ],
        'items': <Map<String, dynamic>>[
          {
            'item_type': 'product',
            'title': 'Yoga Mat',
            'quantity': 2,
            'price_artifacts': {'dumbbell': 100},
            'paid_artifacts': {'dumbbell': 100},
          },
        ],
        'fulfillment': {
          'carrier': 'Swift',
          'tracking_number': 'SW-1',
          'tracking_url': '',
          'pickup_location': '',
          'notes': '',
          'timeline': <Map<String, dynamic>>[],
        },
        'pickup_station': null,
        'delivery_personnel': 'c1',
        'payment_method': 'mpesa',
        'payment_status': 'pending',
        'payment_reference': 'pi-abc',
        'payment_provider': 'flutterwave',
        'is_seller': true,
        'created_at': '2026-03-01T00:00:00Z',
      });
      expect(order.paymentMethod, 'mpesa');
      expect(order.paymentStatus, 'pending');
      expect(order.deliveryPersonnel, 'c1');
      expect(order.pickupStation, isNull);
      expect(order.fulfillment?.trackingNumber, 'SW-1');
      expect(order.isSeller, isTrue);
    });

    test('an older order without payment keys defaults to unpaid', () {
      final order = Order.fromJson({'id': 'o1'});
      expect(order.paymentStatus, 'unpaid');
      expect(order.paymentMethod, isNull);
      expect(order.totalUsd, 0.0);
    });
  });

  group('applications', () {
    test('a courier application round-trips its review fields as read-only', () {
      final application = DeliveryPersonnelApplication.fromJson({
        'id': 'a1',
        'profile': 'p1',
        'vehicle_type': 'tuktuk',
        'service_zones': ['Westlands'],
        'id_document_url': 'https://cdn.example.com/id.jpg',
        'licence_document_url': '',
        'phone': '+254 712 345 678',
        'bio': '',
        'status': 'submitted',
        'reviewer_notes': '',
        'rejection_reason': '',
        'reviewed_at': null,
        'created_at': '2026-03-01T00:00:00Z',
      });
      expect(application.vehicleType, 'tuktuk');
      expect(application.serviceZones, ['Westlands']);
      expect(application.status, 'submitted');
    });

    test('a station application defaults its decimal site to null', () {
      final application = StationApplication.fromJson({
        'id': 'a2',
        'shop': '11111111-1111-1111-1111-111111111111',
        'status': 'draft',
        'opening_hours': <String, dynamic>{},
        'documents': <Map<String, dynamic>>[],
        'agreed_to_policy': false,
        'created_at': '2026-03-01T00:00:00Z',
      });
      expect(application.shop, isNotNull);
      expect(application.gym, isNull);
      expect(application.latitude, isNull);
      expect(application.agreedToPolicy, isFalse);
    });
  });
}