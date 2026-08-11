import logging
import re

from .config import settings

logger = logging.getLogger(__name__)

# ─────────────────────────────────────────────────────────────────────────────
# Policy guardrail engine.
#
# Two lightweight, deterministic detectors that enforce the platform's legal
# guardrails from the BuddyUp governance + fitness/meal-plan regulation research:
#
#   1. analyze_health_claims(text)  → scope-of-practice check for nutrition /
#      fitness / wellness content. Flags wording that implies diagnosing,
#      treating, curing or managing a medical condition, plus "quick fix" and
#      guarantee-style red flags that regulators treat as deceptive weight-loss
#      or health advertising.
#
#   2. analyze_sponsorship(text)   → material-connection check. Flags content
#      that is promotional (gifting, affiliate, brand mentions) and reports
#      whether a clear sponsorship disclosure is present. Regulators require a
#      prominent disclosure whenever a material connection exists.
#
# Both are rule-based (fast, offline, CPU-only, no model load). If OPENAI_API_KEY
# is configured, a secondary LLM pass can be used for ambiguous cases.
# ─────────────────────────────────────────────────────────────────────────────

# Health-claim / scope-of-practice detector
# -----------------------------------------------------------------------------
# Phrases that imply treatment, cure, or management of a specific medical
# condition (medical nutrition therapy territory). These are the core risk
# terms from the meal-plan regulation research.
TREATMENT_VERBS = [
    'cure', 'cures', 'cured', 'treat', 'treats', 'treated', 'heal', 'heals',
    'healed', 'reverses', 'reverse', 'reversed', 'reversing', 'fix', 'fixes',
    'prescribe', 'prescribed', 'prescription', 'diagnose', 'diagnosed',
    'diagnosis', 'therapeutic', 'therapy', 'treatment', 'medical management',
    'manage your', 'manages your', 'combat', 'fights', 'battles',
]

# Condition-specific nouns — anything that ties nutrition/fitness advice to a
# diagnosed medical condition pushes the content toward clinical territory.
CONDITION_TERMS = [
    'diabetes', 'type 2 diabetes', 'pcos', 'ibs', 'irritable bowel',
    'hypertension', 'blood pressure', 'insulin resistance', 'kidney disease',
    'renal', 'thyroid', 'hashimoto', 'arthritis', 'autoimmune', 'celiac',
    'coeliac', 'crohn', 'ulcerative colitis', 'cancer', 'tumor', 'tumour',
    'heart disease', 'cardiovascular', 'alzheimer', 'depression treated',
    'anxiety disorder', 'hormonal imbalance', 'hormone imbalance',
    'blood glucose', 'blood sugar', 'cholesterol', 'triglycerides',
    'gout', 'fatty liver', 'asthma', 'chronic pain', 'migraine',
]

# Guarantee / quick-fix / pseudo-science framing — regulators (FTC, Kenya PPB)
# treat these as deceptive weight-loss or health-claim red flags.
RED_FLAG_PHRASES = [
    'guaranteed', 'guarantee', '100% works', 'clinically proven',
    'scientifically proven', 'miracle', 'magic', 'quick fix', 'rapid results',
    'fast results', 'instant results', 'lose 10 pounds in', 'lose 20 pounds',
    'lose weight fast', 'belly fat gone', 'melt fat', 'burn fat overnight',
    'reverse insulin resistance', 'reverse diabetes', 'cure diabetes',
    'balance your hormones', 'balance hormones', 'detox your', 'cleanse your',
    'boost your metabolism to', 'boost metabolism fast',
]

# Wellness-safe language that should NOT trigger the detector on its own.
# Used to subtract benign phrases from a sentence before matching.
WELLNESS_SAFE = [
    'supports overall fitness', 'supports healthy living', 'healthy eating',
    'general wellness', 'balanced meals', 'activity-supportive',
    'consult your', 'consult a', 'seek medical', 'see a doctor',
    'registered dietitian', 'talk to your', 'ask your doctor',
    'not medical advice', 'does not replace', 'for informational purposes',
]

