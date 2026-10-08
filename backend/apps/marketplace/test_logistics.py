"""Endpoint-level tests for pickup stations, couriers and order logistics.

Companion to ``test_fulfillment_models.py`` (which pins the model/DB
invariants). Everything here goes through the HTTP API, so what is being tested
is the behaviour a seller or buyer actually gets: who may write a station, what
the nearby list looks like, which status transitions a pickup order is allowed,
and what a seller sees of a shared order.
"""

from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.gyms.models import Gym, GymMembership
from apps.marketplace.models import (
    DeliveryPersonnel,
    Order,
    OrderItem,
    PickupStation,
    Product,
    Shop,
    ShopMembership,
    StationApplication,
    DeliveryPersonnelApplication,
)
from apps.profiles.models import Profile


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


class LogisticsTestBase(TestCase):
    def setUp(self):
        self.owner = make_profile('shopowner')
        self.other_owner = make_profile('otherowner')
        self.starting_balance = {'champion': 10, 'dumbbell': 10, 'sprint': 10}
        self.buyer = make_profile('logisticsbuyer', self.starting_balance)
        self.outsider = make_profile('outsider')

        self.shop = Shop.objects.create(name='Gear Shack', handle='gear-shack', verification_status='verified')
        ShopMembership.objects.create(shop=self.shop, profile=self.owner, role='owner')
        self.other_shop = Shop.objects.create(name='Rival Gear', handle='rival-gear')
        ShopMembership.objects.create(shop=self.other_shop, profile=self.other_owner, role='owner')

        self.gym = Gym.objects.create(name='Iron Temple', handle='iron-temple', category='fitness',
                                      access_type='public')
        self.gym_owner = make_profile('gymowner')
        GymMembership.objects.create(gym=self.gym, member=self.gym_owner, role='owner')
        self.gym_trainer = make_profile('gymtrainer')
        GymMembership.objects.create(gym=self.gym, member=self.gym_trainer, role='trainer')

        self.stations_url = '/api/v1/marketplace/stations/'


# ---------------------------------------------------------------------------
# Station discovery
# ---------------------------------------------------------------------------

