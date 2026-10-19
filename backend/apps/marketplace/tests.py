from django.core.files.uploadedfile import SimpleUploadedFile
from django.utils import timezone
from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.marketplace.models import (
    CreatorPayoutSetup, DiscountCode, EventTicket, InventoryReservation, MealPlan, Order,
    OrderCase, OrderItem, Product, Shop, ShopMembership, TrainingProgramme,
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
        # A verified trainer, not just a shop owner: meal-plan creation is
        # gated on professional nutrition authority, and this class is about
        # the rich payload surviving the round-trip, not about who may post.
        # The shop membership below still covers the programme endpoints.
        self.creator = Profile.objects.create(
            user=self.user, username='creator', display_name='Creator',
            role='trainer', verification_status='trainer',
        )
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


def _mk_user(email, username):
    user = User.objects.create_user(email=email, password='TestPass123!')
    profile = Profile.objects.create(user=user, username=username, display_name=username.title())
    return user, profile


def _auth_client(user):
    client = APIClient()
    refresh = RefreshToken.for_user(user)
    client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
    return client


class CartPriceQuoteChargeInvariantTests(TestCase):
    """What the cart quotes must be exactly what checkout charges.

    Four divergent copies of "what does this cart item cost" used to exist.
    The cart quote ignored CartItem.meta['tier'] while checkout charged the
    tier price, and tier prices name a different artifact token than the
    event's base price. The client therefore validated `4 dumbbells` while the
    server demanded `20 sprints`, and checkout 400'd on a funded wallet.

    resolve_item_price() is now the single source of truth; these tests pin
    the quote == charge invariant that let the copies drift unnoticed.
    """

    def setUp(self):
        self.creator_user = User.objects.create_user(
            email='tier-creator@example.com', password='TestPass123!',
        )
        self.creator = Profile.objects.create(
            user=self.creator_user, username='tiercreator', display_name='Tier Creator',
        )
        self.shop = Shop.objects.create(
            name='Tier Shop', handle='tiershop', verification_status='verified',
        )
        ShopMembership.objects.create(shop=self.shop, profile=self.creator, role='owner')
        CreatorPayoutSetup.objects.create(
            profile=self.creator, setup_status='ready',
            terms_accepted_at=timezone.now(), account_reference='acct-tier-creator',
        )

        # Base price is deliberately a DIFFERENT token from the tier price.
        self.base_price = {'sprint': 20}
        self.tier_price = {'dumbbell': 4}
        self.event = None

    def _make_event(self, tiers=None, base_price=None, is_free=False):
        from datetime import timedelta

        from apps.marketplace.models import MarketplaceEvent

        start = timezone.now() + timedelta(days=7)
        return MarketplaceEvent.objects.create(
            creator=self.creator,
            shop=self.shop,
            title='Sunrise Sprint Club',
            description='Tiered ticket event',
            event_type='in_person',
            location='Karura Forest, Nairobi',
            start_datetime=start,
            end_datetime=start + timedelta(hours=2),
            category='fitness',
            capacity=0,
            ticket_tiers=tiers if tiers is not None else [],
            ticket_price_artifacts=self.base_price if base_price is None else base_price,
            is_free=is_free,
        )

    def _buyer(self, handle, balance):
        user = User.objects.create_user(email=f'{handle}@example.com', password='TestPass123!')
        profile = Profile.objects.create(
            user=user, username=handle, display_name=handle.title(), artifact_balance=dict(balance),
        )
        return profile, _auth_client(user)

    def _add_tiered_ticket(self, client, tier_name='Pro'):
        return client.post('/api/v1/marketplace/cart/', {
            'item_type': 'event_ticket', 'event_id': str(self.event.id),
            'tier': tier_name, 'quantity': 1,
        }, format='json')

    def test_quote_matches_charge_for_plain_programme(self):
        programme = TrainingProgramme.objects.create(
            creator=self.creator, shop=self.shop, title='Push Strength',
            category='strength', price_artifacts={'dumbbell': 4},
        )
        buyer, client = self._buyer('plainbuyer', {'dumbbell': 10})

        res = client.post('/api/v1/marketplace/cart/', {
            'item_type': 'programme', 'programme_id': str(programme.id), 'quantity': 2,
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)

        quoted = client.get('/api/v1/marketplace/cart/').json()['data']['total_artifacts']
        self.assertEqual(quoted, {'dumbbell': 8})

        checkout = client.post('/api/v1/marketplace/cart/checkout/', {}, format='json')
        self.assertEqual(checkout.status_code, status.HTTP_200_OK, checkout.content)
        charged = checkout.json()['data']['total_artifacts']
        self.assertEqual(quoted, charged)
        self.assertEqual(charged, {'dumbbell': 8})

        buyer.refresh_from_db()
        self.assertEqual(buyer.artifact_balance, {'dumbbell': 2})

    def test_quote_matches_charge_for_tiered_event_ticket(self):
        self.event = self._make_event(
            tiers=[{'name': 'Pro', 'price_artifacts': self.tier_price, 'description': 'Front row'}],
        )
        # Funded for the TIER price only. The old tier-blind quote asked for sprints.
        buyer, client = self._buyer('tierbuyer', {'dumbbell': 10})

        res = self._add_tiered_ticket(client)
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)

        quoted = client.get('/api/v1/marketplace/cart/').json()['data']['total_artifacts']
        self.assertEqual(quoted, self.tier_price)

        checkout = client.post('/api/v1/marketplace/cart/checkout/', {}, format='json')
        self.assertEqual(checkout.status_code, status.HTTP_200_OK, checkout.content)
        charged = checkout.json()['data']['total_artifacts']
        self.assertEqual(quoted, charged)
        self.assertEqual(charged, self.tier_price)

        buyer.refresh_from_db()
        self.assertEqual(buyer.artifact_balance, {'dumbbell': 6})

    def test_tiered_ticket_checkout_succeeds_when_buyer_holds_tier_tokens(self):
        """The reported regression: funded wallet, 400 'Insufficient X tokens.'"""
        self.event = self._make_event(
            tiers=[{'name': 'Pro', 'price_artifacts': self.tier_price}],
        )
        buyer, client = self._buyer('fundedbuyer', {'dumbbell': 100, 'sprint': 100})

        self._add_tiered_ticket(client)
        checkout = client.post('/api/v1/marketplace/cart/checkout/', {}, format='json')

        self.assertEqual(checkout.status_code, status.HTTP_200_OK, checkout.content)
        self.assertNotIn('Insufficient', checkout.json()['message'])

        ticket = EventTicket.objects.get(event=self.event, holder=buyer)
        self.assertEqual(ticket.tier, 'Pro')
        self.assertEqual(ticket.price_paid_artifacts, self.tier_price)

    def test_tier_name_is_matched_case_insensitively(self):
        self.event = self._make_event(
            tiers=[{'name': 'Pro', 'price_artifacts': self.tier_price}],
        )
        _buyer, client = self._buyer('casebuyer', {'dumbbell': 10})

        res = self._add_tiered_ticket(client, tier_name='pRo')
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        quoted = client.get('/api/v1/marketplace/cart/').json()['data']['total_artifacts']
        self.assertEqual(quoted, self.tier_price)

    def test_insufficient_balance_returns_400_and_deducts_nothing(self):
        """A rejected checkout must not partially debit the buyer."""
        self.event = self._make_event(
            tiers=[{'name': 'Pro', 'price_artifacts': self.tier_price}],
        )
        # Holds the tier token but not enough of it.
        buyer, client = self._buyer('brokebuyer', {'dumbbell': 1})

        self._add_tiered_ticket(client)
        checkout = client.post('/api/v1/marketplace/cart/checkout/', {}, format='json')

        self.assertEqual(checkout.status_code, status.HTTP_400_BAD_REQUEST, checkout.content)
        self.assertIn('Insufficient', checkout.json()['message'])

        buyer.refresh_from_db()
        self.assertEqual(buyer.artifact_balance, {'dumbbell': 1})
        self.assertFalse(EventTicket.objects.filter(event=self.event, holder=buyer).exists())

    def test_insufficient_balance_with_two_items_leaves_every_token_untouched(self):
        programme = TrainingProgramme.objects.create(
            creator=self.creator, shop=self.shop, title='Legs Builder',
            category='strength', price_artifacts={'barbell': 3},
        )
        buyer, client = self._buyer('partialbuyer', {'barbell': 1, 'dumbbell': 1})

        client.post('/api/v1/marketplace/cart/', {
            'item_type': 'programme', 'programme_id': str(programme.id), 'quantity': 1,
        }, format='json')
        client.post('/api/v1/marketplace/cart/', {
            'item_type': 'product', 'product_id': str(self._product().id), 'quantity': 1,
        }, format='json')

        checkout = client.post('/api/v1/marketplace/cart/checkout/', {}, format='json')
        self.assertEqual(checkout.status_code, status.HTTP_400_BAD_REQUEST, checkout.content)

        buyer.refresh_from_db()
        self.assertEqual(buyer.artifact_balance, {'barbell': 1, 'dumbbell': 1})

    def _product(self):
        return Product.objects.create(
            name='Grips', brand='Test', category='equipment',
            affiliate_url='https://example.test', shop=self.shop,
            recommended_by=self.creator,
        )

    def test_tier_without_price_falls_back_to_base_price(self):
        self.event = self._make_event(
            tiers=[
                {'name': 'Early Bird', 'price_artifacts': {}},
                {'name': 'Unpriced', 'price_artifacts': None},
            ],
        )
        buyer, client = self._buyer('fallbackbuyer', {'sprint': 20})

        for tier in ('Early Bird', 'Unpriced'):
            res = self._add_tiered_ticket(client, tier_name=tier)
            self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
            quoted = client.get('/api/v1/marketplace/cart/').json()['data']['total_artifacts']
            self.assertEqual(quoted, self.base_price, f'tier {tier} should fall back to base')
            self._clear_cart(client)

        # Single tier purchase so the buyer only needs the base price once.
        self._add_tiered_ticket(client, tier_name='Early Bird')
        checkout = client.post('/api/v1/marketplace/cart/checkout/', {}, format='json')
        self.assertEqual(checkout.status_code, status.HTTP_200_OK, checkout.content)
        self.assertEqual(checkout.json()['data']['total_artifacts'], self.base_price)

        buyer.refresh_from_db()
        self.assertEqual(buyer.artifact_balance, {'sprint': 0})

    def test_unknown_tier_name_is_rejected_by_the_cart(self):
        self.event = self._make_event(
            tiers=[{'name': 'Pro', 'price_artifacts': self.tier_price}],
        )
        _buyer, client = self._buyer('unknowntier', {'dumbbell': 10})

        res = self._add_tiered_ticket(client, tier_name='Nonexistent')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('Unknown ticket tier', res.json()['message'])

    def test_free_event_checkout_charges_nothing(self):
        self.event = self._make_event(is_free=True, base_price={'sprint': 20})
        buyer, client = self._buyer('freebuyer', {})

        res = self._add_tiered_ticket(client, tier_name=None)
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)

        quoted = client.get('/api/v1/marketplace/cart/').json()['data']['total_artifacts']
        self.assertEqual(quoted, {})

        checkout = client.post('/api/v1/marketplace/cart/checkout/', {}, format='json')
        self.assertEqual(checkout.status_code, status.HTTP_200_OK, checkout.content)
        self.assertEqual(checkout.json()['data']['total_artifacts'], {})

        buyer.refresh_from_db()
        self.assertEqual(buyer.artifact_balance, {})
        self.assertTrue(EventTicket.objects.filter(event=self.event, holder=buyer).exists())

    def test_cart_line_item_subtotal_agrees_with_cart_total(self):
        """CartSerializer and CartItemSerializer must not disagree either."""
        self.event = self._make_event(
            tiers=[{'name': 'Pro', 'price_artifacts': self.tier_price}],
        )
        _buyer, client = self._buyer('subtotalbuyer', {'dumbbell': 10})

        self._add_tiered_ticket(client)
        data = client.get('/api/v1/marketplace/cart/').json()['data']
        line_totals = {}
        for sub in data['subtotals']:
            for k, v in sub['item_total_artifacts'].items():
                line_totals[k] = line_totals.get(k, 0) + v
        self.assertEqual(line_totals, data['total_artifacts'])
        self.assertEqual(data['subtotals'][0]['item_total_artifacts'], self.tier_price)

    def _clear_cart(self, client):
        client.delete('/api/v1/marketplace/cart/', {}, format='json')

    def test_discount_minimum_purchase_uses_the_tier_price(self):
        """DiscountCodeView._cart_total_artifacts was tier-blind too."""
        self.event = self._make_event(
            tiers=[{'name': 'Pro', 'price_artifacts': self.tier_price}],
        )
        _buyer, client = self._buyer('discountbuyer', {'dumbbell': 10})

        code = DiscountCode.objects.create(
            code='TIERMIN', discount_type='percentage', discount_pct=10,
            creator=self.creator, min_purchase_artifacts=self.tier_price,
        )
        self._add_tiered_ticket(client)

        res = client.post('/api/v1/marketplace/cart/discount/', {'code': code.code}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)


