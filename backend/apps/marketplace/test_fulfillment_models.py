"""Tests for the pickup-station / courier / real-money-payment models.

Covers the invariants that only the database can enforce (exactly-one-owner
CHECK, one primary station per owner, positive payment amounts) plus the
defaults and serializer validation that callers of the new endpoints rely on.
"""

from decimal import Decimal

from django.core.exceptions import ValidationError
from django.db import IntegrityError, transaction
from django.test import TestCase

from apps.accounts.models import User
from apps.gyms.models import Gym
from apps.profiles.models import Profile
from apps.marketplace.models import (
    APPLICATION_STATUS_CHOICES,
    DELIVERY_VEHICLE_TYPES,
    DeliveryPersonnel,
    DeliveryPersonnelApplication,
    Order,
    OrderFulfillment,
    PaymentIntent,
    PickupStation,
    Shop,
    ShopVerificationApplication,
    StationApplication,
)
from apps.marketplace.serializers import (
    ApplicationReviewSerializer,
    DeliveryPersonnelApplicationSerializer,
    DeliveryPersonnelSerializer,
    PaymentIntentSerializer,
    PickupStationSerializer,
    StationApplicationSerializer,
)


def make_profile(username):
    user = User.objects.create_user(email=f'{username}@example.com', password='TestPass123!')
    return Profile.objects.create(user=user, username=username, display_name=username.title())


class FulfillmentTestBase(TestCase):
    def setUp(self):
        self.profile = make_profile('applicant')
        self.other = make_profile('reviewer')
        self.shop = Shop.objects.create(name='Shop One', handle='shop-one')
        self.shop_two = Shop.objects.create(name='Shop Two', handle='shop-two')
        self.gym = Gym.objects.create(name='Gym One', handle='gym-one', category='fitness',
                                      access_type='public')
        self.gym_two = Gym.objects.create(name='Gym Two', handle='gym-two', category='fitness',
                                          access_type='public')
        self.order = Order.objects.create(buyer=self.profile)


# ---------------------------------------------------------------------------
# PickupStation ownership invariants
# ---------------------------------------------------------------------------

class PickupStationOwnershipTests(FulfillmentTestBase):

    def test_shop_owned_station_is_allowed_and_records_owner_type(self):
        station = PickupStation.objects.create(shop=self.shop, name='Shop Counter')
        self.assertIsNone(station.gym_id)
        # owner_type is denormalised but must never lie about the owner.
        self.assertEqual(station.owner_type, 'shop')

    def test_gym_owned_station_is_allowed_and_records_owner_type(self):
        station = PickupStation.objects.create(gym=self.gym, name='Gym Reception')
        self.assertIsNone(station.shop_id)
        self.assertEqual(station.owner_type, 'gym')

    def test_station_with_no_owner_is_rejected_by_check_constraint(self):
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                PickupStation.objects.create(name='Ownerless')

    def test_station_with_two_owners_is_rejected_by_check_constraint(self):
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                PickupStation.objects.create(name='Both', shop=self.shop, gym=self.gym)

    def test_owner_type_cannot_contradict_the_owner_fk(self):
        station = PickupStation(shop=self.shop, owner_type='gym', name='Liar')
        with self.assertRaises(ValidationError):
            station.full_clean()

    def test_deleting_an_owner_with_stations_is_refused_by_the_check_constraint(self):
        # SET_NULL would leave an ownerless station, which the one-owner CHECK
        # forbids — so the delete is refused rather than silently half-applied.
        # No API path deletes a Shop/Gym today; this locks the behaviour in.
        shop = Shop.objects.create(name='Doomed Shop', handle='doomed')
        PickupStation.objects.create(shop=shop, name='Counter')
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                shop.delete()

    def test_station_names_are_not_unique(self):
        # Shops legitimately share a building, so the label is not an identity.
        PickupStation.objects.create(shop=self.shop, name='Level 2, Westlands Mall')
        PickupStation.objects.create(shop=self.shop_two, name='Level 2, Westlands Mall')
        self.assertEqual(PickupStation.objects.filter(name='Level 2, Westlands Mall').count(), 2)


