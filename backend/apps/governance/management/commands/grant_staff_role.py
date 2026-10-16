"""Grant a staff role to an account that already exists.

This is the bootstrap path, and it exists because the invitation flow cannot
reach an account that is already staff: ``StaffInvitationCreateSerializer``
refuses to invite an address that already holds staff access, on the grounds
that changing someone's role is a staff-*role* operation, not a new invitation.

That leaves a hole for the very first staff account on a fresh install -- there
is nobody to send an invitation to, because ``is_staff`` has to come from
somewhere. This command is that somewhere, and it is deliberately loud:

* it requires ``--yes`` so it cannot be run by muscle memory;
* it prints exactly what it will change and waits for confirmation;
* it writes the same audit row every other staff action writes, and sends the
  same notification, so the grant appears in the console like any other.

It does **not** bypass the two-person rule for anything after bootstrap: use
the invitation flow, or the approvals queue, for day-to-day changes.
"""
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils import timezone

from apps.accounts.models import User
from apps.governance.audit import record_admin_action
from apps.governance.models import StaffRole


class Command(BaseCommand):
    help = 'Grant a staff role to an existing account (bootstrap only).'

    def add_arguments(self, parser):
        parser.add_argument('--email', required=True, help='Email of the account to promote.')
        parser.add_argument(
            '--role', default='admin',
            choices=[r for r, _ in StaffRole.ROLE_CHOICES],
            help='Role to grant (default: admin).',
        )
        parser.add_argument(
            '--scope', action='append', default=[], dest='scopes',
            help='Extra scope beyond the role defaults. Repeatable.',
        )
        parser.add_argument('--notes', default='', help='Why this grant was made.')
        parser.add_argument(
            '--yes', action='store_true',
            help='Skip the confirmation prompt. Required in any non-interactive run.',
        )

    def handle(self, *args, **options):
        email = options['email'].strip()
        role_name = options['role']
        scopes = options['scopes'] or []
        notes = options['notes']

        user = User.objects.filter(email__iexact=email).first()
        if user is None:
            raise CommandError(
                f'No account with email {email!r}. '
                'Use the invitation flow for an address that has not registered yet.'
            )

        existing = StaffRole.objects.filter(user=user).first()
        was_staff = user.is_staff
        role_display = dict(StaffRole.ROLE_CHOICES)[role_name]

        self.stdout.write('')
        self.stdout.write(f'  Email        : {user.email}')
        self.stdout.write(f'  is_staff     : {was_staff} -> True')
        if existing:
            self.stdout.write(f'  StaffRole    : {existing.role} -> {role_name}')
        else:
            self.stdout.write(f'  StaffRole    : (none) -> {role_name}')
        self.stdout.write(f'  Extra scopes : {scopes or "none"}')
        self.stdout.write('')

        if not options['yes']:
            answer = input('Proceed? [y/N] ').strip().lower()
            if answer not in ('y', 'yes'):
                self.stdout.write('Aborted. Nothing changed.')
                return

        with transaction.atomic():
            if not user.is_staff:
                user.is_staff = True
                user.save(update_fields=['is_staff'])

            row, created = StaffRole.objects.update_or_create(
                user=user,
                defaults={
                    'role': role_name,
                    'scopes': scopes,
                    'notes': notes,
                    'granted_by': None,
                    'granted_at': timezone.now(),
                    'revoked_at': None,
                },
            )

            record_admin_action(
                actor=None,
                action='staff_roles.grant',
                summary=(
                    f'Bootstrap grant via `grant_staff_role` management command: '
                    f'{user.email} is now {role_name}. {notes}'.strip()
                ),
                target_type='staff_role',
                target_id=str(row.id),
                after={'role': role_name, 'scopes': scopes},
                # No actor: nobody is signed in at the shell. The summary names
                # the operator's intent, and the row is timestamped, so the
                # trail still records *that* it happened even though it cannot
                # record *who* ran the command. Same shape as a system action.
            )

        self._notify(user, row, created=created, was_staff=was_staff)

        self.stdout.write(self.style.SUCCESS(
            f'{user.email} is now staff ({role_display}).'
        ))
        if row.role != 'admin':
            self.stdout.write(self.style.WARNING(
                'This account holds no `admin` role, so it cannot grant other '
                'staff roles. Use `--role admin` if that is intended.'
            ))

    def _notify(self, user, row, *, created, was_staff):
        """Same notification type every other grant uses.

        The invitee may have no Profile row (a createsuperuser account), in which
        case create_notification resolves and returns quietly -- which is the
        correct outcome, not a failure.
        """
        from apps.notifications.tasks import create_notification

        create_notification.delay(
            recipient_id=str(user.pk),
            notification_type='staff_role_granted',
            title=f'You now have the {row.role} role on Buddy Up',
            body='Your staff access was set up by a platform operator.',
            metadata={
                'role': row.role,
                'scopes': list(row.scopes or []),
                'previous_role': None if not was_staff else row.role,
                'via': 'management_command',
            },
            dedupe_key=f'staff-bootstrap-{user.pk}-{row.role}',
        )