class EventTicketNotificationSignalTests(TestCase):
    """handle_event_ticket_created 500'd on every successful ticket purchase.

    It read EventTicket.user (the field is `holder`) and MarketplaceEvent.start_time
    (the field is `start_datetime`), so the post_save receiver raised
    AttributeError *after* the buyer had been debited.
    """

    def setUp(self):
        from datetime import timedelta

        from apps.marketplace.models import MarketplaceEvent

        self.user = User.objects.create_user(email='signal@example.com', password='TestPass123!')
        self.buyer = Profile.objects.create(
            user=self.user, username='signalbuyer', display_name='Signal Buyer',
        )
        self.creator_user = User.objects.create_user(
            email='signal-creator@example.com', password='TestPass123!',
        )
        self.creator = Profile.objects.create(
            user=self.creator_user, username='signalcreator', display_name='Signal Creator',
        )
        start = timezone.now() + timedelta(days=2)
        self.event = MarketplaceEvent.objects.create(
            creator=self.creator, title='Signal Test Run', description='signal regression',
            event_type='in_person', location='Nairobi',
            start_datetime=start, end_datetime=start + timedelta(hours=1),
            category='fitness', is_free=True,
        )

    def test_creating_event_ticket_does_not_raise(self):
        ticket = EventTicket.objects.create(
            event=self.event, holder=self.buyer, tier='Standard',
            price_paid_artifacts={}, status='active',
        )
        ticket.refresh_from_db()
        self.assertEqual(ticket.holder, self.buyer)
        self.assertEqual(ticket.tier, 'Standard')

    def test_signal_uses_real_field_names_and_emits_a_notification(self):
        from apps.notifications.models import Notification

        Notification.objects.all().delete()
        EventTicket.objects.create(
            event=self.event, holder=self.buyer, tier='Standard',
            price_paid_artifacts={}, status='active',
        )
        note = Notification.objects.filter(
            recipient=self.buyer, notification_type='event_ticket_purchased',
        ).first()
        self.assertIsNotNone(note, 'expected an event_ticket_purchased notification')
        self.assertEqual(note.metadata['event_title'], self.event.title)
        self.assertIsNotNone(note.metadata['start_time'])
        self.assertEqual(
            note.metadata['start_time'],
            self.event.start_datetime.isoformat(),
        )


