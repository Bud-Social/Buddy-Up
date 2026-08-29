"""Request correlation and process-local metrics for operational endpoints."""
from contextvars import ContextVar
from threading import Lock


request_id_var: ContextVar[str] = ContextVar('request_id', default='-')

_metrics_lock = Lock()
_metrics = {'requests_total': 0, 'errors_total': 0, 'duration_ms_total': 0.0}


def record_request(status_code: int, duration_ms: float) -> None:
    """Record low-cardinality counters; aggregation is per worker process."""
    with _metrics_lock:
        _metrics['requests_total'] += 1
        _metrics['errors_total'] += int(status_code >= 500)
        _metrics['duration_ms_total'] += duration_ms


def prometheus_metrics() -> str:
    with _metrics_lock:
        values = dict(_metrics)
    return '\n'.join([
        '# HELP buddyup_http_requests_total Total HTTP requests handled by this worker.',
        '# TYPE buddyup_http_requests_total counter',
        f"buddyup_http_requests_total {values['requests_total']}",
        '# HELP buddyup_http_errors_total Total HTTP 5xx responses handled by this worker.',
        '# TYPE buddyup_http_errors_total counter',
        f"buddyup_http_errors_total {values['errors_total']}",
        '# HELP buddyup_http_duration_ms_total Total request duration in milliseconds.',
        '# TYPE buddyup_http_duration_ms_total counter',
        f"buddyup_http_duration_ms_total {values['duration_ms_total']:.1f}",
        '',
    ])


class RequestIdFilter:
    """Inject ``request_id`` into every log record used by formatters."""

    def filter(self, record):
        record.request_id = request_id_var.get()
        return True
