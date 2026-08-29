from django.core.management.base import BaseCommand, CommandError

from apps.wallet.tasks import reconcile_flutterwave_transactions


class Command(BaseCommand):
    help = 'Reconcile recent Flutterwave provider records against the internal ledger.'

    def add_arguments(self, parser):
        parser.add_argument('--fail-on-mismatch', action='store_true')

    def handle(self, *args, **options):
        summary = reconcile_flutterwave_transactions.run()
        for key, value in summary.items():
            self.stdout.write(f'{key}: {value}')
        if options['fail_on_mismatch'] and (summary['mismatched'] or summary['errors']):
            raise CommandError('Wallet reconciliation reported actionable discrepancies')
        self.stdout.write(self.style.SUCCESS('Wallet reconciliation completed.'))
