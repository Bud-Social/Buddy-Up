"""DEV-ONLY seed for Find-a-Buddy (NearbyBuddiesView) testing.

Creates BuddySearchProfile rows for existing public Profile rows spread
deterministically around a center point. Idempotent-ish: skips profiles
that already have a search profile unless --overwrite is given.

Never touches staff/superuser accounts and never changes privacy_level.

Example:
    manage.py seed_buddy_search --center "-1.2921,36.8219" --radius-km 8 \\
        --count 12 --intent walk --intent run --available-now --dry-run
"""
import math
import random
from datetime import timedelta
from decimal import Decimal

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.utils import timezone

from apps.profiles.models import BuddySearchProfile, Profile

DEFAULT_CENTER = "-1.2921,36.8219"  # Nairobi

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
            help="Spread radius in km (default: %(default)s).",
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
            help="Intent(s), repeatable or comma-separated (default: walk).",
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
        allowed = set(BuddySearchProfile.INTENT_CHOICES)
        bad = [i for i in intents if i not in allowed]
        if bad:
            raise CommandError(f"Unknown intent(s) {bad}. Choose from {BuddySearchProfile.INTENT_CHOICES}.")

        overwrite = options["overwrite"]
        available_now = options["available_now"]
        rng = random.Random(options["seed"])

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
            lat, lng, _ = spread_point(center_lat, center_lng, radius_km, rng)
            assigned_intents = [intents[idx % len(intents)]]
            modes = list(MODES_POOL[idx % len(MODES_POOL)])
            bio = BIO_POOL[idx % len(BIO_POOL)]
            age_band = AGE_BAND_POOL[idx % len(AGE_BAND_POOL)]
            goals = list(GOALS_POOL[idx % len(GOALS_POOL)])
            distance = haversine_km(center_lat, center_lng, lat, lng)
            custom_intent = "Open to sunrise walks + coffee." if "other" in assigned_intents else ""

            defaults = {
                "intents": assigned_intents,
                "custom_intent": custom_intent,
                "modes": modes,
                "bio": bio,
                "goals": goals,
                "age_band": age_band,
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
                f"intents={assigned_intents} modes={modes} "
                f"({lat:.6f},{lng:.6f} ~{distance:.1f}km from center)"
            )

        if dry_run:
            self.stdout.write(
                self.style.WARNING(
                    f"DRY-RUN: {len(candidates)} profile(s) planned "
                    f"(center {center_lat},{center_lng} r={radius_km}km). No DB writes."
                )
            )
        else:
            self.stdout.write(
                self.style.SUCCESS(
                    f"Done. created={created} updated={updated} "
                    f"considered={len(candidates)} (overwrite={overwrite})."
                )
            )