class PickupStationPrimaryTests(FulfillmentTestBase):

    def test_only_one_primary_station_per_shop(self):
        PickupStation.objects.create(shop=self.shop, name='Main', is_primary=True)
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                PickupStation.objects.create(shop=self.shop, name='Secondary', is_primary=True)

    def test_only_one_primary_station_per_gym(self):
        PickupStation.objects.create(gym=self.gym, name='Main', is_primary=True)
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                PickupStation.objects.create(gym=self.gym, name='Secondary', is_primary=True)

    def test_secondary_stations_per_owner_are_unlimited(self):
        PickupStation.objects.create(shop=self.shop, name='Main', is_primary=True)
        PickupStation.objects.create(shop=self.shop, name='Back Door')
        PickupStation.objects.create(shop=self.shop, name='Basement')
        self.assertEqual(PickupStation.objects.filter(shop=self.shop, is_primary=True).count(), 1)

    def test_primary_shop_and_primary_gym_can_coexist(self):
        # NULL owners are distinct to a partial unique index, so a shop's
        # primary must not block a gym's primary.
        PickupStation.objects.create(shop=self.shop, name='Shop Main', is_primary=True)
        PickupStation.objects.create(gym=self.gym, name='Gym Main', is_primary=True)
        self.assertEqual(PickupStation.objects.filter(is_primary=True).count(), 2)

    def test_different_owners_can_each_have_a_primary(self):
        PickupStation.objects.create(shop=self.shop, name='A', is_primary=True)
        PickupStation.objects.create(shop=self.shop_two, name='B', is_primary=True)
        self.assertEqual(PickupStation.objects.filter(is_primary=True).count(), 2)


class PickupStationFieldTests(FulfillmentTestBase):

    def test_defaults(self):
        station = PickupStation.objects.create(shop=self.shop, name='Counter')
        self.assertTrue(station.is_active)
        self.assertFalse(station.is_primary)
        self.assertEqual(station.opening_hours, {})
        self.assertIsNone(station.latitude)
        self.assertIsNone(station.longitude)
        self.assertEqual(station.instructions, '')

    def test_geo_index_mirrors_venue_location(self):
        geo_indexes = [
            i for i in PickupStation._meta.indexes
            if list(i.fields) == ['is_active', 'latitude', 'longitude']
        ]
        self.assertEqual(len(geo_indexes), 1)


# ---------------------------------------------------------------------------
# StationApplication
# ---------------------------------------------------------------------------

class StationApplicationTests(FulfillmentTestBase):

    def test_defaults_to_draft_and_orders_newest_first(self):
        first = StationApplication.objects.create(shop=self.shop, submitted_by=self.profile)
        second = StationApplication.objects.create(gym=self.gym, submitted_by=self.other)
        self.assertEqual(first.status, 'draft')
        self.assertEqual(second.status, 'draft')
        self.assertFalse(first.agreed_to_policy)
        self.assertIsNone(first.agreed_at)
        self.assertEqual(first.documents, [])
        self.assertEqual(first.opening_hours, {})
        self.assertEqual(StationApplication._meta.ordering, ['-created_at'])
        self.assertEqual(list(StationApplication.objects.all()), [second, first])

    def test_status_vocabulary_matches_shop_verification(self):
        field = StationApplication._meta.get_field('status')
        self.assertEqual(list(field.choices), list(ShopVerificationApplication.STATUS_CHOICES))
        self.assertEqual(list(field.choices), list(APPLICATION_STATUS_CHOICES))

    def test_requires_exactly_one_owner(self):
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                StationApplication.objects.create(submitted_by=self.profile, status='submitted')
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                StationApplication.objects.create(submitted_by=self.profile, shop=self.shop,
                                                 gym=self.gym, status='submitted')

    def test_accepted_owner_combinations(self):
        shop_app = StationApplication.objects.create(shop=self.shop, submitted_by=self.profile,
                                                     status='submitted')
        gym_app = StationApplication.objects.create(gym=self.gym, submitted_by=self.other,
                                                   status='under_review')
        self.assertEqual(list(StationApplication.objects.all()), [gym_app, shop_app])


# ---------------------------------------------------------------------------
# DeliveryPersonnel / DeliveryPersonnelApplication
# ---------------------------------------------------------------------------

