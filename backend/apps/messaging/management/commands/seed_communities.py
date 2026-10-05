"""DEV-ONLY seed for communities (Discover tab + community feed).

Why this exists: a community is a ``Conversation`` with BOTH ``is_community``
and ``is_group`` set, and a fresh database has none. That leaves the Discover
tab empty and the community feed unreachable.

The create path is mirrored exactly from ``CommunityListView.post``:

1. ``Conversation.objects.create(...)`` with ``_generate_invite_code()``,
   ``created_by`` the owner and ``last_message_at`` stamped.
2. ``conv.participants.add(owner)`` — the M2M.
3. A ``ConversationMembership`` row with role ``owner``.
4. Every other member is added to BOTH ``conv.participants`` AND a
   ``ConversationMembership`` row. Both are mandatory: the posts feed
   (``CommunityPostListView``) resolves the viewer through the membership
   table and hard-403s on a missing row even for a public community.
5. A pinned ``CommunityPost`` plus several more, authored by members, with
   likes, comments and matching ``like_count`` / ``comment_count``.

``--count`` is capped at 10 on purpose: ``CommunityListView`` has no
pagination and computes unread/last-message per row in Python.

Idempotent: communities are keyed on ``group_name`` via ``get_or_create``;
reruns skip existing communities unless ``--overwrite`` is given. Posts,
memberships, likes and comments are all ``get_or_create``, so ``--overwrite``
tops a community up rather than duplicating it.

Examples:
    manage.py seed_communities --dry-run
    manage.py seed_communities --count 9 --seed 7
    manage.py seed_communities --public-only --count 6
    manage.py seed_communities --gym "Iron Palace"
    manage.py seed_communities --overwrite
"""
import random
from urllib.parse import urlparse

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils import timezone

from apps.gyms.models import Gym
from apps.messaging.models import (
    CommunityPost,
    CommunityPostComment,
    CommunityPostLike,
    Conversation,
    ConversationMembership,
    Message,
    _generate_invite_code,
)
from apps.profiles.models import Profile

# Image convention shared by the rest of the repo's seeds.
UNSPLASH_URL = "https://images.unsplash.com/photo-{photo_id}?auto=format&fit=crop&w={width}q=80"

# The community list endpoint computes unread + last-message per row in Python
# and does not paginate, so the catalog stays small.
MAX_COMMUNITIES = 10

# Accounts that must never be seeded into a community. `teen`/`parent` are
# minor accounts (age-gated) and the rest are QA/test fixtures.
EXCLUDED_USERNAME_PREFIXES = (
    "teen",
    "parent",
    "stalecheck",
    "flowtest",
    "live",
    "redir",
    "flow",
    "notice",
)

# Per-community roster shape: 1 owner + 2 admins + 5..8 members.
ADMIN_COUNT = 2
MEMBER_COUNT_RANGE = (5, 8)

# Pinned post placed first in every community feed.
PINNED_TEMPLATE = (
    'Housekeeping: read this before posting. Keep training talk in here, keep '
    'medical advice out of it, and spot people in the group rather than in the '
    'comment section. Admins can pin, so this post stays at the top.'
)

COMMENT_BODIES = [
    'Can confirm, same thing happened to me last week.',
    'Going to try this on Saturday.',
    'Thanks for writing it up properly.',
    'Which session were you on for this?',
    'Adding this to my notes.',
    'Great result, congrats.',
]

# --- community seeds -------------------------------------------------------
# is_public drives the Discover tab: six public, three private.
# gym_index resolves against the gyms loaded from the database, so it degrades
# to None (no gym link) gracefully on a database with no gyms.

