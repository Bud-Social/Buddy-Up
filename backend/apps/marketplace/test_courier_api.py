"""The courier (delivery personnel) dashboard API.

`DeliveryPersonnel` had an `Order.delivery_personnel` foreign key that nothing
ever queried: a seller assigned a courier and the courier had no way to find
out, change anything, or see what they had earned. These tests pin the contract
the web and Flutter dashboards are built against:

* registration is required first (404 with a message, never a silent empty list)
* `my-orders` shows the caller's orders and only delivery ones
* the transition map is strictly narrower than the seller's, and writing it
  goes through the same helper, so `status_history` and the fulfillment
  timeline stay consistent
* shipping metadata stays the seller's
* earnings are an honest per-artifact-key, floored estimate — not money
"""

from datetime import timedelta
from decimal import Decimal

from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.marketplace.models import (
    COURIER_TRANSITIONS,
    DeliveryPersonnel,
    Order,
    OrderFulfillment,
    OrderItem,
    Shop,
    ShopMembership,
)
from apps.profiles.models import Profile

SUMMARY_URL = '/api/v1/marketplace/delivery/summary/'
MY_ORDERS_URL = '/api/v1/marketplace/delivery/my-orders/'
EARNINGS_URL = '/api/v1/marketplace/delivery/earnings/'


def make_profile(username, balance=None):
    user = User.objects.create_user(email=f'{username}@example.com', password='TestPass123!')
    return Profile.objects.create(
        user=user, username=username, display_name=username.title(),
        artifact_balance=balance or {},
    )


def client_for(profile):
    client = APIClient()
    refresh = RefreshToken.for_user(profile.user)
    client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
    return client


def make_order(buyer, seller, status_value, *, fulfillment_type='delivery',
               total_artifacts=None, courier=None, created_at=None):
    order = Order.objects.create(
        buyer=buyer,
        fulfillment_type=fulfillment_type,
        status=status_value,
        total_artifacts=total_artifacts or {'sprint': 2},
        items_total_artifacts=total_artifacts or {'sprint': 2},
        delivery_address={'line1': 'Mansion Road', 'city': 'Nairobi'},
        paid_at=timezone.now(),
    )
    if created_at is not None:
        # created_at is auto_now_add, so it has to be written after the insert.
        Order.objects.filter(pk=order.pk).update(created_at=created_at)
        order.refresh_from_db()
    OrderItem.objects.create(
        order=order, item_type='product', title='Whey 2kg', creator=seller, quantity=1,
        price_artifacts=total_artifacts or {'sprint': 2},
        paid_artifacts=total_artifacts or {'sprint': 2},
    )
    if courier is not None:
        order.delivery_personnel = courier
        order.save(update_fields=['delivery_personnel'])
    return order


class CourierTestBase(TestCase):
    def setUp(self):
        self.seller = make_profile('courierseller')
        self.buyer = make_profile('courierbuyer')
        self.courier_profile = make_profile('courierperson')
        self.other_profile = make_profile('othercourier')
        self.stranger = make_profile('courierstranger')

        self.shop = Shop.objects.create(name='Gear Shack', handle='courier-gear-shack')
        ShopMembership.objects.create(shop=self.shop, profile=self.seller, role='owner')

        self.courier = DeliveryPersonnel.objects.create(
            profile=self.courier_profile, vehicle_type='motorbike',
            service_zones=['Westlands', 'Kilimani'],
        )
        self.other_courier = DeliveryPersonnel.objects.create(
            profile=self.other_profile, vehicle_type='bike', service_zones=['Mombasa'],
        )
        self.client_courier = client_for(self.courier_profile)
        self.client_other = client_for(self.other_profile)
        self.client_stranger = client_for(self.stranger)


# ---------------------------------------------------------------------------
# Registration gate
# ---------------------------------------------------------------------------

