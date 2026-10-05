"""DEV-ONLY seed for Find-a-Buddy (NearbyBuddiesView) testing.

Creates BuddySearchProfile rows for existing public Profile rows. Two paths:

* generic (default) — draws --count rows and gives each one a distinct
  identity (intents, modes, pace, Nairobi neighbourhood, age band, bio and
  goals) so radius/mode/intent filtering has something varied to filter on.
* --emails — targeted rows for specific accounts. This path is unchanged:
  it reuses the original flat pools so existing seeds stay reproducible.

Idsempotent-ish: skips profiles that already have a search profile unless
--overwrite is given.

Never touches staff/superuser accounts and never changes privacy_level.

Examples:
    manage.py seed_buddy_search --center "-1.2921,36.8219" --radius-km 8 \\
        --count 12 --intent walk --intent run --available-now --dry-run

    manage.py seed_buddy_search --count 24 --seed 7 --profile-suffix b2

    manage.py seed_buddy_search --neighbourhood Westlands --neighbourhood Karen \\
        --count 8 --overwrite

Target specific accounts (missing users get a minimal account + Profile):
    manage.py seed_buddy_search --emails a@x.com,b@x.com --intent walk --available-now
"""
import math
import random
import re
import secrets
from datetime import timedelta
from decimal import Decimal

from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils import timezone

from apps.profiles.models import BuddySearchProfile, Profile
from common.utils import age_band_label

DEFAULT_CENTER = "-1.2921,36.8219"  # Nairobi

# --- pools shared by the --emails path (unchanged) ------------------------

BIO_POOL = [
    "Easy morning walks before work.",
    "Training for a 10k — join me for runs.",
    "Gym regular, happy to spot and share splits.",
    "Weekend hiker exploring trails around town.",
    "New in town, looking for a steady walk buddy.",
    "Evening runner, conversational pace.",
    "Lunchtime gym sessions, all levels welcome.",
    "Slow long-distance walker, podcasts included.",
]

AGE_BAND_POOL = ["18-24", "25-29", "30-34", "35-39", "40-44", "45+"]

MODES_POOL = [
    ["in_person"],
    ["hybrid"],
    ["neighbourhood"],
    ["virtual"],
    ["in_person", "hybrid"],
    ["in_person", "neighbourhood"],
]

GOALS_POOL = [
    ["consistency"],
    ["5k-walk"],
    ["10k-run"],
    ["strength"],
    ["habit"],
    [],
]

# --- pools for the generic path -------------------------------------------

# Real Nairobi areas, so seeded rows cluster where users actually are and
# --radius-km filtering has something meaningful to cut across.
NEIGHBOURHOODS = [
    ("Westlands", -1.2864, 36.8172),
    ("Kilimani", -1.2830, 36.8100),
    ("Lavington", -1.2780, 36.8030),
    ("Parklands", -1.2650, 36.8220),
    ("South C", -1.3060, 36.8290),
    ("Karen", -1.3300, 36.7100),
    ("Upper Hill", -1.2940, 36.8180),
    ("Eastleigh", -1.2760, 36.8470),
    ("Kasarani", -1.2230, 36.8480),
    ("Runda", -1.2420, 36.8080),
]
NEIGHBOURHOOD_NAMES = [name for name, _, _ in NEIGHBOURHOODS]
# Profiles are scattered a few hundred metres to ~1.5 km around their
# neighbourhood centroid, not across the whole city.
GENERIC_SPREAD_CAP_KM = 1.5

# >= 8 combinations covering every activity intent the platform lists.
INTENT_COMBOS = [
    ("walk",),
    ("run",),
    ("gym",),
    ("hike",),
    ("cycle",),
    ("swim",),
    ("football",),
    ("walk", "gym"),
    ("run", "cycle"),
    ("hike", "walk"),
    ("swim", "gym"),
    ("football", "run"),
    ("cycle", "gym"),
    ("other",),
]

