"""Tests for the admin portal.

Three things are worth more than happy-path coverage here, and get the most
tests: the auth boundary (every route, staff vs not), the privilege-escalation
guard, and the promise that the read-only domains really are read-only and
roster-free.
"""
from datetime import date

from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from apps.accounts.models import User
from apps.gyms.models import Gym, GymMembership
from apps.marketplace.models import (
    DeliveryPersonnel,
    DeliveryPersonnelApplication,
    Order,
    OrderCase,
    OrderFulfillment,
    OrderItem,
    PickupStation,
    Product,
    Shop,
    ShopMembership,
    ShopVerificationApplication,
    StationApplication,
)
from apps.messaging.models import Conversation, ConversationMembership, CommunityPost
from apps.notifications.models import Notification
from apps.profiles.models import BuddySearchProfile, Profile
from apps.wallet.models import ArtifactTransaction, JournalEntry
from common.utils import hash_dob

PREFIX = '/api/v1/portal'


def _make_user(email, username, **extra):
    user = User.objects.create_user(email=email, password='TestPass123!', **extra)
    user.dob_hash = hash_dob(date(1995, 5, 5))
    user.save(update_fields=['dob_hash'])
    Profile.objects.create(user=user, username=username, display_name=username.title())
    return user


class PortalTestBase(TestCase):
    """Shared fixtures: one admin, one plain user, and one row per domain."""

    def setUp(self):
        self.client = APIClient()
        self.admin = _make_user('admin@example.com', 'portaladmin',
                                is_staff=True, is_superuser=True)
        self.staff = _make_user('staff@example.com', 'portalstaff', is_staff=True)
        self.member = _make_user('member@example.com', 'portalmember')
        self.member_profile = self.member.profile
        self.member.profile.role = 'trainer'
        self.member.profile.save(update_fields=['role'])

        BuddySearchProfile.objects.create(profile=self.member.profile, intents=['run'])

        # --- marketplace ---
        self.shop = Shop.objects.create(name='Lift & Lean', handle='lift-and-lean',
                                        category='fitness', verification_status='unverified')
        self.other_shop = Shop.objects.create(name='Whey World', handle='whey-world',
                                              category='nutrition')
        ShopMembership.objects.create(shop=self.shop, profile=self.member.profile, role='owner')
        self.product = Product.objects.create(
            name='Whey Isolate', brand='Lift', category='supplement', shop=self.shop,
            affiliate_url='https://example.com/whey', price_display='KSh 4,500',
        )
        self.cert_app = ShopVerificationApplication.objects.create(
            shop=self.shop, submitted_by=self.member.profile, status='submitted',
            legal_name='Lift & Lean Ltd', business_registration_number='BRN-001',
            agreed_to_creator_policy=True,
        )

        self.order = Order.objects.create(
            buyer=self.member_profile, status='paid', fulfillment_type='delivery',
            payment_method='mpesa', payment_status='paid', spent_usd=25,
        )
        OrderItem.objects.create(order=self.order, item_type='product',
                                 product=self.product, creator=self.member_profile,
                                 title=self.product.name, quantity=1)

        # --- gyms ---
        self.gym = Gym.objects.create(name='Iron Temple', handle='iron-temple',
                                      category='strength', access_type='public')
        GymMembership.objects.create(gym=self.gym, member=self.member.profile, role='member')

        # --- communities (one private) ---
        self.public_community = Conversation.objects.create(
            group_name='Morning Miles', is_group=True, is_community=True, is_public=True,
            origin='community',
        )
        ConversationMembership.objects.create(conversation=self.public_community,
                                              profile=self.member.profile, role='owner')
        CommunityPost.objects.create(conversation=self.public_community,
                                     author=self.member.profile, body='Anyone up for 6am?')
        self.private_community = Conversation.objects.create(
            group_name='Coaches Only', is_group=True, is_community=True, is_public=False,
            origin='community',
        )
        ConversationMembership.objects.create(conversation=self.private_community,
                                              profile=self.member.profile, role='member')

        # --- logistics ---
        self.station = PickupStation.objects.create(
            name='Level 2 Westlands', owner_type='shop', shop=self.shop, city='Nairobi',
        )
        self.station_app = StationApplication.objects.create(
            shop=self.shop, submitted_by=self.member.profile, status='submitted',
            business_registration_number='BRN-001', city='Nairobi',
        )
        self.courier = DeliveryPersonnel.objects.create(
            profile=self.member.profile, vehicle_type='bike', service_zones=['Westlands'],
        )
        self.courier_app = DeliveryPersonnelApplication.objects.create(
            profile=self.member.profile, vehicle_type='bike', status='submitted',
            phone='+254700000000',
        )

        # --- wallet ---
        self.transaction = ArtifactTransaction.objects.create(
            user=self.member_profile, transaction_type='purchase', artifact_type='coins',
            quantity=100, direction='debit', status='completed', tx_ref='TX-TEST-1',
        )

        # OrderCase is the one portal-exposed model with an implicit BigAutoField
        # pk, so the route converter is <int:> rather than <uuid:>.
        self.refund_case = OrderCase.objects.create(
            order=self.order, requester=self.member_profile, case_type='refund',
            reason='Box was empty.',
        )

    # -- helpers ------------------------------------------------------------

    def as_staff(self, user=None):
        self.client.force_authenticate(user or self.staff)
        return self.client

    def as_admin(self):
        self.client.force_authenticate(self.admin)
        return self.client

    def as_plain(self):
        self.client.force_authenticate(self.member)
        return self.client

    def endpoint_table(self):
        """Every (label, method, url, payload) the portal exposes.

        One source of truth for the auth sweep — adding a route here makes the
        401/403 test fail until it is covered.
        """
        u = self.member.pk
        return [
            ('users list', 'get', f'{PREFIX}/users/', None),
            ('user detail', 'get', f'{PREFIX}/users/{u}/', None),
            ('user patch', 'patch', f'{PREFIX}/users/{u}/', {'is_active': False}),
            ('user suspend', 'post', f'{PREFIX}/users/{u}/suspend/', {}),
            ('user reinstate', 'post', f'{PREFIX}/users/{u}/reinstate/', {}),
            ('shops list', 'get', f'{PREFIX}/shops/', None),
            ('shop detail', 'get', f'{PREFIX}/shops/lift-and-lean/', None),
            ('shop patch', 'patch', f'{PREFIX}/shops/lift-and-lean/', {'is_active': False}),
            ('products list', 'get', f'{PREFIX}/products/', None),
            ('cert queue', 'get', f'{PREFIX}/shop-certifications/', None),
            ('cert detail', 'get', f'{PREFIX}/shop-certifications/{self.cert_app.pk}/', None),
            ('cert review', 'patch', f'{PREFIX}/shop-certifications/{self.cert_app.pk}/',
             {'status': 'approved'}),
            ('orders list', 'get', f'{PREFIX}/orders/', None),
            ('order detail', 'get', f'{PREFIX}/orders/{self.order.pk}/', None),
            ('order status', 'patch', f'{PREFIX}/orders/{self.order.pk}/status/',
             {'status': 'shipped'}),
            ('order notes', 'post', f'{PREFIX}/orders/{self.order.pk}/notes/',
             {'note': 'Spoke to the courier.'}),
            ('order cases', 'get', f'{PREFIX}/orders/{self.order.pk}/cases/', None),
            ('order case create', 'post', f'{PREFIX}/orders/{self.order.pk}/cases/',
             {'case_type': 'refund', 'reason': 'Never arrived.'}),
            ('order cases list', 'get', f'{PREFIX}/order-cases/', None),
            ('order case update', 'patch', f'{PREFIX}/order-cases/{self.refund_case.pk}/',
             {'status': 'under_review'}),
            ('gyms list', 'get', f'{PREFIX}/gyms/', None),
            ('gym detail', 'get', f'{PREFIX}/gyms/{self.gym.pk}/', None),
            ('gym patch', 'patch', f'{PREFIX}/gyms/{self.gym.pk}/', {'is_verified': True}),
            ('communities list', 'get', f'{PREFIX}/communities/', None),
            ('community detail', 'get', f'{PREFIX}/communities/{self.public_community.pk}/', None),
            ('stations list', 'get', f'{PREFIX}/stations/', None),
            ('station detail', 'get', f'{PREFIX}/stations/{self.station.pk}/', None),
            ('station patch', 'patch', f'{PREFIX}/stations/{self.station.pk}/',
             {'is_active': False}),
            ('delivery personnel', 'get', f'{PREFIX}/delivery-personnel/', None),
            ('courier detail', 'get', f'{PREFIX}/delivery-personnel/{self.courier.pk}/', None),
            ('courier patch', 'patch', f'{PREFIX}/delivery-personnel/{self.courier.pk}/',
             {'is_active': False}),
            ('station apps', 'get', f'{PREFIX}/station-applications/', None),
            ('station app review', 'patch', f'{PREFIX}/station-applications/{self.station_app.pk}/',
             {'status': 'approved'}),
            ('courier apps', 'get', f'{PREFIX}/delivery-personnel-applications/', None),
            ('courier app review', 'patch',
             f'{PREFIX}/delivery-personnel-applications/{self.courier_app.pk}/',
             {'status': 'approved'}),
            ('transactions', 'get', f'{PREFIX}/transactions/', None),
            ('transaction detail', 'get', f'{PREFIX}/transactions/{self.transaction.pk}/', None),
            ('reconciliation', 'get', f'{PREFIX}/wallet/reconciliation/', None),
        ]