class DeliveryPersonnelTests(FulfillmentTestBase):

    def test_defaults(self):
        courier = DeliveryPersonnel.objects.create(profile=self.profile)
        self.assertEqual(courier.vehicle_type, 'bike')
        self.assertEqual(courier.service_zones, [])
        self.assertTrue(courier.is_active)
        self.assertIsNone(courier.rating)
        self.assertEqual(courier.bio, '')

    def test_accepts_every_supported_vehicle_type(self):
        self.assertEqual([v for v, _ in DELIVERY_VEHICLE_TYPES],
                         ['bike', 'motorbike', 'tuktuk', 'car', 'pickup', 'lorry'])
        for index, (vehicle, label) in enumerate(DELIVERY_VEHICLE_TYPES):
            profile = make_profile(f'courier{index}')
            courier = DeliveryPersonnel.objects.create(profile=profile, vehicle_type=vehicle)
            self.assertEqual(courier.vehicle_type, vehicle)
            self.assertEqual(courier.get_vehicle_type_display(), label)

    def test_rejects_unknown_vehicle_type(self):
        # Django does not police choices on save(), so the guard is full_clean().
        courier = DeliveryPersonnel(profile=self.profile, vehicle_type='hovercraft')
        with self.assertRaises(ValidationError) as ctx:
            courier.full_clean()
        self.assertIn('vehicle_type', ctx.exception.message_dict)

    def test_profile_is_one_to_one(self):
        DeliveryPersonnel.objects.create(profile=self.profile)
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                DeliveryPersonnel.objects.create(profile=self.profile)

    def test_rating_is_nullable_and_round_trips(self):
        unrated = DeliveryPersonnel.objects.create(profile=self.profile)
        self.assertIsNone(unrated.rating)
        rated = DeliveryPersonnel.objects.create(profile=self.other, rating=Decimal('4.75'))
        self.assertEqual(DeliveryPersonnel.objects.get(pk=rated.pk).rating, Decimal('4.75'))


class DeliveryPersonnelApplicationTests(FulfillmentTestBase):

    def test_defaults_to_draft_and_orders_newest_first(self):
        first = DeliveryPersonnelApplication.objects.create(profile=self.profile)
        second = DeliveryPersonnelApplication.objects.create(profile=self.other, status='submitted')
        self.assertEqual(first.status, 'draft')
        self.assertEqual(second.status, 'submitted')
        self.assertEqual(first.vehicle_type, 'bike')
        self.assertEqual(first.service_zones, [])
        self.assertEqual(DeliveryPersonnelApplication._meta.ordering, ['-created_at'])
        self.assertEqual(list(DeliveryPersonnelApplication.objects.all()), [second, first])

    def test_status_vocabulary_matches_shop_verification(self):
        field = DeliveryPersonnelApplication._meta.get_field('status')
        self.assertEqual(list(field.choices), list(ShopVerificationApplication.STATUS_CHOICES))

    def test_vehicle_vocabulary_matches_delivery_personnel(self):
        app_choices = DeliveryPersonnelApplication._meta.get_field('vehicle_type').choices
        courier_choices = DeliveryPersonnel._meta.get_field('vehicle_type').choices
        self.assertEqual(list(app_choices), list(courier_choices))
        self.assertEqual(len(app_choices), 6)


# ---------------------------------------------------------------------------
# Order extensions
# ---------------------------------------------------------------------------

class OrderFieldDefaultTests(FulfillmentTestBase):

    def test_new_logistics_and_payment_fields_default_safely(self):
        order = Order.objects.create(buyer=self.profile)
        self.assertIsNone(order.pickup_station_id)
        self.assertIsNone(order.delivery_personnel_id)
        self.assertIsNone(order.payment_method)
        self.assertEqual(order.payment_status, 'unpaid')
        self.assertEqual(order.payment_reference, '')
        self.assertEqual(order.payment_provider, '')

    def test_payment_method_vocabulary_includes_artifacts_mpesa_card(self):
        field = Order._meta.get_field('payment_method')
        self.assertEqual([v for v, _ in field.choices], ['artifacts', 'mpesa', 'card'])
        self.assertEqual([v for v, _ in Order._meta.get_field('payment_status').choices],
                         ['unpaid', 'pending', 'paid', 'failed', 'refunded'])

    def test_station_and_courier_attach_to_an_order(self):
        station = PickupStation.objects.create(shop=self.shop, name='Counter')
        courier = DeliveryPersonnel.objects.create(profile=self.other, vehicle_type='motorbike')
        order = Order.objects.create(
            buyer=self.profile, fulfillment_type='delivery', pickup_station=station,
            delivery_personnel=courier, payment_method='mpesa', payment_status='pending',
            payment_reference='FLW-123', payment_provider='flutterwave',
        )
        order.refresh_from_db()
        self.assertEqual(order.pickup_station_id, station.id)
        self.assertEqual(order.delivery_personnel_id, courier.id)
        self.assertEqual(order.payment_method, 'mpesa')
        self.assertEqual(list(station.orders.all()), [order])
        self.assertEqual(list(courier.orders.all()), [order])

    def test_deleting_a_station_or_courier_leaves_the_order(self):
        station = PickupStation.objects.create(shop=self.shop, name='Counter')
        courier = DeliveryPersonnel.objects.create(profile=self.other)
        order = Order.objects.create(buyer=self.profile, pickup_station=station,
                                     delivery_personnel=courier)
        station.delete()
        courier.delete()
        order.refresh_from_db()
        self.assertIsNone(order.pickup_station_id)
        self.assertIsNone(order.delivery_personnel_id)