# Required by the search-profile validator whenever 'other' is an intent.
CUSTOM_INTENT_POOL = [
    "Open to sunrise walks and coffee afterwards.",
    "Looking for a climbing partner, indoor or outdoor.",
    "Chasing my first 10k, tempo runs welcome.",
    "Just moved to Nairobi, keen for a running buddy.",
    "Want to build a lifting habit, three days a week.",
    "Early-morning swimmer, lane-friendly.",
    "Looking for a five-a-side football regular.",
    "Weekend trail hikes, intermediate level.",
    "Recovery-focused, yoga and mobility partner.",
    "Steady cycle commute buddy, mornings only.",
]

# Paces are per-intent so a swimmer does not end up "chatty easy". An empty
# entry leaves pace unset, which is a real state worth having in the pool.
PACE_BY_INTENT = {
    "walk": ["", "relaxed", "steady", "chatty easy", "brisk"],
    "run": ["", "easy conversational", "steady", "tempo", "fast"],
    "gym": ["", "steady", "progressive", "grinder"],
    "hike": ["", "steady", "moderate", "strong + hills"],
    "cycle": ["", "easy spin", "steady", "tempo"],
    "swim": ["", "steady", "technique", "endurance"],
    "football": ["", "match speed", "training pace"],
    "other": ["", "steady", "as available"],
}
DEFAULT_PACE_POOL = ["", "steady", "easy", "moderate"]

# Age bands are derived from the same helper that serves real opt-in DOBs, so
# seeded rows carry the same labels production rows do.
AGE_BANDS = [age_band_label(age) for age in (19, 23, 27, 32, 37, 42, 47, 52)]

GENERIC_BIO_POOL = [
    "Just here for consistency and good company.",
    "Early riser looking for someone to keep me honest.",
    "Training for something, happy to share the plan.",
    "New in the city and keen to meet people who train.",
    "No race times, just turning up and enjoying it.",
    "Weekend warrior, weekdays are for work.",
    "Recovering from an injury and building back slowly.",
    "Social pick-up games beat solo sessions every time.",
]

# Bios are keyed by the row's primary intent so every combination reads
# plausibly rather than pairing a swim with a lifting bio.
GENERIC_BIO_BY_INTENT = {
    "walk": [
        "Sunrise walks around the neighbourhood, 6am most days.",
        "Slow long-distance walker. Podcasts welcome.",
        "Early riser, dog walker looking for a walking buddy.",
        "New to the city and looking for a daily walking partner.",
    ],
    "run": [
        "Building a 10k base — easy conversational runs only.",
        "Evening runner, conversational pace, coffee after.",
        "Marathon training block, doing the long slow miles.",
        "Chasing a sub-25 5k, intervals and tempo welcome.",
    ],
    "gym": [
        "Gym three times a week, mostly weights. Happy to spot.",
        "Lunchtime gym sessions during the work week.",
        "Powerlifting sessions, bracing and squat checks appreciated.",
        "Just started lifting again after a long break.",
    ],
    "hike": [
        "Weekend hiker, day hikes around the Rift Valley.",
        "Mount Kenya in training, altitude weekends and long days out.",
        "Day hikes only — no overnighters, no dramas.",
        "Trail season is my favourite season.",
    ],
    "cycle": [
        "Cycling to work daily, looking for a wheel-buddy.",
        "Road bike, early morning rides before the heat.",
        "Gravel and weekend tours, happy to wait on the climbs.",
        "Commuter looking for someone to ride the commute with.",
    ],
    "swim": [
        "Lap swimmer, early mornings before the pool fills up.",
        "Open-water swimmer building up to a lake crossing.",
        "Masters squad twice a week, smooth stroke only.",
        "Learning to swim properly as an adult, very beginner friendly.",
    ],
    "football": [
        "Five-a-side football most weekends, need a team.",
        "Sunday league defender, looking for a midfield partner.",
        "Casual kickabouts, I am the one who never marks anyone.",
        "Football and nothing else — fair warning about my knees.",
    ],
    "other": [
        "Mostly climbing, gym for finger strength.",
        "Rowing machine at 6am, competitive and awkward about it.",
        "Dance classes plus the occasional gym session.",
        "Bit of everything — tell me what you are into.",
    ],
}

