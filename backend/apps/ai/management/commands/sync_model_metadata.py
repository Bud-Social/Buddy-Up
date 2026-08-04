from django.core.management.base import BaseCommand

from apps.ai.sync import push_model_metadata


class Command(BaseCommand):
    help = 'Push ModelMetadata state to the AI service (canary/rollback sync).'

    def handle(self, *args, **options):
        count, result = push_model_metadata()
        if count:
            self.stdout.write(self.style.SUCCESS(
                f'Synced {count} model metadata rows. active={result.get("active")}'
            ))
        else:
            self.stdout.write(self.style.WARNING(
                'No model metadata synced (AI service unreachable or no rows).'
            ))