class CourierRegistrationTests(CourierTestBase):
    def test_summary_404s_without_a_delivery_personnel_row(self):
        res = client_for(self.stranger).get(SUMMARY_URL)
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)
        body = res.json()
        self.assertFalse(body['success'])
        self.assertIn('not registered as delivery personnel', body['message'])

    def test_every_courier_endpoint_404s_without_a_row(self):
        stranger = client_for(self.stranger)
        for url, method in (
            (SUMMARY_URL, 'get'), (MY_ORDERS_URL, 'get'), (EARNINGS_URL, 'get'),
        ):
            with self.subTest(url=url):
                res = getattr(stranger, method)(url)
                self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)
                self.assertIn('not registered as delivery personnel', res.json()['message'])

        order = make_order(self.buyer, self.seller, 'processing')
        res = stranger.patch(f'{MY_ORDERS_URL}{order.id}/', {'status': 'out_for_delivery'})
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)

    def test_summary_returns_the_callers_own_record_once_registered(self):
        res = self.client_courier.get(SUMMARY_URL)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()['data']
        self.assertEqual(str(data['id']), str(self.courier.id))
        self.assertEqual(data['vehicle_type'], 'motorbike')
        self.assertEqual(data['service_zones'], ['Westlands', 'Kilimani'])
        self.assertTrue(data['is_active'])
        self.assertEqual(data['commission_rate'], 0.15)
        self.assertIn('rating', data)
        self.assertFalse(data['active'])

    def test_counts_and_active_flag_track_assigned_orders(self):
        make_order(self.buyer, self.seller, 'processing', courier=self.courier)
        make_order(self.buyer, self.seller, 'out_for_delivery', courier=self.courier)
        make_order(self.buyer, self.seller, 'cancelled', courier=self.courier)
        # Someone else's order, and a non-delivery one: neither is this
        # courier's workload.
        make_order(self.buyer, self.seller, 'processing', courier=self.other_courier)
        make_order(self.buyer, self.seller, 'processing', fulfillment_type='pickup',
                   courier=self.courier)

        data = self.client_courier.get(SUMMARY_URL).json()['data']
        self.assertEqual(data['counts']['processing'], 1)
        self.assertEqual(data['counts']['out_for_delivery'], 1)
        self.assertEqual(data['counts']['cancelled'], 1)
        self.assertEqual(data['total_assigned'], 3)
        self.assertTrue(data['active'])

    def test_counts_are_zero_filled_for_every_order_status(self):
        counts = self.client_courier.get(SUMMARY_URL).json()['data']['counts']
        self.assertEqual(set(counts), {choice for choice, _ in Order.STATUS_CHOICES})

    def test_closed_orders_are_not_active(self):
        make_order(self.buyer, self.seller, 'completed', courier=self.courier)
        self.assertFalse(self.client_courier.get(SUMMARY_URL).json()['data']['active'])

    def test_commission_rate_is_bounded_by_the_database(self):
        """The 0..1 rule is a CHECK, not just a serializer field."""
        from django.db import transaction
        from django.db.utils import IntegrityError

        # Wrapped in its own atomic block: an IntegrityError poisons the
        # surrounding TestCase transaction otherwise.
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                self.courier.commission_rate = Decimal('2.50')
                self.courier.save()
        self.courier.refresh_from_db()
        self.assertEqual(self.courier.commission_rate, Decimal('0.1500'))

    def test_the_endpoints_require_authentication(self):
        anon = APIClient()
        for url in (SUMMARY_URL, MY_ORDERS_URL, EARNINGS_URL):
            with self.subTest(url=url):
                self.assertEqual(anon.get(url).status_code, status.HTTP_401_UNAUTHORIZED)


# ---------------------------------------------------------------------------
# my-orders
# ---------------------------------------------------------------------------

