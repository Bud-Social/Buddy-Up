"""Re-save existing ``totp_secret`` values so they land encrypted.

``totp_secret`` became an ``EncryptedCharField`` in 0009: reads decrypt and
writes encrypt, and a legacy plaintext value is returned unchanged until it
is written back. This migration performs that write-back for every user who
has a secret, so no plaintext TOTP seed survives in the table.

It uses the historical model on purpose — it carries the same custom field,
so ``save()`` goes through ``get_prep_value`` exactly like application code
does. Reading is likewise exercised: a value already stored as ciphertext
comes back decrypted and is simply re-encrypted, which is why re-running
this migration is harmless (it rewrites the same plaintext, never a
double-encrypted blob — ``encrypt_value`` passes an already-marked value
through untouched).
"""
from django.db import migrations

BATCH_SIZE = 500


def encrypt_existing_totp_secrets(apps, schema_editor):
    User = apps.get_model('accounts', 'User')
    last_pk = None
    while True:
        qs = User.objects.exclude(totp_secret='').order_by('pk')
        if last_pk is not None:
            qs = qs.filter(pk__gt=last_pk)
        batch = list(qs.only('pk', 'totp_secret')[:BATCH_SIZE])
        if not batch:
            break
        for user in batch:
            user.save(update_fields=['totp_secret'])
        last_pk = batch[-1].pk


def noop(apps, schema_editor):
    """Reverse is a no-op: the 0009 schema revert restores a plaintext column
    and the stored values stay readable either way."""
    pass


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0009_user_failed_login_count_user_locked_until_and_more'),
    ]

    operations = [
        migrations.RunPython(encrypt_existing_totp_secrets, noop),
    ]
