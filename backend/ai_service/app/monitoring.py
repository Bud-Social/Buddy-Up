"""Lightweight monitoring: request latency, per-path counters, model status.

Deliberately dependency-free (no Prometheus client) so the CPU-only service stays
light. Predictions are still audited server-side via Django `AIPredictionJob`.
"""
import logging
import statistics
import time
from collections import defaultdict, deque

logger = logging.getLogger(__name__)

MAX_SAMPLES = 2000


class _Metrics:
    def __init__(self):
        self.calls = defaultdict(int)
        self.errors = defaultdict(int)
        self.latencies = defaultdict(lambda: deque(maxlen=MAX_SAMPLES))

    def record(self, path: str, elapsed_ms: float, ok: bool):
        route = path or 'unknown'
        self.calls[route] += 1
        self.latencies[route].append(elapsed_ms)
        if not ok:
            self.errors[route] += 1

    def snapshot(self, models: list[str], indexes: list[str]) -> dict:
        routes = []
        for route, count in self.calls.items():
            lat = self.latencies[route]
            routes.append({
                'path': route,
                'calls': count,
                'errors': self.errors.get(route, 0),
                'avg_ms': round(statistics.mean(lat), 2) if lat else 0.0,
                'p95_ms': round(statistics.quantiles(lat, n=20)[18], 2) if len(lat) >= 20 else (round(statistics.mean(lat), 2) if lat else 0.0),
            })
        routes.sort(key=lambda r: -r['calls'])
        return {
            'uptime_seconds': round(time.time() - _STARTED, 1),
            'total_calls': sum(self.calls.values()),
            'total_errors': sum(self.errors.values()),
            'routes': routes,
            'models_loaded': models,
            'embedding_indexes': indexes,
        }


_METRICS = _Metrics()
_STARTED = time.time()


class LatencyMiddleware:
    """Starlette middleware recording per-route latency + errors."""

    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        if scope['type'] != 'http':
            await self.app(scope, receive, send)
            return

        start = time.perf_counter()
        status = [200]

        async def send_wrapper(message):
            if message['type'] == 'http.response.start':
                status[0] = message['status']
            await send(message)

        try:
            await self.app(scope, receive, send_wrapper)
            ok = status[0] < 500
        except Exception:  # noqa: BLE001
            ok = False
            raise
        finally:
            elapsed_ms = (time.perf_counter() - start) * 1000.0
            _METRICS.record(scope.get('path', 'unknown'), elapsed_ms, ok)


def get_metrics() -> dict:
    from .model_registry import ModelRegistry
    from .embedding_engine import FaissIndex
    return _METRICS.snapshot(
        models=sorted(ModelRegistry.list_models()),
        indexes=FaissIndex.list_indexes(),
    )