class OrderFulfillmentPropertyTests(FulfillmentTestBase):
    """``Order.fulfillment`` used to be a get_or_create, so a GET request
    inserted a row. Reading must be free."""

    def test_reading_fulfillment_creates_nothing(self):
        order = Order.objects.create(buyer=self.profile)
        before = OrderFulfillment.objects.count()
        for _ in range(3):
            self.assertIsNone(order.fulfillment)
        self.assertEqual(OrderFulfillment.objects.count(), before)
        self.assertFalse(OrderFulfillment.objects.filter(order=order).exists())

    def test_fulfillment_returns_an_existing_record(self):
        order = Order.objects.create(buyer=self.profile)
        record = OrderFulfillment.objects.create(order=order, carrier='Sendy')
        self.assertEqual(order.fulfillment, record)

    def test_cached_absence_does_not_become_a_row_after_a_create_elsewhere(self):
        order = Order.objects.create(buyer=self.profile)
        self.assertIsNone(order.fulfillment)          # warms the failed lookup
        record = OrderFulfillment.objects.create(order=order)
        self.assertEqual(order.fulfillment, record)
        self.assertEqual(OrderFulfillment.objects.filter(order=order).count(), 1)

    def test_explicit_create_then_read(self):
        order = Order.objects.create(buyer=self.profile)
        fulfillment, created = OrderFulfillment.objects.get_or_create(order=order)
        self.assertTrue(created)
        self.assertEqual(order.fulfillment, fulfillment)


# ---------------------------------------------------------------------------
# PaymentIntent
# ---------------------------------------------------------------------------

class PaymentIntentTests(FulfillmentTestBase):

    def test_defaults(self):
        intent = PaymentIntent.objects.create(order=self.order, method='mpesa',
                                              amount=Decimal('1500.00'))
        self.assertEqual(intent.status, 'initiated')
        self.assertEqual(intent.provider, 'flutterwave')
        self.assertEqual(intent.currency, 'KES')
        self.assertEqual(intent.provider_reference, '')
        self.assertEqual(intent.raw_response, {})
        self.assertIsNone(intent.created_by_id)
        self.assertEqual(PaymentIntent._meta.ordering, ['-created_at'])

    def test_rejects_zero_amount(self):
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                PaymentIntent.objects.create(order=self.order, method='mpesa', amount=0)

    def test_rejects_negative_amount(self):
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                PaymentIntent.objects.create(order=self.order, method='card',
                                             amount=Decimal('-1.00'))

    def test_smallest_valid_amount_is_accepted(self):
        intent = PaymentIntent.objects.create(order=self.order, method='mpesa',
                                              amount=Decimal('0.01'))
        self.assertEqual(intent.amount, Decimal('0.01'))

    def test_several_intents_per_order_are_allowed(self):
        first = PaymentIntent.objects.create(order=self.order, method='card',
                                             amount=Decimal('500.00'))
        second = PaymentIntent.objects.create(order=self.order, method='mpesa',
                                              amount=Decimal('500.00'))
        self.assertEqual(list(self.order.payment_intents.all()), [second, first])

    def test_provider_reference_is_indexed_and_not_unique(self):
        field = PaymentIntent._meta.get_field('provider_reference')
        self.assertTrue(field.db_index)
        # The same reference can arrive twice; the webhook must not blow up.
        PaymentIntent.objects.create(order=self.order, method='mpesa', amount=Decimal('10.00'),
                                     provider_reference='FLW-DUP')
        PaymentIntent.objects.create(order=self.order, method='mpesa', amount=Decimal('10.00'),
                                     provider_reference='FLW-DUP')
        self.assertEqual(
            PaymentIntent.objects.filter(provider_reference='FLW-DUP').count(), 2)

    def test_provider_reference_lookup_finds_the_intent_for_a_webhook(self):
        PaymentIntent.objects.create(order=self.order, method='mpesa', amount=Decimal('10.00'),
                                     provider_reference='FLW-LOOKUP-1')
        found = PaymentIntent.objects.filter(provider_reference='FLW-LOOKUP-1').first()
        self.assertIsNotNone(found)
        self.assertEqual(found.order_id, self.order.id)

    def test_mark_succeeded_flips_only_the_intent(self):
        intent = PaymentIntent.objects.create(order=self.order, method='mpesa',
                                              amount=Decimal('250.00'))
        intent.mark_succeeded(provider_reference='FLW-OK', raw_response={'status': 'successful'})
        intent.refresh_from_db()
        self.assertEqual(intent.status, 'succeeded')
        self.assertEqual(intent.provider_reference, 'FLW-OK')
        self.assertEqual(intent.raw_response, {'status': 'successful'})
        # The order is the caller's to settle — the intent never guesses.
        self.order.refresh_from_db()
        self.assertEqual(self.order.payment_status, 'unpaid')


