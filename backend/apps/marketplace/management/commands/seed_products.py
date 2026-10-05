"""DEV-ONLY seed for the marketplace Products tab.

Why this exists: ``ProductListView.get`` hides every non-compliant supplement
(``supplement_registration_number`` empty, ``supplement_claims_reviewed`` false,
or an expiry in the past). Rows seeded as bare ``category='supplement'``
products are therefore invisible, so the Products tab renders zero results
even though the rows exist.

This command does three things:

1. Creates a ~20-row catalog spread across equipment / gear / apparel / book /
   digital, each with its own Unsplash image, a real description, a
   ``price_display`` string, an explicit ``delivery_modes`` set, a
   ``recommended_by`` profile and a shop drawn from the existing shops.
2. Adds 2 genuinely compliant supplements (registration number, reviewed
   claims, expiry in the future) so the gate is proven to pass.
3. Repairs pre-existing non-compliant supplement rows so they become visible.

Products are free/affiliate: there is no ``price_artifacts`` field, prices are
free text in ``price_display`` and ``affiliate_url`` is the only hard-required
field. Publishing is ``is_active`` (there is no ``is_published``), and the
creator FK is ``recommended_by``.

Idempotent: rows are keyed on ``name`` via ``get_or_create``; reruns skip
existing rows unless ``--overwrite`` is given. The supplement repair is
idempotent too — already-compliant rows are left untouched.

Note ``--count`` caps the non-supplement catalog only. The compliant
supplement rows follow ``--categories``, so a repair-only run is
``--count 0 --categories equipment``.

Examples:
    manage.py seed_products --dry-run
    manage.py seed_products --count 20 --seed 7
    manage.py seed_products --categories gear,apparel --count 6
    manage.py seed_products --overwrite

Repair only (skip the catalog and the compliant supplements):
    manage.py seed_products --count 0 --categories equipment
"""
import random
import re
from datetime import date, timedelta
from urllib.parse import urlparse

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction

from apps.marketplace.models import Product, Shop
from apps.profiles.models import Profile

# Image convention shared by the rest of the repo's seeds. Each catalog row
# carries its own photo id so no two products render the same card.
UNSPLASH_URL = "https://images.unsplash.com/photo-{photo_id}?auto=format&fit=crop&w=1200&q=80"

# Affiliate destinations are placeholders on the reserved .example TLD: these
# rows exist to exercise the card/list UI, not to sell anything.
AFFILIATE_BASE = "https://partners.buddyup.example/r"

# Seed registrations are clearly fictional but well-formed for the gate:
# non-empty, future expiry, claims reviewed.
REGISTRATION_PREFIX = "KE-MOH-DEMO"

# How far ahead a repaired/seeded supplement registration stays valid.
REGISTRATION_VALID_MONTHS = 18

# Accounts that must never be used as a recommender. `teen`/`parent` are minor
# accounts (age-gated) and the rest are QA/test fixtures; seeding a product
# against them makes the recommender card look broken.
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

# --- catalog ---------------------------------------------------------------
# Deliberately not 'supplement': those rows are only visible once they clear
# the compliance gate, which the dedicated block below proves separately.

