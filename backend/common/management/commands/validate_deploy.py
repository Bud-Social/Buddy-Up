"""Validate production configuration without exposing secret values."""
import os
from urllib.parse import urlparse

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError


class Command(BaseCommand):
    help = 'Fail when required production configuration is missing or malformed.'

    def handle(self, *args, **options):
        errors = []
        warnings = []

        required = ('SECRET_KEY', 'DATABASE_URL', 'REDIS_URL')
        for key in required:
            if not os.environ.get(key):
                errors.append(f'{key} is required')
        if not settings.DEBUG and not settings.METRICS_TOKEN:
            errors.append('METRICS_TOKEN is required outside DEBUG mode')

        if settings.SECRET_KEY in ('', 'change-me', 'build-only-placeholder') or len(settings.SECRET_KEY) < 32:
            errors.append('SECRET_KEY must be at least 32 characters and not a placeholder')

        for origin in settings.CORS_ALLOWED_ORIGINS:
            parsed = urlparse(origin)
            if parsed.scheme not in ('http', 'https') or not parsed.netloc:
                errors.append(f'invalid CORS origin: {origin!r}')
        if not settings.CORS_ALLOWED_ORIGINS:
            warnings.append('CORS_ALLOWED_ORIGINS is empty; browsers will block cross-origin API calls')
        elif any('*' in origin for origin in settings.CORS_ALLOWED_ORIGINS):
            warnings.append('CORS_ALLOWED_ORIGINS contains wildcard entries; prefer explicit origins')

        csrf_origins = getattr(settings, 'CSRF_TRUSTED_ORIGINS', [])
        if not csrf_origins:
            warnings.append('CSRF_TRUSTED_ORIGINS is empty; cross-origin form posts will be rejected')
        elif any('*' in origin for origin in csrf_origins):
            warnings.append('CSRF_TRUSTED_ORIGINS contains wildcard entries; prefer explicit origins')

        webauthn_rp_id = os.environ.get('WEBAUTHN_RP_ID', '')
        webauthn_origin = os.environ.get('WEBAUTHN_ORIGIN', '')
        if not webauthn_rp_id or not webauthn_origin:
            warnings.append('WEBAUTHN_RP_ID / WEBAUTHN_ORIGIN unset; passkeys fall back to buddyup.app defaults')
        else:
            frontend_url = os.environ.get('PUBLIC_FRONTEND_URL', '')
            api_url = os.environ.get('PUBLIC_API_URL', '')
            if frontend_url and webauthn_origin.rstrip('/') != frontend_url.rstrip('/'):
                warnings.append(
                    f'WEBAUTHN_ORIGIN {webauthn_origin!r} does not match PUBLIC_FRONTEND_URL '
                    f'{frontend_url!r}; passkey creation will fail on the frontend domain'
                )
            elif not frontend_url and api_url and webauthn_origin.rstrip('/') == api_url.rstrip('/'):
                warnings.append(
                    'WEBAUTHN_ORIGIN points at the API origin; passkeys must be created on the '
                    'frontend domain the browser actually visits'
                )

        public_api = os.environ.get('PUBLIC_API_URL', '')
        if public_api:
            parsed = urlparse(public_api)
            if parsed.scheme != 'https' or not parsed.netloc:
                errors.append('PUBLIC_API_URL must be an absolute https URL')
        elif not os.environ.get('CLOUDINARY_URL'):
            warnings.append('Neither PUBLIC_API_URL nor CLOUDINARY_URL is configured; media URLs may be relative')

        if not os.environ.get('FLUTTERWAVE_WEBHOOK_HASH'):
            warnings.append('FLUTTERWAVE_WEBHOOK_HASH missing; payment webhooks will fail closed')
        if not os.environ.get('SENTRY_DSN'):
            warnings.append('SENTRY_DSN missing; exceptions rely on Railway logs only')

        for warning in warnings:
            self.stdout.write(self.style.WARNING(f'WARNING: {warning}'))
        if errors:
            for error in errors:
                self.stderr.write(self.style.ERROR(f'ERROR: {error}'))
            raise CommandError(f'{len(errors)} deployment configuration error(s)')

        self.stdout.write(self.style.SUCCESS('Deployment configuration valid.'))