COMMUNITY_SEEDS = [
    {
        'group_name': 'Iron Palace Strength Crew',
        'description': (
            'People who train at Iron Palace and want a place to post lifts, '
            'ask about programming and find a spot partner. All levels, no '
            'one-post-wonders.'
        ),
        'is_public': True,
        'gym_index': 0,
        'cover_photo_id': '1517836357463-d25dfeac3438',
        'avatar_photo_id': '1534438327276-14e5300c3a48',
        'welcome': (
            'Welcome to the Iron Palace crew. Introduce yourself, tell us what '
            'you are training for, and say which days you are usually here.'
        ),
        'posts': [
            'Anyone else hitting a plateau on overhead press this week? Reps are fine, the weight is just not moving.',
            'Morning slots are noticeably emptier since the school term started. Anyone want a 7am spot?',
            'Reminder: rack the collars back on after your set. The day shift does not enjoy hunting for a 20.',
            'Bench day log is up. 1x5 at 100kg felt smooth, added 2.5kg for the back-off sets.',
            'Small thing that fixed my knee pain: raised the deadlift start position by an inch. YMMV obviously.',
        ],
    },
    {
        'group_name': 'Zen Flow Yoga & Mobility',
        'description': (
            'A soft landing for anyone who runs or lifts and knows they are '
            'stiff. Class talk, mobility drills and the occasional long '
            'conversation about hips.'
        ),
        'is_public': True,
        'gym_index': 1,
        'cover_photo_id': '1506126613408-eca07ce68773',
        'avatar_photo_id': '1575052814086-f385e2e2ad1b',
        'welcome': (
            'Welcome. No flexibility required to join in. Tell us what you are '
            'working on and what hurts.'
        ),
        'posts': [
            'Sunday morning flow is full again. There is a second class at 10:30 if you missed the first.',
            'Hip flexor stretch that finally worked for me after three years of trying the boring version.',
            'If your hamstrings pull at the bottom of a deadlift, try a wider stance for a set before rewriting anything.',
            'Genuinely lovely session last night, thank you for turning up and not filming every pose.',
            'Reminder that resting in a posture for two minutes is part of the exercise, not a mistake.',
        ],
    },
    {
        'group_name': 'Urban Fitness After Work',
        'description': (
            'The 6pm crowd at Urban Fitness. Share sessions, split the parking '
            'queue, and find someone to squat with after a long day.'
        ),
        'is_public': True,
        'gym_index': 2,
        'cover_photo_id': '1571902943202-507ec2618e8f',
        'avatar_photo_id': '1544367567-0f2fcb009e0b',
        'welcome': (
            'Welcome to the after-work crew. Which sessions are you on this '
            'week? We will try to share machines.'
        ),
        'posts': [
            'Cables are all taken between 6 and 7. Come at 7:15 or go straight to dumbbells.',
            'Tried the Tuesday HIIT class, absolutely wrecked, going back next week.',
            'Anyone got a decent protein shake that is not chalky? The cafe one is edible.',
            'Squats are free after 7.45 most nights. Useful if you have been putting off leg day.',
            'Traffic on the road is a mess right now, allow an extra fifteen minutes.',
        ],
    },
    {
        'group_name': 'CrossFit Central Beginners',
        'description': (
            'Absolute beginners at CrossFit Central. Scaling is normal here, '
            'nobody has to know your first session was humbling, and everyone '
            'remembers their first session.'
        ),
        'is_public': True,
        'gym_index': 3,
        'cover_photo_id': '1546483875-ad9014c88eba',
        'avatar_photo_id': '1521572163474-6864f9cf17ab',
        'welcome': (
            'Welcome. Everyone here started somewhere humbling. Ask the dumb '
            'questions, there are no bad ones.'
        ),
        'posts': [
            'First class done. Could not do any of the running, swapped everything for a bike. Nobody cared at all.',
            'What shoes should I actually buy? Currently running in trainers that are three years old.',
            'Gym staff are incredibly patient with scaling. Use that, it makes week two much better.',
            'The 7am class is the friendliest. That is my entirely unscientific finding.',
            'Post your week one numbers somewhere. Seeing other beginners progress is the whole point.',
        ],
    },
    {
        'group_name': 'Cardio Core: Runners & Rowers',
        'description': (
            'Cardio people. Pacing chat, race reports, and a lot of unsolicited '
            'opinion about Zone 2.'
        ),
        'is_public': True,
        'gym_index': 4,
        'cover_photo_id': '1574680096145-d05b474e2155',
        'avatar_photo_id': '1461896836934-ffe607ba8211',
        'welcome': (
            'Welcome. Tell us your current weekly volume and what you are '
            'training towards, even if it is just "not dying".'
        ),
        'posts': [
            'Sub-25 5k finally. Took nine months and far too much Zone 2.',
            'Rowerg is open in the mornings before work. Erg rows logged on the board if you want company.',
            'Treadmills are out of order until Thursday. Real run or stair climber, your pick.',
            'Reminder that a slow 5k is still a run. Nobody here is judging the watch.',
            'Race in three weeks. Reducing volume hard, feeling like I am doing nothing, apparently correct.',
        ],
    },
    {
        'group_name': 'Trail & Weekend Warriors',
        'description': (
            'Day hikes, trail runs and the long weekend. Route reports, gear '
            'advice, and photos of the good views.'
        ),
        'is_public': True,
        'gym_index': 0,
        'cover_photo_id': '1461896836934-ffe607ba8211',
        'avatar_photo_id': '1517502884422-41eaead166d4',
        'welcome': (
            'Welcome. Post a route you have just done, the season you did it, '
            'and whether it was worth the drive.'
        ),
        'posts': [
            'Karura forest loop at sunrise. Humid but the light was worth every wet step.',
            'Going up Ngong on Saturday, early start. Two spots left in my car.',
            'Trail shoes versus normal shoes on wet rock, has anyone tested both properly?',
            'The trails near the rift are dry for the first time in months.',
            'Bring more water than you think. I carried three litres and finished with one.',
        ],
    },
    {
        'group_name': 'Kibera Strength Squad',
        'description': (
            'Closed group for the Kibera morning squad. Private so the session '
            'plans stay in the group.'
        ),
        'is_public': False,
        'gym_index': 1,
        'cover_photo_id': '1518611012118-696072aa579a',
        'avatar_photo_id': '1517457373958-b7bdd4587205',
        'welcome': (
            'Squad only. Keep the session plan here so we stop sending it in '
            'three different chats.'
        ),
        'posts': [
            'This week: three lower sessions, one push session. Recovery walk on Sunday.',
            'Roster for Saturday is posted. Swap out early so nobody is stood around.',
            'Bringing the spare bands. If someone has not got them, borrow.',
        ],
    },
    {
        'group_name': 'Lifting Fundamentals Cohort',
        'description': (
            'Eight-week cohort working through the barbell basics together. '
            'Private so the weekly check-ins stay in one place.'
        ),
        'is_public': False,
        'gym_index': 3,
        'cover_photo_id': '1524863479829-916d8e77f114',
        'avatar_photo_id': '1584464491033-06628f3a6b7b',
        'welcome': (
            'Cohort only. Week one videos go up Monday, check in on Friday even '
            'if it is a bad week.'
        ),
        'posts': [
            'Week two check-in: squat depth is the theme. Film one set and be honest about it.',
            'Deadlift from blocks looks odd but it is the fastest fix for rounding the bar.',
            'Nobody is exempt from the deload. Especially not the people who feel great.',
            'Bringing knee sleeves if anyone left theirs here last week.',
        ],
    },
    {
        'group_name': 'Nutrition & Meal Prep Circle',
        'description': (
            'Private working group on eating consistently on a normal budget. '
            'Plans stay in the group.'
        ),
        'is_public': False,
        'gym_index': 2,
        'cover_photo_id': '1512621776951-a57141f2eefd',
        'avatar_photo_id': '1600185365483-26d7a4cc7519',
        'welcome': (
            'Group only. Bring last week what worked and what did not, and we '
            'will plan from the real numbers.'
        ),
        'posts': [
            'Sunday prep: cook the grains in bulk, it is the difference between prepping and not prepping.',
            'Protein on a budget, again: eggs, canned fish, and buying bulk before it feels exciting.',
            'Two of us are doing the six week consistency challenge. Starting Monday.',
            'Do not buy anything else until Friday. That is the entire advice this week.',
        ],
    },
]


