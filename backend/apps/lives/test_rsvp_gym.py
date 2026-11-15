"""Gym-aware RSVP behaviour on lives: member/non-member pricing, wallet
credits, reminder preference, tier checkout and the GymWallet ledger.

Gym "anything goes wrong" cases are in test_enhancements.py — this file is
deliberately only the gym-specific paths.
"""
from datetime import timedelta

from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from apps.accounts.models import User
from apps.gyms.models import Gym, GymMembership, GymWallet
from apps.profiles.models import Profile
from apps.wallet.serializers import ARTIFACT_VALUES

from .models import BuddyLive, LiveRSVP


def _mk_user(email, username, artifacts=None):
    user = User.objects.create_user(email=email, password='TestPass123!')
    profile = Profile.objects.create(
        user=user, username=username, display_name=username.title(),
        artifact_balance=artifacts or {},
    )
    return user, profile


def _gym_live(host, gym, **kwargs):
    tomorrow = timezone.now() + timedelta(days=1)
    defaults = dict(
        title='Paid gym live', live_type='gym_live', category='strength',
        access='public', status='scheduled', scheduled_for=tomorrow,
        gym=gym, host=host,
    )
    defaults.update(kwargs)
    return BuddyLive.objects.create(**defaults)


class GymRsvpFeeTests(TestCase):
    def setUp(self):
        self.owner_user, self.owner = _mk_user('owner@rsvp.test', 'gymowner')
        self.gym = Gym.objects.create(
            name='Charging Gym', handle='charginggym', category='fitness',
            access_type='public',
        )
        GymMembership.objects.create(gym=self.gym, member=self.owner, role='owner')
        self.member_user, self.member = _mk_user('member@rsvp.test', 'member',
                                                  {'barbell': 3, 'squat': 2})
        GymMembership.objects.create(gym=self.gym, member=self.member, role='member')
        self.outsider_user, self.outsider = _mk_user('outsider@rsvp.test', 'outsider',
                                                      {'barbell': 3, 'squat': 5})
        self.member_client = APIClient()
        self.member_client.force_authenticate(self.member_user)
        self.outsider_client = APIClient()
        self.outsider_client.force_authenticate(self.outsider_user)

    def test_member_pays_member_fee(self):
        live = _gym_live(
            self.owner, self.gym,
            member_fee_artifacts={'barbell': 2},
            non_member_fee_artifacts={'squat': 3},
        )
        resp = self.member_client.post(f'/api/v1/lives/{live.id}/rsvp/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.member.refresh_from_db()
        self.assertEqual(self.member.artifact_balance.get('barbell'), 1)
        self.assertEqual(self.member.artifact_balance.get('squat'), 2)
        rsvp = LiveRSVP.objects.get(live=live, user=self.member)
        self.assertEqual(rsvp.reminder_minutes, 30)
        self.assertEqual(rsvp.fee_paid, {'barbell': 2})

    def test_non_member_pays_non_member_fee(self):
        live = _gym_live(
            self.owner, self.gym,
            member_fee_artifacts={'barbell': 2},
            non_member_fee_artifacts={'squat': 3},
        )
        resp = self.outsider_client.post(f'/api/v1/lives/{live.id}/rsvp/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        rsvp = LiveRSVP.objects.get(live=live, user=self.outsider)
        self.assertEqual(rsvp.fee_paid, {'squat': 3})

    def test_insufficient_balance_blocks_rsvp(self):
        live = _gym_live(
            self.owner, self.gym,
            member_fee_artifacts={'barbell': 5},
            non_member_fee_artifacts={'squat': 9},
        )
        resp = self.member_client.post(f'/api/v1/lives/{live.id}/rsvp/')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(LiveRSVP.objects.filter(live=live).exists())

    def test_rsvp_fees_are_credited_to_gym_wallet(self):
        live = _gym_live(
            self.owner, self.gym,
            member_fee_artifacts={'barbell': 2},
            non_member_fee_artifacts={'squat': 3},
        )
        self.member_client.post(f'/api/v1/lives/{live.id}/rsvp/')
        wallet = GymWallet.objects.get(gym=self.gym)
        self.assertEqual(wallet.balance.get('barbell'), 2)
        self.assertEqual(wallet.entries.filter(kind='live_fee').count(), 1)

    def test_cancel_refunds_and_debits_gym_wallet(self):
        live = _gym_live(
            self.owner, self.gym,
            member_fee_artifacts={'barbell': 2},
            non_member_fee_artifacts={'squat': 3},
        )
        self.member_client.post(f'/api/v1/lives/{live.id}/rsvp/')
        resp = self.member_client.delete(f'/api/v1/lives/{live.id}/rsvp/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.member.refresh_from_db()
        self.assertEqual(self.member.artifact_balance.get('barbell'), 3)
        wallet = GymWallet.objects.get(gym=self.gym)
        self.assertEqual(wallet.balance.get('barbell') or 0, 0)

    def test_reminder_preference_is_stored(self):
        live = _gym_live(self.owner, self.gym)
        resp = self.member_client.post(f'/api/v1/lives/{live.id}/rsvp/',
                                        {'reminder_minutes': 15}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        rsvp = LiveRSVP.objects.get(live=live, user=self.member)
        self.assertEqual(rsvp.reminder_minutes, 15)

    def test_reminder_zero_means_none(self):
        live = _gym_live(self.owner, self.gym)
        self.member_client.post(f'/api/v1/lives/{live.id}/rsvp/',
                                {'reminder_minutes': 0}, format='json')
        self.assertEqual(LiveRSVP.objects.get(live=live, user=self.member).reminder_minutes, 0)


class GymTierOverviewTests(TestCase):
    def setUp(self):
        self.owner_user, self.owner = _mk_user('t-owner@gym.test', 't-owner')
        self.gym = Gym.objects.create(
            name='Tier Test', handle='tiertestgym', category='fitness',
            access_type='public', location_country='KE',
        )
        GymMembership.objects.create(gym=self.gym, member=self.owner, role='owner')
        self.client = APIClient()
        self.client.force_authenticate(self.owner_user)

    def test_tier_overview_returns_kes_plans(self):
        resp = self.client.get('/api/v1/gyms/tiertestgym/tier/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        plans = resp.data['data']['plans']
        self.assertEqual(plans['regular']['amount_minor'], 0)
        self.assertEqual(plans['regular']['cap'], 50)
        self.assertEqual(plans['midlevel']['currency'], 'KES')
        self.assertGreater(plans['midlevel']['amount_minor'], 0)
        self.assertEqual(plans['executive']['cap'], None)
        self.assertEqual(resp.data['data']['currency'], 'KES')

    def test_tier_wallet_requires_owner(self):
        outsider_user, _ = _mk_user('t-out@gym.test', 't-out')
        self.client.force_authenticate(outsider_user)
        resp = self.client.get('/api/v1/gyms/tiertestgym/wallet/')
        self.assertEqual(resp.status_code, status.HTTP_404_NOT_FOUND)
        # Plans themselves are public-ish: badge explainer needs them.
        resp = self.client.get('/api/v1/gyms/tiertestgym/tier/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
