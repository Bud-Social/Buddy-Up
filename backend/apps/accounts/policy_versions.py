"""Current policy / legal document versions.

These constants are the single source of truth for the legal document versions
the platform asks users to accept. Bump the relevant constant whenever the
corresponding document is materially updated so that re-consent can be
requested (see ``PolicyVersionsView`` and the registration consent flow).
"""

CURRENT_POLICY_VERSIONS = {
    'terms': {'version': '1.2', 'updated_at': '2026-08-11'},
    'privacy': {'version': '1.1', 'updated_at': '2026-08-10'},
    'guidelines': {'version': '1.2', 'updated_at': '2026-08-11'},
    'cookie_policy': {'version': '1.1', 'updated_at': '2026-08-10'},
    'medical_disclaimer': {'version': '1.1', 'updated_at': '2026-08-11'},
    'sponsorship_policy': {'version': '1.1', 'updated_at': '2026-08-11'},
    'adult_content_policy': {'version': '1.0', 'updated_at': '2026-08-11'},
}


def policy_version(key: str) -> str:
    return CURRENT_POLICY_VERSIONS.get(key, {}).get('version', '0.0')