class StationListTests(LogisticsTestBase):
    def setUp(self):
        super().setUp()
        self.near = PickupStation.objects.create(
            shop=self.shop, name='Westlands Counter', city='Nairobi',
            latitude=-1.2599, longitude=36.7936,
        )
        self.far = PickupStation.objects.create(
            shop=self.other_shop, name='Mombasa Depot', city='Mombasa',
            latitude=-4.0435, longitude=39.6692,
        )
        self.closed = PickupStation.objects.create(
            shop=self.shop, name='Closed Counter', city='Nairobi', is_active=False,
        )
        self.gym_station = PickupStation.objects.create(
            gym=self.gym, name='Iron Temple Reception', city='Nairobi',
            latitude=-1.2800, longitude=36.8100,
        )
        self.client = APIClient()

    def test_list_returns_active_stations_only(self):
        res = self.client.get(self.stations_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        names = {row['name'] for row in res.json()['data']}
        self.assertIn('Westlands Counter', names)
        self.assertIn('Iron Temple Reception', names)
        self.assertNotIn('Closed Counter', names)

    def test_distance_is_absent_without_coordinates(self):
        res = self.client.get(self.stations_url)
        self.assertIsNone(res.json()['geo'])
        for row in res.json()['data']:
            # Absent, not null: clients switch on presence, so a permanent
            # `distance_km: null` would be indistinguishable from distance 0.
            self.assertNotIn('distance_km', row)

    def test_lat_lng_returns_nearest_first_with_distance(self):
        res = self.client.get(self.stations_url, {'lat': '-1.2600', 'lng': '36.7936', 'radius_km': '50'})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        body = res.json()
        rows = body['data']
        self.assertEqual(rows[0]['name'], 'Westlands Counter')
        self.assertLess(rows[0]['distance_km'], 0.1)
        self.assertEqual(rows[1]['name'], 'Iron Temple Reception')
        self.assertLess(rows[0]['distance_km'], rows[1]['distance_km'])
        # Mombasa is far outside the bbox, so a 50 km radius excludes it.
        self.assertNotIn('Mombasa Depot', {r['name'] for r in rows})
        self.assertEqual(body['geo']['radius_km'], 50)
        self.assertFalse(body['geo']['auto'])

    def test_radius_is_clamped_to_the_documented_bounds(self):
        res = self.client.get(self.stations_url, {'lat': '-1.26', 'lng': '36.79', 'radius_km': '99999'})
        self.assertEqual(res.json()['geo']['radius_km'], 200)
        res = self.client.get(self.stations_url, {'lat': '-1.26', 'lng': '36.79', 'radius_km': '0'})
        self.assertEqual(res.json()['geo']['radius_km'], 1)

    def test_adaptive_radius_is_reported_when_radius_not_given(self):
        res = self.client.get(self.stations_url, {'lat': '-1.26', 'lng': '36.79'})
        geo = res.json()['geo']
        self.assertTrue(geo['auto'])
        self.assertIn(geo['density'], ('dense', 'sparse'))
        self.assertIsNotNone(geo['message'])

    def test_owner_type_and_text_filters(self):
        res = self.client.get(self.stations_url, {'owner_type': 'gym'})
        self.assertEqual({r['name'] for r in res.json()['data']}, {'Iron Temple Reception'})
        res = self.client.get(self.stations_url, {'q': 'mombasa'})
        self.assertEqual({r['name'] for r in res.json()['data']}, {'Mombasa Depot'})
        res = self.client.get(self.stations_url, {'owner_type': 'warehouse'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_detail_hides_inactive_stations_from_strangers(self):
        res = self.client.get(f'{self.stations_url}{self.closed.id}/')
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)
        res = client_for(self.owner).get(f'{self.stations_url}{self.closed.id}/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_detail_reports_distance_when_coordinates_are_sent(self):
        res = self.client.get(
            f'{self.stations_url}{self.near.id}/', {'lat': '-1.2600', 'lng': '36.7936'},
        )
        self.assertLess(res.json()['data']['distance_km'], 0.1)

    def test_detail_without_coordinates_has_no_distance(self):
        res = self.client.get(f'{self.stations_url}{self.near.id}/')
        self.assertNotIn('distance_km', res.json()['data'])


# ---------------------------------------------------------------------------
# Station ownership
# ---------------------------------------------------------------------------

class StationWritePermissionTests(LogisticsTestBase):
    def _payload(self, **overrides):
        payload = {'shop': str(self.shop.id), 'name': 'Counter', 'city': 'Nairobi'}
        payload.update(overrides)
        return payload

    def test_shop_manager_may_create_a_station(self):
        staff = make_profile('shopmanager')
        ShopMembership.objects.create(shop=self.shop, profile=staff, role='manager')
        res = client_for(staff).post(self.stations_url, self._payload(), format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        self.assertEqual(res.json()['data']['owner_type'], 'shop')

    def test_shop_staff_member_may_not_create_a_station(self):
        staff = make_profile('shopstaff')
        ShopMembership.objects.create(shop=self.shop, profile=staff, role='staff')
        res = client_for(staff).post(self.stations_url, self._payload(), format='json')
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_non_owner_cannot_create_a_station_for_someone_elses_shop(self):
        res = client_for(self.outsider).post(self.stations_url, self._payload(), format='json')
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(PickupStation.objects.count(), 0)

    def test_gym_owner_and_co_owner_may_create_a_station(self):
        for role in ('co_owner',):
            co_owner = make_profile(f'gym{role}')
            GymMembership.objects.create(gym=self.gym, member=co_owner, role=role)
            res = client_for(co_owner).post(
                self.stations_url, {'gym': str(self.gym.id), 'name': f'{role} station'}, format='json',
            )
            self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        res = client_for(self.gym_owner).post(
            self.stations_url, {'gym': str(self.gym.id), 'name': 'Owner station'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)

    def test_gym_trainer_may_not_create_a_station(self):
        res = client_for(self.gym_trainer).post(
            self.stations_url, {'gym': str(self.gym.id), 'name': 'Trainer station'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_update_rejected_for_a_non_owner(self):
        station = PickupStation.objects.create(shop=self.shop, name='Counter')
        res = client_for(self.outsider).patch(
            f'{self.stations_url}{station.id}/', {'name': 'Hijacked'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        station.refresh_from_db()
        self.assertEqual(station.name, 'Counter')

    def test_update_allowed_for_the_right_shop_owner(self):
        station = PickupStation.objects.create(shop=self.shop, name='Counter')
        res = client_for(self.owner).patch(
            f'{self.stations_url}{station.id}/', {'name': 'Rear Counter'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        station.refresh_from_db()
        self.assertEqual(station.name, 'Rear Counter')

    def test_owner_cannot_be_reparented(self):
        station = PickupStation.objects.create(shop=self.shop, name='Counter')
        for field, value in (('shop', str(self.other_shop.id)), ('owner_type', 'gym')):
            with self.subTest(field=field):
                res = client_for(self.owner).patch(
                    f'{self.stations_url}{station.id}/', {field: value}, format='json',
                )
                self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        station.refresh_from_db()
        self.assertEqual(station.shop_id, self.shop.id)
        self.assertEqual(station.owner_type, 'shop')


class StationApplicationTests(LogisticsTestBase):
    url = '/api/v1/marketplace/station-applications/'

    def test_shop_owner_drafts_then_submits(self):
        client = client_for(self.owner)
        res = client.post(self.url, {'shop': str(self.shop.id), 'city': 'Nairobi'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        app = StationApplication.objects.get()
        self.assertEqual(app.status, 'draft')
        self.assertEqual(app.submitted_by, self.owner)

        res = client.post(
            f'{self.url}?submit=true',
            {'shop': str(self.shop.id), 'contact_phone': '+254700000000'},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        app.refresh_from_db()
        self.assertEqual(app.status, 'submitted')
        self.assertEqual(app.contact_phone, '+254700000000')
        # One draft per applicant: submitting reuses the same row.
        self.assertEqual(StationApplication.objects.count(), 1)

    def test_submission_notifies_the_shop_owner(self):
        from apps.notifications.models import Notification

        client_for(self.owner).post(
            f'{self.url}?submit=true', {'shop': str(self.shop.id)}, format='json',
        )
        self.assertTrue(Notification.objects.filter(
            recipient=self.owner, notification_type='verification_update',
        ).exists())

    def test_outsider_cannot_apply_for_someone_elses_shop(self):
        res = client_for(self.outsider).post(self.url, {'shop': str(self.shop.id)}, format='json')
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(StationApplication.objects.count(), 0)

    def test_gym_owner_applies_for_their_gym(self):
        res = client_for(self.gym_owner).post(
            f'{self.url}?submit=true', {'gym': str(self.gym.id), 'city': 'Nairobi'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        self.assertEqual(StationApplication.objects.get().gym_id, self.gym.id)


class DeliveryPersonnelSelfServiceTests(LogisticsTestBase):
    url = '/api/v1/marketplace/delivery-personnel/'

    def test_user_registers_themselves(self):
        res = client_for(self.buyer).post(
            self.url, {'vehicle_type': 'motorbike', 'service_zones': ['Westlands']}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        personnel = DeliveryPersonnel.objects.get(profile=self.buyer)
        self.assertEqual(personnel.vehicle_type, 'motorbike')
        self.assertEqual(personnel.service_zones, ['Westlands'])

    def test_second_call_updates_rather_than_duplicates(self):
        client = client_for(self.buyer)
        client.post(self.url, {'vehicle_type': 'bike'}, format='json')
        res = client.post(self.url, {'vehicle_type': 'tuktuk', 'bio': 'Fast'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        self.assertEqual(DeliveryPersonnel.objects.filter(profile=self.buyer).count(), 1)
        self.assertEqual(DeliveryPersonnel.objects.get(profile=self.buyer).vehicle_type, 'tuktuk')

    def test_invalid_vehicle_type_is_rejected(self):
        res = client_for(self.buyer).post(self.url, {'vehicle_type': 'hovercraft'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('vehicle_type', res.json()['errors'])
        self.assertEqual(DeliveryPersonnel.objects.count(), 0)

    def test_cannot_write_another_users_courier_record(self):
        victim = make_profile('victimcourier')
        DeliveryPersonnel.objects.create(profile=victim, vehicle_type='bike')
        res = client_for(self.outsider).post(
            self.url, {'profile': str(victim.pk), 'vehicle_type': 'lorry'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        victim_record = DeliveryPersonnel.objects.get(profile=victim)
        self.assertEqual(victim_record.vehicle_type, 'bike')


class DeliveryPersonnelApplicationTests(LogisticsTestBase):
    url = '/api/v1/marketplace/delivery-personnel-applications/'

    def test_draft_then_submit(self):
        client = client_for(self.buyer)
        res = client.post(self.url, {'vehicle_type': 'bike', 'phone': '+254711111111'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        self.assertEqual(DeliveryPersonnelApplication.objects.get().status, 'draft')

        res = client.post(f'{self.url}?submit=true', {'service_zones': ['Kilimani']}, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        app = DeliveryPersonnelApplication.objects.get()
        self.assertEqual(app.status, 'submitted')
        self.assertEqual(app.service_zones, ['Kilimani'])
        self.assertEqual(app.profile, self.buyer)

    def test_cannot_apply_on_behalf_of_someone_else(self):
        res = client_for(self.outsider).post(
            self.url, {'profile': str(self.owner.pk), 'vehicle_type': 'bike'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(DeliveryPersonnelApplication.objects.count(), 0)


# ---------------------------------------------------------------------------
# Courier assignment
# ---------------------------------------------------------------------------

class CourierAssignmentTests(LogisticsTestBase):
    def setUp(self):
        super().setUp()
        self.order = Order.objects.create(
            buyer=self.buyer, status='paid', fulfillment_type='delivery',
            delivery_address={'line1': 'Mansion Road', 'city': 'Nairobi',
                              'latitude': -1.2833, 'longitude': 36.8172},
        )
        OrderItem.objects.create(
            order=self.order, item_type='product', title='My Whey', creator=self.owner,
        )
        self.active_bike = DeliveryPersonnel.objects.create(
            profile=make_profile('bikebuddy'), vehicle_type='bike', service_zones=['Westlands'],
        )
        self.active_lorry = DeliveryPersonnel.objects.create(
            profile=make_profile('lorrybuddy'), vehicle_type='lorry', rating='4.50',
        )
        self.retired = DeliveryPersonnel.objects.create(
            profile=make_profile('retiredbuddy'), vehicle_type='car', is_active=False,
        )
        self.couriers_url = f'/api/v1/marketplace/orders/{self.order.id}/couriers/'
        self.fulfillment_url = f'/api/v1/marketplace/orders/{self.order.id}/fulfillment/'

    def test_courier_list_excludes_inactive_personnel(self):
        res = client_for(self.owner).get(self.couriers_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        ids = {row['id'] for row in res.json()['data']['couriers']}
        self.assertEqual(ids, {str(self.active_bike.id), str(self.active_lorry.id)})

    def test_courier_list_is_grouped_by_vehicle_type(self):
        data = client_for(self.owner).get(self.couriers_url).json()['data']
        groups = {g['vehicle_type']: g['count'] for g in data['by_vehicle']}
        self.assertEqual(groups, {'bike': 1, 'lorry': 1})
        bike = next(g for g in data['by_vehicle'] if g['vehicle_type'] == 'bike')
        row = bike['couriers'][0]
        self.assertEqual(row['service_zones'], ['Westlands'])
        self.assertIsNotNone(row['display_name'])
        self.assertIn('vehicle_label', row)

    def test_courier_list_reports_origin_and_distance(self):
        data = client_for(self.owner).get(self.couriers_url).json()['data']
        self.assertEqual(data['origin'], {'lat': -1.2833, 'lng': 36.8172})
        # No courier has an opted-in search profile, so no distance is measured
        # and the key is omitted rather than nulled.
        for row in data['couriers']:
            self.assertNotIn('distance_km', row)

    def test_couriers_without_buyer_coordinates_omit_distance(self):
        self.order.delivery_address = {'line1': 'Mansion Road', 'city': 'Nairobi'}
        self.order.save(update_fields=['delivery_address'])
        data = client_for(self.owner).get(self.couriers_url).json()['data']
        self.assertIsNone(data['origin'])
        for row in data['couriers']:
            self.assertNotIn('distance_km', row)

    def test_buyer_cannot_read_the_courier_list(self):
        res = client_for(self.buyer).get(self.couriers_url)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_seller_assigns_an_active_courier(self):
        res = client_for(self.owner).patch(
            self.fulfillment_url, {'delivery_personnel_id': str(self.active_lorry.id)}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        self.order.refresh_from_db()
        self.assertEqual(self.order.delivery_personnel_id, self.active_lorry.id)

    def test_assigning_an_inactive_courier_is_rejected(self):
        res = client_for(self.owner).patch(
            self.fulfillment_url, {'delivery_personnel_id': str(self.retired.id)}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('not an active courier', res.json()['message'])
        self.order.refresh_from_db()
        self.assertIsNone(self.order.delivery_personnel_id)

    def test_assigning_an_unknown_courier_is_rejected(self):
        res = client_for(self.owner).patch(
            self.fulfillment_url,
            {'delivery_personnel_id': '00000000-0000-0000-0000-000000000000'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('does not exist', res.json()['message'])

    def test_non_seller_cannot_assign_a_courier(self):
        res = client_for(self.outsider).patch(
            self.fulfillment_url, {'delivery_personnel_id': str(self.active_bike.id)}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_inactive_pickup_station_cannot_be_assigned(self):
        closed = PickupStation.objects.create(shop=self.shop, name='Closed', is_active=False)
        res = client_for(self.owner).patch(
            self.fulfillment_url, {'pickup_station_id': str(closed.id)}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('not an active pickup station', res.json()['message'])

    def test_active_pickup_station_can_be_assigned(self):
        station = PickupStation.objects.create(shop=self.shop, name='Open Counter')
        res = client_for(self.owner).patch(
            self.fulfillment_url, {'pickup_station_id': str(station.id)}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        self.order.refresh_from_db()
        self.assertEqual(self.order.pickup_station_id, station.id)

    def test_rejected_transition_does_not_apply_the_assignment_sent_with_it(self):
        # The whole PATCH is one request: a caller may send a courier *and* an
        # illegal status in the same body. The courier must not stick.
        self.order.fulfillment_type = 'pickup'
        self.order.save(update_fields=['fulfillment_type'])
        res = client_for(self.owner).patch(
            self.fulfillment_url,
            {'delivery_personnel_id': str(self.active_bike.id), 'status': 'out_for_delivery'},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.order.refresh_from_db()
        self.assertIsNone(self.order.delivery_personnel_id)
        self.assertEqual(self.order.status, 'paid')

    def test_couriers_are_reachable_under_the_seller_namespaced_path(self):
        # Both spellings exist so a client built against either resolves.
        for url in (self.couriers_url, f'/api/v1/marketplace/orders/seller/{self.order.id}/couriers/'):
            with self.subTest(url=url):
                res = client_for(self.owner).get(url)
                self.assertEqual(res.status_code, status.HTTP_200_OK)
                self.assertEqual(res.json()['data']['order_id'], str(self.order.id))


# ---------------------------------------------------------------------------
# Fulfillment-aware state machine
# ---------------------------------------------------------------------------

class FulfillmentTransitionTests(LogisticsTestBase):
    def setUp(self):
        super().setUp()
        self.buyer_client = client_for(self.buyer)
        self.seller_client = client_for(self.owner)
        self.other_seller_client = client_for(self.other_owner)

    def _order(self, fulfillment_type, status_='paid'):
        order = Order.objects.create(
            buyer=self.buyer, fulfillment_type=fulfillment_type, status=status_,
        )
        OrderItem.objects.create(
            order=order, item_type='product', title='Item', creator=self.owner,
        )
        return order

    def _move(self, order, new_status):
        return self.seller_client.patch(
            f'/api/v1/marketplace/orders/{order.id}/fulfillment/',
            {'status': new_status}, format='json',
        )

    def test_pickup_order_rejects_out_for_delivery(self):
        order = self._order('pickup')
        res = self._move(order, 'out_for_delivery')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('from paid to out_for_delivery', res.json()['message'])
        self.assertIn('pickup', res.json()['message'])
        order.refresh_from_db()
        self.assertEqual(order.status, 'paid')

    def test_pickup_order_rejects_shipped(self):
        order = self._order('pickup')
        self.assertEqual(self._move(order, 'shipped').status_code, status.HTTP_400_BAD_REQUEST)

    def test_pickup_order_may_use_ready_for_pickup_and_delivered(self):
        order = self._order('pickup')
        self.assertEqual(self._move(order, 'ready_for_pickup').status_code, status.HTTP_200_OK)
        order.refresh_from_db()
        self.assertEqual(order.status, 'ready_for_pickup')
        self.assertEqual(self._move(order, 'delivered').status_code, status.HTTP_200_OK)
        order.refresh_from_db()
        self.assertEqual(order.status, 'delivered')
        self.assertEqual(self._move(order, 'completed').status_code, status.HTTP_200_OK)

    def test_digital_order_rejects_shipped_and_out_for_delivery(self):
        for target in ('shipped', 'out_for_delivery'):
            with self.subTest(target=target):
                order = self._order('digital')
                res = self._move(order, target)
                self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertIn(f'from paid to {target}', res.json()['message'])
                self.assertIn('digital', res.json()['message'])

    def test_digital_order_walks_paid_processing_completed(self):
        order = self._order('digital')
        self.assertEqual(self._move(order, 'processing').status_code, status.HTTP_200_OK)
        self.assertEqual(self._move(order, 'completed').status_code, status.HTTP_200_OK)
        order.refresh_from_db()
        self.assertEqual(order.status, 'completed')

    def test_delivery_order_accepts_the_transport_states(self):
        for source, target in (('paid', 'shipped'), ('shipped', 'out_for_delivery'),
                               ('out_for_delivery', 'delivered')):
            with self.subTest(source=source, target=target):
                order = self._order('delivery', status_=source)
                res = self._move(order, target)
                self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
                order.refresh_from_db()
                self.assertEqual(order.status, target)

    def test_delivery_order_rejects_ready_for_pickup(self):
        order = self._order('delivery')
        res = self._move(order, 'ready_for_pickup')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('ready_for_pickup', res.json()['message'])

    def test_every_fulfillment_type_may_be_cancelled(self):
        for fulfillment_type in ('digital', 'pickup', 'delivery'):
            with self.subTest(fulfillment_type=fulfillment_type):
                order = self._order(fulfillment_type)
                self.assertEqual(self._move(order, 'cancelled').status_code, status.HTTP_200_OK)
                order.refresh_from_db()
                self.assertEqual(order.status, 'cancelled')

    def test_completed_order_cannot_be_reopened(self):
        order = self._order('digital', status_='completed')
        res = self._move(order, 'paid')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('from completed to paid', res.json()['message'])

    def test_buyer_confirm_receipt_rule_is_intact(self):
        order = self._order('delivery', status_='out_for_delivery')
        res = self.buyer_client.patch(
            f'/api/v1/marketplace/orders/{order.id}/fulfillment/',
            {'status': 'delivered'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        order.refresh_from_db()
        self.assertEqual(order.status, 'delivered')
        # ...and nothing else.
        order2 = self._order('delivery', status_='paid')
        res = self.buyer_client.patch(
            f'/api/v1/marketplace/orders/{order2.id}/fulfillment/',
            {'status': 'shipped'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)


# ---------------------------------------------------------------------------
# Checkout: payment rails and fulfillment validation
# ---------------------------------------------------------------------------

class CheckoutPaymentRailTests(LogisticsTestBase):
    def setUp(self):
        super().setUp()
        self.product = Product.objects.create(
            name='Whey', brand='Shack', category='supplement', affiliate_url='https://example.test',
            shop=self.shop, recommended_by=self.owner,
            delivery_modes=['digital', 'pickup', 'delivery'],
        )
        self.buyer_client = client_for(self.buyer)

    def _cart(self):
        return self.buyer_client.post(
            '/api/v1/marketplace/cart/',
            {'item_type': 'product', 'product_id': str(self.product.id), 'quantity': 1},
            format='json',
        )

    def test_mpesa_checkout_does_not_deduct_artifacts_and_stays_pending(self):
        # A product priced in artifacts is free here (products have no
        # artifact price), so give the order a priced programme instead.
        from apps.marketplace.models import TrainingProgramme

        programme = TrainingProgramme.objects.create(
            creator=self.owner, shop=self.shop, title='Push', category='strength',
            price_artifacts={'champion': 4},
        )
        self.buyer_client.post(
            '/api/v1/marketplace/cart/',
            {'item_type': 'programme', 'programme_id': str(programme.id), 'quantity': 1},
            format='json',
        )
        res = self.buyer_client.post(
            '/api/v1/marketplace/cart/checkout/',
            {'fulfillment_type': 'digital', 'payment_method': 'mpesa'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        self.buyer.refresh_from_db()
        self.assertEqual(self.buyer.artifact_balance, self.starting_balance, 'nothing may be deducted')
        order = Order.objects.get(buyer=self.buyer)
        self.assertEqual(order.payment_status, 'pending')
        self.assertEqual(order.payment_method, 'mpesa')
        self.assertEqual(order.status, 'pending')
        self.assertIsNone(order.paid_at)
        self.assertEqual(res.json()['data']['payment_status'], 'pending')
        self.assertEqual(res.json()['data']['payment_method'], 'mpesa')
        self.assertTrue(res.json()['data']['payment_required'])

    def test_artifacts_checkout_is_unchanged(self):
        from apps.marketplace.models import TrainingProgramme

        programme = TrainingProgramme.objects.create(
            creator=self.owner, shop=self.shop, title='Push', category='strength',
            price_artifacts={'champion': 4},
        )
        self.buyer_client.post(
            '/api/v1/marketplace/cart/',
            {'item_type': 'programme', 'programme_id': str(programme.id), 'quantity': 1},
            format='json',
        )
        res = self.buyer_client.post('/api/v1/marketplace/cart/checkout/', {}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        self.buyer.refresh_from_db()
        self.assertEqual(
            self.buyer.artifact_balance,
            {**self.starting_balance, 'champion': self.starting_balance['champion'] - 4},
        )
        order = Order.objects.get(buyer=self.buyer)
        self.assertEqual(order.payment_status, 'paid')
        self.assertEqual(order.payment_method, 'artifacts')
        self.assertEqual(order.status, 'paid')
        self.assertIsNotNone(order.paid_at)
        self.assertEqual(res.json()['data']['payment_status'], 'paid')
        # The subscription is provisioned because artifacts settled instantly.
        self.assertTrue(programme.purchases.filter(buyer=self.buyer).exists())

    def test_digital_only_product_rejects_delivery_checkout(self):
        self.product.delivery_modes = ['digital']
        self.product.save(update_fields=['delivery_modes'])
        self._cart()
        res = self.buyer_client.post(
            '/api/v1/marketplace/cart/checkout/',
            {'fulfillment_type': 'delivery', 'delivery_address': {'line1': 'Mansion Road'}},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('digital only', res.json()['message'])
        self.assertEqual(Order.objects.count(), 0)

    def test_delivery_checkout_requires_an_address(self):
        self._cart()
        res = self.buyer_client.post(
            '/api/v1/marketplace/cart/checkout/', {'fulfillment_type': 'delivery'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('delivery address', res.json()['message'])

    def test_pickup_checkout_requires_an_active_station(self):
        self._cart()
        res = self.buyer_client.post(
            '/api/v1/marketplace/cart/checkout/', {'fulfillment_type': 'pickup'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('pickup station', res.json()['message'])

        closed = PickupStation.objects.create(shop=self.shop, name='Closed', is_active=False)
        res = self.buyer_client.post(
            '/api/v1/marketplace/cart/checkout/',
            {'fulfillment_type': 'pickup', 'pickup_station_id': str(closed.id)}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('not an active pickup station', res.json()['message'])

    def test_pickup_checkout_persists_the_station(self):
        station = PickupStation.objects.create(shop=self.shop, name='Open Counter', city='Nairobi')
        self._cart()
        res = self.buyer_client.post(
            '/api/v1/marketplace/cart/checkout/',
            {'fulfillment_type': 'pickup', 'pickup_station_id': str(station.id)}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        order = Order.objects.get(buyer=self.buyer)
        self.assertEqual(order.pickup_station_id, station.id)
        self.assertEqual(res.json()['data']['pickup_station_id'], str(station.id))

    def test_unknown_payment_method_is_rejected(self):
        self._cart()
        res = self.buyer_client.post(
            '/api/v1/marketplace/cart/checkout/', {'payment_method': 'bitcoin'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class PaymentIntentEndpointTests(LogisticsTestBase):
    def setUp(self):
        super().setUp()
        self.order = Order.objects.create(
            buyer=self.buyer, status='pending', spent_usd='500.00',
            payment_method='mpesa', payment_status='pending',
        )
        self.url = '/api/v1/marketplace/orders/payment-intents/'

    def test_no_credentials_records_an_initiated_intent_and_calls_no_provider(self):
        with self.settings(FLUTTERWAVE_SECRET_KEY='', FLUTTERWAVE_PUBLIC_KEY=''):
            res = client_for(self.buyer).post(
                self.url, {'order_id': str(self.order.id), 'method': 'mpesa',
                           'phone': '+254712345678'}, format='json',
            )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        body = res.json()
        self.assertFalse(body['data']['rail_configured'])
        self.assertIn('not configured', body['message'])
        intent = self.order.payment_intents.get()
        self.assertEqual(intent.status, 'initiated')
        self.assertEqual(intent.raw_response, {'skipped': 'provider_not_configured'})
        self.order.refresh_from_db()
        self.assertNotEqual(self.order.payment_status, 'paid')

    def test_artifacts_is_not_a_real_money_method(self):
        res = client_for(self.buyer).post(
            self.url, {'order_id': str(self.order.id), 'method': 'artifacts'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(self.order.payment_intents.count(), 0)

    def test_only_the_buyer_may_start_a_payment(self):
        res = client_for(self.outsider).post(
            self.url, {'order_id': str(self.order.id), 'method': 'mpesa',
                       'phone': '+254712345678'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_already_paid_order_is_rejected(self):
        self.order.payment_status = 'paid'
        self.order.save(update_fields=['payment_status'])
        res = client_for(self.buyer).post(
            self.url, {'order_id': str(self.order.id), 'method': 'mpesa',
                       'phone': '+254712345678'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_mpesa_without_a_phone_is_rejected(self):
        res = client_for(self.buyer).post(
            self.url, {'order_id': str(self.order.id), 'method': 'mpesa'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('phone', res.json()['errors'])

    def test_card_rail_returns_hosted_checkout_payload(self):
        with self.settings(FLUTTERWAVE_SECRET_KEY='FLWSECK_TEST', FLUTTERWAVE_PUBLIC_KEY='FLWPUB_TEST'):
            res = client_for(self.buyer).post(
                self.url, {'order_id': str(self.order.id), 'method': 'card'}, format='json',
            )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        data = res.json()['data']
        self.assertEqual(data['public_key'], 'FLWPUB_TEST')
        self.assertTrue(data['tx_ref'].startswith('pi-'))
        self.assertEqual(self.order.payment_intents.get().status, 'awaiting_confirmation')
        self.order.refresh_from_db()
        self.assertEqual(self.order.payment_status, 'pending')
        self.assertEqual(self.order.payment_reference, data['tx_ref'])

    def test_card_rail_with_partial_card_details_is_rejected(self):
        res = client_for(self.buyer).post(
            self.url, {'order_id': str(self.order.id), 'method': 'card',
                       'card_number': '4242424242424242'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


# ---------------------------------------------------------------------------
# Seller notifications
# ---------------------------------------------------------------------------

class SellerNotificationTests(LogisticsTestBase):
    def setUp(self):
        super().setUp()
        from apps.notifications.models import Notification

        Notification.objects.all().delete()
        self.buyer_client = client_for(self.buyer)
        self.seller_client = client_for(self.owner)
        self.operator = make_profile('shopopnotify')
        ShopMembership.objects.create(shop=self.shop, profile=self.operator, role='manager')
        self.staff = make_profile('shopstaffnotify')
        ShopMembership.objects.create(shop=self.shop, profile=self.staff, role='staff')

    def _checkout(self):
        from apps.marketplace.models import TrainingProgramme

        programme = TrainingProgramme.objects.create(
            creator=self.owner, shop=self.shop, title='Legs', category='strength',
            price_artifacts={'dumbbell': 2},
        )
        self.buyer_client.post(
            '/api/v1/marketplace/cart/',
            {'item_type': 'programme', 'programme_id': str(programme.id), 'quantity': 1},
            format='json',
        )
        res = self.buyer_client.post('/api/v1/marketplace/cart/checkout/', {}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        return Order.objects.get(buyer=self.buyer)

    def test_seller_is_notified_when_an_order_is_created(self):
        from apps.notifications.models import Notification

        order = self._checkout()
        note = Notification.objects.filter(
            recipient=self.owner, notification_type='new_purchase',
        ).first()
        self.assertIsNotNone(note, 'the seller must learn about the sale')
        self.assertEqual(note.metadata['order_id'], str(order.id))
        # A shop manager who is not the listed creator is notified too: the
        # person who has to ship is not always the listed seller.
        self.assertTrue(Notification.objects.filter(
            recipient=self.operator, notification_type='new_purchase',
        ).exists())
        # Staff are not owners/managers, so they are not on the sales fan-out.
        self.assertFalse(Notification.objects.filter(
            recipient=self.staff, notification_type='new_purchase',
        ).exists())
        # The buyer is not double-notified as a seller of their own order.
        self.assertFalse(Notification.objects.filter(
            recipient=self.buyer, notification_type='new_purchase',
        ).exists())

    def test_unrelated_seller_is_not_notified(self):
        self._checkout()
        from apps.notifications.models import Notification

        self.assertFalse(Notification.objects.filter(
            recipient=self.other_owner, notification_type='new_purchase',
        ).exists())

    def test_buyer_gets_exactly_one_notification_per_status_change(self):
        from apps.notifications.models import Notification

        order = self._checkout()
        Notification.objects.all().delete()
        res = self.seller_client.patch(
            f'/api/v1/marketplace/orders/{order.id}/fulfillment/',
            {'status': 'processing'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        self.assertEqual(
            Notification.objects.filter(recipient=self.buyer, notification_type='order_status_changed').count(),
            1,
            'the post_save signal and the view must not both notify the buyer',
        )
        self.assertEqual(
            Notification.objects.filter(recipient=self.owner, notification_type='order_status_changed').count(),
            1,
            'the seller must hear about their own order moving',
        )
        row = Notification.objects.get(recipient=self.buyer, notification_type='order_status_changed')
        self.assertEqual(row.metadata['status'], 'processing')

    def test_each_distinct_status_change_notifies_once(self):
        from apps.notifications.models import Notification

        order = self._checkout()
        Notification.objects.all().delete()
        url = f'/api/v1/marketplace/orders/{order.id}/fulfillment/'
        self.seller_client.patch(url, {'status': 'processing'}, format='json')
        self.seller_client.patch(url, {'status': 'completed'}, format='json')
        self.assertEqual(
            Notification.objects.filter(recipient=self.buyer, notification_type='order_status_changed').count(),
            2,
        )

    def test_seller_notification_reaches_device_push(self):
        """create_notification never touches a device token, so the seller path
        must also call the push helper or a seller with the app closed hears
        nothing."""
        from unittest import mock

        from apps.notifications.models import Notification

        with mock.patch('apps.marketplace.tasks._push_notification_to_profile') as push:
            self._checkout()
        self.assertTrue(Notification.objects.filter(recipient=self.owner).exists())
        pushed_profiles = [c.args[0] for c in push.call_args_list]
        self.assertIn(self.owner, pushed_profiles)

    def test_status_change_pushes_to_device_too(self):
        from unittest import mock

        order = self._checkout()
        with mock.patch('apps.marketplace.tasks._push_notification_to_profile') as push:
            self.seller_client.patch(
                f'/api/v1/marketplace/orders/{order.id}/fulfillment/',
                {'status': 'processing'}, format='json',
            )
        pushed_profiles = [c.args[0] for c in push.call_args_list]
        self.assertIn(self.buyer, pushed_profiles)
        self.assertIn(self.owner, pushed_profiles)

    def test_rejected_transition_notifies_nobody(self):
        from apps.notifications.models import Notification

        order = self._checkout()
        order.fulfillment_type = 'pickup'
        order.save(update_fields=['fulfillment_type'])
        Notification.objects.all().delete()
        res = self.seller_client.patch(
            f'/api/v1/marketplace/orders/{order.id}/fulfillment/',
            {'status': 'out_for_delivery'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(Notification.objects.count(), 0)

    def test_order_creation_signal_still_notifies_the_buyer(self):
        from apps.notifications.models import Notification

        order = Order.objects.create(buyer=self.buyer, spent_usd='10.00')
        self.assertTrue(Notification.objects.filter(
            recipient=self.buyer, notification_type='order_status_changed',
            metadata__order_id=str(order.id),
        ).exists())

class TerminalStateGuardTests(TestCase):
    """The legacy-fallback widening must never reopen a closed order."""

    def _order(self, fulfillment_type, status):
        buyer = Profile.objects.create(
            user=User.objects.create_user(email=f'term-{status}-{fulfillment_type}@example.com',
                                          password='TestPass123!'),
            username=f'term-{status}-{fulfillment_type}',
        )
        return Order.objects.create(buyer=buyer, fulfillment_type=fulfillment_type, status=status)

    def test_cancelled_order_has_no_forward_transitions(self):
        from apps.marketplace.views import allowed_order_transitions
        for ft in ('digital', 'pickup', 'delivery'):
            with self.subTest(fulfillment_type=ft):
                self.assertEqual(allowed_order_transitions(self._order(ft, 'cancelled')), [])

    def test_completed_order_has_no_forward_transitions(self):
        from apps.marketplace.views import allowed_order_transitions
        for ft in ('digital', 'pickup', 'delivery'):
            with self.subTest(fulfillment_type=ft):
                self.assertEqual(allowed_order_transitions(self._order(ft, 'completed')), [])

    def test_legacy_transport_state_is_still_closeable(self):
        """A digital order stranded in 'out_for_delivery' by the old flat map
        must still be closeable — that is what the fallback is for."""
        from apps.marketplace.views import allowed_order_transitions
        allowed = allowed_order_transitions(self._order('digital', 'out_for_delivery'))
        self.assertIn('delivered', allowed)
        self.assertIn('completed', allowed)
