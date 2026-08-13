from decimal import Decimal

from django.core.management.base import BaseCommand, CommandError
from django.db import transaction

from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.wallet.models import ArtifactTransaction
from apps.wallet.serializers import ARTIFACT_VALUES
from apps.wallet.utils import credit_artifacts, credit_creator_artifacts


class Command(BaseCommand):
    help = (
        "Credit a user's wallet with demo/support artifacts and record audited "
        "ArtifactTransaction rows. Used for controlled demo grants only; any "
        "deployment with real stored value must go through licensed payment "
        "flows and financial review."
    )

    def add_arguments(self, parser):
        parser.add_argument('--email', required=True)
        parser.add_argument('--regular', default='', help='e.g. champion:1000,squat:12')
        parser.add_argument('--creator', default='', help='e.g. champion:100,sprint:10')
        parser.add_argument('--note', default='Demo/support grant')

    def handle(self, *args, **options):
        email = options['email']
        user = User.objects.filter(email__iexact=email).first()
        if not user:
            raise CommandError(f'No user with email {email}')
        profile = Profile.objects.get(user=user)

        def parse(spec):
            items = []
            for part in spec.split(','):
                part = part.strip()
                if not part:
                    continue
                if ':' not in part:
                    raise CommandError(f'Bad spec segment: {part!r} (expected artifact:qty)')
                artifact, qty = part.rsplit(':', 1)
                artifact = artifact.strip()
                if artifact not in ARTIFACT_VALUES:
                    raise CommandError(f'Unknown artifact {artifact!r}')
                items.append((artifact, int(qty), Decimal(ARTIFACT_VALUES[artifact]) * int(qty)))
            return items

        regular = parse(options['regular'])
        creator = parse(options['creator'])

        with transaction.atomic():
            for artifact, qty, fiat in regular:
                credit_artifacts(profile, artifact, qty)
                ArtifactTransaction.objects.create(
                    user=profile,
                    transaction_type='bonus',
                    artifact_type=artifact,
                    quantity=qty,
                    direction='credit',
                    status='completed',
                    fiat_amount=fiat,
                    fiat_currency='USD',
                    description=options['note'],
                )
                self.stdout.write(f'regular  +{qty} {artifact} (${fiat})')

            for artifact, qty, fiat in creator:
                credit_creator_artifacts(profile, artifact, qty)
                ArtifactTransaction.objects.create(
                    user=profile,
                    transaction_type='bonus',
                    artifact_type=artifact,
                    quantity=qty,
                    direction='credit',
                    status='completed',
                    fiat_amount=fiat,
                    fiat_currency='USD',
                    description=options['note'],
                )
                self.stdout.write(f'creator  +{qty} {artifact} (${fiat})')

        from apps.wallet.utils import _get_total_balance, calculate_fiat
        total = _get_total_balance(profile)
        self.stdout.write(self.style.SUCCESS(
            f'Done. Email={email} total_balance={total} fiat={calculate_fiat(total)["display"]}'
        ))