class CourierMyOrdersTests(CourierTestBase):
    def setUp(self):
        super().setUp()
        self.mine = make_order(self.buyer, self.seller, 'processing',
                               courier=self.courier, total_artifacts={'sprint': 3})
        self.theirs = make_order(self.buyer, self.seller, 'processing',
                                 courier=self.other_courier)
        self.digital = make_order(self.buyer, self.seller, 'processing',
                                  fulfillment_type='digital', courier=self.courier)
        self.pickup = make_order(self.buyer, self.seller, 'processing',
                                 fulfillment_type='pickup', courier=self.courier)

    def test_only_the_callers_own_orders_come_back(self):
        rows = self.client_courier.get(MY_ORDERS_URL).json()['data']
        self.assertEqual([row['order_number'] for row in rows], [self.mine.order_number])

    def test_only_delivery_orders_ever_appear(self):
        rows = self.client_courier.get(MY_ORDERS_URL).json()['data']
        self.assertTrue(all(row['fulfillment_type'] == 'delivery' for row in rows))
        self.assertNotIn(str(self.digital.id), str(rows))
        self.assertNotIn(str(self.pickup.id), str(rows))

    def test_rows_carry_what_a_courier_needs_to_deliver(self):
        row = self.client_courier.get(MY_ORDERS_URL).json()['data'][0]
        self.assertEqual(row['order_number'], self.mine.order_number)
        self.assertEqual(row['status'], 'processing')
        self.assertEqual(row['status_label'], 'Processing')
        self.assertEqual(row['fulfillment_status'], 'ready_to_collect')
        self.assertEqual(row['allowed_transitions'], ['out_for_delivery'])
        self.assertEqual(row['delivery_address']['line1'], 'Mansion Road')
        self.assertEqual(row['items'][0]['title'], 'Whey 2kg')
        self.assertEqual(row['items'][0]['creator_name'], self.seller.display_name)
        self.assertEqual(row['delivery_personnel_name'],
                         self.courier_profile.display_name)
        self.assertIsNone(row['pickup_station'])
        self.assertIsNotNone(row['created_at'])
        self.assertIsNotNone(row['paid_at'])

    def test_pickup_station_is_reported_when_one_is_set(self):
        from apps.marketplace.models import PickupStation
        station = PickupStation.objects.create(
            shop=self.shop, name='Westlands Counter', address='Level 2, Westlands Mall',
            city='Nairobi',
        )
        self.mine.pickup_station = station
        self.mine.save(update_fields=['pickup_station'])
        row = self.client_courier.get(MY_ORDERS_URL).json()['data'][0]
        self.assertEqual(row['pickup_station']['name'], 'Westlands Counter')
        self.assertEqual(row['pickup_station']['address'], 'Level 2, Westlands Mall')

    def test_newest_first_and_status_filter(self):
        older = make_order(self.buyer, self.seller, 'out_for_delivery',
                           courier=self.courier,
                           created_at=timezone.now() - timedelta(days=3))
        rows = self.client_courier.get(MY_ORDERS_URL).json()['data']
        self.assertEqual([row['order_number'] for row in rows],
                         [self.mine.order_number, older.order_number])

        rows = self.client_courier.get(MY_ORDERS_URL, {'status': 'out_for_delivery'}).json()['data']
        self.assertEqual([row['order_number'] for row in rows], [older.order_number])

    def test_unknown_status_filter_is_rejected_not_ignored(self):
        res = self.client_courier.get(MY_ORDERS_URL, {'status': 'teleported'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('status must be one of', res.json()['message'])

    def test_list_is_paginated_in_the_house_envelope(self):
        for _ in range(25):
            make_order(self.buyer, self.seller, 'processing', courier=self.courier)
        body = self.client_courier.get(MY_ORDERS_URL).json()
        self.assertTrue(body['success'])
        self.assertEqual(body['pagination']['count'], 26)
        self.assertEqual(len(body['data']), 20)
        self.assertIsNotNone(body['pagination']['next'])
        page2 = self.client_courier.get(MY_ORDERS_URL, {'page': 2}).json()
        self.assertEqual(len(page2['data']), 6)


# ---------------------------------------------------------------------------
# Courier transitions
# ---------------------------------------------------------------------------

class CourierTransitionTests(CourierTestBase):
    def setUp(self):
        super().setUp()
        self.order = make_order(self.buyer, self.seller, 'processing',
                                courier=self.courier, total_artifacts={'sprint': 3})

    def _patch(self, new_status, client=None, order=None, **extra):
        payload = {'status': new_status, **extra}
        return (client or self.client_courier).patch(
            f"{MY_ORDERS_URL}{(order or self.order).id}/", payload,
        )

    def test_every_permitted_transition_works(self):
        for source, target in (('processing', 'out_for_delivery'),
                               ('shipped', 'out_for_delivery'),
                               ('out_for_delivery', 'delivered'),
                               ('out_for_delivery', 'processing')):
            with self.subTest(source=source, target=target):
                order = make_order(self.buyer, self.seller, source, courier=self.courier)
                res = self._patch(target, order=order)
                self.assertEqual(res.status_code, status.HTTP_200_OK)
                order.refresh_from_db()
                self.assertEqual(order.status, target)

    def test_transition_writes_history_and_the_fulfillment_timeline(self):
        res = self._patch('out_for_delivery')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.order.refresh_from_db()
        self.assertEqual(self.order.status_history[-1]['status'], 'out_for_delivery')
        fulfillment = OrderFulfillment.objects.get(order=self.order)
        self.assertEqual(fulfillment.timeline[-1]['status'], 'out_for_delivery')
        self.assertIsNotNone(fulfillment.out_for_delivery_at)

    def test_transitions_outside_the_courier_map_are_rejected_by_name(self):
        for target in ('shipped', 'delivered', 'completed', 'cancelled', 'paid'):
            with self.subTest(target=target):
                res = self._patch(target)
                self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
                body = res.json()
                self.assertFalse(body['success'])
                self.assertIn(f'cannot move an order from processing to {target}', body['message'])
                self.assertIn('out_for_delivery', body['message'])
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'processing')

    def test_a_courier_cannot_skip_ahead_out_of_shipped_or_back_out_of_delivered(self):
        self.order.status = 'shipped'
        self.order.save(update_fields=['status'])
        # The seller's map allows shipped -> delivered. The courier's does not.
        self.assertEqual(self._patch('delivered').status_code, status.HTTP_400_BAD_REQUEST)

        self.order.status = 'delivered'
        self.order.save(update_fields=['status'])
        self.assertEqual(self._patch('processing').status_code, status.HTTP_400_BAD_REQUEST)

    def test_missing_or_unknown_status_is_a_400(self):
        res = self.client_courier.patch(f'{MY_ORDERS_URL}{self.order.id}/', {})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('status is required', res.json()['message'])
        res = self._patch('teleported')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('status must be one of', res.json()['message'])

    def test_cannot_touch_another_couriers_order(self):
        res = self._patch('out_for_delivery', client=self.client_other)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('not assigned to you', res.json()['message'])
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'processing')

    def test_a_non_courier_cannot_touch_the_order(self):
        """No courier row means the caller is not a courier at all — 404 with
        the registration pointer, the same gate every /delivery/* endpoint has."""
        res = self._patch('out_for_delivery', client=self.client_stranger)
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)
        self.assertIn('not registered as delivery personnel', res.json()['message'])
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'processing')

    def test_unknown_order_is_404(self):
        res = self.client_courier.patch(
            f'{MY_ORDERS_URL}00000000-0000-0000-0000-000000000000/',
            {'status': 'out_for_delivery'},
        )
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)

    def test_courier_cannot_set_carrier_tracking_or_pickup_station(self):
        for field, value in (('carrier', 'DHL'), ('tracking_number', 'TRK-1'),
                             ('tracking_url', 'https://tracker.example/TRK-1'),
                             ('pickup_location', 'Back door'),
                             ('pickup_station_id', str(self.shop.id)),
                             ('delivery_personnel_id', str(self.other_courier.id))):
            with self.subTest(field=field):
                res = self._patch('out_for_delivery', **{field: value})
                self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
                self.assertIn('shipping details', res.json()['message'])
                self.assertFalse(OrderFulfillment.objects.filter(order=self.order).exists())
                self.order.refresh_from_db()
                self.assertEqual(self.order.status, 'processing')

    def test_a_pickup_order_assigned_to_a_courier_is_refused(self):
        order = make_order(self.buyer, self.seller, 'processing',
                           fulfillment_type='pickup', courier=self.courier)
        res = self._patch('out_for_delivery', order=order)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('only handle delivery orders', res.json()['message'])

    def test_the_courier_map_never_exceeds_the_sellers(self):
        """A regression guard on the claim the whole endpoint rests on.

        Every courier move is either one the seller can also make, or the one
        documented exception — `out_for_delivery -> processing`, the parcel
        going back to the shop, which the seller's delivery table has no reason
        to allow. Anything else in `COURIER_TRANSITIONS` would mean a courier
        can do something a seller cannot, which is the bug to prevent.
        """
        from apps.marketplace.views import ORDER_TRANSITIONS_BY_FULFILLMENT

        seller_delivery = ORDER_TRANSITIONS_BY_FULFILLMENT['delivery']
        decline_edge = ('out_for_delivery', 'processing')

        for source, targets in COURIER_TRANSITIONS.items():
            self.assertIn(source, seller_delivery)
            for target in targets:
                self.assertIn(target, dict(Order.STATUS_CHOICES))
                self.assertTrue(
                    target in seller_delivery[source]
                    or (source, target) == decline_edge,
                    f'a courier may move {source} -> {target}, which the seller '
                    f'may not: {seller_delivery[source]}',
                )

    def test_the_courier_map_offers_no_cancellation_or_close_out(self):
        """Cancelling an order and marking it completed move money and close the
        ledger. Neither is a thing that happens on the road."""
        for targets in COURIER_TRANSITIONS.values():
            self.assertNotIn('cancelled', targets)
            self.assertNotIn('completed', targets)


