"""Automatic activity detection from GPS/speed data.

Classifies a GPS trace into walk / run / cycle / hike based on
speed, elevation gain, and movement patterns. Keyless — works entirely
on-device/server-side with no external API or ML model.
"""

import logging
from typing import List, Tuple, Optional

from common.geo import haversine_km

logger = logging.getLogger(__name__)


def _segment_speeds(points: List[Tuple[float, float, float]]) -> List[float]:
    """Return speed (km/h) for each segment between consecutive points.

    Each point is (lat, lng, timestamp_seconds). timestamp_seconds is a
    Unix timestamp (float).
    """
    speeds = []
    for i in range(1, len(points)):
        lat1, lng1, t1 = points[i - 1]
        lat2, lng2, t2 = points[i]
        dt_hours = (t2 - t1) / 3600.0
        if dt_hours <= 0:
            continue
        dist_km = haversine_km(lat1, lng1, lat2, lng2)
        speeds.append(dist_km / dt_hours)
    return speeds


def _median(values: List[float]) -> float:
    if not values:
        return 0.0
    s = sorted(values)
    n = len(s)
    mid = n // 2
    if n % 2:
        return s[mid]
    return (s[mid - 1] + s[mid]) / 2.0


def _elevation_gain_m(points: List[Tuple[float, float, float, Optional[float]]]) -> float:
    """Total elevation gain from points that include elevation (4th element)."""
    gain = 0.0
    for i in range(1, len(points)):
        elev = points[i][3]
        prev_elev = points[i - 1][3]
        if elev is not None and prev_elev is not None:
            diff = elev - prev_elev
            if diff > 0:
                gain += diff
    return gain


def detect_activity_type(
    route: list,
    duration_seconds: int,
    distance_meters: float,
    elevation_gain_m: float | None = None,
) -> str:
    """Detect activity type from a GPS route.

    Heuristics (keyless, no ML):
    - walk: median speed 3–6 km/h, low elevation gain
    - run: median speed 6–14 km/h
    - cycle: median speed 12–30 km/h, or high speed with low elevation
    - hike: median speed 3–6 km/h with significant elevation gain (>100m)

    Falls back to 'walk' when there isn't enough data.
    """
    if not route or len(route) < 2:
        return 'walk'

    # Normalise each point to (lat, lng, timestamp, elevation?)
    points = []
    for p in route:
        if len(p) >= 3:
            lat, lng, ts = p[0], p[1], p[2]
            elev = p[3] if len(p) >= 4 else None
            points.append((lat, lng, ts, elev))

    if len(points) < 2:
        return 'walk'

    speeds = _segment_speeds([(p[0], p[1], p[2]) for p in points])
    if not speeds:
        return 'walk'

    median_speed = _median(speeds)  # km/h
    max_speed = max(speeds)

    # Elevation gain (from route points or caller-provided)
    if elevation_gain_m is None:
        elevation_gain_m = _elevation_gain_m(points)

    # Distance sanity
    _ = (distance_meters or 0) / 1000.0

    # --- Classification ---
    # Cycle: sustained speed >10 km/h, or max speed >25 km/h
    if median_speed > 12.0 or max_speed > 30.0:
        return 'cycle'

    # Run: median speed >6 km/h
    if median_speed > 6.0:
        return 'run'

    # Hike: walking speed but significant elevation gain
    if median_speed > 2.5 and elevation_gain_m and elevation_gain_m > 100:
        return 'hike'

    # Default: walk
    return 'walk'


def detect_activity_type_from_summary(
    duration_seconds: int,
    distance_meters: float,
    avg_speed_kmh: float | None = None,
    elevation_gain_m: float | None = None,
) -> str:
    """Detect activity type from summary stats alone (no route needed).

    Less accurate than route-based detection but works for manual entries.
    """
    if avg_speed_kmh is None and duration_seconds > 0 and distance_meters > 0:
        avg_speed_kmh = (distance_meters / 1000.0) / (duration_seconds / 3600.0)

    speed = avg_speed_kmh or 0.0

    if speed > 10.0:
        return 'cycle'
    if speed > 6.0:
        return 'run'
    if speed > 2.5 and elevation_gain_m and elevation_gain_m > 100:
        return 'hike'
    return 'walk'
