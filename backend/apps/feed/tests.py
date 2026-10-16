from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.profiles.models import Profile, BuddyRelationship
from apps.feed.models import Post, Poll, PollOption, PollVote
from apps.accounts.views import _provision_social_user, _generate_username
from apps.feed.ai_ranking import paginate_ranked


def _client_for(user):
    client = APIClient()
    refresh = RefreshToken.for_user(user)
    client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
    return client


def _make_user(username):
    user = User.objects.create_user(
        email=f'{username}@example.com', password='TestPass123!',
        dob_hash='x' * 64, is_adult=True,
    )
    Profile.objects.create(user=user, username=username, display_name=username.title())
    return user


class PollMinMaxTests(TestCase):
    """Multi-select bounds are enforced server-side at vote time."""

    def setUp(self):
        self.user = _make_user('poller')
        self.post = Post.objects.create(author=self.user.profile, post_type='poll', body='Pick')
        self.poll = Poll.objects.create(
            post=self.post, question='Pick some',
            allow_multiple=True, min_selections=1, max_selections=3,
        )
        self.options = [
            PollOption.objects.create(poll=self.poll, text=f'Opt {i}', order=i)
            for i in range(5)
        ]
        self.url = f'/api/v1/feed/{self.post.id}/poll/vote/'
        self.client = _client_for(self.user)

    def test_vote_within_bounds_succeeds(self):
        ids = [str(o.id) for o in self.options[:2]]
        res = self.client.post(self.url, {'option_ids': ids}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(PollVote.objects.filter(voter=self.user.profile).count(), 2)

    def test_vote_above_max_rejected(self):
        ids = [str(o.id) for o in self.options[:4]]
        res = self.client.post(self.url, {'option_ids': ids}, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(PollVote.objects.filter(voter=self.user.profile).count(), 0)

    def test_ballot_replacement_removes_unselected_votes(self):
        ids = [str(o.id) for o in self.options[:2]]
        self.client.post(self.url, {'option_ids': ids}, format='json')
        # Resubmit a ballot containing only the second option.
        res = self.client.post(self.url, {'option_ids': ids[1:]}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        remaining = set(PollVote.objects.filter(voter=self.user.profile)
                        .values_list('option_id', flat=True))
        self.assertEqual(remaining, {self.options[1].id})

    def test_single_choice_poll_still_enforces_one_vote(self):
        single = Post.objects.create(author=self.user.profile, post_type='poll', body='One')
        poll = Poll.objects.create(post=single, question='One only', allow_multiple=False)
        opts = [PollOption.objects.create(poll=poll, text=f'O{i}', order=i) for i in range(3)]
        url = f'/api/v1/feed/{single.id}/poll/vote/'
        res = self.client.post(url, {'option_ids': [str(opts[0].id), str(opts[1].id)]}, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class FeedVisibilityTests(TestCase):
    """buddies/gym_members/private audiences are enforced, not just stored."""

    def setUp(self):
        self.author = _make_user('author')
        self.buddy = _make_user('buddy')
        self.stranger = _make_user('stranger')
        BuddyRelationship.objects.create(
            from_user=self.author.profile, to_user=self.buddy.profile, status='confirmed',
        )
        self.buddies_post = Post.objects.create(
            author=self.author.profile, post_type='text',
            body='For buddies only', visibility='buddies',
        )

    def test_buddy_sees_buddies_post_in_feed_and_detail(self):
        res = _client_for(self.buddy).get('/api/v1/feed/', {'tab': 'for_you'})
        self.assertEqual(res.status_code, 200)
        ids = [p['id'] for p in res.data['data']]
        self.assertIn(str(self.buddies_post.id), ids)

        detail = _client_for(self.buddy).get(f'/api/v1/feed/{self.buddies_post.id}/')
        self.assertEqual(detail.status_code, 200)

    def test_stranger_cannot_read_buddies_post(self):
        detail = _client_for(self.stranger).get(f'/api/v1/feed/{self.buddies_post.id}/')
        self.assertEqual(detail.status_code, 404)

        comments = _client_for(self.stranger).get(f'/api/v1/feed/{self.buddies_post.id}/comments/')
        self.assertEqual(comments.status_code, 404)

    def test_author_always_sees_own_post(self):
        detail = _client_for(self.author).get(f'/api/v1/feed/{self.buddies_post.id}/')
        self.assertEqual(detail.status_code, 200)

    def test_private_post_hidden_from_everyone_but_author(self):
        private = Post.objects.create(
            author=self.author.profile, post_type='text',
            body='secret', visibility='private',
        )
        res = _client_for(self.buddy).get(f'/api/v1/feed/{private.id}/')
        self.assertEqual(res.status_code, 404)


class SocialProvisioningTests(TestCase):
    """Social login provisioning: atomicity, collision-safe usernames."""

    def setUp(self):
        self.existing = User.objects.create_user(email='taken@example.com', password='TestPass123!')
        Profile.objects.create(user=self.existing, username='john', display_name='John')

    def test_username_collision_gets_suffix(self):
        candidate = _generate_username('john')
        self.assertNotEqual(candidate, 'john')
        self.assertTrue(candidate.startswith('john'))

    def test_provision_new_social_user_has_no_adult_flag(self):
        user, created = _provision_social_user(
            'newgoogle@example.com', 'google_id', 'gid-123', name='Johnny', picture='',
        )
        self.assertTrue(created)
        self.assertFalse(user.is_adult)          # age gate NOT bypassed
        self.assertTrue(user.email_verified)
        self.assertEqual(user.google_id, 'gid-123')
        self.assertIsNotNone(user.profile)       # profile always provisioned

    def test_provision_links_existing_email_account(self):
        user, created = _provision_social_user(
            'taken@example.com', 'google_id', 'gid-999', name='John',
        )
        self.assertFalse(created)
        self.assertEqual(user.google_id, 'gid-999')
        # Existing profile untouched.
        self.assertEqual(user.profile.username, 'john')

    def test_self_heals_missing_profile(self):
        orphan = User.objects.create_user(email='orphan@example.com', password='TestPass123!')
        Profile.objects.create(user=orphan, username='orphan', display_name='Orphan')
        # Simulate a legacy account whose profile row vanished.
        Profile.objects.filter(user=orphan).delete()
        user, created = _provision_social_user(
            'orphan@example.com', 'apple_id', 'aid-1', name='Orphan',
        )
        self.assertFalse(created)
        self.assertTrue(User.objects.get(email='orphan@example.com').profile is not None)


class PostIdempotencyTests(TestCase):
    def setUp(self):
        self.user = _make_user('idempotent')
        self.client = _client_for(self.user)
        self.url = '/api/v1/feed/create/'

    def test_repeated_idempotency_key_returns_same_post(self):
        payload = {'post_type': 'text', 'body': 'Only once'}
        first = self.client.post(
            self.url, payload, format='json', HTTP_IDEMPOTENCY_KEY='request-123',
        )
        second = self.client.post(
            self.url, payload, format='json', HTTP_IDEMPOTENCY_KEY='request-123',
        )
        self.assertEqual(first.status_code, status.HTTP_201_CREATED)
        self.assertEqual(second.status_code, status.HTTP_200_OK)
        self.assertEqual(first.data['data']['id'], second.data['data']['id'])
        self.assertEqual(Post.objects.filter(author=self.user.profile).count(), 1)

    def test_long_idempotency_key_is_rejected(self):
        response = self.client.post(
            self.url, {'post_type': 'text', 'body': 'Nope'}, format='json',
            HTTP_IDEMPOTENCY_KEY='x' * 129,
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class RankedPaginationTests(TestCase):
    def test_stale_cursor_is_terminal_error(self):
        with self.assertRaisesMessage(ValueError, 'Invalid or expired feed cursor.'):
            paginate_ranked([{'post_id': 'current'}], 'stale', 20)


class GymFeedModerationTests(TestCase):
    """Pinning and deleting a gym-feed post are the same authority question.

    They shipped as two different answers -- pin accepted owner/co_owner/
    moderator, delete accepted the author only -- so a gym moderator could pin
    a member's post and then had no way to remove it. This pins one matrix
    against both verbs.
    """

    URL_DELETE = '/api/v1/feed/{post_id}/'
    URL_PIN = '/api/v1/feed/{post_id}/pin/'

    def setUp(self):
        from apps.gyms.models import Gym, GymMembership
        self.GymMembership = GymMembership
        self.gym = Gym.objects.create(name='Moderated Gym', handle='moderatedgym', category='fitness')
        self.author = _make_user('feedauthor')
        self.owner = _make_user('gymowner')
        self.co_owner = _make_user('gymcoowner')
        self.moderator = _make_user('gymmod')
        self.ordinary_member = _make_user('gymplain')
        self.bystander = _make_user('nobody')

        # `_make_user` hands back the User; memberships hang off the Profile.
        for user, role in (
            (self.owner, 'owner'),
            (self.co_owner, 'co_owner'),
            (self.moderator, 'moderator'),
            (self.ordinary_member, 'member'),
        ):
            GymMembership.objects.create(
                gym=self.gym, member=user.profile, role=role, subscription_active=True,
            )

        self.gym_post = Post.objects.create(
            author=self.author.profile, post_type='text', body='Gym feed post', gym_tag=self.gym,
        )
        self.public_post = Post.objects.create(
            author=self.author.profile, post_type='text', body='No gym here')

    def _delete(self, post, actor):
        return _client_for(actor).delete(self.URL_DELETE.format(post_id=post.id))

    def _pin(self, post, actor):
        return _client_for(actor).post(self.URL_PIN.format(post_id=post.id))

    def test_moderator_can_delete_a_members_gym_post(self):
        res = self._delete(self.gym_post, self.moderator)
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.data)
        self.gym_post.refresh_from_db()
        self.assertTrue(self.gym_post.is_deleted)

    def test_owner_and_co_owner_can_delete_a_members_gym_post(self):
        for actor in (self.owner, self.co_owner):
            with self.subTest(actor=actor.email):
                post = Post.objects.create(
            author=self.author.profile, post_type='text', body=f'for {actor.email}', gym_tag=self.gym,
                )
                res = self._delete(post, actor)
                self.assertEqual(res.status_code, status.HTTP_200_OK, res.data)

    def test_ordinary_member_cannot_delete_someone_elses_gym_post(self):
        res = self._delete(self.gym_post, self.ordinary_member)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN, res.data)
        self.gym_post.refresh_from_db()
        self.assertFalse(self.gym_post.is_deleted)

    def test_a_non_member_cannot_delete_a_gym_post(self):
        res = self._delete(self.gym_post, self.bystander)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN, res.data)

    def test_gym_authority_does_not_leak_to_the_whole_platform(self):
        """A gym moderator has power over their gym's feed only."""
        res = self._delete(self.public_post, self.moderator)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN, res.data)

        res = self._delete(self.public_post, self.owner)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN, res.data)

    def test_author_can_always_delete_their_own_post(self):
        res = self._delete(self.gym_post, self.author)
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.data)

    def test_pin_and_delete_agree_on_who_may_act(self):
        """The regression this class exists for: the two verbs must not drift."""
        for actor in (self.owner, self.co_owner, self.moderator, self.author):
            with self.subTest(actor=actor.email):
                post = Post.objects.create(
            author=self.author.profile, post_type='text', body=f'agreement {actor.email}', gym_tag=self.gym,
                )
                pin = self._pin(post, actor)
                delete = self._delete(post, actor)
                self.assertEqual(
                    pin.status_code, delete.status_code,
                    f'pin and delete disagree for {actor.email}',
                )
                self.assertEqual(pin.status_code, status.HTTP_200_OK)

        for actor in (self.ordinary_member, self.bystander):
            with self.subTest(actor=actor.email):
                post = Post.objects.create(
            author=self.author.profile, post_type='text', body=f'refusal {actor.email}', gym_tag=self.gym,
                )
                pin = self._pin(post, actor)
                delete = self._delete(post, actor)
                self.assertEqual(pin.status_code, status.HTTP_403_FORBIDDEN)
                self.assertEqual(delete.status_code, status.HTTP_403_FORBIDDEN)
