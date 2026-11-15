"""Location-aware pricing for verification tiers.

One source of truth for what each tier costs, in the currency relevant to
where the gym operates. The gym's ``location_country`` picks the currency;
anything we do not price is billed in USD.

Amounts for Kenyan gyms are KES rounded to the nearest 10 (e.g. 1,762 →
1,760) so receipts don't show cents that Flutterwave happily charges but
that nobody wants to see.
"""

from .models import GymTierPlan

# Country ISO-3166 alpha-2 → ISO-4217 currency. Additions here are safe:
# they only affect gyms whose location_country matches.
COUNTRY_CURRENCY = {
    'KE': 'KES',
    'UG': 'UGX',
    'TZ': 'TZS',
    'NG': 'NGN',
    'GH': 'GHS',
    'ZA': 'ZAR',
    'RW': 'RWF',
    'ET': 'ETB',
    'GB': 'GBP',
    'US': 'USD',
    'CA': 'USD',   # bill USD in North America until CAD is priced
    'AU': 'USD',
    'DE': 'EUR', 'FR': 'EUR', 'ES': 'EUR', 'IT': 'EUR', 'NL': 'EUR',
    'IN': 'INR',
}

# FX vs USD. Keep conservative and round; these are the numbers we show
# owners before they pay. Update on a cadence the business picks.
FX_FROM_USD = {
    'USD': 1.0,
    'KES': 147.3,
    'UGX': 3800.0,
    'TZS': 2650.0,
    'NGN': 1600.0,
    'GHS': 15.4,
    'ZAR': 17.9,
    'RWF': 1300.0,
    'ETB': 115.0,
    'GBP': 0.79,
    'EUR': 0.92,
    'INR': 83.0,
}

# Tier price in USD cents. Regular is free.
BASE_PRICE_USD_CENTS = {
    'regular': 0,
    'midlevel': 1200,
    'executive': 4500,
}

_COUNTRY_DEFAULT_CURRENCY = 'USD'
_FALLBACK_FX = {'USD': 1.0}


def currency_for_country(country_code: str) -> str:
    code = (country_code or '').strip().upper()[:2]
    return COUNTRY_CURRENCY.get(code, _COUNTRY_DEFAULT_CURRENCY)


def fx_for(currency: str) -> float:
    return FX_FROM_USD.get(currency, _FALLBACK_FX.get(currency, 1.0))


def price_for(tier: str, country_code: str) -> tuple[str, int]:
    """(currency, amount_minor) for a tier in a gym's country."""
    currency = currency_for_country(country_code)
    tier_key = tier if tier in BASE_PRICE_USD_CENTS else 'regular'
    usd_cents = BASE_PRICE_USD_CENTS[tier_key]
    if currency == 'USD':
        return 'USD', usd_cents
    minor = int(round(usd_cents * fx_for(currency)))
    # Round to the nearest whole major unit for non-USD so amounts look intentional.
    return currency, max(0, round(minor / 100) * 100)


def seeded_plan(tier: str, currency: str) -> 'GymTierPlan | None':
    """Fetch or lazily create the stored plan row for (tier, currency)."""
    tier_key = tier if tier in BASE_PRICE_USD_CENTS else 'regular'
    usd_cents = BASE_PRICE_USD_CENTS[tier_key]
    if currency == 'USD':
        amount_minor = usd_cents
    else:
        amount_minor = round(round(usd_cents * fx_for(currency)) / 100) * 100
    plan, _ = GymTierPlan.objects.get_or_create(
        tier=tier_key, currency=currency,
        defaults={'amount_minor': amount_minor},
    )
    return plan