# ---------------------------------------------------------------------------
# Earnings
# ---------------------------------------------------------------------------

class CourierEarningsTests(CourierTestBase):
    def _deliver(self, order):
        fulfillment, _ = OrderFulfillment.objects.get_or_create(order=order)
        fulfillment.delivered_at = timezone.now()
        fulfillment.save(update_fields=['delivered_at'])
        order.status = 'delivered'
        order.save(update_fields=['status'])

    def test_window_is_reported_back(self):
        order = make_order(self.buyer, self.seller, 'out_for_delivery',
                           courier=self.courier)
        self._deliver(order)
        res = self.client_courier.get(EARNINGS_URL)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()['data']
        self.assertIsNotNone(data['window']['from'])
        self.assertIsNotNone(data['window']['to'])
        self.assertFalse(data['window']['from_supplied'])
        self.assertFalse(data['window']['to_supplied'])
        self.assertFalse(data['is_payout'])
        self.assertIn('NOT a payout', data['note'])

    def test_window_from_is_null_when_there_is_nothing_to_bound_it_with(self):
        """Nothing delivered means no earliest delivery to report. `null` is the
        honest answer; inventing "the epoch" would be a lie the client renders."""
        make_order(self.buyer, self.seller, 'processing', courier=self.courier)
        data = self.client_courier.get(EARNINGS_URL).json()['data']
        self.assertIsNone(data['window']['from'])
        self.assertIsNotNone(data['window']['to'])

    def test_earnings_are_an_estimate_not_money(self):
        """Nothing here may be mistaken for a payable balance."""
        order = make_order(self.buyer, self.seller, 'out_for_delivery',
                           courier=self.courier, total_artifacts={'sprint': 20})
        self._deliver(order)
        data = self.client_courier.get(EARNINGS_URL).json()['data']
        self.assertEqual(data['delivered_count'], 1)
        self.assertEqual(data['delivered_value_artifacts'], {'sprint': 20})
        self.assertIs(data['is_payout'], False)
        self.assertNotIn('balance', data)
        self.assertNotIn('payout', data)
        self.assertNotIn('ledger', data)

    def test_commission_is_per_artifact_key_and_floors(self):
        """20 sprints + 3 barbells at 15%: 3.0 -> 3, 0.45 -> 0. Rounding down
        per key, never up and never carried between buckets."""
        self.courier.commission_rate = Decimal('0.15')
        self.courier.save(update_fields=['commission_rate'])
        order = make_order(self.buyer, self.seller, 'out_for_delivery',
                           courier=self.courier,
                           total_artifacts={'sprint': 20, 'barbell': 3})
        self._deliver(order)
        data = self.client_courier.get(EARNINGS_URL).json()['data']
        self.assertEqual(data['delivered_value_artifacts'], {'sprint': 20, 'barbell': 3})
        self.assertEqual(data['commission_artifacts'], {'sprint': 3, 'barbell': 0})
        self.assertEqual(data['commission_rate'], 0.15)

    def test_undelivered_and_other_couriers_orders_are_excluded(self):
        undelivered = make_order(self.buyer, self.seller, 'out_for_delivery',
                                 courier=self.courier, total_artifacts={'sprint': 5})
        self.assertIsNotNone(undelivered)
        delivered = make_order(self.buyer, self.seller, 'out_for_delivery',
                               courier=self.courier, total_artifacts={'sprint': 20})
        self._deliver(delivered)
        theirs = make_order(self.buyer, self.seller, 'out_for_delivery',
                            courier=self.other_courier, total_artifacts={'sprint': 99})
        self._deliver(theirs)

        data = self.client_courier.get(EARNINGS_URL).json()['data']
        self.assertEqual(data['delivered_count'], 1)
        self.assertEqual(data['delivered_value_artifacts'], {'sprint': 20})

    def test_completed_orders_count_as_delivered(self):
        order = make_order(self.buyer, self.seller, 'out_for_delivery',
                           courier=self.courier, total_artifacts={'sprint': 10})
        self._deliver(order)
        order.status = 'completed'
        order.save(update_fields=['status'])
        self.assertEqual(
            self.client_courier.get(EARNINGS_URL).json()['data']['delivered_count'], 1,
        )

    def test_the_window_actually_filters(self):
        recent = make_order(self.buyer, self.seller, 'out_for_delivery',
                            courier=self.courier, total_artifacts={'sprint': 10})
        self._deliver(recent)
        older = make_order(self.buyer, self.seller, 'out_for_delivery',
                           courier=self.courier, total_artifacts={'sprint': 10})
        fulfillment, _ = OrderFulfillment.objects.get_or_create(order=older)
        fulfillment.delivered_at = timezone.now() - timedelta(days=40)
        fulfillment.save(update_fields=['delivered_at'])
        older.status = 'delivered'
        older.save(update_fields=['status'])

        data = self.client_courier.get(
            EARNINGS_URL, {'from': (timezone.now() - timedelta(days=7)).date().isoformat()},
        ).json()['data']
        self.assertEqual(data['delivered_count'], 1)
        self.assertEqual(data['delivered_value_artifacts'], {'sprint': 10})
        self.assertTrue(data['window']['from_supplied'])

        everything = self.client_courier.get(EARNINGS_URL).json()['data']
        self.assertEqual(everything['delivered_count'], 2)

    def test_bad_window_values_are_rejected(self):
        for params in ({'from': 'yesterday'}, {'to': '2026-13-45'},
                       {'from': '2026-05-01', 'to': '2026-01-01'}):
            with self.subTest(params=params):
                res = self.client_courier.get(EARNINGS_URL, params)
                self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_a_courier_with_nothing_delivered_gets_zeroes_not_an_error(self):
        make_order(self.buyer, self.seller, 'processing', courier=self.courier)
        data = self.client_courier.get(EARNINGS_URL).json()['data']
        self.assertEqual(data['delivered_count'], 0)
        self.assertEqual(data['delivered_value_artifacts'], {})
        self.assertEqual(data['commission_artifacts'], {})


