"""Server-side mirror of waitlist signups to a Google Sheet.

The Apps Script webhook URL lives ONLY in the backend environment
(GOOGLE_SHEETS_WEBHOOK_URL on Railway). It is never shipped to the
browser, so it cannot be discovered from the client bundle or devtools —
that is the whole point of relaying here instead of posting from the SPA.
"""

import logging
import os
import threading

import requests

logger = logging.getLogger(__name__)

_WEBHOOK_TIMEOUT_SECONDS = 10


def mirror_to_sheets_later(email: str, name: str, country: str, source: str,
                           interest: str = 'user', metadata: dict | None = None) -> None:
    """Queue a fire-and-forget POST of a signup to the Sheets webhook.

    Runs on a daemon thread so a slow or unreachable webhook can never
    delay (or fail) the signup response. Silently no-ops when the env var
    is unset (dev environments without the sheet).
    """
    url = os.environ.get('GOOGLE_SHEETS_WEBHOOK_URL', '').strip()
    if not url:
        return
    threading.Thread(
        target=_mirror,
        args=(url, email, name, country, source, interest, metadata or {}),
        daemon=True,
    ).start()


def _mirror(url: str, email: str, name: str, country: str, source: str,
            interest: str, metadata: dict) -> None:
    try:
        # Form-encoded POST matches the Apps Script doPost(e) contract; the
        # script appends one row per POST with its own server timestamp.
        requests.post(
            url,
            data={'email': email, 'name': name, 'country': country,
                  'source': source, 'interest': interest,
                  'metadata': json_dumps(metadata)},
            timeout=_WEBHOOK_TIMEOUT_SECONDS,
        )
    except Exception:  # noqa: BLE001 — best-effort mirror; never propagate
        # Log without the URL so the webhook address stays out of logs.
        logger.warning('Google Sheets webhook mirror failed', exc_info=True)


def json_dumps(payload: dict) -> str:
    import json
    try:
        return json.dumps(payload)
    except (TypeError, ValueError):
        return '{}'