PRODUCT_SEEDS = [
    # --- equipment ---------------------------------------------------------
    {
        'name': 'Cast Iron Adjustable Kettlebell 5-32kg',
        'brand': 'Iron Temple',
        'category': 'equipment',
        'price_display': '$189.00',
        'delivery_modes': ['pickup', 'delivery'],
        'photo_id': '1518611012118-696072aa579a',
        'description': (
            'A single cast iron bell that replaces a rack of fixed weights. '
            'Turn the dial and the plates resettle with a proper clunk, so the '
            'handle stays honest under a swing clean. 32kg ceiling is enough '
            'for front squats and farmer carries without needing a barbell set '
            'in a studio apartment.'
        ),
        'highlights': [
            'Six weight settings from 5kg to 32kg',
            'Competition-handle diameter for gym use',
            'Powder coat resists chipping at the base',
        ],
    },
    {
        'name': 'Rubber Coated Dumbbell Pair 2-24kg',
        'brand': 'Iron Temple',
        'category': 'equipment',
        'price_display': '$320.00',
        'delivery_modes': ['pickup', 'delivery'],
        'photo_id': '1581009146145-b5ef050c2e1e',
        'description': (
            'Twelve pairs of hex dumbbells with a full rubber coat, so dropping '
            'one on a wooden floor is a thud instead of a crack. The knurling '
            'is deep enough to keep a chalked hand from sliding during a heavy '
            'row, and the rack footprint fits under most beds.'
        ),
        'highlights': [
            'Twelve pairs per rack, 2kg increments',
            'Full rubber coating, indoor friendly',
            'Includes a two-tier steel rack',
        ],
    },
    {
        'name': 'Heavy Resistance Band Set (5pcs)',
        'brand': 'Flexline',
        'category': 'equipment',
        'price_display': '$44.00',
        'delivery_modes': ['delivery'],
        'photo_id': '1576678927484-cc907957088c',
        'description': (
            'Five latex-free resistance bands from 10lb to 60lb. Latex is the '
            'usual culprit behind a rash after two sessions, and these are '
            'made from TPE instead. They pack into a gym bag and cover warm-ups, '
            'banded pull-ups and assisted dips without owning a rack.'
        ),
        'highlights': [
            'TPE, no latex powder on the surface',
            'Loops with reinforced anchor points',
            'Includes a door anchor and carry bag',
        ],
    },
    {
        'name': 'Folding Adjustable Squat Rack',
        'brand': 'Iron Temple',
        'category': 'equipment',
        'price_display': '$465.00',
        'delivery_modes': ['pickup', 'delivery'],
        'photo_id': '1556909212-d5b604d0c90d',
        'description': (
            'A rack that lives folded against a wall and opens into a real squat '
            'station in about a minute. Independent uprights and a spot-arm pair '
            'mean a heavy single is safe, which a cheap half-rack never is. '
            'Rated to 300kg and it bolts down if you want it to.'
        ),
        'highlights': [
            'Folds to 60cm deep against a wall',
            '300kg rated with safety spot arms',
            'J-cups adjust without a wrench',
        ],
    },
    {
        'name': 'Weight Plates Set 20kg (10, 5, 2.5, 1.25)',
        'brand': 'Iron Temple',
        'category': 'equipment',
        'price_display': '$132.00',
        'delivery_modes': ['pickup', 'delivery'],
        'photo_id': '1517130038641-a774d04afb3c',
        'description': (
            'A full set of iron plates that adds twenty kilos to a barbell, '
            'which is enough to make pull-ups and presses honest at home. '
            'Holes are machined to fit dumbbell bars as well as Olympic ones, '
            'so one plate does double duty.'
        ),
        'highlights': [
            '20kg total: 10 + 5 + 2.5 + 1.25kg',
            '50mm holes, fits dumbbell and Olympic bars',
            'Powder coat, no chipping at the hub',
        ],
    },
    # --- gear --------------------------------------------------------------
    {
        'name': 'Leather Weightlifting Belt',
        'brand': 'Grain & Oak',
        'category': 'gear',
        'price_display': '$74.00',
        'delivery_modes': ['delivery'],
        'photo_id': '1583454110551-21f2fa2afe61',
        'description': (
            'A 10mm-thick genuine leather belt with a single-prong buckle that '
            'does not roll under load. Boring, heavy, and the reason your brace '
            'stays at the same height for the whole set instead of creeping '
            'down the ribcage on rep five.'
        ),
        'highlights': [
            '10mm full-grain leather, breaks in not out',
            'Single-prong buckle, no pinch points',
            'Breakaway quick-release for compounds',
        ],
    },
    {
        'name': 'Lifting Chalk Block (2 pack)',
        'brand': 'Grain & Oak',
        'category': 'gear',
        'price_display': '$18.00',
        'delivery_modes': ['pickup', 'delivery'],
        'photo_id': '1552674605-db6ffd4facb5',
        'description': (
            'Block chalk beats liquid chalk for anything above bodyweight, '
            'because it lasts a whole session instead of ninety seconds. Two '
            'blocks in a bag in your gym bag is the cheapest grip fix there is.'
        ),
        'highlights': [
            'Dense block chalk, not re-baggable powder',
            'Rough on the hands for a day or two, then fine',
            'Two blocks per pack',
        ],
    },
    {
        'name': 'Competition Grip Chalk Bucket',
        'brand': 'Grain & Oak',
        'category': 'gear',
        'price_display': '$29.00',
        'delivery_modes': ['pickup', 'delivery'],
        'photo_id': '1532384748853-8f54a8f476e2',
        'description': (
            'A screw-top bucket sized for a competition chalk block, with a '
            'carabiner loop so it hangs off the bar or clips to a bag. Deep '
            'enough that a full block sits well below the rim and does not '
            'shake itself to dust on the walk from locker to rack.'
        ),
        'highlights': [
            'Screw lid, no spill in a gym bag',
            'Carabiner loop included',
            'Deep well for a full block',
        ],
    },
    {
        'name': 'Waterproof Training Duffel 45L',
        'brand': 'Trek Form',
        'category': 'gear',
        'price_display': '$96.00',
        'delivery_modes': ['delivery'],
        'photo_id': '1546483875-ad9014c88eba',
        'description': (
            'A wipe-clean duffel with a separate wet compartment, because a '
            'sweaty towel touching your kit is how good kit goes musty. The '
            '45L is right for a weekend of kit without becoming a checked '
            'luggage.'
        ),
        'highlights': [
            '45L with a ventilated wet-shoe compartment',
            'Wipe-clean lining, no fabric softener',
            'YKK zips and a bar-tacked handle',
        ],
    },
    {
        'name': 'Lifting Wrist Wraps (pair)',
        'brand': 'Grain & Oak',
        'category': 'gear',
        'price_display': '$27.00',
        'delivery_modes': ['delivery'],
        'photo_id': '1584464491033-06628f3a6b7b',
        'description': (
            'Heavy-duty wraps that hold a bar line over the wrist on the last '
            'rep of a max single. Stiff cotton-weave with a thumb loop, so they '
            'roll on in one motion and stay on for the rest of the set. Sold as '
            'a pair, because one wrap is never the answer.'
        ),
        'highlights': [
            'Heavy cotton weave with a thumb loop',
            'Rolls on in one motion, no re-tying',
            'Sold as a pair',
        ],
    },
    # --- apparel -----------------------------------------------------------
    {
        'name': 'Training Singlet - Dry Fit',
        'brand': 'Pace Studio',
        'category': 'apparel',
        'price_display': '$42.00',
        'delivery_modes': ['delivery'],
        'photo_id': '1521572163474-6864f9cf17ab',
        'description': (
            'A cut-through-the-shoulder singlet in a fabric that actually moves '
            'sweat off your back. Mesh under the arm, flatlock seams so the '
            'rub line disappears by the second session. Runs true to size.'
        ),
        'highlights': [
            'Flatlock seams, no rub line',
            'Mesh underarm panels',
            'Colour holds after 30+ washes',
        ],
    },
    {
        'name': 'Everyday Lifting Shorts 7"',
        'brand': 'Pace Studio',
        'category': 'apparel',
        'price_display': '$55.00',
        'delivery_modes': ['delivery'],
        'photo_id': '1622445275576-721325763afe',
        'description': (
            'Seven-inch shorts with a seven-pocket layout, including two that '
            'stay shut during a snatch. The fabric is a poly-nylon blend that '
            'dries in the time it takes to rack your plates, and the waistband '
            'does not roll down on a deep squat.'
        ),
        'highlights': [
            'Seven pockets, two zip',
            'Quick-dry poly-nylon, no cotton',
            'Non-roll waistband',
        ],
    },
    {
        'name': 'Recovery Slide Slippers',
        'brand': 'Pace Studio',
        'category': 'apparel',
        'price_display': '$48.00',
        'delivery_modes': ['delivery'],
        'photo_id': '1549298916-b41d501d3772',
        'description': (
            'Wide foam slides for the walk from the rack to the showers. The '
            'strap is wide enough to stay on while you cross a wet gym floor, '
            'which is the only test these ever face.'
        ),
        'highlights': [
            'Wide moulded strap, stays on',
            'Contoured foam footbed',
            'Quick-drain outsole',
        ],
    },
    {
        'name': 'Merino Base Layer Long Sleeve',
        'brand': 'Trek Form',
        'category': 'apparel',
        'price_display': '$88.00',
        'delivery_modes': ['delivery'],
        'photo_id': '1517649763962-0c623066013b',
        'description': (
            'A 180gsm merino layer for cold early sessions and cool-down walks. '
            'Merino because it is the only wool that keeps working after it '
            'gets sweaty, and it stops smelling on day five without a wash.'
        ),
        'highlights': [
            '180gsm merino, no itch',
            'Naturally odour resistant',
            'Flat seams under a harness',
        ],
    },
    # --- book --------------------------------------------------------------
    {
        'name': 'The Barbell Programming Handbook',
        'brand': 'Grain & Oak Press',
        'category': 'book',
        'price_display': '$32.00',
        'delivery_modes': ['delivery'],
        'photo_id': '1544947950-fa07a98d237f',
        'description': (
            'Twelve weeks of straight-barbell programming with the reasoning '
            'printed next to the numbers. Every block states the target, the '
            'fatigue cost and what to cut when a week goes wrong, which is the '
            'part most templates leave out.'
        ),
        'highlights': [
            '12 weeks, 4-day and 6-day variants',
            'Every block lists its fatigue cost',
            'Deliberate deload guidance',
        ],
    },
    {
        'name': 'Mobility for Desk-Bound Athletes',
        'brand': 'Trek Form Press',
        'category': 'book',
        'price_display': '$26.00',
        'delivery_modes': ['delivery'],
        'photo_id': '1512820790803-83ca734da794',
        'description': (
            'A mobility book written for people who sit eight hours and lift '
            'three. Each chapter is a fifteen-minute routine with a clear '
            "what-it-is-for, and the photographs show the position rather than "
            'an idealised version of it.'
        ),
        'highlights': [
            '15-minute routines, desk-worker framing',
            'Hip, thoracic and shoulder focus',
            'Photo-led, no equipment needed',
        ],
    },
    {
        'name': 'Trail Running: A First 50km',
        'brand': 'Trek Form Press',
        'category': 'book',
        'price_display': '$21.00',
        'delivery_modes': ['digital'],
        'photo_id': '1541534741688-6078c6bfb5c5',
        'description': (
            'A plan for a first ultra built around what actually goes wrong: '
            'fueling, foot strike, and the mental dip at 35km. Week-by-week '
            'mileage sits inside a volume most people can hold with a job, and '
            'each long run has a cut-back alternative.'
        ),
        'highlights': [
            '16-week first-50km plan',
            'Every long run has a shorter alternative',
            'Fueling and aid-station chapters',
        ],
    },
    # --- digital -----------------------------------------------------------
    {
        'name': 'Home Strength Program: 8 Weeks',
        'brand': 'Pace Studio',
        'category': 'digital',
        'price_display': '$39.00',
        'delivery_modes': ['digital'],
        'photo_id': '1499750310107-5fef28a66643',
        'description': (
            'Eight weeks of at-home strength with nothing but a pair of '
            'dumbbells and a chair. Video for every movement, both a strict and '
            'a scaled option, plus a printable log. Delivered instantly as a '
            'download link.'
        ),
        'highlights': [
            '40 video sessions, strict and scaled',
            'Printable training log',
            'Instant download, no expiry',
        ],
    },
    {
        'name': '12-Month Training Plan (PDF)',
        'brand': 'Pace Studio',
        'category': 'digital',
        'price_display': '$24.00',
        'delivery_modes': ['digital'],
        'photo_id': '1461749280684-dccba630e2f6',
        'description': (
            'A year of periodised training you can read in ten minutes and '
            'follow without a coach. Three routes (marathon, strength, general '
            'fitness) share one recovery framework, so a missed week does not '
            'knock the whole block off the rails.'
        ),
        'highlights': [
            'Three routes on one recovery framework',
            'Week-by-week spreadsheet included',
            'Instant PDF download',
        ],
    },
    {
        'name': 'Gym Onboarding Video Course',
        'brand': 'Iron Temple',
        'category': 'digital',
        'price_display': '$59.00',
        'delivery_modes': ['digital'],
        'photo_id': '1519389950473-47ba0277781c',
        'description': (
            'A first-month course for people who feel lost in a gym. Covers '
            'the eight movements worth learning, how to read a plan, and how '
            'to ask for a spot without losing face. Six short lessons, kept to '
            'under an hour in total.'
        ),
        'highlights': [
            '6 lessons, under 60 minutes total',
            'Eight-movement foundation',
            'Transcript and printable cheat sheet',
        ],
    },
]

