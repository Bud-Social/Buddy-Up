"""Register (or promote) a trained model artifact.

Thin CLI over apps.ai.ModelMetadata — the counterpart of
``app/ml/hf_utils.log_run`` for the packaging step::

    docker compose exec backend python manage.py register_model \\
        --name nsfw_classifier --model-version 2.0.0 \\
        --artifact-path models/nsfw_classifier-2.0.0_int8.onnx \\
        --framework pytorch --metrics '{"accuracy": 0.97, "p95_ms": 210}' \\
        --activate

``--activate`` flips this version active (canary/rollback is just another
call with the previous version). ``--no-sync`` skips pushing state to the
AI service; without it, sync_model_metadata runs afterwards so serving
picks the change up.
"""
import json

from django.core.management.base import BaseCommand, CommandError

from apps.ai.models import ModelMetadata


class Command(BaseCommand):
    help = 'Upsert a ModelMetadata row for a trained artifact (and optionally activate it).'

    def add_arguments(self, parser):
        parser.add_argument('--name', required=True)
        # NOTE: `--version` is reserved by Django itself (it prints the
        # framework version), so the model version travels as --model-version.
        parser.add_argument('--model-version', required=True)
        parser.add_argument('--artifact-path', default='')
        parser.add_argument('--framework', default='pytorch')
        parser.add_argument('--description', default='')
        parser.add_argument('--metrics', default='{}')
        parser.add_argument('--activate', action='store_true',
                            help='set is_active=True on this version (others of the same name stay as-is)')
        parser.add_argument('--deactivate-others', action='store_true',
                            help='set is_active=False on all other versions of this model')
        parser.add_argument('--no-sync', action='store_true')

    def handle(self, *args, **options):
        try:
            metrics = json.loads(options['metrics'])
        except json.JSONDecodeError as exc:
            raise CommandError(f'--metrics must be valid JSON: {exc}')
        if not isinstance(metrics, dict):
            raise CommandError('--metrics must be a JSON object')

        row, created = ModelMetadata.objects.update_or_create(
            name=options['name'], version=options['model_version'],
            defaults={
                'artifact_path': options['artifact_path'],
                'framework': options['framework'],
                'description': options['description'],
                'metrics': metrics,
            },
        )
        # is_active is only ever touched via explicit flags — re-registering
        # metrics must never silently deactivate a live model.
        if options['activate'] and not row.is_active:
            row.is_active = True
            row.save(update_fields=['is_active'])
        if options['deactivate_others']:
            ModelMetadata.objects.filter(name=options['name']).exclude(pk=row.pk).update(is_active=False)
        self.stdout.write(self.style.SUCCESS(
            f"{'Created' if created else 'Updated'} {row.name} {row.version} "
            f"(active={row.is_active}, artifact={row.artifact_path or '—'})"
        ))

        if not options['no_sync']:
            from django.core.management import call_command
            call_command('sync_model_metadata')