# Sponsorship / material-connection detector
# -----------------------------------------------------------------------------
# Language that suggests a commercial relationship (gifting, affiliate, brand
# partnership) requiring disclosure per influencer-advertising rules.
PROMOTIONAL_TERMS = [
    'gifted', 'sponsored', 'sponsor', 'brand partner', 'collab', 'collabed',
    'affiliate', 'commission', 'use my code', 'use code', 'discount code',
    'promo code', 'link in bio', 'check my link', 'get 10% off',
    'get 20% off', 'ad ', ' ad', 'advert', 'press sample', 'i was sent',
    'they sent me', 'sent me their', 'brand sent', 'the brand sent',
    'this brand sent', 'thanks to @', 'shoutout to', 'as seen on',
    'featured on', 'partner post', 'free product', 'free programme',
    'free program', 'sent to me', 'my code', 'ambassador', 'ambassador',
    'trial week', 'free trial', 'checkout with my', 'promo', 'giveaway',
    'they gifted', 'they gave me', 'they sent', 'got this from',
    'this is from', 'was sent this',
]

# Clear, prominent disclosure markers that satisfy the transparency requirement.
DISCLOSURE_MARKERS = [
    '#ad', '#advert', '#sponsored', '#spon', '#paid', '#paidpartnership',
    '#partner', '#gifted', 'paid partnership', 'this is an ad', 'advertisement',
    'sponsored post', 'sponsored content', 'sponsored by', 'ad by',
    'ad:', 'ads by', 'partner post', 'gifted by', 'in partnership with',
    'collaboration with', 'paid promotion', 'sponsored', 'advertorial',
]

# Disclosure markers that are buried / ineffective and should be flagged as
# non-compliant even when a weak marker is present.
WEAK_DISCLOSURE = [
    'thanks to', 'in collaboration', 'in partnership', 'as seen on',
    'featured on', 'shoutout', 'link in bio',
]


def _clean_text(text: str) -> str:
    if not text:
        return ''
    lowered = text.lower()
    for phrase in WELLNESS_SAFE:
        lowered = lowered.replace(phrase, '')
    return lowered


def analyze_health_claims(text: str) -> dict:
    """Detect medical/treatment-style claims in fitness, nutrition, wellness text.

    Returns a result dict matching the moderation engine result shape so the
    Django moderation tasks can persist ContentFlag rows consistently.
    """
    if not text or not text.strip():
        return {
            'has_medical_claim': False,
            'confidence': 0.0,
            'matched_terms': [],
            'risk_level': 'low',
            'action': 'approve',
            'method': 'rule_based',
        }

    cleaned = _clean_text(text)

    matched = []
    # Condition-specific claims carry the highest risk.
    for term in CONDITION_TERMS:
        if re.search(rf'\b{re.escape(term)}\b', cleaned):
            matched.append(f'condition:{term}')

    # Treatment verbs next.
    for verb in TREATMENT_VERBS:
        if re.search(rf'\b{re.escape(verb)}\b', cleaned):
            matched.append(f'treatment:{verb}')

    # Red-flag / guarantee phrasing.
    for phrase in RED_FLAG_PHRASES:
        if phrase in cleaned:
            matched.append(f'redflag:{phrase}')

    matched = list(dict.fromkeys(matched))

    if not matched:
        return {
            'has_medical_claim': False,
            'confidence': 0.0,
            'matched_terms': [],
            'risk_level': 'low',
            'action': 'approve',
            'method': 'rule_based',
        }

    has_condition = any(m.startswith('condition:') for m in matched)
    has_treatment = any(m.startswith('treatment:') for m in matched)
    has_redflag = any(m.startswith('redflag:') for m in matched)

    if has_condition or has_treatment:
        risk_level = 'high'
        confidence = 0.9 if (has_condition and has_treatment) else 0.8
    else:
        risk_level = 'medium'
        confidence = 0.7

    return {
        'has_medical_claim': True,
        'confidence': round(confidence, 2),
        'matched_terms': matched[:20],
        'risk_level': risk_level,
        'action': 'flag',
        'method': 'rule_based',
    }


