"""The event organiser API.

`MarketplaceEvent.creator` existed, and `EventTicket.is_checked_in` /
`checked_in_at` existed and had never been written by anything. There was no
attendee list, no event list for the person running the event, and no door
scanner — an organiser ran their own event off a paper spreadsheet.

These tests pin what the web and Flutter dashboards are built against: the
"my events" list (created *or* hosted by a shop they own/manage), a filterable
attendee list, check-in that cannot double-fire or check in a cancelled
ticket, a check-out that reverses it, and stats that survive an event with no
ticket tiers at all.
"""

from datetime import timedelta

from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.marketplace.models import EventTicket, MarketplaceEvent, Shop, ShopMembership
from apps.profiles.models import Profile

MINE_URL = '/api/v1/marketplace/events/mine/'


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


def make_event(creator, shop=None, **kwargs):
    defaults = {
        'title': 'Sunrise HIIT',
        'start_datetime': timezone.now() + timedelta(days=3),
        'end_datetime': timezone.now() + timedelta(days=3, hours=2),
        'capacity': 50,
    }
    defaults.update(kwargs)
    return MarketplaceEvent.objects.create(creator=creator, shop=shop, **defaults)


def make_ticket(event, holder, *, tier='Standard', ticket_status='active',
                paid=None, checked_in=False, checked_in_at=None):
    ticket = EventTicket.objects.create(
        event=event, holder=holder, tier=tier, status=ticket_status,
        price_paid_artifacts=paid if paid is not None else {'sprint': 4},
        is_checked_in=checked_in, checked_in_at=checked_in_at,
    )
    return ticket


class OrganiserTestBase(TestCase):
    def setUp(self):
        self.organiser = make_profile('eventorganiser')
        self.creator = make_profile('eventcreator')
        self.attendee = make_profile('eventattendee')
        self.other_attendee = make_profile('eventattendee2')
        self.stranger = make_profile('eventstranger')
        self.staff = make_profile('shopstaff')

        self.shop = Shop.objects.create(name='Iron Temple Goods', handle='iron-goods')
        ShopMembership.objects.create(shop=self.shop, profile=self.organiser, role='owner')
        self.other_shop = Shop.objects.create(name='Rival Goods', handle='rival-goods')
        ShopMembership.objects.create(
            shop=self.other_shop, profile=self.stranger, role='owner',
        )
        ShopMembership.objects.create(shop=self.shop, profile=self.staff, role='staff')

        self.client_org = client_for(self.organiser)
        self.client_stranger = client_for(self.stranger)
        self.client_staff = client_for(self.staff)


# ---------------------------------------------------------------------------
# My events
# ---------------------------------------------------------------------------