# ---------------------------------------------------------------------------
# Serializer validation
# ---------------------------------------------------------------------------

class PickupStationSerializerTests(FulfillmentTestBase):

    def test_create_requires_exactly_one_owner(self):
        for payload in (
            {'name': 'No owner'},
            {'name': 'Two owners', 'shop': str(self.shop.id), 'gym': str(self.gym.id)},
        ):
            with self.subTest(payload=payload):
                serializer = PickupStationSerializer(data=payload)
                self.assertFalse(serializer.is_valid())
                self.assertIn('non_field_errors', serializer.errors)

    def test_create_with_one_owner_succeeds(self):
        serializer = PickupStationSerializer(data={'name': 'Counter', 'shop': str(self.shop.id)})
        self.assertTrue(serializer.is_valid(), serializer.errors)
        station = serializer.save()
        self.assertEqual(station.owner_type, 'shop')

    def test_owner_type_is_read_only(self):
        serializer = PickupStationSerializer(
            instance=PickupStation.objects.create(shop=self.shop, name='Counter'),
            data={'name': 'Counter', 'is_primary': True}, partial=True,
        )
        self.assertTrue(serializer.is_valid(), serializer.errors)
        self.assertNotIn('owner_type', serializer.initial_data)

    def test_second_primary_station_is_rejected_with_a_400(self):
        PickupStation.objects.create(shop=self.shop, name='Main', is_primary=True)
        serializer = PickupStationSerializer(
            data={'name': 'Second', 'shop': str(self.shop.id), 'is_primary': True},
        )
        self.assertFalse(serializer.is_valid())
        self.assertIn('is_primary', serializer.errors)

    def test_distance_km_is_absent_without_an_explicit_origin(self):
        station = PickupStation.objects.create(shop=self.shop, name='Counter',
                                               latitude=Decimal('-1.286389'),
                                               longitude=Decimal('36.817223'))
        data = PickupStationSerializer(station).data
        # Omitted rather than null: a client switching on the key's presence
        # cannot tell "not measured" from "0 km away" if it is always sent.
        self.assertNotIn('distance_km', data)

    def test_distance_km_is_computed_from_an_explicit_origin(self):
        # Nairobi CBD → Mombasa (Nyali), roughly 440 km apart.
        station = PickupStation.objects.create(
            shop=self.shop, name='Counter',
            latitude=Decimal('-4.0435'), longitude=Decimal('39.6682'),
        )
        serializer = PickupStationSerializer(instance=station, partial=True, data={
            'origin_latitude': '-1.286389', 'origin_longitude': '36.817223',
        })
        self.assertTrue(serializer.is_valid(), serializer.errors)
        distance = serializer.data['distance_km']
        self.assertIsNotNone(distance)
        self.assertGreater(distance, 400)
        self.assertLess(distance, 470)

    def test_distance_km_is_zero_when_origin_matches_the_station(self):
        station = PickupStation.objects.create(shop=self.shop, name='Counter',
                                               latitude=Decimal('-1.286389'),
                                               longitude=Decimal('36.817223'))
        serializer = PickupStationSerializer(instance=station, partial=True, data={
            'origin_latitude': '-1.286389', 'origin_longitude': '36.817223',
        })
        self.assertTrue(serializer.is_valid(), serializer.errors)
        self.assertAlmostEqual(serializer.data['distance_km'], 0.0, places=2)

    def test_distance_km_is_absent_when_the_station_has_no_coordinates(self):
        station = PickupStation.objects.create(shop=self.shop, name='Counter')
        serializer = PickupStationSerializer(instance=station, partial=True, data={
            'origin_latitude': '-1.286389', 'origin_longitude': '36.817223',
        })
        self.assertTrue(serializer.is_valid(), serializer.errors)
        self.assertNotIn('distance_km', serializer.data)

    def test_origin_fields_are_write_only_and_never_persisted(self):
        serializer = PickupStationSerializer(data={
            'name': 'Counter', 'shop': str(self.shop.id),
            'origin_latitude': '-1.286389', 'origin_longitude': '36.817223',
        })
        self.assertTrue(serializer.is_valid(), serializer.errors)
        station = serializer.save()
        self.assertIsNone(station.latitude)   # origin_*, not the station's coords
        self.assertNotIn('origin_latitude', PickupStationSerializer(station).data)
        self.assertEqual(PickupStation.objects.filter(name='Counter').count(), 1)