# --- compliant supplements --------------------------------------------------
# Both clear every clause of the ProductListView gate, which is the point:
# they prove the filter lets compliant supplements through.

SUPPLEMENT_SEEDS = [
    {
        'name': 'Iso Whey Protein - Vanilla',
        'brand': 'Optimum Nutrition',
        'category': 'supplement',
        'price_display': '$64.00',
        'delivery_modes': ['delivery'],
        'photo_id': '1600185365483-26d7a4cc7519',
        'registration_number': 'KE-MOH-DEMO-00021',
        'description': (
            '25g of isolate per serving with 6g leucine, third-party tested '
            'and batch labelled. Carries a full Ministry of Health registration '
            'number and a reviewed claims panel, which is why it passes the '
            'marketplace compliance gate.'
        ),
        'highlights': [
            '25g protein, 6g leucine per serving',
            'Third-party tested, batch COA available',
            'Ministry registered, claims reviewed',
        ],
    },
    {
        'name': 'Daily Creatine Monohydrate 500g',
        'brand': 'Optimum Nutrition',
        'category': 'supplement',
        'price_display': '$41.00',
        'delivery_modes': ['pickup', 'delivery'],
        'photo_id': '1593095948071-474c5cc2989d',
        'registration_number': 'KE-MOH-DEMO-00022',
        'description': (
            'Pure creatine monohydrate with nothing else in the tub, which is '
            'the only version worth buying. Registered with the Ministry of '
            'Health with its claims reviewed, and it clears the marketplace '
            'compliance gate.'
        ),
        'highlights': [
            '100% creatine monohydrate, no fillers',
            'Unflavoured, dissolves clean',
            'Ministry registered, claims reviewed',
        ],
    },
]


