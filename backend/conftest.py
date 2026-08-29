import pytest

from django.core.cache import cache


@pytest.fixture(autouse=True)
def _isolate_cache():
    """Reset the shared cache around every test.

    Rate limits, idempotency markers and other throttling state live in the
    cache backend. Without this fixture, counters survive ``--reuse-db`` runs
    and make throttle-heavy suites order-dependent and flaky.
    """
    cache.clear()
    yield
    cache.clear()
