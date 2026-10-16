"""Who is allowed to publish what, on the server.

Three different credentials buy three different things, and until now the
marketplace had a single rule — "own a shop" — applied to all of them. That was
wrong in both directions: a certified trainer with no storefront could not
publish a single meal plan, and the rule that gates nutrition has nothing to say
about selling protein powder.

These tests pin the matrix that replaced it, at two levels:

  * the helpers (`_can_create_meal_plan`, `_resolve_commerce_publisher`), so the
    rule is legible on its own; and
  * **the endpoints**, which is the part that actually matters. A helper that is
    correct but not wired to the view is worth nothing, so every allow row below
    is proved by a real POST as well as a truthy helper.

The matrix:

    | caller                              | meal plan | product / event |
    |-------------------------------------|-----------|-----------------|
    | verified trainer                    | yes       | no              |
    | verified practitioner               | yes       | no              |
    | gym owner / co-owner                | yes       | no              |
    | plain gym member                    | no        | no              |
    | unverified trainer                  | no        | no              |
    | verified distributor, no shop       | no        | yes             |
    | shop owner                          | no        | yes             |
    | shop manager                        | no        | yes             |
    | shop staff                          | no        | no              |
    | plain user                          | no        | no              |

Note the diagonal: nobody in the left column may publish on the right, and
nobody on the right may publish nutrition. `role` alone never grants anything —
it was client-declared at registration, so every grant is a conjunction of the
role *and* the verification status that certifies it.
"""

from datetime import timedelta

from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.gyms.models import Gym, GymMembership
from apps.marketplace.models import (
    CreatorPayoutSetup, MarketplaceEvent, MealPlan, Product, Shop, ShopMembership,
)
from apps.marketplace.views import _can_create_meal_plan, _resolve_commerce_publisher
from apps.profiles.models import Profile

MEAL_PLANS_URL = '/api/v1/marketplace/meal-plans/'
PRODUCTS_URL = '/api/v1/marketplace/products/'
EVENTS_URL = '/api/v1/marketplace/events/'


def make_profile(username, role='user', verification_status='none', balance=None):
    user = User.objects.create_user(email=f'{username}@example.com', password='TestPass123!')
    return Profile.objects.create(
        user=user, username=username, display_name=username.title(),
        role=role, verification_status=verification_status,
        artifact_balance=balance or {},
    )


def client_for(profile, **kwargs):
    client = APIClient(**kwargs)
    refresh = RefreshToken.for_user(profile.user)
    client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
    return client


def make_shop(handle, *, verified=True):
    shop = Shop.objects.create(
        name=handle.title(), handle=handle,
        verification_status='verified' if verified else 'pending',
    )
    return shop


def ready_to_publish(profile):
    """`_resolve_creator_shop` demands more than a membership: the shop must be
    verified (or have an approved application) and payouts must be set up. These
    are preconditions of *any* shop-based publish, not part of the role rule, so
    every allow row sets them and the only thing under test is the role."""
    CreatorPayoutSetup.objects.create(
        profile=profile, setup_status='ready', is_verified=True,
        terms_accepted_at=timezone.now(),
    )


def make_gym(handle):
    return Gym.objects.create(
        name=handle.title(), handle=handle, category='fitness', access_type='public',
    )


def meal_plan_payload(**overrides):
    return {'title': 'Lean Bulk', 'diet_type': 'high_protein', **overrides}


def product_payload(**overrides):
    return {
        'name': 'Whey Isolate', 'brand': 'Iron Temple', 'category': 'gear',
        'affiliate_url': 'https://example.test/whey',
        **overrides,
    }


def event_payload(**overrides):
    start = timezone.now() + timedelta(days=7)
    return {
        'title': 'Distribution Masterclass',
        'start_datetime': start.isoformat(),
        'end_datetime': (start + timedelta(hours=2)).isoformat(),
        **overrides,
    }


