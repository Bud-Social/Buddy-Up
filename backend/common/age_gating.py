"""
Country-aware age gating for mature/adult content categories.

BuddyUp exposes an 18+/16+ "Mature" content category (nude or suggestive
trainer profiles, adult-only lives, adult marketplace items, nude gyms, etc.).
The minimum age to view the category is country-dependent:

* 18+ for the vast majority of countries (including Kenya, where the age of
  majority is 18).
* 16+ only where local law sets the relevant age floor at 16 and the platform
  has confirmed, via legal review, that 16-year-olds may lawfully access such
  content.

This module is the single source of truth for those thresholds and for the
reusable audience/content-rating constants used across models and serializers.
"""

# Content rating choices shared across content models (lives, gyms,
# marketplace, trainers, posts).
CONTENT_RATING_CHOICES = [
    ('general', 'General (all ages)'),
    ('mature', 'Mature (18+ / 16+)'),
]

CONTENT_RATING_DEFAULT = 'general'

# Audience enum used by the moderation layer.
AUDIENCE_GENERAL = 'general'
AUDIENCE_MATURE = 'mature'
AUDIENCE_CHOICES = [
    (AUDIENCE_GENERAL, 'General (all ages)'),
    (AUDIENCE_MATURE, 'Mature (18+ / 16+)'),
]

# Countries where local law sets the age floor for mature content at 16.
# Empty by default — the platform defaults to 18+ everywhere unless legal
# review confirms a lower threshold for a specific country. Override by
# extending this set after that review.
MATURE_MIN_AGE_16_COUNTRIES: set[str] = set()

MATURE_DEFAULT_MIN_AGE = 18


def mature_content_min_age(country: str | None = None) -> int:
    """Return the minimum age to access the mature category for a country.

    Falls back to the conservative 18+ default when the country is unknown.
    """
    if country and country.lower() in MATURE_MIN_AGE_16_COUNTRIES:
        return 16
    return MATURE_DEFAULT_MIN_AGE


def can_access_mature_content(age: int | None, country: str | None = None) -> bool:
    """Return True when a user of ``age`` may view mature content for ``country``."""
    if age is None:
        return False
    return age >= mature_content_min_age(country)


def request_can_access_mature(request) -> bool:
    """Return True when the authenticated user on ``request`` may view mature content.

    Uses the persisted 18+ flag / 16+ consent flag rather than a computed age.
    Unauthenticated users return False.
    """
    from common.permissions import CanAccessMatureContent

    return CanAccessMatureContent().has_permission(request, None)


def gate_mature_queryset(request, queryset, rating_field: str = 'content_rating'):
    """Exclude mature-rated rows unless the request user may access mature content.

    Also apply an explicit ``content_rating`` query filter when supplied, so a
    caller can request only general, only mature, or rely on the default which
    shows general content plus (when permitted) mature content.
    """
    rating = (request.query_params.get('content_rating') or '').lower()
    if rating in ('general', 'mature'):
        queryset = queryset.filter(**{rating_field: rating})
    elif not request_can_access_mature(request):
        queryset = queryset.exclude(**{rating_field: AUDIENCE_MATURE})
    return queryset


def can_view_content(request, obj, rating_field: str = 'content_rating') -> bool:
    """Return True when ``request``'s user may view a single content object.

    If the object is mature-rated, the caller must pass the mature age gate.
    """
    rating = (getattr(obj, rating_field, None) or AUDIENCE_GENERAL)
    if rating != AUDIENCE_MATURE:
        return True
    return request_can_access_mature(request)