def analyze_sponsorship(text: str) -> dict:
    """Detect promotional content and whether a disclosure is present.

    Per the influencer-gifting regulation research, a "material connection"
    (gift, free program, affiliate, paid partnership) triggers a disclosure
    duty. If promotional language is detected and no prominent disclosure is
    present, the content is flagged for review.
    """
    if not text or not text.strip():
        return {
            'is_promotional': False,
            'has_disclosure': False,
            'disclosure_compliant': True,
            'confidence': 0.0,
            'matched_terms': [],
            'action': 'approve',
            'method': 'rule_based',
        }

    lowered = text.lower()

    promo_matches = [t for t in PROMOTIONAL_TERMS if t in lowered]
    has_disclosure = any(m in lowered for m in DISCLOSURE_MARKERS)
    weak_disclosure = [m for m in WEAK_DISCLOSURE if m in lowered]
    promo_matches = list(dict.fromkeys(promo_matches))

    is_promotional = bool(promo_matches)

    if not is_promotional:
        return {
            'is_promotional': False,
            'has_disclosure': False,
            'disclosure_compliant': True,
            'confidence': 0.0,
            'matched_terms': [],
            'action': 'approve',
            'method': 'rule_based',
        }

    # Weak disclosure (e.g. "thanks to" without #ad) does NOT satisfy the
    # prominence requirement — regulators treat buried/grey-area disclosures as
    # non-compliant.
    if has_disclosure:
        return {
            'is_promotional': True,
            'has_disclosure': True,
            'disclosure_compliant': True,
            'confidence': round(0.85 + min(len(promo_matches), 3) * 0.05, 2),
            'matched_terms': promo_matches[:15],
            'action': 'approve',
            'method': 'rule_based',
        }

    if weak_disclosure:
        return {
            'is_promotional': True,
            'has_disclosure': False,
            'disclosure_compliant': False,
            'confidence': 0.7,
            'matched_terms': promo_matches[:15],
            'weak_disclosure': weak_disclosure[:5],
            'action': 'flag',
            'method': 'rule_based',
        }

    return {
        'is_promotional': True,
        'has_disclosure': False,
        'disclosure_compliant': False,
        'confidence': round(0.85 + min(len(promo_matches), 3) * 0.05, 2),
        'matched_terms': promo_matches[:15],
        'action': 'flag',
        'method': 'rule_based',
    }


async def _llm_policy_review(text: str, kind: str) -> dict | None:
    """Optional LLM-as-judge for ambiguous policy cases (returns None if unconfigured)."""
    if not settings.openai_api_key:
        return None
    import httpx

    prompt = (
        'You are a compliance reviewer for a fitness/wellness platform. '
        f'Review the following content for {kind}. '
        'Respond with JSON: {"verdict": "flag"|"approve", "reasons": ["..."], "confidence": 0.0}. '
        'Consider Kenyan consumer-protection and health-advertising rules.\n\n'
        f'Content: {text[:2000]}'
    )
    url = f'{settings.openai_base_url.rstrip("/")}/chat/completions'
    headers = {
        'Authorization': f'Bearer {settings.openai_api_key}',
        'Content-Type': 'application/json',
    }
    try:
        async with httpx.AsyncClient(timeout=20) as client:
            resp = await client.post(url, headers=headers, json={
                'model': settings.openai_model,
                'messages': [{'role': 'user', 'content': prompt}],
                'temperature': 0,
                'response_format': {'type': 'json_object'},
            })
            resp.raise_for_status()
            data = resp.json()
        content = data['choices'][0]['message']['content']
        import json
        parsed = json.loads(content)
        return {
            'action': parsed.get('verdict', 'approve'),
            'matched_terms': parsed.get('reasons', []),
            'confidence': round(float(parsed.get('confidence', 0.7)), 2),
            'method': 'openai_policy_review',
        }
    except Exception as exc:
        logger.warning('LLM policy review failed: %s', exc)
        return None