class FulfillmentAwareTransitionsTests(TestCase):
    """Status transitions must mean something for the fulfillment type.

    The old flat `ORDER_FORWARD_STATES` map let a pickup order go
    `paid -> shipped -> out_for_delivery` and a digital one do the same, so a
    buyer could see "out for delivery" for a PDF. These pin the vocabulary of
    each fulfillment type.
    """

    def setUp(self):
        self.buyer = Profile.objects.create(
            user=User.objects.create_user(email='fs-buyer@example.com', password='TestPass123!'),
            username='fsbuyer', display_name='FS Buyer',
        )
        self.seller = Profile.objects.create(
            user=User.objects.create_user(email='fs-seller@example.com', password='TestPass123!'),
            username='fsseller', display_name='FS Seller',
        )
        self.client = _auth_client(self.seller.user)

    def _order(self, fulfillment_type, status='paid'):
        order = Order.objects.create(
            buyer=self.buyer, fulfillment_type=fulfillment_type, status=status,
        )
        OrderItem.objects.create(
            order=order, item_type='product', title='Item', creator=self.seller,
        )
        return order

    def _move(self, order, new_status):
        return self.client.patch(
            f'/api/v1/marketplace/orders/{order.id}/fulfillment/',
            {'status': new_status}, format='json',
        )

    def test_pickup_rejects_out_for_delivery(self):
        order = self._order('pickup')
        res = self._move(order, 'out_for_delivery')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('from paid to out_for_delivery', res.json()['message'])
        order.refresh_from_db()
        self.assertEqual(order.status, 'paid')

    def test_digital_rejects_shipped_and_out_for_delivery(self):
        for target in ('shipped', 'out_for_delivery'):
            with self.subTest(target=target):
                res = self._move(self._order('digital'), target)
                self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertIn(f'from paid to {target}', res.json()['message'])
                self.assertIn('digital', res.json()['message'])

    def test_delivery_accepts_out_for_delivery(self):
        order = self._order('delivery', status='shipped')
        res = self._move(order, 'out_for_delivery')
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        order.refresh_from_db()
        self.assertEqual(order.status, 'out_for_delivery')

    def test_digital_walks_paid_processing_completed(self):
        order = self._order('digital')
        self.assertEqual(self._move(order, 'processing').status_code, status.HTTP_200_OK)
        self.assertEqual(self._move(order, 'completed').status_code, status.HTTP_200_OK)
        order.refresh_from_db()
        self.assertEqual(order.status, 'completed')

    def test_pickup_walks_ready_for_pickup_delivered(self):
        order = self._order('pickup')
        self.assertEqual(self._move(order, 'ready_for_pickup').status_code, status.HTTP_200_OK)
        self.assertEqual(self._move(order, 'delivered').status_code, status.HTTP_200_OK)