# Uses the same vocabulary as the profile interests goal keys so the UI can
# label them.
GENERIC_GOALS_POOL = [
    ["general_wellness"],
    ["endurance"],
    ["weight_loss"],
    ["muscle_gain"],
    ["flexibility"],
    ["consistency"],
    ["endurance", "nutrition"],
    ["weight_loss", "general_wellness"],
    ["muscle_gain", "general_wellness"],
    ["sports_performance"],
    ["rehabilitation", "flexibility"],
    ["mental_health", "general_wellness"],
    ["nutrition", "endurance"],
    ["flexibility", "mental_health"],
]


def parse_center(value):
    try:
        lat_s, lng_s = [p.strip() for p in str(value).split(",")]
        lat, lng = float(lat_s), float(lng_s)
    except (TypeError, ValueError):
        raise CommandError('--center must look like "lat,lng" (e.g. "-1.2921,36.8219").')
    if not (-90 <= lat <= 90 and -180 <= lng <= 180):
        raise CommandError("Center out of range: lat -90..90, lng -180..180.")
    return lat, lng


def flatten_intents(raw_values):
    """Accept repeatable --intent and comma-separated lists."""
    intents = []
    for raw in raw_values or []:
        for part in str(raw).split(","):
            part = part.strip().lower()
            if part:
                intents.append(part)
    # De-dupe preserving order.
    seen = set()
    out = []
    for intent in intents:
        if intent not in seen:
            seen.add(intent)
            out.append(intent)
    return out or ["walk"]


def flatten_emails(raw_values):
    """Accept repeatable --emails and comma-separated lists."""
    emails = []
    for raw in raw_values or []:
        for part in str(raw).split(","):
            part = part.strip()
            if part:
                emails.append(part)
    # De-dupe case-insensitively, preserving order.
    seen = set()
    out = []
    for email in emails:
        key = email.lower()
        if key not in seen:
            seen.add(key)
            out.append(email)
    return out


def flatten_neighbourhoods(raw_values):
    """Accept repeatable --neighbourhood and comma-separated lists.

    Matched case-insensitively against the known Nairobi areas so a typo
    fails loudly instead of silently seeding every row.
    """
    wanted = []
    for raw in raw_values or []:
        for part in str(raw).split(","):
            part = part.strip()
            if part:
                wanted.append(part)
    if not wanted:
        return []

    by_name = {name.lower(): name for name in NEIGHBOURHOOD_NAMES}
    out, seen = [], set()
    for name in wanted:
        resolved = by_name.get(name.lower())
        if resolved is None:
            raise CommandError(
                f"Unknown neighbourhood {name!r}. Choose from {NEIGHBOURHOOD_NAMES}."
            )
        if resolved not in seen:
            seen.add(resolved)
            out.append(resolved)
    return out


def select_neighbourhoods(requested):
    """Resolve the neighbourhood subset to seed, preserving CLI order."""
    if not requested:
        return list(NEIGHBOURHOODS)
    by_name = {name: (name, lat, lng) for name, lat, lng in NEIGHBOURHOODS}
    return [by_name[name] for name in requested]


def sanitize_username_base(prefix):
    """Sanitize an email prefix to [a-z0-9_] for username derivation."""
    return re.sub(r"[^a-z0-9_]", "", prefix.lower())[:24] or "buddy"


def sanitize_username_suffix(value):
    """Sanitize a --profile-suffix value to [a-z0-9_] for username derivation."""
    return re.sub(r"[^a-z0-9_]", "", str(value or "").lower())[:12]


def unique_username(base):
    """Dedupe a username base with a numeric suffix (mirrors registration)."""
    if not Profile.objects.filter(username=base).exists():
        return base
    for i in range(2, 100):
        candidate = f"{base}{i}"[:30]
        if not Profile.objects.filter(username=candidate).exists():
            return candidate
    return f"{base[:24]}_{secrets.token_hex(2)}"