class ApplicationSerializerTests(FulfillmentTestBase):

    def test_station_application_rejects_two_owners(self):
        serializer = StationApplicationSerializer(data={
            'shop': str(self.shop.id), 'gym': str(self.gym.id),
            'submitted_by': str(self.profile.user_id),
        })
        self.assertFalse(serializer.is_valid())
        self.assertIn('non_field_errors', serializer.errors)

    def test_station_application_create_defaults_to_draft(self):
        serializer = StationApplicationSerializer(data={
            'shop': str(self.shop.id), 'submitted_by': str(self.profile.user_id),
            'documents': [{'url': 'https://example.com/lease.pdf', 'label': 'Lease'}],
        })
        self.assertTrue(serializer.is_valid(), serializer.errors)
        application = serializer.save()
        self.assertEqual(application.status, 'draft')
        self.assertEqual(len(application.documents), 1)

    def test_station_application_status_is_read_only_for_applicants(self):
        serializer = StationApplicationSerializer(data={
            'shop': str(self.shop.id), 'submitted_by': str(self.profile.user_id),
            'status': 'approved',
        })
        self.assertTrue(serializer.is_valid(), serializer.errors)
        # Silently ignored, not honoured — an applicant cannot self-approve.
        self.assertEqual(serializer.save().status, 'draft')

    def test_station_application_documents_must_carry_a_url(self):
        serializer = StationApplicationSerializer(data={
            'shop': str(self.shop.id), 'submitted_by': str(self.profile.user_id),
            'documents': [{'label': 'No url'}],
        })
        self.assertFalse(serializer.is_valid())
        self.assertIn('documents', serializer.errors)

    def test_review_serializer_accepts_a_known_status(self):
        serializer = ApplicationReviewSerializer(data={'status': 'approved'})
        self.assertTrue(serializer.is_valid(), serializer.errors)
        self.assertEqual(serializer.validated_data['status'], 'approved')

    def test_review_serializer_rejects_an_unknown_status(self):
        serializer = ApplicationReviewSerializer(data={'status': 'shipped_it'})
        self.assertFalse(serializer.is_valid())
        self.assertIn('status', serializer.errors)

    def test_review_serializer_requires_a_reason_when_rejecting(self):
        serializer = ApplicationReviewSerializer(data={'status': 'rejected'})
        self.assertFalse(serializer.is_valid())
        self.assertIn('rejection_reason', serializer.errors)
        ok = ApplicationReviewSerializer(data={'status': 'rejected',
                                               'rejection_reason': 'No storage at site'})
        self.assertTrue(ok.is_valid(), ok.errors)

    def test_review_serializer_accepts_the_full_shared_vocabulary(self):
        for value, _ in APPLICATION_STATUS_CHOICES:
            with self.subTest(status=value):
                payload = {'status': value}
                if value == 'rejected':
                    payload['rejection_reason'] = 'No storage at site'
                serializer = ApplicationReviewSerializer(data=payload)
                self.assertTrue(serializer.is_valid(), serializer.errors)

    def test_delivery_application_rejects_an_unknown_vehicle_type(self):
        serializer = DeliveryPersonnelApplicationSerializer(data={
            'profile': str(self.profile.user_id), 'vehicle_type': 'hovercraft',
        })
        self.assertFalse(serializer.is_valid())
        self.assertIn('vehicle_type', serializer.errors)

    def test_delivery_application_accepts_every_vehicle_type(self):
        for index, (vehicle, _) in enumerate(DELIVERY_VEHICLE_TYPES):
            with self.subTest(vehicle=vehicle):
                profile = make_profile(f'applicant{index}')
                serializer = DeliveryPersonnelApplicationSerializer(data={
                    'profile': str(profile.user_id), 'vehicle_type': vehicle,
                    'service_zones': ['Westlands'],
                })
                self.assertTrue(serializer.is_valid(), serializer.errors)
                self.assertEqual(serializer.save().vehicle_type, vehicle)

    def test_delivery_application_status_is_read_only_for_applicants(self):
        serializer = DeliveryPersonnelApplicationSerializer(data={
            'profile': str(self.profile.user_id), 'status': 'approved',
        })
        self.assertTrue(serializer.is_valid(), serializer.errors)
        self.assertEqual(serializer.save().status, 'draft')

    def test_service_zones_must_be_a_list_of_strings(self):
        serializer = DeliveryPersonnelSerializer(data={'service_zones': 'Westlands'})
        self.assertFalse(serializer.is_valid())
        self.assertIn('service_zones', serializer.errors)
        serializer = DeliveryPersonnelSerializer(data={'service_zones': [1, 2]})
        self.assertFalse(serializer.is_valid())
        self.assertIn('service_zones', serializer.errors)

    def test_courier_serializer_keeps_profile_and_rating_read_only(self):
        # A courier record only ever exists because an application was approved,
        # so it is created with its profile and then updated — never created
        # from a request body that names its own owner.
        courier = DeliveryPersonnel.objects.create(profile=self.profile, vehicle_type='bike')
        serializer = DeliveryPersonnelSerializer(
            instance=courier, data={'vehicle_type': 'lorry', 'rating': '5.00'}, partial=True,
        )
        self.assertTrue(serializer.is_valid(), serializer.errors)
        updated = serializer.save()
        self.assertEqual(updated.vehicle_type, 'lorry')
        self.assertEqual(updated.profile_id, self.profile.user_id)
        self.assertIsNone(updated.rating)   # rating is never client-writable