class OrganiserMyEventsTests(OrganiserTestBase):
    def setUp(self):
        super().setUp()
        self.mine = make_event(self.organiser, capacity=30)
        self.hosted = make_event(self.creator, shop=self.shop, title='Shop Open Day')
        self.theirs = make_event(self.stranger, shop=self.other_shop, title='Rival Expo')

    def test_lists_events_created_by_the_caller(self):
        rows = self.client_org.get(MINE_URL).json()['data']
        self.assertIn(str(self.mine.id), [row['id'] for row in rows])
        self.assertTrue(next(r for r in rows if r['id'] == str(self.mine.id))['is_organizer'])

    def test_lists_events_hosted_by_a_shop_they_own_or_manage(self):
        rows = self.client_org.get(MINE_URL).json()['data']
        row = next(r for r in rows if r['id'] == str(self.hosted.id))
        self.assertFalse(row['is_organizer'])
        self.assertEqual(row['title'], 'Shop Open Day')

    def test_a_staff_membership_is_not_enough(self):
        """Staff operate a shop; they do not get to read its attendee list."""
        rows = self.client_staff.get(MINE_URL).json()['data']
        self.assertEqual(rows, [])

    def test_other_peoples_events_never_appear(self):
        rows = self.client_stranger.get(MINE_URL).json()['data']
        self.assertEqual([row['id'] for row in rows], [str(self.theirs.id)])

    def test_row_carries_what_the_dashboard_needs(self):
        # attendee_count is the counter checkout maintains: it counts ACTIVE
        # tickets, so the used one below is deliberately absent from it. The
        # live tickets_sold_count counts both — that divergence is the reason
        # both are sent.
        make_ticket(self.mine, self.attendee, paid={'sprint': 4})
        make_ticket(self.mine, self.other_attendee, ticket_status='cancelled', paid={})
        make_ticket(self.mine, self.creator, ticket_status='used')
        self.mine.attendee_count = 1
        self.mine.save(update_fields=['attendee_count'])

        row = next(r for r in self.client_org.get(MINE_URL).json()['data']
                   if r['id'] == str(self.mine.id))
        self.assertEqual(row['capacity'], 30)
        self.assertEqual(row['attendee_count'], 1)
        self.assertEqual(row['tickets_sold_count'], 2)
        self.assertTrue(row['is_published'])
        self.assertFalse(row['is_cancelled'])
        self.assertIn('start_datetime', row)
        self.assertIn('end_datetime', row)

    def test_tickets_sold_count_excludes_cancelled_and_refunded(self):
        make_ticket(self.mine, self.attendee)
        make_ticket(self.mine, self.other_attendee, ticket_status='cancelled')
        make_ticket(self.mine, self.stranger, ticket_status='refunded')
        make_ticket(self.mine, self.creator, ticket_status='used')
        row = next(r for r in self.client_org.get(MINE_URL).json()['data']
                   if r['id'] == str(self.mine.id))
        self.assertEqual(row['tickets_sold_count'], 2)

    def test_list_is_paginated_in_the_house_envelope(self):
        for index in range(25):
            make_event(self.organiser, title=f'Gym {index}')
        body = self.client_org.get(MINE_URL).json()
        self.assertTrue(body['success'])
        self.assertEqual(body['pagination']['count'], 27)
        self.assertEqual(len(body['data']), 20)

    def test_requires_authentication(self):
        self.assertEqual(APIClient().get(MINE_URL).status_code,
                         status.HTTP_401_UNAUTHORIZED)


# ---------------------------------------------------------------------------
# Attendees
# ---------------------------------------------------------------------------

class OrganiserAttendeesTests(OrganiserTestBase):
    def setUp(self):
        super().setUp()
        self.event = make_event(self.organiser, shop=self.shop)
        self.their_event = make_event(self.stranger, shop=self.other_shop)
        self.vip = make_ticket(self.event, self.attendee, tier='VIP', paid={'sprint': 10})
        self.standard = make_ticket(self.event, self.other_attendee, paid={'barbell': 2})
        self.checked = make_ticket(self.event, self.creator, checked_in=True,
                                   checked_in_at=timezone.now())
        self.dead = make_ticket(self.event, self.staff, ticket_status='cancelled')
        self.elsewhere = make_ticket(self.their_event, self.attendee, paid={'champion': 99})

    def url(self, event=None):
        return f'/api/v1/marketplace/events/{(event or self.event).id}/attendees/'

    def test_lists_only_this_events_tickets(self):
        rows = self.client_org.get(self.url()).json()['data']
        codes = {row['ticket_code'] for row in rows}
        self.assertIn(str(self.vip.ticket_code), codes)
        self.assertNotIn(str(self.elsewhere.ticket_code), codes)

    def test_row_shape(self):
        row = next(r for r in self.client_org.get(self.url()).json()['data']
                   if r['ticket_code'] == str(self.vip.ticket_code))
        self.assertEqual(row['tier'], 'VIP')
        self.assertEqual(row['status'], 'active')
        self.assertFalse(row['is_checked_in'])
        self.assertIsNone(row['checked_in_at'])
        self.assertEqual(row['price_paid_artifacts'], {'sprint': 10})
        self.assertEqual(row['username'], self.attendee.username)
        self.assertEqual(row['display_name'], self.attendee.display_name)

    def test_no_holder_email_is_exposed(self):
        """`EventTicketSerializer` discloses username / display_name / avatar
        only, so the attendee list must not quietly widen that to `user.email`."""
        for row in self.client_org.get(self.url()).json()['data']:
            self.assertNotIn('holder', row)
            self.assertNotIn(self.attendee.user.email, str(row))

    def test_filters(self):
        get = self.client_org.get
        self.assertEqual(len(get(self.url(), {'checked_in': 'true'}).json()['data']), 1)
        self.assertEqual(len(get(self.url(), {'checked_in': 'false'}).json()['data']), 3)
        self.assertEqual(len(get(self.url(), {'status': 'cancelled'}).json()['data']), 1)
        self.assertEqual(len(get(self.url(), {'tier': 'vip'}).json()['data']), 1)
        self.assertEqual(len(get(self.url(), {'ticket_code': str(self.vip.ticket_code)}
                                ).json()['data']), 1)
        self.assertEqual(len(get(self.url(), {'status': 'active', 'tier': 'VIP'}
                                ).json()['data']), 1)

    def test_bad_filter_values_are_rejected_rather_than_ignored(self):
        for params in ({'checked_in': 'maybe'}, {'status': 'refunded-ish'},
                       {'ticket_code': 'not-a-uuid'}):
            with self.subTest(params=params):
                res = self.client_org.get(self.url(), params)
                self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_is_paginated_in_the_house_envelope(self):
        for index in range(22):
            make_ticket(self.event, self.creator, tier=f'Tier {index}')
        body = self.client_org.get(self.url()).json()
        self.assertEqual(body['pagination']['count'], 26)
        self.assertEqual(len(body['data']), 20)


