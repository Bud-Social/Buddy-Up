"""System checks for the lives app.

Surfaces deploy-time misconfigurations that would otherwise fail silently
at runtime (e.g. Agora channels running open because the RTC certificate
is missing in production).
"""

from django.conf import settings
from django.core import checks


@checks.register('lives')
def check_agora_certificate(app_configs=None, **kwargs):
    """Warn when production would issue RTC joins without token enforcement.

    ``generate_agora_token`` returns ``None`` when ``AGORA_APP_CERTIFICATE``
    is unset, and the client then joins the channel without a token —
    anyone with the (public) App ID can join and publish. Dev/DEBUG is
    exempt; in production this is almost always a mistake.
    """
    errors = []
    if getattr(settings, 'DEBUG', False):
        return errors

    app_id = getattr(settings, 'AGORA_APP_ID', '')
    certificate = getattr(settings, 'AGORA_APP_CERTIFICATE', '')
    if app_id and not certificate:
        errors.append(checks.Warning(
            'AGORA_APP_CERTIFICATE is not set — live RTC channels run in '
            'non-secure mode (anyone with the App ID can join and publish).',
            hint='Set AGORA_APP_CERTIFICATE in the production environment, '
                 'or remove AGORA_APP_ID to disable RTC tokens entirely.',
            id='lives.W001',
        ))
    return errors