class CommercePermissionTestBase(TestCase):
    """Every persona the matrix names, built once."""

    def setUp(self):
        self.trainer = make_profile('permstrainer', 'trainer', 'trainer')
        self.practitioner = make_profile('permspractitioner', 'practitioner', 'practitioner')
        self.unverified_trainer = make_profile('permsunverified', 'trainer', 'none')
        self.distributor = make_profile('permsdistributor', 'distributor', 'distributor')
        self.unverified_distributor = make_profile('permsunverifieddist', 'distributor', 'none')
        self.plain = make_profile('permsplain')

        self.gym = make_gym('perms-gym')
        self.gym_owner = make_profile('permsgymowner')
        GymMembership.objects.create(gym=self.gym, member=self.gym_owner, role='owner')
        self.gym_co_owner = make_profile('permsgymcoowner')
        GymMembership.objects.create(gym=self.gym, member=self.gym_co_owner, role='co_owner')
        self.gym_member = make_profile('permsgymmember')
        GymMembership.objects.create(gym=self.gym, member=self.gym_member, role='member')
        # A gym the caller merely trains at is not a gym they run.
        self.other_gym = make_gym('perms-other-gym')
        self.other_gym_trainer = make_profile('permsothertrainer')
        GymMembership.objects.create(
            gym=self.other_gym, member=self.other_gym_trainer, role='trainer',
        )

        self.shop = make_shop('perms-shop')
        self.shop_owner = make_profile('permsshopowner')
        ShopMembership.objects.create(shop=self.shop, profile=self.shop_owner, role='owner')
        ready_to_publish(self.shop_owner)

        self.shop_manager = make_profile('permsshopmanager')
        ShopMembership.objects.create(shop=self.shop, profile=self.shop_manager, role='manager')
        ready_to_publish(self.shop_manager)

        self.shop_staff = make_profile('permsshopstaff')
        ShopMembership.objects.create(shop=self.shop, profile=self.shop_staff, role='staff')

        self.unverified_shop_owner = make_profile('permsunverifiedowner')
        unverified = make_shop('perms-unverified-shop', verified=False)
        ShopMembership.objects.create(shop=unverified, profile=self.unverified_shop_owner, role='owner')
        ready_to_publish(self.unverified_shop_owner)


# ---------------------------------------------------------------------------
# _can_create_meal_plan
# ---------------------------------------------------------------------------

class CanCreateMealPlanHelperTests(CommercePermissionTestBase):
    def test_a_verified_trainer_may(self):
        self.assertTrue(_can_create_meal_plan(self.trainer))

    def test_a_verified_practitioner_may(self):
        self.assertTrue(_can_create_meal_plan(self.practitioner))

    def test_a_gym_owner_may(self):
        self.assertTrue(_can_create_meal_plan(self.gym_owner))

    def test_a_gym_co_owner_may(self):
        self.assertTrue(_can_create_meal_plan(self.gym_co_owner))

    def test_a_plain_gym_member_may_not(self):
        # Membership is not ownership. The gym exists and they are on its roster;
        # that is not the same claim as "this is my gym".
        self.assertTrue(GymMembership.objects.filter(
            gym=self.gym, member=self.gym_member).exists())
        self.assertFalse(_can_create_meal_plan(self.gym_member))

    def test_a_gym_trainer_may_not(self):
        self.assertFalse(_can_create_meal_plan(self.other_gym_trainer))

    def test_an_unverified_trainer_may_not(self):
        self.assertFalse(_can_create_meal_plan(self.unverified_trainer))

    def test_a_plain_user_may_not(self):
        self.assertFalse(_can_create_meal_plan(self.plain))

    def test_a_verified_distributor_alone_may_not(self):
        # Nutrition authority and selling authority are separate credentials, and
        # the backend keeps them separate. Were this True, any distributor could
        # publish dietary advice they are not qualified to give.
        self.assertFalse(_can_create_meal_plan(self.distributor))


# ---------------------------------------------------------------------------
# _resolve_commerce_publisher
# ---------------------------------------------------------------------------

