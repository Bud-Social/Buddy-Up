from django.core.files.uploadedfile import SimpleUploadedFile
from django.utils import timezone
from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.marketplace.models import (
    CreatorPayoutSetup, InventoryReservation, MealPlan, Order, OrderCase, OrderItem, Product, Shop,
    ShopMembership, TrainingProgramme,
)


class BuyerDeliveryConfirmationTests(TestCase):
    """Buyers may confirm delivery; sellers keep full fulfillment control."""

    def setUp(self):
        self.buyer_user = User.objects.create_user(email='buyer@example.com', password='TestPass123!')
        self.seller_user = User.objects.create_user(email='seller@example.com', password='TestPass123!')
        self.buyer = Profile.objects.create(user=self.buyer_user, username='buyer', display_name='Buyer')
        self.seller = Profile.objects.create(user=self.seller_user, username='seller', display_name='Seller')

        self.order = Order.objects.create(buyer=self.buyer, status='shipped')
        OrderItem.objects.create(
            order=self.order, item_type='product', title='Grips', quantity=1, creator=self.seller,
        )
        self.url = f'/api/v1/marketplace/orders/{self.order.id}/fulfillment/'

    def _client_for(self, profile):
        client = APIClient()
        refresh = RefreshToken.for_user(profile.user)
        client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        return client

    def test_buyer_can_confirm_delivery(self):
        resp = self._client_for(self.buyer).patch(self.url, {'status': 'delivered'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'delivered')

    def test_buyer_cannot_set_arbitrary_status_or_edit_shipping(self):
        client = self._client_for(self.buyer)
        resp = client.patch(self.url, {'status': 'cancelled'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
        resp = client.patch(self.url, {'status': 'delivered', 'tracking_number': 'FAKE-123'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'shipped')

    def test_seller_can_advance_status(self):
        resp = self._client_for(self.seller).patch(
            self.url,
            {'status': 'out_for_delivery', 'carrier': 'Sendy', 'tracking_number': 'TRK-9'},
            format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'out_for_delivery')

    def test_outsider_gets_403(self):
        stranger_user = User.objects.create_user(email='stranger@example.com', password='TestPass123!')
        Profile.objects.create(user=stranger_user, username='stranger', display_name='Stranger')
        resp = self._client_for(
            Profile.objects.get(user=stranger_user),
        ).patch(self.url, {'status': 'delivered'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)


class CommerceReadinessTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(email='creator@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='creator', display_name='Creator')
        self.client = APIClient()
        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_creator_payout_setup_requires_terms_and_account(self):
        response = self.client.patch('/api/v1/marketplace/creator/payout-setup/', {
            'accept_terms': True,
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['setup_status'], 'in_progress')
        response = self.client.patch('/api/v1/marketplace/creator/payout-setup/', {
            'account_reference': 'acct-1',
        }, format='json')
        self.assertEqual(response.data['data']['setup_status'], 'ready')
        self.assertTrue(CreatorPayoutSetup.objects.filter(profile=self.profile, setup_status='ready').exists())

    def test_order_case_captures_evidence(self):
        order = Order.objects.create(buyer=self.profile)
        response = self.client.post(f'/api/v1/marketplace/orders/{order.id}/cases/', {
            'case_type': 'dispute', 'reason': 'Item not received', 'evidence': [{'url': 'https://example.test/proof'}],
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['data']['status'], 'requested')
        self.assertEqual(OrderCase.objects.get(order=order).evidence[0]['url'], 'https://example.test/proof')

    def test_uncompliant_supplements_are_not_listed(self):
        Product.objects.create(name='Unregistered', brand='Test', category='supplement', affiliate_url='https://example.test')
        Product.objects.create(
            name='Registered', brand='Test', category='supplement', affiliate_url='https://example.test',
            supplement_registration_number='PPB-1', supplement_claims_reviewed=True,
        )
        response = self.client.get('/api/v1/marketplace/products/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual([item['name'] for item in response.data['data']], ['Registered'])

    def test_inventory_is_consumed_at_checkout(self):
        shop = Shop.objects.create(name='Shop', handle='shop', verification_status='verified')
        ShopMembership.objects.create(shop=shop, profile=self.profile, role='owner')
        product = Product.objects.create(
            name='Stocked', brand='Test', category='equipment', affiliate_url='https://example.test',
            shop=shop, recommended_by=self.profile, stock_quantity=3, stock_tracking_enabled=True,
        )
        buyer_user = User.objects.create_user(email='buyer2@example.com', password='TestPass123!')
        Profile.objects.create(user=buyer_user, username='buyer2', display_name='Buyer', artifact_balance={'dumbbell': 5})
        buyer_client = APIClient()
        refresh = RefreshToken.for_user(buyer_user)
        buyer_client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        buyer_client.post('/api/v1/marketplace/cart/', {'item_type': 'product', 'product_id': str(product.id), 'quantity': 2}, format='json')
        response = buyer_client.post('/api/v1/marketplace/cart/checkout/', {}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        product.refresh_from_db()
        self.assertEqual(product.stock_quantity, 1)
        self.assertEqual(InventoryReservation.objects.get(product=product).status, 'consumed')


class ShopCertUploadTests(TestCase):
    """Certification documents must never be stored under client filenames."""

    def setUp(self):
        self.owner_user = User.objects.create_user(email='cert-owner@example.com', password='TestPass123!')
        self.owner = Profile.objects.create(user=self.owner_user, username='cert-owner', display_name='Cert Owner')
        self.shop = Shop.objects.create(name='Cert Shop', handle='certshop')
        ShopMembership.objects.create(shop=self.shop, profile=self.owner, role='owner')
        self.client = APIClient()
        refresh = RefreshToken.for_user(self.owner_user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        self.url = f'/api/v1/marketplace/shops/{self.shop.handle}/certification/'

    def test_cert_upload_stores_uuid_filename(self):
        upload = SimpleUploadedFile(
            'my degree certificate signed.pdf', b'%PDF-1.4 FAKE', content_type='application/pdf',
        )
        response = self.client.post(self.url, {'id_document': upload}, format='multipart')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        app = self.shop.verification_applications.latest('created_at')
        self.assertIn('/certs/id_docs/', app.id_document_url)
        stored_name = app.id_document_url.rstrip('/').rsplit('/', 1)[-1]
        self.assertRegex(stored_name, r'^[0-9a-f]{32}\.pdf$')
        self.assertNotIn('my degree', app.id_document_url)


class EventDiscoveryFilterTests(TestCase):
    def setUp(self):
        from datetime import timedelta
        from django.utils import timezone
        from apps.gyms.models import Gym
        from apps.marketplace.models import MarketplaceEvent

        self.user = User.objects.create_user(email='fan@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='fan', display_name='Fan')
        self.client = APIClient()
        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

        start = timezone.now() + timedelta(days=3)
        end = start + timedelta(hours=2)
        self.gym = Gym.objects.create(
            name='Verified Arena', handle='verified-arena', category='fitness',
            access_type='public', is_verified=True,
            location_city='Nairobi', location_country='Kenya',
        )
        self.physical = MarketplaceEvent.objects.create(
            creator=self.profile, title='Nairobi Sunrise Run', description='5k run',
            event_type='in_person', location='Karura Forest, Nairobi',
            location_lat=-1.2421, location_lng=36.8273,
            start_datetime=start, end_datetime=end, category='fitness',
        )
        self.online = MarketplaceEvent.objects.create(
            creator=self.profile, title='Global Breathwork Basics', description='online session',
            event_type='online', online_url='https://example.com/live',
            start_datetime=start, end_datetime=end, category='wellness', is_free=True,
        )
        self.gym_event = MarketplaceEvent.objects.create(
            creator=self.profile, gym=self.gym, title='Arena Hybrid Games',
            description='hybrid competition', event_type='hybrid',
            location='Verified Arena, Nairobi',
            start_datetime=start, end_datetime=end, category='competition',
        )

    def _titles(self, params):
        res = self.client.get('/api/v1/marketplace/events/', params)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        return [e['title'] for e in res.json()['data']]

    def test_event_type_filter(self):
        self.assertEqual(set(self._titles({'event_type': 'online'})), {'Global Breathwork Basics'})

    def test_text_search(self):
        self.assertEqual(set(self._titles({'q': 'breathwork'})), {'Global Breathwork Basics'})

    def test_city_filter(self):
        titles = set(self._titles({'city': 'Nairobi'}))
        self.assertIn('Nairobi Sunrise Run', titles)
        self.assertIn('Arena Hybrid Games', titles)
        self.assertNotIn('Global Breathwork Basics', titles)

    def test_nearby_filter(self):
        titles = set(self._titles({'lat': '-1.2921', 'lng': '36.8219', 'radius_km': '50'}))
        self.assertEqual(titles, {'Nairobi Sunrise Run'})

    def test_verified_only(self):
        titles = set(self._titles({'verified': 'true'}))
        self.assertEqual(titles, {'Arena Hybrid Games'})

    def test_gym_handle_filter(self):
        self.assertEqual(set(self._titles({'gym': 'verified-arena'})), {'Arena Hybrid Games'})

    def test_free_only(self):
        titles = set(self._titles({'is_free': 'true'}))
        self.assertIn('Global Breathwork Basics', titles)

    def test_serializer_exposes_new_fields(self):
        res = self.client.get('/api/v1/marketplace/events/', {'q': 'Sunrise'})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        event = res.json()['data'][0]
        self.assertAlmostEqual(event['location_lat'], -1.2421)
        self.assertIn('verification_status', event['creator_data'])


class ProgrammeSchedulePersistenceTests(TestCase):
    """The programme/meal editors send rich schedule + reminder payloads.

    The create/update serializers used to omit these fields entirely, so the
    blocks were silently dropped on save. These tests pin the contract."""

    def setUp(self):
        self.user = User.objects.create_user(email='creator@example.com', password='TestPass123!')
        self.creator = Profile.objects.create(user=self.user, username='creator', display_name='Creator')
        self.shop = Shop.objects.create(name='Creator Shop', handle='creatorshop', verification_status='verified')
        ShopMembership.objects.create(shop=self.shop, profile=self.creator, role='owner')
        CreatorPayoutSetup.objects.create(
            profile=self.creator, setup_status='ready',
            terms_accepted_at=timezone.now(), account_reference='acct-creator',
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)

    def test_create_persists_schedule_and_notification_config(self):
        schedule = {
            'week_1': {
                'day_1': [{
                    'title': 'Upper body push',
                    'duration_mins': 45,
                    'timing': 'morning',
                    'video_url': 'https://cdn.example.com/session.mp4',
                    'description': 'Bench, incline press, shoulder press.',
                    'tips': 'Leave a rep in reserve.',
                    'warnings': 'Stop if shoulder pain.',
                }],
            },
        }
        res = self.client.post('/api/v1/marketplace/programmes/', {
            'title': 'Push Strength',
            'description': 'Eight week push block.',
            'category': 'strength',
            'duration_weeks': 8,
            'schedule': schedule,
            'notification_config': {'enabled': True, 'frequency': '30m', 'timing': 'morning'},
            'price_artifacts': {'barbell': 2},
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        programme = TrainingProgramme.objects.get(id=res.json()['data']['id'])
        self.assertEqual(programme.schedule['week_1']['day_1'][0]['title'], 'Upper body push')
        self.assertEqual(programme.schedule['week_1']['day_1'][0]['timing'], 'morning')
        self.assertEqual(programme.notification_config['frequency'], '30m')

    def test_create_rejects_unknown_block_timing(self):
        res = self.client.post('/api/v1/marketplace/programmes/', {
            'title': 'Bad Timing',
            'category': 'strength',
            'notification_config': {'frequency': '30m', 'timing': 'sometime'},
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_update_persists_schedule(self):
        res = self.client.post('/api/v1/marketplace/programmes/', {
            'title': 'Legs Builder',
            'category': 'strength',
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        programme_id = res.json()['data']['id']

        schedule = {'week_1': {'day_2': [{'title': 'Squats', 'duration_mins': 40, 'timing': 'evening'}]}}
        res = self.client.put(
            f'/api/v1/marketplace/programmes/{programme_id}/', {'schedule': schedule}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        self.assertEqual(
            TrainingProgramme.objects.get(id=programme_id).schedule['week_1']['day_2'][0]['title'],
            'Squats',
        )

    def test_meal_plan_blocks_persist(self):
        full_plan = {
            'week_1': {
                'day_1': [{
                    'slot': 'breakfast',
                    'title': 'Oats + eggs',
                    'duration_mins': 15,
                    'timing': 'morning',
                    'photo_url': 'https://cdn.example.com/oats.jpg',
                    'alternatives': 'Swap eggs for tofu scramble',
                    'side_effects': 'High fibre - hydrate well',
                }],
            },
        }
        res = self.client.post('/api/v1/marketplace/meal-plans/', {
            'title': 'High Protein Week',
            'diet_type': 'high_protein',
            'duration_weeks': 1,
            'full_plan': full_plan,
            'reminder_settings': {'enabled': True, 'frequency': '1h', 'timing': 'morning'},
            'price_artifacts': {'dumbbell': 2},
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        plan = MealPlan.objects.get(id=res.json()['data']['id'])
        block = plan.full_plan['week_1']['day_1'][0]
        self.assertEqual(block['photo_url'], 'https://cdn.example.com/oats.jpg')
        self.assertEqual(block['alternatives'], 'Swap eggs for tofu scramble')
        self.assertEqual(block['side_effects'], 'High fibre - hydrate well')