# ---------------------------------------------------------------------------
# Serialiser-level contract
# ---------------------------------------------------------------------------

class CourierCommissionUnitTests(CourierTestBase):
    def test_rounds_down_per_bucket_and_keeps_every_key(self):
        from apps.marketplace.serializers import estimate_commission_artifacts

        self.assertEqual(
            estimate_commission_artifacts({'sprint': 20, 'barbell': 3}, Decimal('0.15')),
            {'sprint': 3, 'barbell': 0},
        )
        self.assertEqual(
            estimate_commission_artifacts({'sprint': 7}, Decimal('0.5')),
            {'sprint': 3},  # 3.5 floors, it does not round to 4
        )
        self.assertEqual(estimate_commission_artifacts({'sprint': 10}, Decimal('0')), {'sprint': 0})
        self.assertEqual(estimate_commission_artifacts({}, Decimal('0.15')), {})
        self.assertEqual(estimate_commission_artifacts(None, Decimal('0.15')), {})

    def test_commission_artifacts_per_order_matches_the_rate(self):
        order = make_order(self.buyer, self.seller, 'processing',
                           courier=self.courier, total_artifacts={'sprint': 20, 'barbell': 3})
        self.courier.commission_rate = Decimal('0.15')
        self.courier.save(update_fields=['commission_rate'])
        order.refresh_from_db()
        row = self.client_courier.get(MY_ORDERS_URL).json()['data'][0]
        self.assertEqual(row['commission_artifacts'], {'sprint': 3, 'barbell': 0})