# ---------------------------------------------------------------------------
# Check-in / check-out
# ---------------------------------------------------------------------------

class OrganiserCheckInTests(OrganiserTestBase):
    def setUp(self):
        super().setUp()
        self.event = make_event(self.organiser, shop=self.shop)
        self.ticket = make_ticket(self.event, self.attendee, tier='VIP', paid={'sprint': 10})
        self.their_event = make_event(self.stranger, shop=self.other_shop)
        self.their_ticket = make_ticket(self.their_event, self.attendee)

    def url(self, event=None, action='check-in'):
        return f'/api/v1/marketplace/events/{(event or self.event).id}/{action}/'

    def test_check_in_works_and_stamps_the_time(self):
        res = self.client_org.post(self.url(), {'ticket_code': str(self.ticket.ticket_code)})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()['data']
        self.assertTrue(data['is_checked_in'])
        self.assertIsNotNone(data['checked_in_at'])
        self.ticket.refresh_from_db()
        self.assertTrue(self.ticket.is_checked_in)
        self.assertIsNotNone(self.ticket.checked_in_at)

    def test_second_check_in_is_409_and_says_when(self):
        stamp = timezone.now() - timedelta(hours=2)
        self.ticket.is_checked_in = True
        self.ticket.checked_in_at = stamp
        self.ticket.save(update_fields=['is_checked_in', 'checked_in_at'])

        res = self.client_org.post(self.url(), {'ticket_code': str(self.ticket.ticket_code)})
        self.assertEqual(res.status_code, status.HTTP_409_CONFLICT)
        self.assertIn('already checked in', res.json()['message'])
        self.assertIn('check-out', res.json()['message'])

    def test_unknown_code_is_404(self):
        res = self.client_org.post(self.url(), {'ticket_code': str(self.their_ticket.ticket_code)})
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)
        res = self.client_org.post(
            self.url(), {'ticket_code': '11111111-1111-1111-1111-111111111111'},
        )
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)

    def test_a_code_from_another_event_is_404_not_a_wrong_door_check_in(self):
        """The stranger organises their own event; scanning the organiser's
        ticket there must not check it in."""
        res = self.client_stranger.post(
            self.url(event=self.their_event), {'ticket_code': str(self.ticket.ticket_code)},
        )
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)
        self.ticket.refresh_from_db()
        self.assertFalse(self.ticket.is_checked_in)

    def test_cancelled_and_refunded_tickets_are_refused(self):
        for ticket_status in ('cancelled', 'refunded'):
            with self.subTest(status=ticket_status):
                ticket = make_ticket(self.event, self.creator, ticket_status=ticket_status)
                res = self.client_org.post(self.url(), {'ticket_code': str(ticket.ticket_code)})
                self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertIn(ticket_status, res.json()['message'])
                ticket.refresh_from_db()
                self.assertFalse(ticket.is_checked_in)

    def test_missing_or_malformed_code_is_400(self):
        self.assertEqual(self.client_org.post(self.url(), {}).status_code,
                         status.HTTP_400_BAD_REQUEST)
        self.assertEqual(
            self.client_org.post(self.url(), {'ticket_code': 'abc'}).status_code,
            status.HTTP_400_BAD_REQUEST,
        )

    def test_unknown_event_is_404(self):
        res = self.client_org.post(
            '/api/v1/marketplace/events/00000000-0000-0000-0000-000000000000/check-in/',
            {'ticket_code': str(self.ticket.ticket_code)},
        )
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)


