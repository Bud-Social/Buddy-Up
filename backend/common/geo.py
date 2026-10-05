"""Shared geo helpers: haversine distance + adaptive nearby radius.

Default nearby is 5-10 km depending on area density:
- dense/connected areas (>= DENSE_MIN_COUNT venues in 5 km): 5 km
- sparse/remote areas: 10 km (expanded so users still see results)

The caller reports the chosen radius + reason so the UI can show a
slide-down note explaining the choice. Explicit user radius always wins.
"""
import math

NEAR_RADIUS_KM = 5.0
WIDE_RADIUS_KM = 10.0
DENSE_MIN_COUNT = 10


def haversine_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    r = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlng = math.radians(lng2 - lng1)
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlng / 2) ** 2
    )
    return 2 * r * math.asin(math.sqrt(a))


def bbox_deltas(lat: float, radius_km: float) -> tuple[float, float]:
    lat_delta = radius_km / 111.0
    lng_delta = radius_km / max(111.0 * abs(math.cos(math.radians(lat))), 1e-6)
    return lat_delta, lng_delta


def pick_adaptive_radius(count_in_near: int) -> tuple[float, str]:
    """Return (radius_km, density) where density is 'dense' or 'sparse'."""
    if count_in_near >= DENSE_MIN_COUNT:
        return NEAR_RADIUS_KM, 'dense'
    return WIDE_RADIUS_KM, 'sparse'


def adaptive_message(radius_km: float, density: str, count_in_near: int) -> str:
    if density == 'dense':
        return (
            f'Showing places within {radius_km:g} km — '
            f'{count_in_near} nearby, so we kept it tight.'
        )
    return (
        f'Showing places within {radius_km:g} km — '
        f'only {count_in_near} within {NEAR_RADIUS_KM:g} km, so we expanded the search.'
    )


def count_within_latlng(queryset, lat: float, lng: float, radius_km: float) -> int:
    """Count rows with latitude/longitude fields inside the bbox."""
    lat_delta, lng_delta = bbox_deltas(lat, radius_km)
    return queryset.filter(
        latitude__isnull=False,
        longitude__isnull=False,
        latitude__gte=lat - lat_delta,
        latitude__lte=lat + lat_delta,
        longitude__gte=lng - lng_delta,
        longitude__lte=lng + lng_delta,
    ).count()