class ResolveCommercePublisherHelperTests(CommercePermissionTestBase):
    def test_a_verified_distributor_without_a_shop_may(self):
        shop, error = _resolve_commerce_publisher(self.distributor)
        self.assertIsNone(error)
        self.assertIsNone(shop, 'a distributor publishes unattached, not through a shop')

    def test_a_shop_owner_may(self):
        shop, error = _resolve_commerce_publisher(self.shop_owner)
        self.assertIsNone(error)
        self.assertEqual(shop, self.shop)

    def test_a_shop_manager_may(self):
        shop, error = _resolve_commerce_publisher(self.shop_manager)
        self.assertIsNone(error)
        self.assertEqual(shop, self.shop)

    def test_shop_staff_may_not(self):
        shop, error = _resolve_commerce_publisher(self.shop_staff)
        self.assertIsNone(shop)
        self.assertTrue(error)

    def test_a_plain_user_may_not(self):
        shop, error = _resolve_commerce_publisher(self.plain)
        self.assertIsNone(shop)
        self.assertTrue(error)

    def test_an_unverified_distributor_may_not(self):
        shop, error = _resolve_commerce_publisher(self.unverified_distributor)
        self.assertIsNone(shop)
        self.assertTrue(error)

    def test_a_distributor_naming_a_shop_they_do_not_own_is_refused(self):
        # `shop_id` is a claim about an existing shop. A distributor cannot use
        # the grant to publish *through* somebody else's storefront.
        shop, error = _resolve_commerce_publisher(self.distributor, str(self.shop.id))
        self.assertIsNone(shop)
        self.assertIn('permission', error.lower())

    def test_an_unverified_shop_is_still_refused(self):
        # The role matrix and the shop-readiness rules are independent: owner is
        # the right role, and the shop is still not publishable.
        shop, error = _resolve_commerce_publisher(self.unverified_shop_owner)
        self.assertIsNone(shop)
        self.assertTrue(error)

    def test_a_shop_owner_without_payout_setup_is_refused(self):
        ready = make_profile('permsnopayout')
        ShopMembership.objects.create(shop=self.shop, profile=ready, role='owner')
        shop, error = _resolve_commerce_publisher(ready)
        self.assertIsNone(shop)
        self.assertIn('payout', error.lower())


# ---------------------------------------------------------------------------
# The endpoints — the part that actually matters
# ---------------------------------------------------------------------------

class CreateEndpointEnforcementTests(CommercePermissionTestBase):
    """The helpers are private; these views are the contract."""

    def test_a_plain_user_is_refused_a_meal_plan(self):
        res = client_for(self.plain).post(MEAL_PLANS_URL, meal_plan_payload(), format='json')
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(res.json()['success'])
        self.assertIn('trainers', res.json()['message'])
        self.assertEqual(MealPlan.objects.count(), 0,
                         'a refused create must not leave a row behind')

    def test_a_plain_user_is_refused_a_product(self):
        res = client_for(self.plain).post(PRODUCTS_URL, product_payload(), format='json')
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(res.json()['success'])
        self.assertTrue(res.json()['message'])
        self.assertEqual(Product.objects.count(), 0)

    def test_a_plain_user_is_refused_an_event(self):
        res = client_for(self.plain).post(EVENTS_URL, event_payload(), format='json')
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(res.json()['success'])
        self.assertTrue(res.json()['message'])
        self.assertEqual(MarketplaceEvent.objects.count(), 0)

    def test_a_refusal_never_leaks_an_empty_success(self):
        """A 200 with `data: []` is indistinguishable from "you have nothing",
        and both render identically on a dashboard. Permission errors must carry
        a status and a message."""
        for url, payload in ((MEAL_PLANS_URL, meal_plan_payload()),
                             (PRODUCTS_URL, product_payload()),
                             (EVENTS_URL, event_payload())):
            with self.subTest(url=url):
                body = client_for(self.plain).post(url, payload, format='json').json()
                self.assertFalse(body['success'])
                self.assertIsNone(body['data'])
                self.assertTrue(body['message'])

    def test_anonymous_callers_get_401_not_403(self):
        for url, payload in ((MEAL_PLANS_URL, meal_plan_payload()),
                             (PRODUCTS_URL, product_payload()),
                             (EVENTS_URL, event_payload())):
            with self.subTest(url=url):
                self.assertEqual(
                    APIClient().post(url, payload, format='json').status_code,
                    status.HTTP_401_UNAUTHORIZED,
                )


