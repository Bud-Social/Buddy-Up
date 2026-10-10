"""What a seller may see of an order they share with other sellers.

An order is a basket: one buyer, many sellers, one order row. ``SellerOrdersView``
used to serialise the whole ``Order`` for every seller in it, which handed each
of them the other sellers' line items (their titles, unit prices and per-unit
paid amounts) and the order-wide money totals — the sum of everyone's revenue.

These tests pin the narrowed contract: a seller sees their own lines and the
order-level facts they need in order to ship, and nothing belonging to anybody
else. They also cover the two filters added alongside it (``fulfillment_type``
and ``payment_status``) and the seller-namespaced legacy path.
"""

from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.marketplace.models import Order, OrderItem, PickupStation, Shop, ShopMembership
from apps.profiles.models import Profile

SELLER_ORDERS_URL = '/api/v1/marketplace/orders/seller/'
CREATOR_ORDERS_URL = '/api/v1/marketplace/creator/orders/'


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


class SellerOrderVisibilityTests(TestCase):
    """Two sellers, one buyer, one order — the leak is between the sellers."""

    def setUp(self):
        self.owner = make_profile('sellershopowner')
        self.rival = make_profile('sellershiprival')
        self.bystander = make_profile('sellersidebystander')
        self.buyer = make_profile('sellerordersbuyer')

        self.shop = Shop.objects.create(name='Gear Shack', handle='gear-shack')
        ShopMembership.objects.create(shop=self.shop, profile=self.owner, role='owner')
        self.other_shop = Shop.objects.create(name='Rival Gear', handle='rival-gear')
        ShopMembership.objects.create(shop=self.other_shop, profile=self.rival, role='owner')

        self.order = Order.objects.create(
            buyer=self.buyer, status='paid', fulfillment_type='delivery',
            payment_method='mpesa', payment_status='pending', spent_usd='175.00',
            delivery_address={'line1': 'Mansion Road', 'city': 'Nairobi', 'phone': '+254700000000'},
        )
        # My line: 2 x 10 sprint. Theirs: 1 x 40 champion.
        self.mine = OrderItem.objects.create(
            order=self.order, item_type='product', title='My Whey', creator=self.owner,
            quantity=2, price_artifacts={'sprint': 10}, paid_artifacts={'sprint': 10},
        )
        self.theirs = OrderItem.objects.create(
            order=self.order, item_type='product', title='Their Secret Blend',
            creator=self.rival, quantity=1,
            price_artifacts={'champion': 40}, paid_artifacts={'champion': 40},
        )

    # -- line-item isolation -------------------------------------------------

    def test_list_shows_only_the_callers_own_items(self):
        res = client_for(self.owner).get(SELLER_ORDERS_URL)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        rows = res.json()['data']
        self.assertEqual(len(rows), 1)
        order = rows[0]
        self.assertEqual([i['title'] for i in order['items']], ['My Whey'])
        self.assertNotIn('Their Secret Blend', str(order))

    def test_the_other_seller_sees_their_own_line_not_mine(self):
        order = client_for(self.rival).get(SELLER_ORDERS_URL).json()['data'][0]
        self.assertEqual([i['title'] for i in order['items']], ['Their Secret Blend'])
        self.assertNotIn('My Whey', str(order))

    def test_no_other_sellers_row_leaks_through_any_field(self):
        """The whole payload, not just ``items``, must be free of the rival's
        line. A leak through ``total_artifacts`` is as much a leak as one
        through a title."""
        order = client_for(self.owner).get(SELLER_ORDERS_URL).json()['data'][0]
        self.assertNotIn('champion', str(order))
        self.assertEqual(order['total_artifacts'], {'sprint': 10})
        self.assertEqual(order['items_total_artifacts'], {'sprint': 10})
        self.assertEqual(order['spent_usd'], 50.0)
        self.assertEqual(order['items_count'], 1)
        self.assertNotIn('Their Secret Blend', str(order['discount_artifacts']))
        self.assertNotIn('Their Secret Blend', str(order['status_history']))

    def test_order_wide_totals_are_narrowed_to_the_callers_lines(self):
        # 10 sprints @ $5.00 each. The order as a whole is worth $175; the other
        # seller's 1 champion ($25) must not appear in this seller's figures.
        order = client_for(self.owner).get(SELLER_ORDERS_URL).json()['data'][0]
        self.assertEqual(order['spent_usd'], 50.0)

    def test_detail_endpoint_is_not_a_way_around_the_list_filter(self):
        res = client_for(self.owner).get(f'/api/v1/marketplace/orders/{self.order.id}/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        order = res.json()['data']
        self.assertEqual([i['title'] for i in order['items']], ['My Whey'])
        self.assertNotIn('Their Secret Blend', str(order))
        self.assertEqual(order['total_artifacts'], {'sprint': 10})

    def test_seller_keeps_what_they_need_to_ship(self):
        """Narrowing must not take away the facts fulfilment depends on."""
        order = client_for(self.owner).get(SELLER_ORDERS_URL).json()['data'][0]
        self.assertEqual(order['status'], 'paid')
        self.assertEqual(order['fulfillment_type'], 'delivery')
        self.assertEqual(order['order_number'], self.order.order_number)
        self.assertEqual(order['delivery_address']['line1'], 'Mansion Road')
        self.assertEqual(order['payment_status'], 'pending')
        self.assertEqual(order['payment_method'], 'mpesa')

    def test_is_seller_flag_is_true_for_the_caller(self):
        order = client_for(self.owner).get(SELLER_ORDERS_URL).json()['data'][0]
        self.assertTrue(order['is_seller'])

    # -- who is in the list at all ------------------------------------------

    def test_buyer_is_not_a_seller(self):
        res = client_for(self.buyer).get(SELLER_ORDERS_URL)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(len(res.json()['data']), 0)

    def test_profile_that_sells_nothing_gets_nothing(self):
        res = client_for(self.bystander).get(SELLER_ORDERS_URL)
        self.assertEqual(res.json()['data'], [])

    def test_a_complete_stranger_cannot_read_the_order(self):
        res = client_for(self.bystander).get(f'/api/v1/marketplace/orders/{self.order.id}/')
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_the_list_requires_authentication(self):
        res = APIClient().get(SELLER_ORDERS_URL)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_legacy_creator_path_serves_the_same_rows(self):
        rows = client_for(self.owner).get(CREATOR_ORDERS_URL).json()['data']
        self.assertEqual([i['title'] for i in rows[0]['items']], ['My Whey'])

    # -- filters -------------------------------------------------------------

    def test_fulfillment_and_payment_status_filters(self):
        client = client_for(self.owner)
        res = client.get(SELLER_ORDERS_URL, {'fulfillment_type': 'delivery'})
        self.assertEqual(len(res.json()['data']), 1)
        res = client.get(SELLER_ORDERS_URL, {'fulfillment_type': 'pickup'})
        self.assertEqual(len(res.json()['data']), 0)
        res = client.get(SELLER_ORDERS_URL, {'payment_status': 'paid'})
        self.assertEqual(len(res.json()['data']), 0)
        res = client.get(SELLER_ORDERS_URL, {'payment_status': 'pending'})
        self.assertEqual(len(res.json()['data']), 1)
        res = client.get(SELLER_ORDERS_URL, {'status': 'paid'})
        self.assertEqual(len(res.json()['data']), 1)

    def test_unknown_filter_values_are_rejected_rather_than_ignored(self):
        client = client_for(self.owner)
        res = client.get(SELLER_ORDERS_URL, {'fulfillment_type': 'teleport'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        res = client.get(SELLER_ORDERS_URL, {'payment_status': 'bogus'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_filters_combine(self):
        client = client_for(self.owner)
        res = client.get(SELLER_ORDERS_URL, {'fulfillment_type': 'delivery',
                                             'payment_status': 'pending'})
        self.assertEqual(len(res.json()['data']), 1)
        res = client.get(SELLER_ORDERS_URL, {'fulfillment_type': 'delivery',
                                             'payment_status': 'paid'})
        self.assertEqual(len(res.json()['data']), 0)

    # -- station / courier columns the seller UI reads -----------------------

    def test_pickup_station_is_reported_when_set(self):
        station = PickupStation.objects.create(shop=self.shop, name='Westlands Counter')
        self.order.pickup_station = station
        self.order.fulfillment_type = 'pickup'
        self.order.save(update_fields=['pickup_station', 'fulfillment_type'])
        order = client_for(self.owner).get(SELLER_ORDERS_URL).json()['data'][0]
        self.assertEqual(order['pickup_station'], str(station.id))
        self.assertIsNone(order['delivery_personnel'])
    def test_unknown_status_filter_is_rejected_not_silently_ignored(self):
        """A status from the wrong vocabulary must report itself.

        The web admin shipped a filter chip sending `refunded` (a
        payment_status) here, and because `status` was never validated the
        query matched nothing and the seller saw an empty list.
        """
        client = client_for(self.owner)
        for bad in ('refunded', 'confirmed', 'teleported', 'unpaid', 'failed'):
            with self.subTest(status=bad):
                res = client.get(SELLER_ORDERS_URL, {'status': bad})
                self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertIn('status must be one of', res.json()['message'])

    def test_every_real_order_status_is_accepted(self):
        from apps.marketplace.models import Order
        client = client_for(self.owner)
        for good in dict(Order.STATUS_CHOICES):
            with self.subTest(status=good):
                res = client.get(SELLER_ORDERS_URL, {'status': good})
                self.assertEqual(res.status_code, status.HTTP_200_OK)