class OrganiserCheckOutTests(OrganiserTestBase):
    def setUp(self):
        super().setUp()
        self.event = make_event(self.organiser, shop=self.shop)
        self.ticket = make_ticket(self.event, self.attendee, checked_in=True,
                                  checked_in_at=timezone.now())

    def url(self, action='check-out'):
        return f'/api/v1/marketplace/events/{self.event.id}/{action}/'

    def test_check_out_reverses_a_check_in_and_clears_the_stamp(self):
        res = self.client_org.post(self.url(), {'ticket_code': str(self.ticket.ticket_code)})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()['data']
        self.assertFalse(data['is_checked_in'])
        self.assertIsNone(data['checked_in_at'])
        self.ticket.refresh_from_db()
        self.assertFalse(self.ticket.is_checked_in)
        self.assertIsNone(self.ticket.checked_in_at)

    def test_checking_out_a_ticket_that_is_not_checked_in_is_409(self):
        self.ticket.is_checked_in = False
        self.ticket.checked_in_at = None
        self.ticket.save(update_fields=['is_checked_in', 'checked_in_at'])
        res = self.client_org.post(self.url(), {'ticket_code': str(self.ticket.ticket_code)})
        self.assertEqual(res.status_code, status.HTTP_409_CONFLICT)

    def test_the_pair_round_trips(self):
        client = self.client_org
        client.post(self.url('check-in'), {'ticket_code': str(self.ticket.ticket_code)})
        self.assertEqual(
            client.post(self.url('check-in'), {'ticket_code': str(self.ticket.ticket_code)}
                        ).status_code, status.HTTP_409_CONFLICT)
        self.assertEqual(
            client.post(self.url(), {'ticket_code': str(self.ticket.ticket_code)}).status_code,
            status.HTTP_200_OK,
        )
        self.assertEqual(
            client.post(self.url('check-in'), {'ticket_code': str(self.ticket.ticket_code)}
                        ).status_code, status.HTTP_200_OK)


# ---------------------------------------------------------------------------
# Stats
# ---------------------------------------------------------------------------

class OrganiserStatsTests(OrganiserTestBase):
    def setUp(self):
        super().setUp()
        self.event = make_event(self.organiser, shop=self.shop, capacity=10)

    def url(self, event=None):
        return f'/api/v1/marketplace/events/{(event or self.event).id}/stats/'

    def test_stats_over_a_tiered_event(self):
        make_ticket(self.event, self.attendee, tier='VIP', paid={'sprint': 10})
        make_ticket(self.event, self.other_attendee, tier='VIP', paid={'sprint': 10},
                    checked_in=True, checked_in_at=timezone.now())
        make_ticket(self.event, self.creator, tier='Standard', paid={'barbell': 4})
        make_ticket(self.event, self.staff, ticket_status='cancelled', paid={'sprint': 99})
        make_ticket(self.event, self.stranger, ticket_status='refunded', paid={'sprint': 99})

        data = self.client_org.get(self.url()).json()['data']
        self.assertEqual(data['capacity'], 10)
        self.assertFalse(data['capacity_is_unlimited'])
        self.assertEqual(data['spots_remaining'], 7)
        self.assertEqual(data['tickets_sold'], 3)
        self.assertEqual(data['checked_in'], 1)
        self.assertEqual(data['gross_artifacts'], {'sprint': 20, 'barbell': 4})
        self.assertEqual(
            {row['tier']: (row['count'], row['gross_artifacts'])
             for row in data['sold_by_tier']},
            {'VIP': (2, {'sprint': 20}), 'Standard': (1, {'barbell': 4})},
        )

    def test_stats_handle_a_tier_less_event(self):
        """A single base price and no `ticket_tiers` at all must not crash —
        the tickets still carry the model default tier."""
        self.event.ticket_tiers = []
        self.event.ticket_price_artifacts = {'sprint': 5}
        self.event.save(update_fields=['ticket_tiers', 'ticket_price_artifacts'])
        make_ticket(self.event, self.attendee, tier='Standard', paid={'sprint': 5})
        make_ticket(self.event, self.other_attendee, tier='Standard', paid={'sprint': 5},
                    checked_in=True, checked_in_at=timezone.now())

        data = self.client_org.get(self.url()).json()['data']
        self.assertEqual(data['tickets_sold'], 2)
        self.assertEqual(data['checked_in'], 1)
        self.assertEqual(data['gross_artifacts'], {'sprint': 10})
        self.assertEqual(data['sold_by_tier'],
                         [{'tier': 'Standard', 'count': 2,
                           'gross_artifacts': {'sprint': 10}}])

    def test_stats_of_an_event_with_no_tickets_at_all(self):
        data = self.client_org.get(self.url()).json()['data']
        self.assertEqual(data['tickets_sold'], 0)
        self.assertEqual(data['checked_in'], 0)
        self.assertEqual(data['gross_artifacts'], {})
        self.assertEqual(data['sold_by_tier'], [])
        self.assertEqual(data['spots_remaining'], 10)

    def test_unlimited_capacity_is_flagged(self):
        self.event.capacity = 0
        self.event.save(update_fields=['capacity'])
        data = self.client_org.get(self.url()).json()['data']
        self.assertTrue(data['capacity_is_unlimited'])
        self.assertIsNone(data['spots_remaining'])

    def test_a_blank_tier_falls_back_rather_than_crashing(self):
        make_ticket(self.event, self.attendee, tier='')
        data = self.client_org.get(self.url()).json()['data']
        self.assertEqual([row['tier'] for row in data['sold_by_tier']], ['Standard'])


