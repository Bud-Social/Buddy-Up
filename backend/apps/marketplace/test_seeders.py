"""Tests for the DEV-ONLY marketplace/community seeders.

Kept in its own module because ``apps/marketplace/tests.py`` is concurrently
edited by another agent. ``pytest.ini`` collects ``test_*.py``, so this file
runs alongside the existing suites.

Both commands refuse to write unless ``DEBUG=True`` and Django forces
``DEBUG=False`` under test, so the real runs are wrapped in
``override_settings(DEBUG=True)``.
"""
from django.core.management import CommandError, call_command
from django.db.models import Q
from django.test import TestCase, override_settings
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.gyms.models import Gym
from apps.marketplace.models import Product, Shop
from apps.messaging.management.commands.seed_communities import (
    COMMUNITY_SEEDS,
    MAX_COMMUNITIES,
    member_pool,
)
from apps.messaging.models import (
    CommunityPost,
    CommunityPostComment,
    CommunityPostLike,
    Conversation,
    ConversationMembership,
)
from apps.profiles.models import Profile


def visible_products():
    """The exact compliance filter from ProductListView.get."""
    return Product.objects.filter(is_active=True).filter(
        ~Q(category='supplement') | (
            Q(
                category='supplement',
                supplement_registration_number__gt='',
                supplement_claims_reviewed=True,
            ) & (
                Q(supplement_registration_expiry__isnull=True)
                | Q(supplement_registration_expiry__gte=timezone.now().date())
            )
        )
    )


class SeederTestBase(TestCase):
    """Shared fixtures: enough profiles, shops and gyms for both seeders."""

    def make_profiles(self, count=14):
        profiles = []
        for i in range(count):
            user = User.objects.create_user(
                email=f'seeder{i}@example.com', password='TestPass123!',
            )
            user.is_adult = True
            user.save(update_fields=['is_adult'])
            profiles.append(Profile.objects.create(
                user=user,
                username=f'seeder{i}',
                display_name=f'Seeder {i}',
                # Trainers first so the recommender/member pool matches
                # production ordering.
                role='trainer' if i < 4 else ('practitioner' if i < 8 else 'user'),
                privacy_level='public',
            ))
        return profiles

    def make_shops(self, count=3):
        return [
            Shop.objects.create(name=f'Shop {i}', handle=f'shop-{i}')
            for i in range(count)
        ]

    def make_gyms(self, count=3):
        return [
            Gym.objects.create(name=f'Gym {i}', handle=f'gym{i}')
            for i in range(count)
        ]

    def auth_client_for(self, profile):
        client = APIClient()
        refresh = RefreshToken.for_user(profile.user)
        client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        return client