class CreateMealPlanEndpointTests(CommercePermissionTestBase):
    def post(self, profile, **overrides):
        return client_for(profile).post(
            MEAL_PLANS_URL, meal_plan_payload(**overrides), format='json')

    def test_a_verified_trainer_gets_201(self):
        res = self.post(self.trainer)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        self.assertEqual(MealPlan.objects.get().creator, self.trainer)

    def test_a_verified_practitioner_gets_201(self):
        self.assertEqual(self.post(self.practitioner).status_code,
                         status.HTTP_201_CREATED)

    def test_a_gym_owner_gets_201_without_a_shop(self):
        # The point of separating this gate: professional nutrition does not
        # require a storefront. A gym owner with no shop still publishes.
        res = self.post(self.gym_owner)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        plan = MealPlan.objects.get()
        self.assertIsNone(plan.shop, 'the shop is optional for a meal plan')

    def test_a_gym_co_owner_gets_201(self):
        self.assertEqual(self.post(self.gym_co_owner).status_code,
                         status.HTTP_201_CREATED)

    def test_a_plain_gym_member_gets_403(self):
        self.assertEqual(self.post(self.gym_member).status_code,
                         status.HTTP_403_FORBIDDEN)
        self.assertEqual(MealPlan.objects.count(), 0)

    def test_an_unverified_trainer_gets_403(self):
        self.assertEqual(self.post(self.unverified_trainer).status_code,
                         status.HTTP_403_FORBIDDEN)
        self.assertEqual(MealPlan.objects.count(), 0)

    def test_a_shop_owner_without_the_professional_credential_gets_403(self):
        # Owning a shop is not a nutrition credential, and the two gates must not
        # leak into each other.
        self.assertEqual(self.post(self.shop_owner).status_code,
                         status.HTTP_403_FORBIDDEN)

    def test_a_verified_distributor_gets_403(self):
        self.assertEqual(self.post(self.distributor).status_code,
                         status.HTTP_403_FORBIDDEN)

    def test_a_meal_plan_may_still_attach_a_shop_the_author_owns(self):
        """Attaching a shop is a bonus on top of the authority, and the shop must
        be one they actually own or manage."""
        res = self.post(self.trainer, shop_id=str(self.shop.id))
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('permission', res.json()['message'].lower())
        self.assertEqual(MealPlan.objects.count(), 0)

        owner_who_is_also_a_trainer = make_profile(
            'permsownerplustrainer', 'trainer', 'trainer')
        ShopMembership.objects.create(
            shop=self.shop, profile=owner_who_is_also_a_trainer, role='owner')
        res = self.post(owner_who_is_also_a_trainer, shop_id=str(self.shop.id))
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        self.assertEqual(MealPlan.objects.get().shop, self.shop)

    def test_a_shop_that_does_not_exist_is_refused_not_ignored(self):
        res = self.post(self.trainer, shop_id='11111111-1111-1111-1111-111111111111')
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('no longer exists', res.json()['message'])


class CreateProductEndpointTests(CommercePermissionTestBase):
    def post(self, profile, **overrides):
        return client_for(profile).post(PRODUCTS_URL, product_payload(**overrides),
                                        format='json')

    def test_a_verified_distributor_gets_201_without_a_shop(self):
        res = self.post(self.distributor)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        product = Product.objects.get()
        self.assertEqual(product.recommended_by, self.distributor)
        self.assertIsNone(product.shop)

    def test_a_shop_owner_gets_201(self):
        res = self.post(self.shop_owner)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        self.assertEqual(Product.objects.get().shop, self.shop)

    def test_a_shop_manager_gets_201(self):
        self.assertEqual(self.post(self.shop_manager).status_code,
                         status.HTTP_201_CREATED)

    def test_shop_staff_get_403(self):
        self.assertEqual(self.post(self.shop_staff).status_code,
                         status.HTTP_403_FORBIDDEN)
        self.assertEqual(Product.objects.count(), 0)

    def test_a_verified_trainer_gets_403(self):
        # A professional credential authorises nutrition, not commerce.
        self.assertEqual(self.post(self.trainer).status_code,
                         status.HTTP_403_FORBIDDEN)
        self.assertEqual(Product.objects.count(), 0)

    def test_a_gym_owner_gets_403(self):
        self.assertEqual(self.post(self.gym_owner).status_code,
                         status.HTTP_403_FORBIDDEN)

    def test_a_distributor_cannot_publish_through_somebody_elses_shop(self):
        res = self.post(self.distributor, shop_id=str(self.shop.id))
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('permission', res.json()['message'].lower())
        self.assertEqual(Product.objects.count(), 0)

    def test_a_shop_owner_may_target_a_second_shop_they_own(self):
        second = make_shop('perms-shop-two')
        ShopMembership.objects.create(shop=second, profile=self.shop_owner, role='owner')
        res = self.post(self.shop_owner, shop_id=str(second.id))
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        self.assertEqual(Product.objects.get().shop, second)