def derive_username(prefix, profile_suffix=""):
    """Username for a new account, optionally tagged with a batch suffix.

    With an empty suffix this is exactly the pre-existing derivation.
    """
    base = f"{sanitize_username_base(prefix)}{sanitize_username_suffix(profile_suffix)}"
    return unique_username(base[:30])


def display_name_for_prefix(prefix):
    """Title-case an email prefix for a placeholder display name."""
    cleaned = re.sub(r"[._\-]+", " ", prefix).strip()
    return cleaned.title() or prefix.title()


def build_search_defaults(idx, intents, lat, lng, now, available_now, available_until):
    """BuddySearchProfile defaults for email-targeted rows (unchanged)."""
    assigned_intents = [intents[idx % len(intents)]]
    return {
        "intents": assigned_intents,
        "custom_intent": "Open to sunrise walks + coffee." if "other" in assigned_intents else "",
        "modes": list(MODES_POOL[idx % len(MODES_POOL)]),
        "bio": BIO_POOL[idx % len(BIO_POOL)],
        "goals": list(GOALS_POOL[idx % len(GOALS_POOL)]),
        "age_band": AGE_BAND_POOL[idx % len(AGE_BAND_POOL)],
        "display_name": "",
        "photos": [],
        "neighbourhood": "Nairobi",
        "latitude": Decimal(str(lat)),
        "longitude": Decimal(str(lng)),
        "location_updated_at": now,
        "available_now": available_now,
        "available_until": available_until,
        "pace": "",
        "visibility": "public",
        "incognito": False,
    }


def generic_intent_combos(idx, intents, restrict_intents):
    """Intents for a generic row.

    An explicit --intent keeps the original single-intent rotation; without
    one the rich pool walks every activity so a small --count still covers
    a wide spread.
    """
    if restrict_intents:
        return [intents[idx % len(intents)]]
    return list(INTENT_COMBOS[idx % len(INTENT_COMBOS)])


def build_generic_defaults(idx, hood, lat, lng, now, available_now,
                           available_until, intents, restrict_intents):
    """BuddySearchProfile defaults for generic rows.

    Every field varies with idx so rows never read identically: intents,
    modes, pace, neighbourhood, age band, bio and goals all advance
    together. Bio and pace are keyed off the row's primary intent so a
    swimmer never ends up with a "chatty easy" walking bio.
    """
    assigned_intents = generic_intent_combos(idx, intents, restrict_intents)
    primary = assigned_intents[0]
    pace_pool = PACE_BY_INTENT.get(primary, DEFAULT_PACE_POOL)
    bio_pool = GENERIC_BIO_BY_INTENT.get(primary, GENERIC_BIO_POOL)
    return {
        "intents": assigned_intents,
        "custom_intent": CUSTOM_INTENT_POOL[idx % len(CUSTOM_INTENT_POOL)] if "other" in assigned_intents else "",
        "modes": list(MODES_POOL[idx % len(MODES_POOL)]),
        "bio": bio_pool[idx % len(bio_pool)],
        "goals": list(GENERIC_GOALS_POOL[idx % len(GENERIC_GOALS_POOL)]),
        "age_band": AGE_BANDS[idx % len(AGE_BANDS)],
        "display_name": "",
        "photos": [],
        "neighbourhood": hood[0],
        "latitude": Decimal(str(lat)),
        "longitude": Decimal(str(lng)),
        "location_updated_at": now,
        "available_now": available_now,
        "available_until": available_until,
        "pace": pace_pool[idx % len(pace_pool)],
        "visibility": "public",
        "incognito": False,
    }


def haversine_km(lat1, lng1, lat2, lng2):
    r = 6371.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp = math.radians(lat2 - lat1)
    dl = math.radians(lng2 - lng1)
    a = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * r * math.asin(math.sqrt(a))