def unsplash_url(photo_id):
    """Marketplace image URL for a photo id, following the repo convention."""
    return UNSPLASH_URL.format(photo_id=photo_id)


def affiliate_url_for(name):
    """Stable placeholder affiliate destination for a product name."""
    slug = re.sub(r'[^a-z0-9]+', '-', name.lower()).strip('-')
    return f"{AFFILIATE_BASE}/{slug}"


def registration_expiry(days=0):
    """A registration expiry comfortably in the future (default ~18 months)."""
    return date.today() + timedelta(days=days or REGISTRATION_VALID_MONTHS * 30)


def is_safe_url(value):
    """Mirror the API's media-URL guard: http(s), no embedded credentials."""
    try:
        parsed = urlparse(value)
    except ValueError:
        return False
    return parsed.scheme in ('http', 'https') and bool(parsed.hostname) and not parsed.username


def flatten_categories(raw_values):
    """Accept repeatable --categories and comma-separated lists."""
    wanted = []
    for raw in raw_values or []:
        for part in str(raw).split(','):
            part = part.strip().lower()
            if part:
                wanted.append(part)
    allowed = {key for key, _ in Product.CATEGORIES}
    unknown = [c for c in wanted if c not in allowed]
    if unknown:
        raise CommandError(
            f"Unknown categor(y/ies) {unknown}. Choose from {sorted(allowed)}."
        )
    # De-dupe preserving order; empty means every category.
    seen, out = set(), []
    for cat in wanted:
        if cat not in seen:
            seen.add(cat)
            out.append(cat)
    return out or sorted(allowed)