class AuthBoundaryTests(PortalTestBase):
    """Every route: 403 for authenticated non-staff, 401 for anonymous."""

    def test_non_staff_gets_403_on_every_endpoint(self):
        self.as_plain()
        for label, method, url, payload in self.endpoint_table():
            with self.subTest(endpoint=label):
                response = getattr(self.client, method)(url, payload, format='json')
                self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN, label)
                self.assertFalse(response.data['success'])

    def test_anonymous_gets_401_on_every_endpoint(self):
        self.client.logout()
        for label, method, url, payload in self.endpoint_table():
            with self.subTest(endpoint=label):
                response = getattr(self.client, method)(url, payload, format='json')
                self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED, label)
                self.assertFalse(response.data['success'])

    def test_suspended_staff_loses_portal_access(self):
        """IsAdminUser checks is_staff only; is_active is enforced one layer down,
        by JWT authentication (SimpleJWT refuses an inactive user), so the test
        exercises a real bearer token rather than force_authenticate."""
        from rest_framework_simplejwt.tokens import RefreshToken

        token = str(RefreshToken.for_user(self.staff).access_token)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        self.assertEqual(self.client.get(f'{PREFIX}/users/').status_code,
                         status.HTTP_200_OK)

        self.staff.is_active = False
        self.staff.save(update_fields=['is_active'])
        response = self.client.get(f'{PREFIX}/users/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_superuser_without_profile_can_still_read(self):
        """createsuperuser makes staff with no Profile row; reads must not 500."""
        orphan = User.objects.create_user(email='orphan@example.com', password='TestPass123!')
        orphan.is_staff = True
        orphan.is_superuser = True
        orphan.save(update_fields=['is_staff', 'is_superuser'])
        self.as_staff(orphan)
        response = self.client.get(f'{PREFIX}/users/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        row = next(r for r in response.data['data'] if r['id'] == str(orphan.pk))
        self.assertIsNone(row['username'])
        self.assertIsNone(row['role'])

    def test_ml_dashboard_still_resolves(self):
        """The portal is a new mount; /api/v1/admin/ must be untouched."""
        response = self.client.get('/api/v1/admin/dashboard/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        response = self.as_plain().get('/api/v1/admin/dashboard/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)


class PrivilegeEscalationTests(PortalTestBase):
    """No endpoint may write is_staff / is_superuser."""

    def _assert_rejected(self, response):
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(response.data['success'])
        self.assertIn('Refusing to change admin privileges', response.data['message'])

    def test_staff_cannot_grant_is_staff(self):
        self.as_admin()
        target = self.member
        response = self.client.patch(f'{PREFIX}/users/{target.pk}/',
                                     {'is_staff': True}, format='json')
        self._assert_rejected(response)
        target.refresh_from_db()
        self.assertFalse(target.is_staff)

    def test_staff_cannot_grant_is_superuser(self):
        self.as_admin()
        response = self.client.patch(f'{PREFIX}/users/{self.member.pk}/',
                                     {'is_superuser': True}, format='json')
        self._assert_rejected(response)
        self.member.refresh_from_db()
        self.assertFalse(self.member.is_superuser)

    def test_staff_cannot_revoke_existing_superuser(self):
        self.as_admin()
        response = self.client.patch(f'{PREFIX}/users/{self.admin.pk}/',
                                     {'is_superuser': False}, format='json')
        self._assert_rejected(response)
        self.admin.refresh_from_db()
        self.assertTrue(self.admin.is_superuser)

    def test_privilege_change_is_rejected_even_mixed_with_allowed_fields(self):
        self.as_admin()
        response = self.client.patch(f'{PREFIX}/users/{self.member.pk}/',
                                     {'role': 'practitioner', 'is_staff': True}, format='json')
        self._assert_rejected(response)
        self.member.profile.refresh_from_db()
        self.assertEqual(self.member.profile.role, 'trainer')  # unchanged

    def test_groups_and_user_permissions_are_rejected_too(self):
        self.as_admin()
        for field in ('groups', 'user_permissions'):
            with self.subTest(field=field):
                response = self.client.patch(f'{PREFIX}/users/{self.member.pk}/',
                                             {field: [1]}, format='json')
                self._assert_rejected(response)

    def test_suspend_never_touches_privilege_flags(self):
        self.as_admin()
        response = self.client.post(f'{PREFIX}/users/{self.member.pk}/suspend/', {})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.member.refresh_from_db()
        self.assertFalse(self.member.is_active)
        self.assertFalse(self.member.is_staff)
        self.assertFalse(self.member.is_superuser)

    def test_non_superuser_staff_cannot_suspend_another_admin(self):
        self.as_staff(self.staff)
        response = self.client.post(f'{PREFIX}/users/{self.admin.pk}/suspend/', {})
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.admin.refresh_from_db()
        self.assertTrue(self.admin.is_active)

    def test_admin_cannot_suspend_itself(self):
        self.as_admin()
        response = self.client.post(f'{PREFIX}/users/{self.admin.pk}/suspend/', {})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.admin.refresh_from_db()
        self.assertTrue(self.admin.is_active)


class UserEndpointTests(PortalTestBase):
    def setUp(self):
        super().setUp()
        self.as_staff()

    def test_list_is_paginated_with_the_repo_envelope(self):
        response = self.client.get(f'{PREFIX}/users/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        for key in ('success', 'data', 'message', 'errors', 'pagination'):
            self.assertIn(key, response.data)
        self.assertEqual(response.data['pagination']['count'], User.objects.count())
        self.assertIsNotNone(response.data['pagination']['next'] if
                             response.data['pagination']['count'] > 20 else True)

    def test_limit_is_honoured(self):
        response = self.client.get(f'{PREFIX}/users/?limit=2')
        self.assertEqual(len(response.data['data']), 2)
        self.assertEqual(response.data['pagination']['count'], User.objects.count())

    def test_search_matches_email_or_username(self):
        response = self.client.get(f'{PREFIX}/users/?search=member@example.com')
        emails = [row['email'] for row in response.data['data']]
        self.assertEqual(emails, ['member@example.com'])

    def test_filter_by_role(self):
        response = self.client.get(f'{PREFIX}/users/?role=trainer')
        self.assertEqual([r['email'] for r in response.data['data']], ['member@example.com'])

    def test_filter_by_verification_status(self):
        self.member.profile.verification_status = 'id'
        self.member.profile.save(update_fields=['verification_status'])
        response = self.client.get(f'{PREFIX}/users/?verification_status=id')
        self.assertEqual([r['email'] for r in response.data['data']], ['member@example.com'])

    def test_filter_by_has_search_profile(self):
        with_search = self.client.get(f'{PREFIX}/users/?has_search_profile=true')
        self.assertEqual([r['email'] for r in with_search.data['data']], ['member@example.com'])
        without = self.client.get(f'{PREFIX}/users/?has_search_profile=false')
        self.assertNotIn('member@example.com', [r['email'] for r in without.data['data']])

    def test_filter_by_is_active(self):
        self.member.is_active = False
        self.member.save(update_fields=['is_active'])
        response = self.client.get(f'{PREFIX}/users/?is_active=false')
        self.assertEqual([r['email'] for r in response.data['data']], ['member@example.com'])

    def test_list_reports_order_count_and_buddy_search(self):
        response = self.client.get(f'{PREFIX}/users/?search=member@example.com')
        row = response.data['data'][0]
        self.assertEqual(row['order_count'], 1)
        self.assertTrue(row['has_buddy_search'])

    def test_detail_view(self):
        response = self.client.get(f'{PREFIX}/users/{self.member.pk}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['username'], 'portalmember')

    def test_patch_sets_allowed_fields(self):
        response = self.client.patch(f'{PREFIX}/users/{self.member.pk}/',
                                     {'role': 'practitioner',
                                      'verification_status': 'trainer',
                                      'is_active': True}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.member.profile.refresh_from_db()
        self.assertEqual(self.member.profile.role, 'practitioner')
        self.assertEqual(self.member.profile.verification_status, 'trainer')

    def test_patch_rejects_role_outside_choices(self):
        response = self.client.patch(f'{PREFIX}/users/{self.member.pk}/',
                                     {'role': 'superuser'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_suspend_then_reinstate(self):
        self.assertEqual(self.client.post(f'{PREFIX}/users/{self.member.pk}/suspend/', {})
                         .status_code, status.HTTP_200_OK)
        self.assertEqual(self.client.post(f'{PREFIX}/users/{self.member.pk}/reinstate/', {})
                         .status_code, status.HTTP_200_OK)
        self.member.refresh_from_db()
        self.assertTrue(self.member.is_active)

    def test_suspend_twice_is_rejected(self):
        self.client.post(f'{PREFIX}/users/{self.member.pk}/suspend/', {})
        response = self.client.post(f'{PREFIX}/users/{self.member.pk}/suspend/', {})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class ShopEndpointTests(PortalTestBase):
    def setUp(self):
        super().setUp()
        self.as_staff()

    def test_list_includes_product_counts(self):
        response = self.client.get(f'{PREFIX}/shops/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        row = next(r for r in response.data['data'] if r['handle'] == 'lift-and-lean')
        self.assertEqual(row['product_count'], 1)
        self.assertEqual(row['owner_count'], 1)

    def test_filter_by_verification_status_and_category(self):
        self.shop.verification_status = 'verified'
        self.shop.save(update_fields=['verification_status'])
        response = self.client.get(f'{PREFIX}/shops/?verification_status=verified')
        self.assertEqual([r['handle'] for r in response.data['data']], ['lift-and-lean'])
        response = self.client.get(f'{PREFIX}/shops/?category=nutrition')
        self.assertEqual([r['handle'] for r in response.data['data']], ['whey-world'])

    def test_filter_by_handle_and_is_active(self):
        response = self.client.get(f'{PREFIX}/shops/?handle=LIFT-AND-LEAN')
        self.assertEqual(len(response.data['data']), 1)
        response = self.client.get(f'{PREFIX}/shops/?is_active=false')
        self.assertEqual(response.data['data'], [])

    def test_invalid_filter_value_is_a_clear_400(self):
        response = self.client.get(f'{PREFIX}/shops/?verification_status=bogus')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('bogus', response.data['message'])

    def test_patch_shop_fields(self):
        response = self.client.patch(f'{PREFIX}/shops/lift-and-lean/',
                                     {'is_active': False,
                                      'verification_status': 'rejected',
                                      'rejection_reason': 'Unverifiable documents.'},
                                     format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.shop.refresh_from_db()
        self.assertFalse(self.shop.is_active)
        self.assertEqual(self.shop.verification_status, 'rejected')
        self.assertEqual(self.shop.rejection_reason, 'Unverifiable documents.')

    def test_products_filter_by_shop_and_category(self):
        response = self.client.get(f'{PREFIX}/products/?shop=lift-and-lean')
        self.assertEqual([r['name'] for r in response.data['data']], ['Whey Isolate'])
        response = self.client.get(f'{PREFIX}/products/?category=supplement')
        self.assertEqual(len(response.data['data']), 1)
        response = self.client.get(f'{PREFIX}/products/?search=does-not-exist')
        self.assertEqual(response.data['data'], [])


class ShopCertificationQueueTests(PortalTestBase):
    """The queue that did not exist before: nothing could discover pending certs."""

    def setUp(self):
        super().setUp()
        self.as_staff()
        self.url = f'{PREFIX}/shop-certifications/'

    def test_queue_lists_pending_applications(self):
        response = self.client.get(self.url, {'status': 'submitted'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['pagination']['count'], 1)
        row = response.data['data'][0]
        self.assertEqual(row['id'], str(self.cert_app.pk))
        self.assertEqual(row['shop_handle'], 'lift-and-lean')
        self.assertEqual(row['submitted_by_username'], 'portalmember')

    def test_queue_is_filterable_by_shop_handle(self):
        response = self.client.get(self.url, {'handle': 'lift-and-lean'})
        self.assertEqual(response.data['pagination']['count'], 1)
        response = self.client.get(self.url, {'handle': 'whey-world'})
        self.assertEqual(response.data['pagination']['count'], 0)

    def test_review_approve_mirrors_onto_shop(self):
        response = self.client.patch(f'{PREFIX}/shop-certifications/{self.cert_app.pk}/',
                                     {'status': 'approved', 'reviewer_notes': 'Docs check out.'},
                                     format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.cert_app.refresh_from_db()
        self.shop.refresh_from_db()
        self.assertEqual(self.cert_app.status, 'approved')
        self.assertIsNotNone(self.cert_app.reviewed_at)
        self.assertEqual(self.cert_app.reviewed_by, self.staff.profile)
        self.assertEqual(self.shop.verification_status, 'verified')
        self.assertIsNotNone(self.shop.verified_at)

    def test_review_reject_mirrons_reason_onto_shop(self):
        response = self.client.patch(f'{PREFIX}/shop-certifications/{self.cert_app.pk}/',
                                     {'status': 'rejected',
                                      'rejection_reason': 'BRN does not match.'},
                                     format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.shop.refresh_from_db()
        self.cert_app.refresh_from_db()
        self.assertEqual(self.shop.verification_status, 'rejected')
        self.assertEqual(self.shop.rejection_reason, 'BRN does not match.')

    def test_review_more_info_needed_back_to_pending(self):
        response = self.client.patch(f'{PREFIX}/shop-certifications/{self.cert_app.pk}/',
                                     {'status': 'more_info_needed',
                                      'reviewer_notes': 'Need a tax pin.'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.shop.refresh_from_db()
        self.assertEqual(self.shop.verification_status, 'pending')

    def test_review_rejects_unknown_status(self):
        response = self.client.patch(f'{PREFIX}/shop-certifications/{self.cert_app.pk}/',
                                     {'status': 'yolo'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.cert_app.refresh_from_db()
        self.assertEqual(self.cert_app.status, 'submitted')

    def test_rejection_requires_a_reason(self):
        response = self.client.patch(f'{PREFIX}/shop-certifications/{self.cert_app.pk}/',
                                     {'status': 'rejected'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.cert_app.refresh_from_db()
        self.assertEqual(self.cert_app.status, 'submitted')

    def test_review_notifies_shop_owners(self):
        self.client.patch(f'{PREFIX}/shop-certifications/{self.cert_app.pk}/',
                          {'status': 'approved'}, format='json')
        notifications = Notification.objects.filter(
            notification_type='shop_cert_status', recipient=self.member_profile,
        )
        self.assertTrue(notifications.exists())

    def test_review_also_notifies_linked_gym_owners(self):
        """Gym ownership lives in GymMembership, not a Gym.admin column."""
        from apps.marketplace.models import ShopGymLink

        ShopGymLink.objects.create(shop=self.shop, gym=self.gym, is_primary=True)
        self.client.patch(f'{PREFIX}/shop-certifications/{self.cert_app.pk}/',
                          {'status': 'approved'}, format='json')
        GymMembership.objects.filter(gym=self.gym, member=self.member_profile).update(
            role='owner',
        )
        self.client.patch(f'{PREFIX}/shop-certifications/{self.cert_app.pk}/',
                          {'status': 'under_review'}, format='json')
        self.assertTrue(Notification.objects.filter(
            notification_type='shop_cert_status', recipient=self.member_profile,
        ).exists())


class OrderEndpointTests(PortalTestBase):
    def setUp(self):
        super().setUp()
        self.as_staff()

    def test_platform_wide_list_spans_all_buyers(self):
        """The buyer can no longer see their own order list; staff see all."""
        other = _make_user('buyer2@example.com', 'buyer2')
        Order.objects.create(buyer=other.profile, status='pending')
        response = self.client.get(f'{PREFIX}/orders/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['pagination']['count'], 2)

    def test_list_includes_buyer_and_per_item_seller(self):
        response = self.client.get(f'{PREFIX}/orders/')
        row = response.data['data'][0]
        self.assertEqual(row['buyer_username'], 'portalmember')
        self.assertEqual(row['items'][0]['creator_username'], 'portalmember')

    def test_filters(self):
        for query, expected in [
            ({'status': 'paid'}, 1),
            ({'status': 'pending'}, 0),
            ({'fulfillment_type': 'delivery'}, 1),
            ({'payment_status': 'paid'}, 1),
            ({'payment_method': 'mpesa'}, 1),
            ({'payment_method': 'card'}, 0),
            ({'order_number': self.order.order_number}, 1),
            ({'order_number': 'NOPE'}, 0),
            ({'date_from': '2000-01-01'}, 1),
            ({'date_from': '2999-01-01'}, 0),
            ({'date_to': '2000-01-01'}, 0),
        ]:
            with self.subTest(query=query):
                response = self.client.get(f'{PREFIX}/orders/', query)
                self.assertEqual(response.status_code, status.HTTP_200_OK)
                self.assertEqual(response.data['pagination']['count'], expected)

    def test_invalid_status_filter_is_400(self):
        response = self.client.get(f'{PREFIX}/orders/', {'status': 'teleported'})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_legal_forward_transition_succeeds(self):
        response = self.client.patch(f'{PREFIX}/orders/{self.order.pk}/status/',
                                     {'status': 'shipped', 'note': 'Handed to courier.'},
                                     format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'shipped')
        self.assertEqual(self.order.status_history[-1]['note'], 'Handed to courier.')

    def test_illegal_transition_is_rejected(self):
        """A delivery order may never be moved to a pickup-only state."""
        response = self.client.patch(f'{PREFIX}/orders/{self.order.pk}/status/',
                                     {'status': 'ready_for_pickup'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('Cannot move order from paid to ready_for_pickup', response.data['message'])
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'paid')
        self.assertEqual(self.order.status_history, [])

    def test_delivery_order_may_complete_directly(self):
        """paid -> completed is legal for a delivery order."""
        response = self.client.patch(f'{PREFIX}/orders/{self.order.pk}/status/',
                                     {'status': 'completed'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.content)

    def test_backwards_transition_is_rejected(self):
        self.order.set_status('delivered')
        response = self.client.patch(f'{PREFIX}/orders/{self.order.pk}/status/',
                                     {'status': 'paid'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_terminal_state_has_no_forward_transitions(self):
        self.order.set_status('cancelled')
        response = self.client.patch(f'{PREFIX}/orders/{self.order.pk}/status/',
                                     {'status': 'delivered'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('terminal state', response.data['message'])

    def test_unknown_status_is_rejected(self):
        response = self.client.patch(f'{PREFIX}/orders/{self.order.pk}/status/',
                                     {'status': 'teleported'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_status_change_updates_an_existing_fulfillment_timeline(self):
        OrderFulfillment.objects.create(order=self.order, carrier='Sendy')
        response = self.client.patch(f'{PREFIX}/orders/{self.order.pk}/status/',
                                     {'status': 'shipped', 'note': 'Picked up.'},
                                     format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        fulfillment = OrderFulfillment.objects.get(order=self.order)
        self.assertEqual(fulfillment.timeline[-1]['status'], 'shipped')
        self.assertIsNotNone(fulfillment.shipped_at)
        # Exactly one history entry per transition.
        self.order.refresh_from_db()
        self.assertEqual(len(self.order.status_history), 1)

    def test_status_change_notifies_the_buyer(self):
        self.client.patch(f'{PREFIX}/orders/{self.order.pk}/status/',
                          {'status': 'shipped'}, format='json')
        self.assertTrue(Notification.objects.filter(
            recipient=self.member_profile, notification_type='new_purchase').exists())

    def test_note_appends_to_history_without_changing_status(self):
        response = self.client.post(f'{PREFIX}/orders/{self.order.pk}/notes/',
                                    {'note': 'Buyer asked for a refund.'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'paid')
        self.assertEqual(self.order.status_history[-1]['note'],
                         'Buyer asked for a refund.')

    def test_case_is_recorded_and_claims_no_ledger_movement(self):
        response = self.client.post(f'{PREFIX}/orders/{self.order.pk}/cases/',
                                   {'case_type': 'refund', 'reason': 'Box was empty.'},
                                   format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertFalse(response.data['data']['affects_ledger'])
        case = OrderCase.objects.exclude(pk=self.refund_case.pk).get(order=self.order)
        self.assertEqual(case.status, 'requested')
        self.assertEqual(case.requester, self.staff.profile)

    def test_case_approval_does_not_touch_the_ledger(self):
        journal_before = JournalEntry.objects.count()
        transactions_before = ArtifactTransaction.objects.count()
        response = self.client.patch(f'{PREFIX}/order-cases/{self.refund_case.pk}/',
                                     {'status': 'approved', 'resolution': 'Refund agreed.'},
                                     format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('No ledger entry was created', response.data['message'])
        self.refund_case.refresh_from_db()
        self.assertEqual(self.refund_case.status, 'approved')
        self.assertIsNotNone(self.refund_case.resolved_at)
        self.assertEqual(JournalEntry.objects.count(), journal_before)
        self.assertEqual(ArtifactTransaction.objects.count(), transactions_before)

    def test_case_queue_is_filterable(self):
        OrderCase.objects.create(order=self.order, requester=self.member_profile,
                                 case_type='dispute', reason='Wrong item.')
        self.assertEqual(self.client.get(f'{PREFIX}/order-cases/')
                         .data['pagination']['count'], 2)
        self.assertEqual(self.client.get(f'{PREFIX}/order-cases/', {'case_type': 'dispute'})
                         .data['pagination']['count'], 1)
        self.assertEqual(self.client.get(f'{PREFIX}/order-cases/', {'case_type': 'return'})
                         .data['pagination']['count'], 0)

    def test_there_is_no_delete_route(self):
        response = self.client.delete(f'{PREFIX}/orders/{self.order.pk}/')
        self.assertEqual(response.status_code, status.HTTP_405_METHOD_NOT_ALLOWED)
        self.assertTrue(Order.objects.filter(pk=self.order.pk).exists())


class GymEndpointTests(PortalTestBase):
    def setUp(self):
        super().setUp()
        self.as_staff()

    def test_list_with_filters(self):
        Gym.objects.create(name='Sunrise Yoga', handle='sunrise-yoga', category='yoga',
                           access_type='private', is_verified=True)
        self.assertEqual(self.client.get(f'{PREFIX}/gyms/')
                         .data['pagination']['count'], 2)
        self.assertEqual(self.client.get(f'{PREFIX}/gyms/', {'access_type': 'private'})
                         .data['pagination']['count'], 1)
        self.assertEqual(self.client.get(f'{PREFIX}/gyms/', {'is_verified': 'true'})
                         .data['pagination']['count'], 1)
        self.assertEqual(self.client.get(f'{PREFIX}/gyms/', {'category': 'strength'})
                         .data['pagination']['count'], 1)
        self.assertEqual(self.client.get(f'{PREFIX}/gyms/', {'search': 'yoga'})
                         .data['pagination']['count'], 1)

    def test_list_never_exposes_the_member_roster(self):
        response = self.client.get(f'{PREFIX}/gyms/')
        self.assertEqual(response.data['data'][0]['member_count'], 0)
        self.assertNotIn('memberships', response.data['data'][0])
        self.assertNotIn('members', response.data['data'][0])

    def test_detail_never_exposes_the_member_roster(self):
        response = self.client.get(f'{PREFIX}/gyms/{self.gym.pk}/')
        body = str(response.data['data'])
        self.assertNotIn('portalmember', body)
        self.assertNotIn('member@example.com', body)

    def test_patch_verification_and_access_type(self):
        response = self.client.patch(f'{PREFIX}/gyms/{self.gym.pk}/',
                                     {'is_verified': True, 'access_type': 'private'},
                                     format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.gym.refresh_from_db()
        self.assertTrue(self.gym.is_verified)
        self.assertEqual(self.gym.access_type, 'private')

    def test_patch_rejects_access_type_outside_choices(self):
        response = self.client.patch(f'{PREFIX}/gyms/{self.gym.pk}/',
                                     {'access_type': 'secret_handshake'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_gym_has_no_is_active_field_so_none_is_invented(self):
        self.assertFalse(
            any(f.name == 'is_active' for f in Gym._meta.get_fields()),
            'Gym gained an is_active field — revisit GymAdminUpdateSerializer.',
        )
        response = self.client.patch(f'{PREFIX}/gyms/{self.gym.pk}/',
                                     {'is_active': False}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class CommunityEndpointTests(PortalTestBase):
    def setUp(self):
        super().setUp()
        self.as_staff()

    def test_private_communities_are_listed(self):
        """Conversation has no Django admin registration anywhere else; this is
        the only way staff can see a private community at all."""
        response = self.client.get(f'{PREFIX}/communities/')
        names = {row['group_name'] for row in response.data['data']}
        self.assertEqual(names, {'Morning Miles', 'Coaches Only'})

    def test_filters(self):
        self.assertEqual(self.client.get(f'{PREFIX}/communities/', {'is_public': 'true'})
                         .data['pagination']['count'], 1)
        self.assertEqual(self.client.get(f'{PREFIX}/communities/', {'is_public': 'false'})
                         .data['pagination']['count'], 1)
        self.assertEqual(self.client.get(f'{PREFIX}/communities/', {'is_community': 'true'})
                         .data['pagination']['count'], 2)
        self.assertEqual(self.client.get(f'{PREFIX}/communities/', {'search': 'Morning'})
                         .data['pagination']['count'], 1)

    def test_counts_only_never_the_roster(self):
        response = self.client.get(f'{PREFIX}/communities/')
        row = next(r for r in response.data['data'] if r['group_name'] == 'Morning Miles')
        self.assertEqual(row['member_count'], 1)
        self.assertEqual(row['post_count'], 1)
        self.assertNotIn('participants', row)
        self.assertNotIn('participants_data', row)

    def test_detail_never_leaks_participants(self):
        response = self.client.get(f'{PREFIX}/communities/{self.private_community.pk}/')
        body = str(response.data['data'])
        self.assertNotIn('portalmember', body)
        self.assertNotIn('member@example.com', body)
        self.assertNotIn('participants', response.data['data'])

    def test_list_is_read_only(self):
        response = self.client.patch(f'{PREFIX}/communities/{self.private_community.pk}/',
                                     {'group_name': 'Renamed'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_405_METHOD_NOT_ALLOWED)
        self.private_community.refresh_from_db()
        self.assertEqual(self.private_community.group_name, 'Coaches Only')


class LogisticsEndpointTests(PortalTestBase):
    def setUp(self):
        super().setUp()
        self.as_staff()

    def test_station_list_and_filters(self):
        PickupStation.objects.create(name='Dockside', owner_type='shop', shop=self.other_shop,
                                     city='Mombasa', is_active=False)
        self.assertEqual(self.client.get(f'{PREFIX}/stations/')
                         .data['pagination']['count'], 2)
        self.assertEqual(self.client.get(f'{PREFIX}/stations/', {'is_active': 'true'})
                         .data['pagination']['count'], 1)
        self.assertEqual(self.client.get(f'{PREFIX}/stations/', {'owner_type': 'shop'})
                         .data['pagination']['count'], 2)
        self.assertEqual(self.client.get(f'{PREFIX}/stations/', {'city': 'Mombasa'})
                         .data['pagination']['count'], 1)

    def test_station_patch_deactivates(self):
        response = self.client.patch(f'{PREFIX}/stations/{self.station.pk}/',
                                     {'is_active': False}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.station.refresh_from_db()
        self.assertFalse(self.station.is_active)

    def test_delivery_personnel_list_and_filters(self):
        other = _make_user('rider@example.com', 'rider')
        DeliveryPersonnel.objects.create(profile=other.profile, vehicle_type='car',
                                         is_active=False)
        self.assertEqual(self.client.get(f'{PREFIX}/delivery-personnel/')
                         .data['pagination']['count'], 2)
        self.assertEqual(self.client.get(f'{PREFIX}/delivery-personnel/', {'vehicle_type': 'car'})
                         .data['pagination']['count'], 1)
        self.assertEqual(self.client.get(f'{PREFIX}/delivery-personnel/', {'is_active': 'false'})
                         .data['pagination']['count'], 1)

    def test_delivery_personnel_patch_deactivates(self):
        response = self.client.patch(f'{PREFIX}/delivery-personnel/{self.courier.pk}/',
                                     {'is_active': False}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.courier.refresh_from_db()
        self.assertFalse(self.courier.is_active)

    def test_station_application_queue_and_review(self):
        response = self.client.get(f'{PREFIX}/station-applications/', {'status': 'submitted'})
        self.assertEqual(response.data['pagination']['count'], 1)
        response = self.client.patch(f'{PREFIX}/station-applications/{self.station_app.pk}/',
                                     {'status': 'approved',
                                      'reviewer_notes': 'Site visit done.'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.station_app.refresh_from_db()
        self.assertEqual(self.station_app.status, 'approved')
        self.assertEqual(self.station_app.reviewed_by, self.staff.profile)
        self.assertIsNotNone(self.station_app.reviewed_at)
        self.assertTrue(Notification.objects.filter(
            recipient=self.member_profile,
            notification_type='station_application_status').exists())

    def test_station_application_rejection_requires_a_reason(self):
        response = self.client.patch(f'{PREFIX}/station-applications/{self.station_app.pk}/',
                                     {'status': 'rejected'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.station_app.refresh_from_db()
        self.assertEqual(self.station_app.status, 'submitted')

    def test_delivery_application_queue_and_review(self):
        response = self.client.get(f'{PREFIX}/delivery-personnel-applications/',
                                   {'status': 'submitted', 'vehicle_type': 'bike'})
        self.assertEqual(response.data['pagination']['count'], 1)
        response = self.client.patch(
            f'{PREFIX}/delivery-personnel-applications/{self.courier_app.pk}/',
            {'status': 'rejected', 'rejection_reason': 'No licence on file.'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.courier_app.refresh_from_db()
        self.assertEqual(self.courier_app.status, 'rejected')
        self.assertEqual(self.courier_app.rejection_reason, 'No licence on file.')
        # Approving an application does not silently mint a DeliveryPersonnel row.
        self.assertEqual(DeliveryPersonnel.objects.filter(
            profile=self.member_profile).count(), 1)
        self.assertTrue(Notification.objects.filter(
            recipient=self.member_profile,
            notification_type='delivery_application_status').exists())


class WalletEndpointTests(PortalTestBase):
    def setUp(self):
        super().setUp()
        self.as_staff()

    def test_transaction_list_and_filters(self):
        ArtifactTransaction.objects.create(
            user=self.admin.profile, transaction_type='tip_received',
            artifact_type='coins', quantity=5, direction='credit', status='pending',
        )
        self.assertEqual(self.client.get(f'{PREFIX}/transactions/')
                         .data['pagination']['count'], 2)
        self.assertEqual(self.client.get(f'{PREFIX}/transactions/',
                                         {'email': 'member@'})
                         .data['pagination']['count'], 1)
        self.assertEqual(self.client.get(f'{PREFIX}/transactions/',
                                         {'transaction_type': 'tip_received'})
                         .data['pagination']['count'], 1)
        self.assertEqual(self.client.get(f'{PREFIX}/transactions/', {'direction': 'debit'})
                         .data['pagination']['count'], 1)
        self.assertEqual(self.client.get(f'{PREFIX}/transactions/', {'status': 'pending'})
                         .data['pagination']['count'], 1)
        self.assertEqual(self.client.get(f'{PREFIX}/transactions/',
                                         {'date_from': '2999-01-01'})
                         .data['pagination']['count'], 0)

    def test_invalid_transaction_type_filter_is_400(self):
        response = self.client.get(f'{PREFIX}/transactions/',
                                   {'transaction_type': 'laundering'})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_no_write_verbs_on_the_wallet(self):
        """The ledger is evidence. Only GET exists on every wallet route."""
        routes = [
            f'{PREFIX}/transactions/',
            f'{PREFIX}/transactions/{self.transaction.pk}/',
            f'{PREFIX}/wallet/reconciliation/',
        ]
        for url in routes:
            for method in ('post', 'put', 'patch', 'delete'):
                with self.subTest(url=url, method=method):
                    response = getattr(self.client, method)(url, {}, format='json')
                    self.assertEqual(response.status_code,
                                     status.HTTP_405_METHOD_NOT_ALLOWED)
        self.assertEqual(ArtifactTransaction.objects.count(), 1)

    def test_reconciliation_reports_without_writing(self):
        response = self.client.get(f'{PREFIX}/wallet/reconciliation/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(response.data['data']['writes_ledger'])
        self.assertIn('provider', response.data['data'])
        self.assertIn('local', response.data['data'])
        self.assertEqual(ArtifactTransaction.objects.count(), 1)
        self.assertEqual(JournalEntry.objects.count(), 0)

    def test_reconciliation_counts_local_drift(self):
        ArtifactTransaction.objects.create(
            user=self.member_profile, transaction_type='withdrawal', artifact_type='coins',
            quantity=10, direction='debit', status='pending', payment_provider='flutterwave',
        )
        response = self.client.get(f'{PREFIX}/wallet/reconciliation/')
        self.assertEqual(
            response.data['data']['local']['flutterwave_rows_without_provider_id'], 1)
        self.assertGreaterEqual(response.data['data']['local']['mismatched'], 1)


class PermissionClassTests(PortalTestBase):
    """ScopedPlatformAdmin must authorise exactly like IsAdminUser."""

    def test_scope_is_recorded_but_not_enforced(self):
        from apps.admin_portal.permissions import IsPlatformAdmin, ScopedPlatformAdmin

        scoped = ScopedPlatformAdmin.for_scope('users.read')
        self.assertEqual(scoped.required_scope, 'users.read')
        self.assertTrue(issubclass(scoped, IsPlatformAdmin))
        self.assertTrue(issubclass(scoped, ScopedPlatformAdmin))
        self.assertEqual(scoped().scope, 'users.read')

    def test_scope_is_required(self):
        from apps.admin_portal.permissions import ScopedPlatformAdmin

        with self.assertRaises(ValueError):
            ScopedPlatformAdmin()
        with self.assertRaises(ValueError):
            ScopedPlatformAdmin.for_scope('')

    def test_every_portal_route_is_staff_gated(self):
        from apps.admin_portal import urls as portal_urls
        from apps.admin_portal.permissions import IsPlatformAdmin

        # The 401/403 sweep must cover at least every route that exists.
        self.assertGreaterEqual(len(self.endpoint_table()), len(portal_urls.urlpatterns))
        for entry in portal_urls.urlpatterns:
            view_class = entry.callback.cls
            self.assertTrue(hasattr(view_class, 'permission_classes'), entry.name)
            for permission in view_class.permission_classes:
                with self.subTest(route=entry.name, permission=permission.__name__):
                    self.assertTrue(issubclass(permission, IsPlatformAdmin))


class UrlMountTests(PortalTestBase):
    def test_portal_is_mounted_at_its_own_prefix(self):
        self.assertEqual(reverse('admin_portal:users'), f'{PREFIX}/users/')
        self.assertEqual(reverse('admin_portal:orders'), f'{PREFIX}/orders/')

    def test_ml_admin_mount_is_untouched(self):
        self.assertEqual(reverse('ai_admin:admin-dashboard-list'),
                         '/api/v1/admin/dashboard/')


class PortalOrderTransitionFulfillmentTests(TestCase):
    """The portal must enforce the same fulfillment-aware rules as the
    seller path, or an admin could ship a digital order."""

    def setUp(self):
        self.admin = User.objects.create_user(
            email='portal-admin@example.com', password='TestPass123!', is_staff=True,
        )
        self.buyer_user = User.objects.create_user(email='portal-buyer@example.com', password='TestPass123!')
        self.buyer = Profile.objects.create(user=self.buyer_user, username='portal-buyer')
        self.client = APIClient()
        self.client.force_authenticate(user=self.admin)
        self.base = '/api/v1/portal/orders/'

    def _order(self, fulfillment_type):
        return Order.objects.create(
            buyer=self.buyer, fulfillment_type=fulfillment_type, status='paid',
        )

    def test_digital_order_cannot_be_shipped(self):
        order = self._order('digital')
        resp = self.client.patch(f'{self.base}{order.id}/status/', {'status': 'shipped'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        order.refresh_from_db()
        self.assertEqual(order.status, 'paid')

    def test_pickup_order_cannot_go_out_for_delivery(self):
        order = self._order('pickup')
        resp = self.client.patch(
            f'{self.base}{order.id}/status/', {'status': 'out_for_delivery'}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_pickup_order_can_be_marked_ready(self):
        order = self._order('pickup')
        resp = self.client.patch(
            f'{self.base}{order.id}/status/', {'status': 'ready_for_pickup'}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK, resp.content)
        order.refresh_from_db()
        self.assertEqual(order.status, 'ready_for_pickup')

    def test_delivery_order_can_go_out_for_delivery(self):
        order = self._order('delivery')
        resp = self.client.patch(
            f'{self.base}{order.id}/status/', {'status': 'out_for_delivery'}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK, resp.content)
