"""Make no demotion, loudly and repeatably.

Why this migration writes nothing
---------------------------------
Closing the self-declared-role hole tempts a companion data migration that
"cleans up" the damage: demote every ``role != 'user'`` profile back to
``user``, or clear the ``verification_status`` that no longer matches. That
migration would be wrong, and not in a subtle way:

* The ``role`` values already in the table are not all fraudulent. They are a
  mix of legitimately-verified professionals and people who typed "trainer" into
  a signup form. The table cannot tell the two apart, so any blanket demotion
  silently strips real professionals of their role and their verified status
  together, in one unreviewed statement.
* Silently is the operative word. A user would log in tomorrow, find their
  trainer profile gone, and have no record of why.
* Neither is recoverable from the database afterwards: ``role`` has no history,
  so the demotion destroys the only copy.

So the population is *counted and reported*, never rewritten. The authorisation
fix that makes the count harmless is in code, not data:
``Profile.is_verified_role()`` and the corrected permission classes in
``apps.verification.permissions`` both require role *and* verification_status,
so every one of these rows is already treated as an unverified claim by the
permission layer regardless of what this migration does or does not write.

Reverting a professional's role is a per-person, evidenced decision. It belongs
in a reviewed staff action with an actor and a reason — not in a migration that
runs once, unattended, with no audit row.
"""
from django.db import migrations


def report_self_declared_roles(apps, schema_editor):
    """Count the affected population. Writes nothing. Always safe to re-run."""
    Profile = apps.get_model('profiles', 'Profile')

    elevated = Profile.objects.exclude(role='user')
    total = elevated.count()

    # The split that matters operationally: a role with the matching verified
    # status is a genuine professional; a role without one is the unverified
    # claim this whole change is about. Both keep their row.
    role_values = [c[0] for c in Profile._meta.get_field('role').choices]
    breakdown = {}
    unverified = 0
    for role in role_values:
        if role == 'user':
            continue
        rows = elevated.filter(role=role)
        count = rows.count()
        if not count:
            continue
        verified_for_role = rows.filter(verification_status=role).count()
        breakdown[role] = {
            'total': count,
            'verification_status_matches_role': verified_for_role,
            # Everything else: 'none', 'email', or another role's status. All of
            # these are the unverified claim — a role with no certifying status.
            'verification_status_does_not_match_role': count - verified_for_role,
        }
        unverified += count - verified_for_role

    # No write. Not a no-op migration for symmetry's sake: the absence of the
    # write is the point, and a comment cannot be mistaken for one.
    print(
        '[profiles.migrations] self-declared-role audit: '
        f'{total} profile(s) hold an elevated role; '
        f'{unverified} of them have no verification_status matching that role '
        'and are treated as unverified claims by apps.verification.permissions. '
        'No rows were modified. Breakdown: ' + repr(breakdown)
    )


def noop(apps, schema_editor):
    """Schema operation counterpart — this migration has no schema change."""
    return None


class Migration(migrations.Migration):

    dependencies = [
        ('profiles', '0013_buddyinterest'),
    ]

    operations = [
        migrations.RunPython(report_self_declared_roles, noop),
    ]