def spread_point(center_lat, center_lng, radius_km, rng):
    """Deterministic uniform-ish point inside a disc of radius_km."""
    angle = rng.uniform(0, 2 * math.pi)
    dist = radius_km * math.sqrt(rng.random())
    dlat = (dist * math.cos(angle)) / 111.32
    # Guard cos() near poles.
    denom = 111.32 * max(0.2, math.cos(math.radians(center_lat)))
    dlng = (dist * math.sin(angle)) / denom
    return round(center_lat + dlat, 6), round(center_lng + dlng, 6), dist


class Command(BaseCommand):
    help = "DEV-ONLY: seed BuddySearchProfile rows around a center for Find-a-Buddy testing."

    def add_arguments(self, parser):
        parser.add_argument(
            "--center",
            type=str,
            default=DEFAULT_CENTER,
            help='Center as "lat,lng" (default: "%(default)s").',
        )
        parser.add_argument(
            "--radius-km",
            type=float,
            default=8,
            help="Spread radius in km (default: %(default)s). For generic rows this "
            "is the scatter around each neighbourhood centroid (capped at 1.5km); "
            "for --emails it is the spread around --center.",
        )
        parser.add_argument(
            "--count",
            type=int,
            default=12,
            help="Max profiles to seed (default: %(default)s).",
        )
        parser.add_argument(
            "--intent",
            action="append",
            default=None,
            dest="intent",
            help="Intent(s), repeatable or comma-separated. Restricts generic rows "
            "to these intents (default: every activity, one per row).",
        )
        parser.add_argument(
            "--neighbourhood",
            action="append",
            default=None,
            dest="neighbourhood",
            help="Nairobi area(s) to seed, repeatable or comma-separated "
            f"(default: all of {', '.join(NEIGHBOURHOOD_NAMES)}). "
            "Use with --overwrite to re-seed a subset for one area.",
        )
        parser.add_argument(
            "--profile-suffix",
            type=str,
            default="",
            dest="profile_suffix",
            help="Optional username suffix for accounts this command creates, so a "
            "second batch can be seeded without colliding usernames.",
        )
        parser.add_argument(
            "--available-now",
            action="store_true",
            help="Mark seeded profiles available_now (available_until = now + 2h).",
        )
        parser.add_argument(
            "--overwrite",
            action="store_true",
            help="Update profiles that already have a search profile (default: skip).",
        )
        parser.add_argument(
            "--seed",
            type=int,
            default=42,
            help="RNG seed for repeatable coordinate spread (default: %(default)s).",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Print what would happen without writing to the DB.",
        )
        parser.add_argument(
            "--emails",
            action="append",
            default=None,
            dest="emails",
            help="Target account email(s), repeatable or comma-separated. "
            "Missing users get a minimal account + Profile. "
            "When given, only these emails are seeded (--count is ignored).",
        )

    def handle(self, *args, **options):
        dry_run = options["dry_run"]
        if not dry_run and not getattr(settings, "DEBUG", False):
            raise CommandError("Refusing to seed: DEV-ONLY command requires DEBUG=True.")

        center_lat, center_lng = parse_center(options["center"])
        radius_km = float(options["radius_km"] or 0)
        if radius_km <= 0 or radius_km > 200:
            raise CommandError("--radius-km must be within (0, 200].")
        count = int(options["count"] or 0)
        if count <= 0:
            raise CommandError("--count must be a positive integer.")

        intents = flatten_intents(options.get("intent"))
        restrict_intents = bool(options.get("intent"))
        allowed = set(BuddySearchProfile.INTENT_CHOICES)
        bad = [i for i in intents if i not in allowed]
        if bad:
            raise CommandError(f"Unknown intent(s) {bad}. Choose from {BuddySearchProfile.INTENT_CHOICES}.")

        overwrite = options["overwrite"]
        available_now = options["available_now"]
        profile_suffix = options.get("profile_suffix") or ""
        rng = random.Random(options["seed"])

        emails = flatten_emails(options.get("emails"))
        if emails:
            self._handle_email_targets(
                emails,
                intents=intents,
                center_lat=center_lat,
                center_lng=center_lng,
                radius_km=radius_km,
                overwrite=overwrite,
                available_now=available_now,
                profile_suffix=profile_suffix,
                rng=rng,
                dry_run=dry_run,
            )
            return

        # Guard the rich pool against an INTENT_CHOICES trim.
        pooled = sorted({intent for combo in INTENT_COMBOS for intent in combo})
        stale = [i for i in pooled if i not in allowed]
        if stale:
            raise CommandError(
                f"INTENT_COMBOS references intent(s) {stale} that are no longer in "
                f"BuddySearchProfile.INTENT_CHOICES."
            )

        hoods = select_neighbourhoods(flatten_neighbourhoods(options.get("neighbourhood")))
        if not hoods:
            raise CommandError("No neighbourhoods to seed.")
        spread_km = min(radius_km, GENERIC_SPREAD_CAP_KM)

        candidates = (
            Profile.objects.filter(
                privacy_level="public",
                user__is_staff=False,
                user__is_superuser=False,
            )
            .order_by("username")
        )
        if not overwrite:
            candidates = candidates.filter(search_profile__isnull=True)
        candidates = list(candidates[:count])

        if not candidates:
            self.stdout.write("No eligible public profiles to seed (nothing to do).")
            return

        now = timezone.now()
        available_until = now + timedelta(hours=2) if available_now else None

        created = updated = 0
        for idx, profile in enumerate(candidates):
            hood = hoods[idx % len(hoods)]
            lat, lng, _ = spread_point(hood[1], hood[2], spread_km, rng)
            defaults = build_generic_defaults(
                idx, hood, lat, lng, now, available_now, available_until,
                intents, restrict_intents,
            )
            distance = haversine_km(center_lat, center_lng, lat, lng)

            exists = hasattr(profile, "search_profile")
            if not dry_run and exists:
                # hasattr triggers a query; refresh via direct check to be safe.
                exists = BuddySearchProfile.objects.filter(profile=profile).exists()

            action = "would seed"
            if dry_run:
                action = "would update" if exists else "would create"
            else:
                if exists and overwrite:
                    BuddySearchProfile.objects.filter(profile=profile).update(**defaults)
                    updated += 1
                    action = "updated"
                elif exists:
                    action = "skipped (exists)"
                else:
                    BuddySearchProfile.objects.create(profile=profile, **defaults)
                    created += 1
                    action = "created"

            self.stdout.write(
                f"{action}: @{profile.username} "
                f"intents={defaults['intents']} modes={defaults['modes']} "
                f"pace={defaults['pace'] or '-'} {hood[0]} "
                f"age={defaults['age_band']} goals={defaults['goals']} "
                f"({lat:.6f},{lng:.6f} ~{distance:.1f}km from center)"
            )
            if defaults["bio"]:
                self.stdout.write(f"    bio: {defaults['bio']}")
            if defaults["custom_intent"]:
                self.stdout.write(f"    custom_intent: {defaults['custom_intent']}")

        where = ", ".join(name for name, _, _ in hoods)
        if dry_run:
            self.stdout.write(
                self.style.WARNING(
                    f"DRY-RUN: {len(candidates)} profile(s) planned "
                    f"(center {center_lat},{center_lng} r={radius_km}km, "
                    f"scatter {spread_km}km around {where}). No DB writes."
                )
            )
        else:
            self.stdout.write(
                self.style.SUCCESS(
                    f"Done. created={created} updated={updated} "
                    f"considered={len(candidates)} (overwrite={overwrite})."
                )
            )

    def _handle_email_targets(
        self, emails, *, intents, center_lat, center_lng,
        radius_km, overwrite, available_now, profile_suffix, rng, dry_run,
    ):
        """Seed BuddySearchProfile rows for explicit email addresses.

        Emails with no User (e.g. Google social emails) get a minimal account
        (unusable password) + Profile; existing accounts/Profiles are never
        modified (privacy_level untouched). Staff/superuser accounts are
        skipped. Without --overwrite, emails that already have a search
        profile are reported as existing and left alone.
        """
        from django.core.exceptions import ValidationError
        from django.core.validators import validate_email

        User = get_user_model()
        now = timezone.now()
        available_until = now + timedelta(hours=2) if available_now else None

        created = updated = skipped = 0
        for idx, email in enumerate(emails):
            try:
                validate_email(email)
            except ValidationError:
                self.stdout.write(f"skipped (invalid email): {email}")
                skipped += 1
                continue

            user = User.objects.filter(email__iexact=email).first()
            if user is not None and (user.is_staff or user.is_superuser):
                self.stdout.write(f"skipped (staff): {email}")
                skipped += 1
                continue

            lat, lng, _ = spread_point(center_lat, center_lng, radius_km, rng)
            defaults = build_search_defaults(
                idx, intents, lat, lng, now, available_now, available_until
            )
            where = f"({lat:.6f},{lng:.6f} ~{haversine_km(center_lat, center_lng, lat, lng):.1f}km from center)"

            if user is None:
                if dry_run:
                    self.stdout.write(
                        f"would create user+profile+search: {email} "
                        f"intents={defaults['intents']} {where}"
                    )
                    continue
                with transaction.atomic():
                    user = User(email=User.objects.normalize_email(email))
                    user.set_unusable_password()
                    user.save()
                    prefix = email.split("@")[0]
                    profile = Profile.objects.create(
                        user=user,
                        username=derive_username(prefix, profile_suffix),
                        display_name=display_name_for_prefix(prefix),
                    )
                    BuddySearchProfile.objects.create(profile=profile, **defaults)
                created += 1
                self.stdout.write(
                    f"created: {email} [new account @{profile.username}] "
                    f"intents={defaults['intents']} {where}"
                )
                continue

            try:
                profile = user.profile
            except Profile.DoesNotExist:
                profile = None
            if profile is None:
                if dry_run:
                    self.stdout.write(f"would create profile+search: {email} {where}")
                    continue
                with transaction.atomic():
                    prefix = email.split("@")[0]
                    profile = Profile.objects.create(
                        user=user,
                        username=derive_username(prefix, profile_suffix),
                        display_name=display_name_for_prefix(prefix),
                    )
                    BuddySearchProfile.objects.create(profile=profile, **defaults)
                created += 1
                self.stdout.write(
                    f"created: {email} [existing account, new profile @{profile.username}] "
                    f"intents={defaults['intents']} {where}"
                )
                continue

            search_exists = BuddySearchProfile.objects.filter(profile=profile).exists()
            if dry_run:
                if search_exists:
                    action = "would update (overwrite)" if overwrite else "would skip (exists)"
                else:
                    action = "would create"
                self.stdout.write(
                    f"{action}: {email} [existing account @{profile.username}] "
                    f"intents={defaults['intents']} {where}"
                )
                continue

            if search_exists and overwrite:
                BuddySearchProfile.objects.filter(profile=profile).update(**defaults)
                updated += 1
                self.stdout.write(f"updated: {email} [existing account @{profile.username}] {where}")
            elif search_exists:
                skipped += 1
                self.stdout.write(
                    f"skipped (exists): {email} [existing account @{profile.username}] "
                    "rerun with --overwrite to replace"
                )
            else:
                BuddySearchProfile.objects.create(profile=profile, **defaults)
                created += 1
                self.stdout.write(
                    f"created: {email} [existing account @{profile.username}] "
                    f"intents={defaults['intents']} {where}"
                )

        if dry_run:
            self.stdout.write(
                self.style.WARNING(
                    f"DRY-RUN: {len(emails)} email(s) planned. No DB writes."
                )
            )
        else:
            self.stdout.write(
                self.style.SUCCESS(
                    f"Done. created={created} updated={updated} skipped={skipped} "
                    f"considered={len(emails)} (overwrite={overwrite})."
                )
            )