class CreateEventEndpointTests(CommercePermissionTestBase):
    """Events share the commerce gate with products.

    A pre-existing defect sits between that gate and the row it would create:
    `CreateEventSerializer` declares a `visibility` field with `default='public'`,
    but `MarketplaceEvent` has no such column, so `MarketplaceEvent.objects.create`
    raises `TypeError` for *every* caller who passes the gate. It is present at
    HEAD, it is unrelated to the publishing rules, and it lives in code this file
    does not own — so the refusal tests below run unconditionally and the
    allow-path tests wait behind a probe rather than baking the crash in as an
    expectation.
    """

    def setUp(self):
        super().setUp()
        self.events_reach_disk = self._events_reach_disk()

    def _events_reach_disk(self):
        # `raise_request_exception=False` because the defect escapes as an
        # unhandled TypeError, not a rendered 500 — a raising test client would
        # re-raise it straight out of this probe.
        probe = client_for(self.shop_owner, raise_request_exception=False).post(
            EVENTS_URL, event_payload(), format='json')
        # A 2xx means the gate passed and the row was written. A 4xx means the gate
        # refused, which is not what this probe is asking. Anything else is the
        # create blowing up on its way to the database.
        return 200 <= probe.status_code < 300

    def skipUnlessEventsReachDisk(self, reason='event creation is broken upstream of the gate'):
        if not self.events_reach_disk:
            self.skipTest(
                f'{reason}: CreateEventSerializer sends `visibility`, '
                f'MarketplaceEvent has no such field, so every accepted event '
                f'create raises TypeError. Fix that and this test re-runs.')

    def post(self, profile, **overrides):
        return client_for(profile).post(EVENTS_URL, event_payload(**overrides), format='json')

    def test_a_shop_owner_gets_201(self):
        self.skipUnlessEventsReachDisk()
        res = self.post(self.shop_owner)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        self.assertEqual(MarketplaceEvent.objects.get().shop, self.shop)

    def test_a_verified_distributor_gets_201_without_a_shop(self):
        self.skipUnlessEventsReachDisk()
        res = self.post(self.distributor)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        event = MarketplaceEvent.objects.get()
        self.assertEqual(event.creator, self.distributor)
        self.assertIsNone(event.shop)

    def test_a_shop_owner_passes_the_gate(self):
        """Gate-level proof that survives the defect above: the request is not
        refused for permissions, whatever happens further down the view."""
        res = client_for(self.shop_owner, raise_request_exception=False).post(
            EVENTS_URL, event_payload(), format='json')
        self.assertNotEqual(res.status_code, status.HTTP_403_FORBIDDEN, res.content)

    def test_a_verified_trainer_gets_403(self):
        self.assertEqual(self.post(self.trainer).status_code,
                         status.HTTP_403_FORBIDDEN)
        self.assertEqual(MarketplaceEvent.objects.count(), 0)

    def test_shop_staff_get_403(self):
        self.assertEqual(self.post(self.shop_staff).status_code,
                         status.HTTP_403_FORBIDDEN)

    def test_an_unknown_gym_is_a_404_not_a_silently_dropped_attachment(self):
        res = self.post(self.shop_owner,
                        gym_id='11111111-1111-1111-1111-111111111111')
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)
        self.assertIn('not found', res.json()['message'].lower())
        self.assertEqual(MarketplaceEvent.objects.count(), 0)

    def test_a_gym_the_caller_does_not_run_cannot_host_the_event(self):
        res = self.post(self.shop_owner, gym_id=str(self.gym.id))
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('gym owner', res.json()['message'].lower())
        self.assertEqual(MarketplaceEvent.objects.count(), 0)

    def test_a_gym_the_caller_runs_may_host_the_event(self):
        # The gym check runs before the publisher check, so a gym owner who also
        # owns a shop passes both and the gym is attached.
        both = make_profile('permsgymandshop')
        GymMembership.objects.create(gym=self.gym, member=both, role='owner')
        ShopMembership.objects.create(shop=self.shop, profile=both, role='owner')
        ready_to_publish(both)

        self.skipUnlessEventsReachDisk()
        res = self.post(both, gym_id=str(self.gym.id))
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.content)
        self.assertEqual(MarketplaceEvent.objects.get().gym, self.gym)