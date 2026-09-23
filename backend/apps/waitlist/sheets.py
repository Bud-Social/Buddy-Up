"""Server-side mirror of waitlist signups to Google Sheets.

Dual-sheet routing:
- ``user`` interest → the users sheet (GOOGLE_SHEETS_WEBHOOK_URL). This is
  the legacy path and is intentionally left untouched.
- every other interest (gym, trainer, corporate, organiser, supplier,
  distributor, partnership, investor) → the consolidated sheet
  (CONS_ALL_SHEETS), authenticated with SHEETS_MIRROR_KEY.

The webhook URLs and mirror key live ONLY in the backend environment. They
are never shipped to the browser, so they cannot be discovered from the
client bundle or devtools — that is the whole point of relaying here
instead of posting from the SPA.
"""

import logging
import os
import threading

import requests

logger = logging.getLogger(__name__)

_WEBHOOK_TIMEOUT_SECONDS = 10

#: Interests that belong to the consolidated sheet. Anything unknown falls
#: back to the users sheet so a lead is never silently dropped.
CONSOLIDATED_INTERESTS = frozenset({
    'gym', 'trainer', 'corporate', 'organiser', 'supplier',
    'distributor', 'partnership', 'investor',
})


def resolve_mirror_target(interest: str):
    """Return (url, key) for an interest, falling back to the users sheet.

    The key is only ever sent to the consolidated webhook, whose Apps
    Script enforces it. The users webhook predates the secret and is
    called without one.
    """
    interest = (interest or 'user').strip().lower()
    if interest in CONSOLIDATED_INTERESTS:
        url = os.environ.get('CONS_ALL_SHEETS', '').strip()
        key = os.environ.get('SHEETS_MIRROR_KEY', '').strip()
        if url:
            return url, key
        logger.warning(
            'Consolidated sheet webhook unset; falling back to users sheet '
            'for interest=%s',
            interest,
        )
    url = os.environ.get('GOOGLE_SHEETS_WEBHOOK_URL', '').strip()
    return url, ''


def mirror_to_sheets_later(email: str, name: str, country: str, source: str,
                           interest: str = 'user', metadata: dict | None = None) -> None:
    """Queue a fire-and-forget POST of a signup to the Sheets webhook.

    Runs on a daemon thread so a slow or unreachable webhook can never
    delay (or fail) the signup response. Silently no-ops when no webhook
    URL is configured (dev environments without the sheet).
    """
    url, key = resolve_mirror_target(interest)
    if not url:
        return
    threading.Thread(
        target=_mirror,
        args=(url, key, email, name, country, source,
              interest or 'user', metadata or {}),
        daemon=True,
    ).start()


def _mirror(url: str, key: str, email: str, name: str, country: str,
            source: str, interest: str, metadata: dict) -> None:
    try:
        # Form-encoded POST matches the Apps Script doPost(e) contract; the
        # script appends one row per POST with its own server timestamp.
        payload = {'email': email, 'name': name, 'country': country,
                   'source': source, 'interest': interest,
                   'metadata': json_dumps(metadata)}
        if key:
            payload['key'] = key
        requests.post(url, data=payload, timeout=_WEBHOOK_TIMEOUT_SECONDS)
    except Exception:  # noqa: BLE001 — best-effort mirror; never propagate
        # Log without the URL or key so secrets stay out of logs.
        logger.warning('Google Sheets webhook mirror failed', exc_info=True)


def json_dumps(payload: dict) -> str:
    import json
    try:
        return json.dumps(payload)
    except (TypeError, ValueError):
        return '{}'
