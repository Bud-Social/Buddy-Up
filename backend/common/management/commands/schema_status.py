"""
schema_status — make database/code drift visible in deploy logs.

Django applies migrations via the migrate command, but when a deployment
serves code whose models reference columns/tables that do not exist yet
(e.g. migrations skipped or a stale release), every affected endpoint 500s
with an opaque ProgrammingError. This command prints exactly what is out of
sync so Railway logs point straight at the problem.

Usage:
    python manage.py schema_status          # print pending migrations
    python manage.py schema_status --strict # exit non-zero if any pending
"""
from django.core.management.base import BaseCommand
from django.db import connection
from django.db.migrations.executor import MigrationExecutor


class Command(BaseCommand):
    help = 'Report (and optionally enforce) unapplied migrations.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--strict', action='store_true',
            help='Exit with a non-zero status if any migration is unapplied.',
        )

    def handle(self, *args, **options):
        executor = MigrationExecutor(connection)
        plan = executor.migration_plan(executor.loader.graph.leaf_nodes())
        if not plan:
            self.stdout.write(self.style.SUCCESS(
                'Schema OK: all migrations applied.'
            ))
            return

        self.stdout.write(self.style.ERROR(
            f'SCHEMA DRIFT: {len(plan)} migration(s) not applied:'
        ))
        for migration, _backward in plan:
            self.stdout.write(self.style.ERROR(f'  - {migration.app_label}: {migration.name}'))
        self.stdout.write(self.style.ERROR(
            'Endpoints touching these models will return 500 until '
            '"python manage.py migrate" completes.'
        ))

        if options['strict']:
            raise SystemExit(1)