def excluded_username(username):
    """True for minor accounts and QA fixtures we must never seed against."""
    low = str(username or '').lower()
    return any(low == p or low.startswith(p) for p in EXCLUDED_USERNAME_PREFIXES)


def recommender_pool():
    """Profiles that may be credited as a product recommender.

    Trainers and practitioners come first because a recommender card showing a
    trainer is what the UI is designed around; verified adults come next;
    remaining public members are the fallback so the command still works on a
    bare database. Minor accounts and QA fixtures are never included.
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


def non_compliant_supplements(today):
    """Supplements the ProductListView compliance filter hides.

    Mirrors the view exactly: no registration number, unreviewed claims, or an
    expiry already in the past.
    """
    from django.db.models import Q

    return Product.objects.filter(category='supplement').filter(
        Q(supplement_registration_number='')
        | Q(supplement_claims_reviewed=False)
        | Q(supplement_registration_expiry__lt=today)
    ).order_by('name')


def registration_number_for(name, used):
    """Deterministic, obviously-demo registration number that does not collide."""
    base = abs(hash(name)) % 90000 + 10000
    bump = 0
    while f"{REGISTRATION_PREFIX}-{base + bump}" in used:
        bump += 1
    return f"{REGISTRATION_PREFIX}-{base + bump}"


class Command(BaseCommand):
    help = "DEV-ONLY: seed marketplace Products (compliant supplements included) and repair non-compliant supplement rows."

    def add_arguments(self, parser):
        parser.add_argument(
            "--count",
            type=int,
            default=20,
            help="Max non-supplement catalog products to seed (default: %(default)s). "
            "--count 0 skips the catalog but still seeds the compliant supplements; "
            "pair it with a --categories filter that excludes 'supplement' for a "
            "repair-only run.",
        )
        parser.add_argument(
            "--categories",
            action="append",
            default=None,
            dest="categories",
            help="Restrict catalog categories, repeatable or comma-separated "
            "(default: every category except supplement). Include 'supplement' "
            "to add the compliant supplement seeds too.",
        )
        parser.add_argument(
            "--seed",
            type=int,
            default=42,
            help="RNG seed for click counts (default: %(default)s).",
        )
        parser.add_argument(
            "--overwrite",
            action="store_true",
            help="Update products that already exist (default: skip).",
        )
        parser.add_argument(
            "--no-repair",
            action="store_true",
            dest="no_repair",
            help="Skip repairing pre-existing non-compliant supplement rows.",
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
        if count < 0:
            raise CommandError("--count must be zero or a positive integer.")
        categories = flatten_categories(options.get("categories"))
        overwrite = options["overwrite"]
        rng = random.Random(options["seed"])

        shops = list(Shop.objects.filter(is_active=True).order_by("created_at"))
        if not shops and not dry_run:
            raise CommandError(
                "No active Shop rows found, so products would have no storefront. "
                "Seed creators/shops first (see autocreate_creator_shops) or run with --dry-run."
            )
        recommenders = recommender_pool()
        if not recommenders and not dry_run:
            raise CommandError(
                "No eligible Profile rows to credit as recommended_by. "
                "Seed accounts first or run with --dry-run."
            )

        seen_urls = set()

        def assign_image(photo_id):
            url = unsplash_url(photo_id)
            if not is_safe_url(url):
                raise CommandError(f"Refusing to seed unsafe image URL: {url!r}")
            if url in seen_urls:
                raise CommandError(
                    f"Duplicate seed image {url!r}: every catalog row needs a distinct photo."
                )
            seen_urls.add(url)
            return url

        catalog = [
            seed for seed in PRODUCT_SEEDS
            if seed['category'] != 'supplement' and seed['category'] in categories
        ][:count]
        supplements = [s for s in SUPPLEMENT_SEEDS if 'supplement' in categories]
        planned = catalog + supplements
        if not planned and not options["no_repair"]:
            self.stdout.write(
                self.style.WARNING("No catalog rows selected; running the supplement repair only.")
            )

        created = updated = skipped = 0
        for idx, seed in enumerate(planned):
            # Round-robin the shops and recommenders so no shop or profile owns
            # the whole catalog.
            shop = shops[idx % len(shops)] if shops else None
            recommender = recommenders[idx % len(recommenders)] if recommenders else None
            image_url = assign_image(seed['photo_id'])

            defaults = {
                'brand': seed['brand'],
                'description': seed['description'],
                'category': seed['category'],
                'image_url': image_url,
                'highlights': list(seed['highlights']),
                'affiliate_url': affiliate_url_for(seed['name']),
                'price_display': seed['price_display'],
                'delivery_modes': list(seed['delivery_modes']),
                'fulfillment_details': {},
                'content_rating': 'general',
                'stock_tracking_enabled': False,
                'is_active': True,
                'click_count': rng.randint(3, 480),
            }
            if seed['category'] == 'supplement':
                defaults.update({
                    'supplement_registration_number': seed['registration_number'],
                    'supplement_claims_reviewed': True,
                    'supplement_registration_expiry': registration_expiry(),
                    'supplement_label_url': unsplash_url(seed['photo_id']),
                })
            else:
                defaults.update({
                    'supplement_registration_number': '',
                    'supplement_claims_reviewed': False,
                    'supplement_registration_expiry': None,
                })
            if shop is not None:
                defaults['shop'] = shop
            if recommender is not None:
                defaults['recommended_by'] = recommender

            exists = Product.objects.filter(name=seed['name']).exists()
            if dry_run:
                action = "would update" if (exists and overwrite) else ("would skip (exists)" if exists else "would create")
            elif exists and overwrite:
                Product.objects.filter(name=seed['name']).update(**defaults)
                updated += 1
                action = "updated"
            elif exists:
                skipped += 1
                action = "skipped (exists)"
            else:
                Product.objects.create(name=seed['name'], **defaults)
                created += 1
                action = "created"

            self.stdout.write(
                f"{action}: {seed['name']} [{seed['category']}] {seed['price_display']} "
                f"modes={seed['delivery_modes']} shop={shop.handle if shop else '-'} "
                f"by=@{recommender.username if recommender else '-'} "
                f"clicks={defaults['click_count']}"
            )
            if seed['category'] == 'supplement':
                self.stdout.write(
                    f"    compliant: reg={defaults['supplement_registration_number']} "
                    f"reviewed={defaults['supplement_claims_reviewed']} "
                    f"expiry={defaults['supplement_registration_expiry']}"
                )

        repaired = self.repair_supplements(
            no_repair=options["no_repair"], dry_run=dry_run,
        )

        if dry_run:
            self.stdout.write(
                self.style.WARNING(
                    f"DRY-RUN: {len(planned)} product(s) planned "
                    f"(categories={categories}, shops={len(shops)}, "
                    f"recommenders={len(recommenders)}), "
                    f"{repaired} supplement row(s) would be repaired. No DB writes."
                )
            )
        else:
            self.stdout.write(
                self.style.SUCCESS(
                    f"Done. created={created} updated={updated} skipped={skipped} "
                    f"considered={len(planned)} (overwrite={overwrite}), "
                    f"supplements_repaired={repaired}."
                )
            )

    def repair_supplements(self, *, no_repair, dry_run):
        """Make existing non-compliant supplements visible.

        Assigns a demo registration number and flips claims_reviewed so the
        compliance gate in ``ProductListView.get`` stops filtering them out.
        Rows that already pass are left alone.
        """
        if no_repair:
            self.stdout.write("Skipping supplement repair (--no-repair).")
            return 0

        today = date.today()
        broken = list(non_compliant_supplements(today))
        if not broken:
            self.stdout.write("Supplement repair: nothing non-compliant found.")
            return 0

        used = set(
            Product.objects.exclude(pk__in=[p.pk for p in broken])
            .values_list('supplement_registration_number', flat=True)
        )
        repaired = 0
        for product in broken:
            reg = product.supplement_registration_number.strip()
            if not reg or reg in used:
                reg = registration_number_for(product.name, used)
                used.add(reg)
            expiry = registration_expiry()
            if dry_run:
                self.stdout.write(
                    f"would repair: {product.name} reg='' -> {reg} expiry -> {expiry}"
                )
            else:
                product.supplement_registration_number = reg
                product.supplement_claims_reviewed = True
                product.supplement_registration_expiry = expiry
                product.save(update_fields=[
                    'supplement_registration_number',
                    'supplement_claims_reviewed',
                    'supplement_registration_expiry',
                ])
                self.stdout.write(
                    f"repaired: {product.name} reg={reg} expiry={expiry}"
                )
            repaired += 1
        return repaired