def unsplash_url(photo_id, width=1200):
    """Community cover/avatar URL for a photo id, following the repo convention."""
    return UNSPLASH_URL.format(photo_id=photo_id, width=width)


def is_safe_url(value):
    """Mirror the API's media-URL guard: http(s), no embedded credentials."""
    try:
        parsed = urlparse(value)
    except ValueError:
        return False
    return parsed.scheme in ('http', 'https') and bool(parsed.hostname) and not parsed.username


def excluded_username(username):
    """True for minor accounts and QA fixtures we must never seed."""
    low = str(username or '').lower()
    return any(low == p or low.startswith(p) for p in EXCLUDED_USERNAME_PREFIXES)


def member_pool():
    """Profiles eligible to own or join a community.

    Trainers and practitioners come first, then verified adults, then remaining
    public members, so rosters look like real communities. Minor accounts
    (``teen``, ``parent``) and QA fixtures are never included.
    """
    qs = (
        Profile.objects.filter(user__is_active=True, user__is_staff=False, user__is_superuser=False)
        .select_related('user')
        .order_by('username')
    )
    trainers, adults, public = [], [], []
    for profile in qs:
        if excluded_username(profile.username):
            continue
        if profile.role in ('trainer', 'practitioner'):
            trainers.append(profile)
        elif getattr(profile.user, 'is_adult', False):
            adults.append(profile)
        elif profile.privacy_level == 'public':
            public.append(profile)
    return trainers + adults + public


