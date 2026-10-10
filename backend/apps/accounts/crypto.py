"""Reversible encryption for secrets that must not sit in the database in clear.

Used for ``User.totp_secret``: a plaintext TOTP seed in a database dump (or in
an ``accounts/admin.py`` fieldset) is a second factor that has to be typed
into an authenticator app. If the table leaks, every enrolled account is one
row away from a full takeover.

Scheme: Fernet (AES-128-CBC + HMAC-SHA256, authenticated) from
``cryptography``, with a key derived from ``SECRET_KEY`` via SHA-256 under a
fixed domain-separation label. Consequences, deliberately accepted:

* Rotating ``SECRET_KEY`` makes every stored seed undecryptable. The
  decryption path fails CLOSED (returns an empty secret, logs an error), so
  the affected accounts can no longer complete a TOTP challenge; they recover
  through a recovery code or a password reset, which clears 2FA. That is the
  right failure direction — never silently fall back to "no second factor".
* ``cryptography`` is an explicit dependency in ``requirements/base.txt``,
  not an incidental transitive one.

Ciphertext is stored with a ``f1:`` marker so a legacy plaintext value (a row
written before this landed, or a value assigned in a shell) is recognised,
returned unchanged on read, and encrypted on the next write. That is what
makes the re-encrypting data migration idempotent and safe to re-run.
"""
import base64
import hashlib
import logging

from cryptography.fernet import Fernet, InvalidToken
from django.conf import settings

logger = logging.getLogger(__name__)

#: Marks a value as Fernet ciphertext produced by this module.
CIPHER_MARKER = 'f1:'


def _fernet() -> Fernet:
    key = base64.urlsafe_b64encode(
        hashlib.sha256(
            b'buddyup-account-secret-v1|' + str(settings.SECRET_KEY).encode()
        ).digest()
    )
    return Fernet(key)


def is_encrypted(value) -> bool:
    return isinstance(value, str) and value.startswith(CIPHER_MARKER)


def encrypt_value(value: str) -> str:
    """Return ciphertext for ``value``; empty and already-encrypted pass through."""
    if not value:
        return ''
    if is_encrypted(value):
        return value
    return CIPHER_MARKER + _fernet().encrypt(str(value).encode()).decode()


def decrypt_value(value: str) -> str:
    """Return plaintext for ``value``.

    Legacy plaintext (no marker) is returned unchanged so rows written before
    this landed keep working until they are re-saved. Undecryptable ciphertext
    returns ``''`` and logs — never raises — because this runs inside query
    hydration, where an exception would turn one unreadable row into a 500 on
    every request that touches the user.
    """
    if not value:
        return ''
    if not is_encrypted(value):
        return value
    try:
        return _fernet().decrypt(value[len(CIPHER_MARKER):].encode()).decode()
    except (InvalidToken, ValueError, TypeError):
        logger.error(
            'Failed to decrypt a stored account secret (rotated SECRET_KEY or '
            'corrupt value). The secret is being ignored; 2FA for this account '
            'cannot be completed until it is re-enrolled.',
        )
        return ''