# ---------------------------------------------------------------------------
# Permission boundaries
# ---------------------------------------------------------------------------

class OrganiserPermissionTests(OrganiserTestBase):
    def setUp(self):
        super().setUp()
        self.event = make_event(self.organiser, shop=self.shop)
        self.ticket = make_ticket(self.event, self.attendee, paid={'sprint': 4})

    def test_a_non_organiser_gets_403_on_every_event_scoped_endpoint(self):
        stranger = self.client_stranger
        cases = [
            ('get', f'/api/v1/marketplace/events/{self.event.id}/attendees/', None),
            ('get', f'/api/v1/marketplace/events/{self.event.id}/stats/', None),
            ('post', f'/api/v1/marketplace/events/{self.event.id}/check-in/',
             {'ticket_code': str(self.ticket.ticket_code)}),
            ('post', f'/api/v1/marketplace/events/{self.event.id}/check-out/',
             {'ticket_code': str(self.ticket.ticket_code)}),
        ]
        for method, url, payload in cases:
            with self.subTest(url=url):
                res = getattr(stranger, method)(url, payload) if payload else \
                    getattr(stranger, method)(url)
                self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
                self.assertFalse(res.json()['success'])
                self.assertTrue(res.json()['message'])
        self.ticket.refresh_from_db()
        self.assertFalse(self.ticket.is_checked_in)

    def test_my_events_only_ever_returns_the_callers_own(self):
        """`mine/` is a list of what you run, not a guarded resource, so the
        guarantee is containment rather than a 403: an outsider with no events
        gets an empty list and never anybody else's."""
        nobody = client_for(make_profile('organisernobody'))
        body = nobody.get(MINE_URL).json()
        self.assertEqual(body['data'], [])
        self.assertNotIn(str(self.event.id), str(body))

        make_event(self.stranger, shop=self.other_shop, title='Rival Expo')
        rows = self.client_stranger.get(MINE_URL).json()['data']
        self.assertTrue(rows)  # they organise their own shop's event
        self.assertNotIn(str(self.event.id), [row['id'] for row in rows])

    def test_a_stranger_sees_only_their_own_shops_events(self):
        make_event(self.stranger, shop=self.other_shop, title='Rival Expo')
        rows = self.client_stranger.get(MINE_URL).json()['data']
        self.assertEqual([row['title'] for row in rows], ['Rival Expo'])

    def test_a_shop_manager_may_administer_the_shops_events(self):
        from apps.marketplace.models import ShopMembership as Membership
        manager = make_profile('shopmanager')
        Membership.objects.create(shop=self.shop, profile=manager, role='manager')
        client = client_for(manager)
        self.assertEqual(client.get(f'/api/v1/marketplace/events/{self.event.id}/stats/'
                                    ).status_code, status.HTTP_200_OK)
        self.assertEqual(client.post(
            f'/api/v1/marketplace/events/{self.event.id}/check-in/',
            {'ticket_code': str(self.ticket.ticket_code)},
        ).status_code, status.HTTP_200_OK)

    def test_permission_errors_are_never_a_silent_empty_list(self):
        res = self.client_stranger.get(
            f'/api/v1/marketplace/events/{self.event.id}/attendees/')
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIsNone(res.json()['data'])