def roster_for(pool, idx, size):
    """Deterministic roster of up to ``size`` distinct profiles for community ``idx``.

    The pool is rotated by community index so consecutive communities get
    visibly different rosters instead of the same dozen names every time.
    """
    if not pool:
        return []
    if len(pool) <= size:
        return list(pool)
    offset = (idx * 3) % len(pool)
    rotated = pool[offset:] + pool[:offset]
    return rotated[:size]


class Command(BaseCommand):
    help = "DEV-ONLY: seed communities (group_name + membership + posts) for the Discover tab and community feed."

    def add_arguments(self, parser):
        parser.add_argument(
            "--count",
            type=int,
            default=9,
            help=f"Max communities to seed, capped at {MAX_COMMUNITIES} (default: %(default)s).",
        )
        parser.add_argument(
            "--public-only",
            action="store_true",
            help="Only seed the public communities (Discover tab).",
        )
        parser.add_argument(
            "--gym",
            type=str,
            default="",
            dest="gym",
            help="Only seed communities linked to this gym name (exact match, case-insensitive).",
        )
        parser.add_argument(
            "--seed",
            type=int,
            default=42,
            help="RNG seed for roster sizes and engagement (default: %(default)s).",
        )
        parser.add_argument(
            "--overwrite",
            action="store_true",
            help="Top up communities that already exist (default: skip).",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Print what would happen without writing to the DB.",
        )

    @transaction.atomic
    def handle(self, *args, **options):
        dry_run = options["dry_run"]
        if not dry_run and not getattr(settings, "DEBUG", False):
            raise CommandError("Refusing to seed: DEV-ONLY command requires DEBUG=True.")

        count = int(options["count"] or 0)
        if count <= 0:
            raise CommandError("--count must be a positive integer.")
        if count > MAX_COMMUNITIES:
            raise CommandError(
                f"--count is capped at {MAX_COMMUNITIES}: the community list endpoint "
                "does not paginate and computes unread/last-message per row in Python."
            )
        overwrite = options["overwrite"]
        rng = random.Random(options["seed"])

        gyms = list(Gym.objects.order_by("created_at"))
        if not gyms and not dry_run:
            raise CommandError(
                "No Gym rows found, so communities would have no gym link. "
                "Seed gyms first or run with --dry-run."
            )
        seeds = self.select_seeds(
            options["public_only"], options.get("gym") or "", gyms, count,
        )
        if not seeds:
            self.stdout.write("No communities match the filters (nothing to do).")
            return

        pool = member_pool()
        if not pool and not dry_run:
            raise CommandError(
                "No eligible Profile rows for community members. "
                "Seed accounts first or run with --dry-run."
            )

        created = updated = skipped = 0
        for idx, seed in enumerate(seeds):
            # Roster: 1 owner + 2 admins + 5..8 members, all distinct.
            n_members = rng.randint(*MEMBER_COUNT_RANGE)
            roster = roster_for(pool, idx, 1 + ADMIN_COUNT + n_members)
            min_roster = 1 + ADMIN_COUNT + 1
            if len(roster) < min_roster:
                self.stdout.write(
                    self.style.WARNING(
                        f"skipping {seed['group_name']}: need at least {min_roster} "
                        f"eligible profiles, found {len(roster)}."
                    )
                )
                continue
            owner = roster[0]
            admins = roster[1:1 + ADMIN_COUNT]
            members = roster[1 + ADMIN_COUNT:]

            gym = gyms[seed['gym_index'] % len(gyms)] if gyms else None
            cover_url = unsplash_url(seed['cover_photo_id'], width=1200)
            avatar_url = unsplash_url(seed['avatar_photo_id'], width=400)
            for url in (cover_url, avatar_url):
                if not is_safe_url(url):
                    raise CommandError(f"Refusing to seed unsafe media URL: {url!r}")

            existing = Conversation.objects.filter(
                is_community=True, group_name=seed['group_name'],
            ).first()

            if dry_run:
                if existing:
                    action = "would update" if overwrite else "would skip (exists)"
                else:
                    action = "would create"
                self.stdout.write(
                    f"{action}: {seed['group_name']} public={seed['is_public']} "
                    f"gym={gym.name if gym else '-'} owner=@{owner.username} "
                    f"admins={len(admins)} members={len(members)} "
                    f"posts={1 + len(seed['posts'])}"
                )
                continue

            if existing and not overwrite:
                self.stdout.write(f"skipped (exists): {seed['group_name']}")
                skipped += 1
                continue

            # 1. The conversation itself. Mirrors CommunityListView.post.
            if existing:
                conv = existing
                conv.description = seed['description']
                conv.cover_url = cover_url
                conv.group_avatar_url = avatar_url
                conv.group_gym = gym
                conv.is_public = seed['is_public']
                conv.save(update_fields=[
                    'description', 'cover_url', 'group_avatar_url',
                    'group_gym', 'is_public',
                ])
            else:
                conv = Conversation.objects.create(
                    is_group=True,
                    is_community=True,
                    group_name=seed['group_name'][:100],
                    description=seed['description'],
                    cover_url=cover_url,
                    group_avatar_url=avatar_url,
                    group_gym=gym,
                    is_public=seed['is_public'],
                    invite_code=_generate_invite_code(),
                    created_by=owner,
                    last_message_at=timezone.now(),
                )
            # 2. Owner on the M2M.
            conv.participants.add(owner)
            # 3. Owner membership row.
            ConversationMembership.objects.get_or_create(
                conversation=conv, profile=owner,
                defaults={'role': 'owner'},
            )
            # 4. Everyone else on BOTH the M2M and the membership table. The
            #    posts feed hard-403s on a missing membership row, even for a
            #    public community.
            for role, people in (('admin', admins), ('member', members)):
                for person in people:
                    conv.participants.add(person)
                    ConversationMembership.objects.get_or_create(
                        conversation=conv, profile=person, defaults={'role': role},
                    )

            # 5. Pinned post + the rest of the feed, then likes and comments.
            posts = self.seed_posts(conv, seed, owner, admins, members)
            self.seed_engagement(conv, posts, roster, rng)
            self.seed_welcome_message(conv, seed, owner)

            conv.last_message_text = posts[0].body[:200]
            conv.last_message_at = timezone.now()
            conv.save(update_fields=['last_message_text', 'last_message_at'])

            if existing:
                updated += 1
            else:
                created += 1
            self.stdout.write(
                f"{'updated' if existing else 'created'}: {seed['group_name']} "
                f"public={seed['is_public']} gym={gym.name if gym else '-'} "
                f"invite={conv.invite_code} owner=@{owner.username} "
                f"admins={len(admins)} members={len(members)} posts={len(posts)} "
                f"likes={CommunityPostLike.objects.filter(post__conversation=conv).count()} "
                f"comments={CommunityPostComment.objects.filter(post__conversation=conv).count()}"
            )

        if dry_run:
            self.stdout.write(
                self.style.WARNING(
                    f"DRY-RUN: {len(seeds)} community/communities planned "
                    f"(gyms={len(gyms)}, eligible_profiles={len(pool)}). No DB writes."
                )
            )
        else:
            self.stdout.write(
                self.style.SUCCESS(
                    f"Done. created={created} updated={updated} skipped={skipped} "
                    f"considered={len(seeds)} (overwrite={overwrite}), "
                    f"communities_total={Conversation.objects.filter(is_community=True).count()}."
                )
            )

    def select_seeds(self, public_only, gym_name, gyms, count):
        """Apply --public-only / --gym filters, then cap at --count."""
        seeds = list(COMMUNITY_SEEDS)
        if public_only:
            seeds = [s for s in seeds if s['is_public']]
        wanted = str(gym_name or '').strip().lower()
        if wanted:
            known = [g.name.strip().lower() for g in gyms]
            if wanted not in known:
                raise CommandError(
                    f"Unknown gym {gym_name!r}. Available: {sorted(g.name for g in gyms) or '(none)'}."
                )
            by_index = {i: name for i, name in enumerate(known)}
            seeds = [
                s for s in seeds
                if gyms and by_index.get(s['gym_index'] % len(gyms)) == wanted
            ]
        return seeds[:count]

    def seed_posts(self, conv, seed, owner, admins, members):
        """Create the pinned post plus the seed's post bodies."""
        created = []
        pinned, _ = CommunityPost.objects.get_or_create(
            conversation=conv,
            body=PINNED_TEMPLATE,
            defaults={'author': owner, 'is_pinned': True},
        )
        created.append(pinned)

        # Authors must be members, so the roster is the author pool.
        authors = [owner] + list(admins) + list(members)
        for offset, body in enumerate(seed['posts']):
            author = authors[offset % len(authors)]
            post, _ = CommunityPost.objects.get_or_create(
                conversation=conv,
                body=body,
                defaults={'author': author, 'is_pinned': False},
            )
            created.append(post)
        return created

    def seed_engagement(self, conv, posts, roster, rng):
        """A few likes and comments per community, then sync the counters."""
        for post in posts:
            # 1-4 likes from distinct members; nobody likes their own post.
            likers = [p for p in roster if p != post.author]
            rng.shuffle(likers)
            for liker in likers[:rng.randint(1, min(4, len(likers))) if likers else 0]:
                CommunityPostLike.objects.get_or_create(post=post, profile=liker)
            post.like_count = post.likes.count()

            # 0-3 comments per post; body is required on CommunityPostComment.
            commenters = [p for p in roster if p != post.author]
            rng.shuffle(commenters)
            for commenter in commenters[:rng.randint(0, 3)]:
                CommunityPostComment.objects.get_or_create(
                    post=post,
                    author=commenter,
                    body=rng.choice(COMMENT_BODIES),
                )
            post.comment_count = post.comments.count()
            post.save(update_fields=['like_count', 'comment_count'])

    def seed_welcome_message(self, conv, seed, owner):
        """One welcome message from the owner so last_message is not empty."""
        Message.objects.get_or_create(
            conversation=conv,
            sender=owner,
            body=seed['welcome'],
            defaults={'message_type': 'text', 'is_read': True},
        )