class SeedProductsTests(SeederTestBase):
    """seed_products must populate the Products tab and open the gate."""

    def setUp(self):
        self.profiles = self.make_profiles()
        self.shops = self.make_shops()

    @override_settings(DEBUG=True)
    def test_seeds_catalog_and_distributes_across_shops(self):
        call_command('seed_products', verbosity=0)
        catalog = Product.objects.exclude(category='supplement')
        self.assertEqual(catalog.count(), 20)
        # Every category the Products tab offers gets rows.
        categories = set(catalog.values_list('category', flat=True))
        self.assertEqual(categories, {'equipment', 'gear', 'apparel', 'book', 'digital'})
        # Spread over the existing shops rather than piling onto one.
        self.assertEqual(
            Product.objects.values('shop').distinct().count(), len(self.shops),
        )
        # The card needs these five fields or it renders blank.
        for product in Product.objects.all():
            self.assertTrue(product.image_url.startswith('https://images.unsplash.com/photo-'))
            self.assertTrue(product.brand)
            self.assertTrue(product.price_display.startswith('$'))
            self.assertIsNotNone(product.recommended_by)
            self.assertEqual(product.content_rating, 'general')
            self.assertFalse(product.stock_tracking_enabled)

    @override_settings(DEBUG=True)
    def test_images_are_distinct_and_clicks_varied(self):
        call_command('seed_products', verbosity=0)
        seeded = Product.objects.exclude(affiliate_url='https://example.com/product')
        self.assertEqual(
            seeded.values('image_url').distinct().count(), seeded.count(),
        )
        self.assertGreater(seeded.values('click_count').distinct().count(), 5)

    @override_settings(DEBUG=True)
    def test_delivery_modes_are_explicit(self):
        call_command('seed_products', verbosity=0)
        for product in Product.objects.all():
            self.assertTrue(product.delivery_modes)
            self.assertTrue(
                set(product.delivery_modes) <= {'digital', 'pickup', 'delivery'}
            )

    @override_settings(DEBUG=True)
    def test_compliant_supplements_pass_the_gate(self):
        call_command('seed_products', verbosity=0)
        supps = Product.objects.filter(
            affiliate_url__contains='buddyup.example',
        ).filter(category='supplement')
        self.assertEqual(supps.count(), 2)
        for supp in supps:
            self.assertTrue(supp.supplement_registration_number)
            self.assertTrue(supp.supplement_claims_reviewed)
            self.assertGreater(supp.supplement_registration_expiry, timezone.now().date())
            self.assertIn(supp, visible_products())

    @override_settings(DEBUG=True)
    def test_repairs_existing_non_compliant_supplements(self):
        hidden = []
        for i in range(3):
            hidden.append(Product.objects.create(
                name=f'Legacy Whey {i}',
                brand='Optimum Nutrition',
                category='supplement',
                affiliate_url='https://example.com/product',
                supplement_registration_number='',
                supplement_claims_reviewed=False,
            ))
        self.assertEqual(visible_products().filter(category='supplement').count(), 0)

        # Repair-only: no catalog rows and no compliant supplements seeded.
        call_command(
            'seed_products', '--count', '0', '--categories', 'equipment', verbosity=0,
        )

        self.assertEqual(visible_products().filter(category='supplement').count(), 3)
        self.assertEqual(Product.objects.count(), 3)
        regs = set()
        for product in hidden:
            product.refresh_from_db()
            self.assertTrue(product.supplement_registration_number)
            self.assertTrue(product.supplement_claims_reviewed)
            self.assertGreater(product.supplement_registration_expiry, timezone.now().date())
            regs.add(product.supplement_registration_number)
        self.assertEqual(len(regs), 3, 'repair must not hand out duplicate reg numbers')

    @override_settings(DEBUG=True)
    def test_products_tab_returns_rows_end_to_end(self):
        call_command('seed_products', verbosity=0)
        resp = self.auth_client_for(self.profiles[0]).get('/api/v1/marketplace/products/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        payload = resp.json()
        self.assertEqual(payload['pagination']['count'], 22)
        self.assertEqual(len(payload['data']), 20)
        row = payload['data'][0]
        for field in ('image_url', 'name', 'brand', 'price_display', 'recommended_by'):
            self.assertTrue(row[field], f'{field} missing from product card')

    @override_settings(DEBUG=True)
    def test_rerun_is_idempotent(self):
        call_command('seed_products', verbosity=0)
        before = list(Product.objects.values_list('name', flat=True))
        call_command('seed_products', verbosity=0)
        self.assertEqual(list(Product.objects.values_list('name', flat=True)), before)
        self.assertEqual(Product.objects.count(), 22)

    @override_settings(DEBUG=True)
    def test_categories_filter_restricts_the_catalog(self):
        call_command('seed_products', '--categories', 'gear', verbosity=0)
        catalog = Product.objects.exclude(category='supplement')
        self.assertEqual(set(catalog.values_list('category', flat=True)), {'gear'})
        self.assertEqual(Product.objects.filter(category='supplement').count(), 0)

    @override_settings(DEBUG=True)
    def test_count_caps_the_catalog(self):
        call_command('seed_products', '--count', '3', verbosity=0)
        self.assertEqual(Product.objects.exclude(category='supplement').count(), 3)

    def test_dry_run_writes_nothing(self):
        call_command('seed_products', '--dry-run', verbosity=0)
        self.assertEqual(Product.objects.count(), 0)

    def test_refuses_without_debug(self):
        with self.assertRaisesMessage(CommandError, 'DEBUG=True'):
            call_command('seed_products', verbosity=0)

    def test_rejects_unknown_category(self):
        with self.assertRaisesMessage(CommandError, 'Unknown categor'):
            call_command('seed_products', '--categories', 'spaceship', '--dry-run', verbosity=0)

    @override_settings(DEBUG=True)
    def test_no_repair_leaves_rows_hidden(self):
        Product.objects.create(
            name='Legacy Whey', brand='Optimum Nutrition', category='supplement',
            affiliate_url='https://example.com/product',
        )
        call_command(
            'seed_products', '--count', '0', '--categories', 'equipment',
            '--no-repair', verbosity=0,
        )
        # Only the legacy row exists and --no-repair left it gated.
        self.assertEqual(Product.objects.count(), 1)
        self.assertEqual(visible_products().filter(category='supplement').count(), 0)


class SeedCommunitiesTests(SeederTestBase):
    """seed_communities must produce communities the API will actually serve."""

    def setUp(self):
        self.profiles = self.make_profiles()
        self.gyms = self.make_gyms()

    @override_settings(DEBUG=True)
    def test_creates_community_flagged_group_and_community(self):
        call_command('seed_communities', verbosity=0)
        self.assertEqual(Conversation.objects.filter(is_community=True).count(), 9)
        self.assertEqual(
            Conversation.objects.filter(is_community=True, is_group=True).count(), 9,
        )
        # 6 public for Discover, 3 private.
        self.assertEqual(
            Conversation.objects.filter(is_community=True, is_public=True).count(), 6,
        )
        self.assertEqual(
            Conversation.objects.filter(is_community=True, is_public=False).count(), 3,
        )
        self.assertLessEqual(Conversation.objects.filter(is_community=True).count(), MAX_COMMUNITIES)

    @override_settings(DEBUG=True)
    def test_every_roster_shape_and_gym_link(self):
        call_command('seed_communities', verbosity=0)
        for conv in Conversation.objects.filter(is_community=True):
            roles = list(
                conv.memberships.values_list('role', flat=True),
            )
            self.assertEqual(roles.count('owner'), 1, conv.group_name)
            self.assertEqual(roles.count('admin'), 2, conv.group_name)
            self.assertGreaterEqual(roles.count('member'), 5, conv.group_name)
            self.assertLessEqual(roles.count('member'), 8, conv.group_name)
            self.assertIsNotNone(conv.group_gym, conv.group_name)
            self.assertTrue(conv.invite_code)
            self.assertTrue(conv.cover_url.startswith('https://'))
            self.assertTrue(conv.group_avatar_url.startswith('https://'))

    @override_settings(DEBUG=True)
    def test_membership_mirrors_participants(self):
        """Both tables are mandatory: the posts feed 403s without membership."""
        call_command('seed_communities', verbosity=0)
        for conv in Conversation.objects.filter(is_community=True):
            participants = set(conv.participants.values_list('pk', flat=True))
            members = set(conv.memberships.values_list('profile_id', flat=True))
            self.assertEqual(participants, members, conv.group_name)

    @override_settings(DEBUG=True)
    def test_pinned_post_plus_feed_and_engagement(self):
        call_command('seed_communities', verbosity=0)
        conv = Conversation.objects.filter(is_community=True).first()
        posts = list(conv.community_posts.all())
        self.assertGreaterEqual(len(posts), 4)
        self.assertEqual(posts[0].is_pinned, True)
        self.assertEqual(sum(1 for p in posts if p.is_pinned), 1)
        # Every post has an author who is a member of its own community.
        member_ids = set(conv.memberships.values_list('profile_id', flat=True))
        for post in posts:
            self.assertIn(post.author_id, member_ids)
        # Counters match reality and comment bodies are required.
        for post in posts:
            self.assertEqual(post.like_count, CommunityPostLike.objects.filter(post=post).count())
            self.assertEqual(post.comment_count, CommunityPostComment.objects.filter(post=post).count())
        for comment in CommunityPostComment.objects.all():
            self.assertTrue(comment.body.strip())
        # Engagement exists: at least one like and one comment overall.
        self.assertGreater(CommunityPostLike.objects.count(), 0)
        self.assertGreater(CommunityPostComment.objects.count(), 0)

    @override_settings(DEBUG=True)
    def test_no_minor_or_test_accounts_seeded(self):
        call_command('seed_communities', verbosity=0)
        banned = ('teen', 'parent', 'stalecheck', 'flowtest', 'live', 'redir', 'flow', 'notice')
        usernames = set(
            Conversation.objects.filter(is_community=True)
            .values_list('participants__username', flat=True)
        )
        for name in usernames:
            self.assertFalse(
                any(name == p or name.startswith(p) for p in banned),
                f'{name} must not be seeded into a community',
            )

    @override_settings(DEBUG=True)
    def test_discover_and_posts_feed_serve_rows(self):
        call_command('seed_communities', verbosity=0)
        conv = Conversation.objects.filter(is_community=True, is_public=True).first()
        member = Profile.objects.get(pk=conv.memberships.first().profile_id)
        client = self.auth_client_for(member)

        resp = client.get('/api/v1/messaging/communities/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertTrue(resp.json()['data']['discover'])

        resp = client.get(f'/api/v1/messaging/communities/{conv.id}/posts/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(resp.json()['data']), 4)

    @override_settings(DEBUG=True)
    def test_outsider_is_403_on_private_posts_feed(self):
        call_command('seed_communities', verbosity=0)
        private = Conversation.objects.filter(is_community=True, is_public=False).first()
        outsider = Profile.objects.exclude(
            pk__in=private.memberships.values_list('profile_id', flat=True),
        ).first()
        resp = self.auth_client_for(outsider).get(
            f'/api/v1/messaging/communities/{private.id}/posts/',
        )
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)

    @override_settings(DEBUG=True)
    def test_rerun_is_idempotent(self):
        call_command('seed_communities', verbosity=0)
        snapshot = (
            Conversation.objects.filter(is_community=True).count(),
            ConversationMembership.objects.count(),
            CommunityPost.objects.count(),
            CommunityPostLike.objects.count(),
            CommunityPostComment.objects.count(),
        )
        call_command('seed_communities', verbosity=0)
        self.assertEqual(
            (
                Conversation.objects.filter(is_community=True).count(),
                ConversationMembership.objects.count(),
                CommunityPost.objects.count(),
                CommunityPostLike.objects.count(),
                CommunityPostComment.objects.count(),
            ),
            snapshot,
        )

    @override_settings(DEBUG=True)
    def test_public_only_and_gym_filters(self):
        call_command('seed_communities', '--public-only', verbosity=0)
        self.assertEqual(
            Conversation.objects.filter(is_community=True, is_public=False).count(), 0,
        )
        self.assertEqual(Conversation.objects.filter(is_community=True).count(), 6)

        call_command('seed_communities', '--gym', 'Gym 1', verbosity=0)
        linked = Conversation.objects.filter(is_community=True, group_gym=self.gyms[1])
        self.assertTrue(linked.exists())
        self.assertEqual(
            Conversation.objects.filter(is_community=True).count(), 7,
        )

    def test_dry_run_writes_nothing(self):
        call_command('seed_communities', '--dry-run', verbosity=0)
        self.assertEqual(Conversation.objects.filter(is_community=True).count(), 0)
        self.assertEqual(CommunityPost.objects.count(), 0)

    def test_refuses_without_debug(self):
        with self.assertRaisesMessage(CommandError, 'DEBUG=True'):
            call_command('seed_communities', verbosity=0)

    def test_count_is_capped(self):
        # --dry-run so the DEBUG guard does not fire before the cap is checked.
        with self.assertRaisesMessage(CommandError, f'capped at {MAX_COMMUNITIES}'):
            call_command('seed_communities', '--count', '25', '--dry-run', verbosity=0)

    def test_rejects_unknown_gym(self):
        with self.assertRaisesMessage(CommandError, 'Unknown gym'):
            call_command('seed_communities', '--gym', 'Nowhere Gym', '--dry-run', verbosity=0)

    def test_member_pool_excludes_test_accounts(self):
        for name in ('teen', 'parent', 'stalecheck3', 'flowtest1', 'live123', 'redir', 'flow', 'notice'):
            user = User.objects.create_user(email=f'{name}@example.com', password='TestPass123!')
            Profile.objects.create(user=user, username=name, display_name=name, role='user')
        pool = {p.username for p in member_pool()}
        for name in ('teen', 'parent', 'stalecheck3', 'flowtest1', 'live123', 'redir', 'flow', 'notice'):
            self.assertNotIn(name, pool)

    def test_seed_catalog_stays_within_the_list_endpoint_budget(self):
        self.assertLessEqual(len(COMMUNITY_SEEDS), MAX_COMMUNITIES)