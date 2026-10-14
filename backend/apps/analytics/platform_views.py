"""Staff analytics endpoints, mounted at ``/api/v1/portal/analytics/``.

These live in ``apps.analytics`` rather than ``apps.admin_portal`` because every
line of the computation — the metric registry, the rollup reader, the window
validation — belongs to the analytics app, and ``admin_portal`` only owns the
route table. What they borrow from the portal is the envelope, the scope helper
(:mod:`apps.analytics.platform_permissions`) and the audit writer.

Conventions, matching ``admin_portal``:

* Every response is ``{success, data, message, errors, pagination}``.
* An unknown metric / kind / granularity / date is a 400 naming the allowed
  set — never a silently empty result, which reads as "no data" when it means
  "you passed something invalid".
* Every figure declares its own window (see :mod:`apps.analytics.platform_metrics`).
* Nothing here writes to a source table. Exports write exactly one audit row.

Scope note: ``GovernanceAuditMixin`` is deliberately *not* mixed in here. It skips
SAFE_METHODS by design ("reading the audit trail does not grow it"), and an
export is a GET that moves platform data off-platform. The export view therefore
records its own row through ``governance.services.record_admin_action`` — the
same writer the mixin uses, called at the moment the file is actually produced,
including the row count, so the audit says what left the building.
"""
import logging

from rest_framework import status
from rest_framework.exceptions import ValidationError

from apps.admin_portal.views import PortalView

from . import platform_metrics as metrics
from .exports import (
    FORMATS, XLSX_MISSING_MESSAGE, XlsxUnavailable, build_report,
    openpyxl_available, render_csv, render_xlsx,
)
from .platform_permissions import CanExportAnalytics, CanReadAnalytics

logger = logging.getLogger(__name__)


class AnalyticsView(PortalView):
    """Base for every analytics route: envelope + read scope + report dispatch."""

    permission_classes = [CanReadAnalytics]

    #: Set by subclasses that read a different kind of param.
    report_key = None

    def build(self, request):
        return getattr(metrics, self.report_key)(request.query_params)


class AnalyticsOverviewView(AnalyticsView):
    """Headline KPIs, each with its own declared window."""

    report_key = 'build_overview'

    def get(self, request):
        return self.ok(self.build(request), message='Platform overview.')


class AnalyticsTimeseriesView(AnalyticsView):
    """One metric over time, zero-filled, from the rollup when it is complete."""

    report_key = 'build_timeseries'

    def get(self, request):
        data = self.build(request)
        source = data['data_source']['path']
        return self.ok(
            data,
            message=f'{data["metric"]["key"]} ({source}).',
        )


class AnalyticsTrendingView(AnalyticsView):
    """Top items for a kind. ``pages`` answers honestly that it has no data."""

    report_key = 'build_trending'

    def get(self, request):
        data = self.build(request)
        message = 'Trending items.' if data['available'] else data['reason']
        return self.ok(data, message=message)


class AnalyticsAIQualityView(AnalyticsView):
    """Per-model accuracy proxy, fallback rate, latency and cost."""

    report_key = 'build_ai_quality'

    def get(self, request):
        data = self.build(request)
        return self.ok(data, message='AI quality and cost.')


class AnalyticsPredictiveView(AnalyticsView):
    """Observed recommendation signals. No forecast, and it says so."""

    report_key = 'build_predictive'

    def get(self, request):
        data = self.build(request)
        return self.ok(data, message='Observed recommendation signals. No forecast is produced.')


class AnalyticsExportView(AnalyticsView):
    """Download a report as CSV or XLSX.

    Scope is ``analytics.export`` and nothing else. The rows are produced by the
    same builder the screen uses for the same ``report`` key, with the same date
    validation, so an export cannot cover a different period from the report the
    caller was looking at.
    """

    permission_classes = [CanExportAnalytics]

    def perform_content_negotiation(self, request, force=True):
        """Stop DRF reading ``?format=`` as a *renderer* override.

        ``URL_FORMAT_OVERRIDE`` is set to ``'format'``, so DRF looks for a
        renderer literally named "csv" or "xlsx", finds none and raises
        Http404 — a 404 on every export, with no hint that the parameter is the
        problem. The public contract for this endpoint is ``?format=csv|xlsx``,
        so rather than rename it, the parameter is hidden from negotiation for
        the duration of the call and read by ``get()`` instead. Restored in a
        ``finally`` so an exception cannot leave the request mutated.
        """
        original = request._request.GET
        if 'format' not in original:
            return super().perform_content_negotiation(request, force=force)
        stripped = original.copy()
        stripped.pop('format', None)
        request._request.GET = stripped
        try:
            return super().perform_content_negotiation(request, force=force)
        finally:
            request._request.GET = original

    def get(self, request):
        params = request.query_params
        report_key = (params.get('report') or '').strip()
        fmt = (params.get('format') or 'csv').strip().lower()

        if fmt not in FORMATS:
            return self.fail(
                f'Unknown format {fmt!r}. Must be one of: {", ".join(FORMATS)}.',
                status_code=status.HTTP_400_BAD_REQUEST,
                errors={'format': [f'Unknown format {fmt!r}.']},
            )

        # Build first. A bad report key, a bad window or a bad metric has to be
        # a 400 naming the problem — never a 503 that blames a missing package,
        # which would send the caller off to rebuild an image for what is
        # really a typo. Building once (rather than building then re-building
        # inside the renderer) keeps the expensive aggregate off the error path
        # of a missing-dependency deployment only once, not twice.
        try:
            built = build_report(report_key, params)
        except ValidationError:
            raise
        except Exception:  # noqa: BLE001 — never leak a non-DRF error as a 500
            logger.exception('analytics_export_build_failed report=%s', report_key)
            return self.fail(
                f'Could not build the {report_key!r} report.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

        if fmt == 'xlsx' and not openpyxl_available():
            _audit(request, built, fmt, outcome='refused_missing_dependency')
            return self.fail(
                XLSX_MISSING_MESSAGE,
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                errors={'format': ['xlsx requires the "openpyxl" package.']},
            )

        try:
            response = render_csv(built) if fmt == 'csv' else render_xlsx(built)
        except XlsxUnavailable:
            _audit(request, built, fmt, outcome='refused_missing_dependency')
            return self.fail(
                XLSX_MISSING_MESSAGE,
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                errors={'format': ['xlsx requires the "openpyxl" package.']},
            )

        _audit(
            request, built, fmt, outcome='exported',
            rows=int(response.get('X-Analytics-Rows') or 0),
            window_from=response.get('X-Analytics-From', ''),
            window_to=response.get('X-Analytics-To', ''),
            data_source=response.get('X-Analytics-Data-Source', ''),
        )
        return response

def _audit(request, built, fmt, *, outcome, rows=0, window_from='', window_to='',
           data_source=''):
    """One AdminActionLog row per export attempt.

    Written through ``governance.services.record_admin_action`` — the same
    writer ``GovernanceAuditMixin`` uses — because the mixin skips safe methods
    by design ("reading the audit trail does not grow it") and an export is a GET
    that moves platform data off-platform. Refusals are recorded too: "who tried
    to export and could not" is a more interesting audit line than a success.
    """
    from apps.governance.services import record_admin_action

    record_admin_action(
        actor=request.user,
        action='analytics.export',
        summary=f'Exported analytics report {built.key!r} as {fmt} ({outcome}).',
        target_type='analytics_export',
        target_id=built.key[:64],
        after={
            'report': built.key,
            'format': fmt,
            'outcome': outcome,
            'rows': rows,
            'from': window_from,
            'to': window_to,
            'data_source': data_source,
        },
        request=request,
    )