class PaymentIntentSerializerTests(FulfillmentTestBase):

    def test_create_validates_method(self):
        serializer = PaymentIntentSerializer(data={
            'order': str(self.order.id), 'method': 'bitcoin', 'amount': '100.00',
        })
        self.assertFalse(serializer.is_valid())
        self.assertIn('method', serializer.errors)

    def test_create_rejects_non_positive_amount(self):
        for amount in ('0', '-10.00'):
            with self.subTest(amount=amount):
                serializer = PaymentIntentSerializer(data={
                    'order': str(self.order.id), 'method': 'mpesa', 'amount': amount,
                })
                self.assertFalse(serializer.is_valid())
                self.assertIn('amount', serializer.errors)

    def test_create_succeeds_and_lands_on_initiated(self):
        serializer = PaymentIntentSerializer(data={
            'order': str(self.order.id), 'method': 'mpesa', 'amount': '750.00',
        })
        self.assertTrue(serializer.is_valid(), serializer.errors)
        intent = serializer.save()
        self.assertEqual(intent.status, 'initiated')
        self.assertEqual(intent.provider, 'flutterwave')
        self.assertEqual(intent.currency, 'KES')
        self.assertEqual(PaymentIntentSerializer(intent).data['order_number'],
                         self.order.order_number)

    def test_client_cannot_declare_its_own_payment_successful(self):
        serializer = PaymentIntentSerializer(data={
            'order': str(self.order.id), 'method': 'mpesa', 'amount': '750.00',
            'status': 'succeeded', 'provider_reference': 'FORGED',
        })
        self.assertTrue(serializer.is_valid(), serializer.errors)
        intent = serializer.save()
        self.assertEqual(intent.status, 'initiated')
        self.assertEqual(intent.provider_reference, '')