class SellerOrderIsolationTests(TestCase):
    """A seller must only ever see its own line items in a shared order."""

    def setUp(self):
        self.seller = Profile.objects.create(
            user=User.objects.create_user(email='iso-seller@example.com', password='TestPass123!'),
            username='isoseller', display_name='Iso Seller',
        )
        self.rival = Profile.objects.create(
            user=User.objects.create_user(email='iso-rival@example.com', password='TestPass123!'),
            username='isorival', display_name='Iso Rival',
        )
        self.buyer = Profile.objects.create(
            user=User.objects.create_user(email='iso-buyer@example.com', password='TestPass123!'),
            username='isobuyer', display_name='Iso Buyer',
        )
        self.order = Order.objects.create(buyer=self.buyer, status='paid')
        OrderItem.objects.create(
            order=self.order, item_type='product', title='Mine', creator=self.seller,
            quantity=1, price_artifacts={'sprint': 10}, paid_artifacts={'sprint': 10},
        )
        OrderItem.objects.create(
            order=self.order, item_type='product', title='Rival Secret', creator=self.rival,
            quantity=1, price_artifacts={'champion': 40}, paid_artifacts={'champion': 40},
        )
        self.client = _auth_client(self.seller.user)

    def test_seller_list_contains_no_other_sellers_rows(self):
        res = self.client.get('/api/v1/marketplace/orders/seller/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()['data']
        self.assertEqual(len(data), 1)
        self.assertEqual([i['title'] for i in data[0]['items']], ['Mine'])
        self.assertNotIn('Rival Secret', str(data))

    def test_seller_totals_exclude_the_other_sellers_revenue(self):
        order = self.client.get('/api/v1/marketplace/orders/seller/').json()['data'][0]
        self.assertEqual(order['total_artifacts'], {'sprint': 10})
        self.assertEqual(order['spent_usd'], 50.0)


class CheckoutPaymentRailTests(TestCase):
    """`payment_method` decides whether checkout settles or defers."""

    def setUp(self):
        from apps.marketplace.models import TrainingProgramme

        self.seller = Profile.objects.create(
            user=User.objects.create_user(email='pay-seller@example.com', password='TestPass123!'),
            username='payseller', display_name='Pay Seller',
        )
        self.buyer = Profile.objects.create(
            user=User.objects.create_user(email='pay-buyer@example.com', password='TestPass123!'),
            username='paybuyer', display_name='Pay Buyer',
            artifact_balance={'champion': 10},
        )
        self.programme = TrainingProgramme.objects.create(
            creator=self.seller, title='Push Block', category='strength',
            price_artifacts={'champion': 4},
        )
        self.shop = Shop.objects.create(name='Pay Shop', handle='payshop')
        self.product = Product.objects.create(
            name='Digital Manual', brand='Test', category='digital',
            affiliate_url='https://example.test', delivery_modes=['digital'],
            recommended_by=self.seller,
        )
        self.client = _auth_client(self.buyer.user)
        self.client.post('/api/v1/marketplace/cart/', {
            'item_type': 'programme', 'programme_id': str(self.programme.id), 'quantity': 1,
        }, format='json')

    def test_mpesa_checkout_defers_settlement(self):
        res = self.client.post(
            '/api/v1/marketplace/cart/checkout/',
            {'fulfillment_type': 'digital', 'payment_method': 'mpesa'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        self.buyer.refresh_from_db()
        self.assertEqual(self.buyer.artifact_balance, {'champion': 10})
        order = Order.objects.get(buyer=self.buyer)
        self.assertEqual(order.payment_status, 'pending')
        self.assertEqual(order.payment_method, 'mpesa')
        self.assertEqual(order.status, 'pending')
        self.assertIsNone(order.paid_at)
        self.assertEqual(res.json()['data']['payment_status'], 'pending')
        self.assertEqual(res.json()['data']['payment_method'], 'mpesa')
        # Not provisioned until the money lands.
        self.assertFalse(self.programme.purchases.filter(buyer=self.buyer).exists())

    def test_artifacts_checkout_is_unchanged(self):
        res = self.client.post('/api/v1/marketplace/cart/checkout/', {}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        self.buyer.refresh_from_db()
        self.assertEqual(self.buyer.artifact_balance, {'champion': 6})
        order = Order.objects.get(buyer=self.buyer)
        self.assertEqual(order.payment_status, 'paid')
        self.assertEqual(order.payment_method, 'artifacts')
        self.assertEqual(order.status, 'paid')
        self.assertIsNotNone(order.paid_at)
        self.assertTrue(self.programme.purchases.filter(buyer=self.buyer).exists())

    def test_digital_only_cart_rejects_a_delivery_fulfillment_type(self):
        from apps.marketplace.models import Cart

        self.client.post('/api/v1/marketplace/cart/checkout/', {}, format='json')
        cart = Cart.objects.get(buyer=self.buyer)
        self.client.post('/api/v1/marketplace/cart/', {
            'item_type': 'product', 'product_id': str(self.product.id), 'quantity': 1,
        }, format='json')
        self.assertEqual(cart.items.count(), 1)
        res = self.client.post('/api/v1/marketplace/cart/checkout/', {
            'fulfillment_type': 'delivery', 'delivery_address': {'line1': 'Mansion Road'},
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('digital only', res.json()['message'])


class OrderStatusNotificationDeduplicationTests(TestCase):
    """One seller status change must produce exactly one buyer notification.

    Both the Order post_save receiver and OrderFulfillmentView used to notify
    the buyer, so every seller update arrived twice (once mislabelled
    `new_purchase`). Sellers were not notified at all.
    """

    def setUp(self):
        from apps.notifications.models import Notification

        Notification.objects.all().delete()
        self.seller = Profile.objects.create(
            user=User.objects.create_user(email='dedup-seller@example.com', password='TestPass123!'),
            username='dedupseller', display_name='Dedup Seller',
        )
        self.buyer = Profile.objects.create(
            user=User.objects.create_user(email='dedup-buyer@example.com', password='TestPass123!'),
            username='dedupbuyer', display_name='Dedup Buyer',
        )
        self.order = Order.objects.create(buyer=self.buyer, status='paid')
        OrderItem.objects.create(
            order=self.order, item_type='product', title='Item', creator=self.seller,
        )
        self.seller_client = _auth_client(self.seller.user)
        self.url = f'/api/v1/marketplace/orders/{self.order.id}/fulfillment/'

    def test_buyer_gets_exactly_one_notification_per_status_change(self):
        from apps.notifications.models import Notification

        Notification.objects.all().delete()
        res = self.seller_client.patch(self.url, {'status': 'processing'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        self.assertEqual(
            Notification.objects.filter(recipient=self.buyer).count(), 1,
            'post_save and the view must not both notify',
        )

    def test_seller_is_also_notified(self):
        from apps.notifications.models import Notification

        Notification.objects.all().delete()
        self.seller_client.patch(self.url, {'status': 'processing'}, format='json')
        self.assertEqual(
            Notification.objects.filter(recipient=self.seller, notification_type='order_status_changed').count(),
            1,
        )

    def test_a_rejected_transition_notifies_nobody(self):
        from apps.notifications.models import Notification

        self.order.fulfillment_type = 'pickup'
        self.order.save(update_fields=['fulfillment_type'])
        Notification.objects.all().delete()
        res = self.seller_client.patch(self.url, {'status': 'out_for_delivery'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(Notification.objects.count(), 0)

    def test_seller_notification_also_invokes_device_push(self):
        from unittest import mock

        from apps.notifications.models import Notification

        Notification.objects.all().delete()
        with mock.patch('apps.marketplace.tasks._push_notification_to_profile') as push:
            self.seller_client.patch(self.url, {'status': 'processing'}, format='json')
        pushed = [call.args[0] for call in push.call_args_list]
        self.assertIn(self.seller, pushed)
        self.assertIn(self.buyer, pushed)


class OrderCardPayloadTests(TestCase):
    """An order notification has to carry enough to render a card.

    `Notification.metadata` is a free-form JSONField, so this cost no schema
    change -- the payload simply was never populated. A buyer was told "order
    BU-1 is now shipped" with no line items, no images and no destination.
    """

    def setUp(self):
        self.buyer, self.buyer_profile = _mk_user('cardbuyer@example.com', 'cardbuyer')
        self.seller, self.seller_profile = _mk_user('cardseller@example.com', 'cardseller')

    def _order(self, item_type='meal_plan'):
        from apps.marketplace.models import MealPlan, Order, OrderItem

        plan = MealPlan.objects.create(
            creator=self.seller_profile, title='Card Plan', description='d',
            diet_type='balanced',
        )
        order = Order.objects.create(
            buyer=self.buyer_profile, status='paid', fulfillment_type='digital',
        )
        # Only the FK matching `item_type` is set: the serializer resolves the
        # target through the item_type -> FK map, so a stray FK would hide a
        # real mismatch.
        OrderItem.objects.create(
            order=order, item_type=item_type, title='Card Plan',
            meal_plan=plan if item_type == 'meal_plan' else None,
            quantity=2, paid_artifacts={'dumbbell_tokens': 50},
        )
        return order

    def test_order_item_exposes_a_target_and_a_route(self):
        from apps.marketplace.serializers import OrderItemSerializer

        order = self._order()
        item = order.items.first()
        data = OrderItemSerializer(item).data
        self.assertEqual(data['item_type'], 'meal_plan')
        self.assertTrue(data['target'], 'An order line must say what it bought.')
        self.assertTrue(data['detail_route'].startswith('/marketplace/meal-plans/'))

    def test_a_deleted_target_serialises_as_null_not_as_a_dead_link(self):
        """OrderItem uses SET_NULL, so the purchase record outlives the product."""
        from apps.marketplace.models import MealPlan, OrderItem
        from apps.marketplace.serializers import OrderItemSerializer

        order = self._order()
        item = order.items.first()
        MealPlan.objects.filter(id=item.meal_plan_id).delete()
        data = OrderItemSerializer(OrderItem.objects.get(id=item.id)).data
        self.assertIsNone(data['target'])
        self.assertIsNone(data['detail_route'])
        self.assertEqual(data['title'], 'Card Plan', 'The record of what was bought must survive.')

    def test_card_payload_carries_line_items_and_a_destination(self):
        from apps.marketplace.views import _order_card_payload

        order = self._order()
        card = _order_card_payload(order)
        self.assertEqual(card['order_number'], order.order_number)
        self.assertEqual(card['item_count'], 1)
        self.assertEqual(card['items'][0]['title'], 'Card Plan')
        self.assertTrue(card['items'][0]['target_id'])


class TicketVisibilityTests(TestCase):
    """A ticket must not vanish because it was used or refunded."""

    def setUp(self):
        self.buyer, self.buyer_profile = _mk_user('tixbuyer@example.com', 'tixbuyer')

    def _ticket(self, status):
        from datetime import timedelta

        from django.utils import timezone as djtz

        from apps.marketplace.models import EventTicket, MarketplaceEvent

        event = MarketplaceEvent.objects.create(
            creator=self.buyer_profile, title='Tix Event', category='fitness',
            start_datetime=djtz.now() + timedelta(days=1),
            end_datetime=djtz.now() + timedelta(days=1, hours=2),
        )
        return EventTicket.objects.create(event=event, holder=self.buyer_profile, status=status)

    def test_used_and_refunded_tickets_still_appear(self):
        from rest_framework.test import APIClient

        self._ticket('active')
        self._ticket('used')
        self._ticket('refunded')

        client = APIClient()
        client.force_authenticate(self.buyer)
        response = client.get('/api/v1/marketplace/events/my-tickets/')
        self.assertEqual(response.status_code, 200, response.content)
        statuses = {row['status'] for row in response.data['data']}
        self.assertEqual(
            statuses, {'active', 'used', 'refunded'},
            'A ticket disappearing from the only list that shows tickets leaves '
            'its holder no way to follow a refund.',
        )

    def test_the_active_filter_is_still_available(self):
        from rest_framework.test import APIClient

        self._ticket('active')
        self._ticket('refunded')

        client = APIClient()
        client.force_authenticate(self.buyer)
        response = client.get('/api/v1/marketplace/events/my-tickets/?status=active')
        self.assertEqual(
            {row['status'] for row in response.data['data']}, {'active'},
        )

    def test_ticket_exposes_flat_event_id_and_order_link(self):
        from rest_framework.test import APIClient

        ticket = self._ticket('active')
        client = APIClient()
        client.force_authenticate(self.buyer)
        response = client.get('/api/v1/marketplace/events/my-tickets/')
        row = response.data['data'][0]
        self.assertEqual(row['event_id'], str(ticket.event_id))


class ProductPurchaseSignalTests(TestCase):
    """Products had no purchase signal in any layer."""

    def setUp(self):
        self.buyer, self.buyer_profile = _mk_user('prodbuyer@example.com', 'prodbuyer')
        self.seller, self.seller_profile = _mk_user('prodseller@example.com', 'prodseller')

    def test_a_bought_product_reports_is_purchased_with_its_order(self):
        from apps.marketplace.models import Order, OrderItem, Product

        product = Product.objects.create(
            name='Bought Thing', brand='Acme', category='equipment',
            description='d', recommended_by=self.seller_profile,
        )
        order = Order.objects.create(buyer=self.buyer_profile, status='paid')
        OrderItem.objects.create(
            order=order, item_type='product', product=product, title=product.name,
            quantity=1,
        )

        from rest_framework.test import APIClient

        client = APIClient()
        client.force_authenticate(self.buyer)
        response = client.get(f'/api/v1/marketplace/products/{product.pk}/')
        self.assertEqual(response.status_code, 200, response.content)
        self.assertTrue(
            response.data['data']['is_purchased'],
            'A product has to be able to tell the buyer they already own it.',
        )
        self.assertEqual(response.data['data']['purchase_order_ids'], [str(order.id)])

    def test_a_cancelled_order_is_not_a_purchase(self):
        from apps.marketplace.models import Order, OrderItem, Product

        product = Product.objects.create(
            name='Cancelled Thing', brand='Acme', category='equipment',
            description='d', recommended_by=self.seller_profile,
        )
        order = Order.objects.create(buyer=self.buyer_profile, status='cancelled')
        OrderItem.objects.create(
            order=order, item_type='product', product=product, title=product.name, quantity=1,
        )

        from rest_framework.test import APIClient

        client = APIClient()
        client.force_authenticate(self.buyer)
        response = client.get(f'/api/v1/marketplace/products/{product.pk}/')
        self.assertFalse(response.data['data']['is_purchased'])

    def test_another_buyers_purchase_does_not_leak(self):
        from apps.marketplace.models import Order, OrderItem, Product

        product = Product.objects.create(
            name='Someone Elses', brand='Acme', category='equipment',
            description='d', recommended_by=self.seller_profile,
        )
        order = Order.objects.create(buyer=self.seller_profile, status='paid')
        OrderItem.objects.create(
            order=order, item_type='product', product=product, title=product.name, quantity=1,
        )

        from rest_framework.test import APIClient

        client = APIClient()
        client.force_authenticate(self.buyer)
        response = client.get(f'/api/v1/marketplace/products/{product.pk}/')
        self.assertFalse(response.data['data']['is_purchased'])


class MyLibraryEndpointTests(TestCase):
    """"Programmes" and "Meal Plans" tabs need a server-side "mine" source.

    Filtering `/programmes/` on `is_purchased` happens client-side against a
    paginated, popularity-ordered list -- so a buyer's own item drops off page 1
    and simply is not there.
    """

    def setUp(self):
        self.buyer, self.buyer_profile = _mk_user('libbuyer@example.com', 'libbuyer')
        self.other, self.other_profile = _mk_user('libother@example.com', 'libother')
        self.creator, self.creator_profile = _mk_user('libcreator@example.com', 'libcreator')

    def _programme(self, title):
        from apps.marketplace.models import TrainingProgramme

        return TrainingProgramme.objects.create(
            creator=self.creator_profile, title=title, description='d',
            difficulty='beginner',
        )

    def _plan(self, title):
        from apps.marketplace.models import MealPlan

        return MealPlan.objects.create(
            creator=self.creator_profile, title=title, description='d',
            diet_type='balanced',
        )

    def test_my_programmes_returns_only_what_the_caller_bought(self):
        from apps.marketplace.models import TrainingProgrammePurchase
        from rest_framework.test import APIClient

        mine = self._programme('Mine')
        theirs = self._programme('Theirs')
        TrainingProgrammePurchase.objects.create(programme=mine, buyer=self.buyer_profile)
        TrainingProgrammePurchase.objects.create(programme=theirs, buyer=self.other_profile)

        client = APIClient()
        client.force_authenticate(self.buyer)
        response = client.get('/api/v1/marketplace/programmes/mine/')
        self.assertEqual(response.status_code, 200, response.content)
        titles = [row['title'] for row in response.data['data']]
        self.assertEqual(titles, ['Mine'])
        self.assertTrue(response.data['data'][0]['is_purchased'])

    def test_my_meal_plans_returns_only_what_the_caller_bought(self):
        from apps.marketplace.models import MealPlanPurchase
        from rest_framework.test import APIClient

        mine = self._plan('Mine')
        theirs = self._plan('Theirs')
        MealPlanPurchase.objects.create(meal_plan=mine, buyer=self.buyer_profile)
        MealPlanPurchase.objects.create(meal_plan=theirs, buyer=self.other_profile)

        client = APIClient()
        client.force_authenticate(self.buyer)
        response = client.get('/api/v1/marketplace/meal-plans/mine/')
        self.assertEqual(response.status_code, 200, response.content)
        self.assertEqual([row['title'] for row in response.data['data']], ['Mine'])

    def test_a_buyer_with_nothing_gets_an_empty_list_not_a_404(self):
        from rest_framework.test import APIClient

        client = APIClient()
        client.force_authenticate(self.buyer)
        programmes = client.get('/api/v1/marketplace/programmes/mine/')
        plans = client.get('/api/v1/marketplace/meal-plans/mine/')
        self.assertEqual(programmes.data['data'], [])
        self.assertEqual(plans.data['data'], [])

    def test_mine_requires_authentication(self):
        from rest_framework.test import APIClient

        response = APIClient().get('/api/v1/marketplace/programmes/mine/')
        self.assertIn(response.status_code, (401, 403))


class ProductListPurchaseFlagTests(TestCase):
    """The list endpoint batches ownership into one query, so cover that path."""

    def setUp(self):
        self.buyer, self.buyer_profile = _mk_user('listbuyer@example.com', 'listbuyer')
        self.seller, self.seller_profile = _mk_user('listseller@example.com', 'listseller')

    def test_the_grid_marks_owned_products(self):
        from apps.marketplace.models import Order, OrderItem, Product
        from rest_framework.test import APIClient

        owned = Product.objects.create(
            name='Owned', brand='Acme', category='equipment', description='d',
            recommended_by=self.seller_profile,
        )
        unowned = Product.objects.create(
            name='Unowned', brand='Acme', category='equipment', description='d',
            recommended_by=self.seller_profile,
        )
        order = Order.objects.create(buyer=self.buyer_profile, status='paid')
        OrderItem.objects.create(
            order=order, item_type='product', product=owned, title=owned.name, quantity=1,
        )

        client = APIClient()
        client.force_authenticate(self.buyer)
        response = client.get('/api/v1/marketplace/products/')
        self.assertEqual(response.status_code, 200, response.content)
        rows = {str(row['id']): row for row in response.data['data']}
        self.assertTrue(rows[str(owned.id)]['is_purchased'])
        self.assertEqual(rows[str(owned.id)]['purchase_order_ids'], [str(order.id)])
        self.assertFalse(rows[str(unowned.id)]['is_purchased'])
