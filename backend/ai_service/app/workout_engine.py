import logging
from datetime import datetime, timedelta
from typing import Any

import numpy as np

logger = logging.getLogger(__name__)


def _est_1rm(weight: float, reps: int) -> float:
    if reps == 1:
        return weight
    return weight * (1 + reps / 30)


def _compute_volume(exercise: dict) -> float:
    sets = exercise.get('sets', 1)
    reps = exercise.get('reps', 1)
    weight = exercise.get('weight', 0)
    return sets * reps * weight


def _slope(x: list[float], y: list[float]) -> float:
    if len(x) < 2:
        return 0.0
    A = np.vstack([x, np.ones(len(x))]).T
    m, _ = np.linalg.lstsq(A, y, rcond=None)[0]
    return float(m)


class WorkoutAnalysis:
    def __init__(self, history: list[dict]):
        self.history = history

    def analyze(self) -> dict:
        if not self.history:
            return {'exercises': {}, 'summary': 'No workout data to analyze.'}

        exercises: dict[str, list[dict]] = {}
        for entry in self.history:
            log = entry.get('workout_log_data', {}) if isinstance(entry, dict) else entry
            exc_name = log.get('exercise', 'Unknown')
            exercises.setdefault(exc_name, []).append(log)

        results = {}
        for name, logs in exercises.items():
            results[name] = self._analyze_exercise(name, logs)

        summary = self._build_summary(results)
        return {
            'exercises': results,
            'summary': summary,
            'total_workouts': len(self.history),
        }

    def _analyze_exercise(self, name: str, logs: list[dict]) -> dict:
        logs_sorted = sorted(logs, key=lambda x: x.get('date', ''))
        volumes = [_compute_volume(e) for e in logs_sorted]
        max_weights = [e.get('weight', 0) for e in logs_sorted]
        reps_list = [e.get('reps', 1) for e in logs_sorted]
        est_1rms = [_est_1rm(e.get('weight', 0), e.get('reps', 1)) for e in logs_sorted]

        indices = list(range(len(est_1rms)))
        volume_trend = _slope(indices, volumes) if volumes else 0
        strength_trend = _slope(indices, est_1rms) if est_1rms else 0

        plateau = self._detect_plateau(est_1rms)
        progression = self._detect_progression(est_1rms, logs_sorted)

        return {
            'logs_count': len(logs_sorted),
            'latest_weight': max_weights[-1] if max_weights else 0,
            'latest_reps': reps_list[-1] if reps_list else 0,
            'latest_volume': volumes[-1] if volumes else 0,
            'max_weight': max(max_weights) if max_weights else 0,
            'max_volume': max(volumes) if volumes else 0,
            'estimated_1rm': round(est_1rms[-1], 1) if est_1rms else 0,
            'best_estimated_1rm': round(max(est_1rms), 1) if est_1rms else 0,
            'volume_trend': round(volume_trend, 1),
            'strength_trend': round(strength_trend, 1),
            'plateau': plateau,
            'progression': progression,
        }

    def _detect_plateau(self, est_1rms: list[float]) -> dict:
        if len(est_1rms) < 4:
            return {'is_plateau': False, 'reason': 'Not enough data points (need >= 4).'}
        recent = est_1rms[-4:]
        mean_val = np.mean(recent).item()
        max_dev = max(abs(v - mean_val) for v in recent)
        if max_dev / max(mean_val, 1) < 0.03:
            return {
                'is_plateau': True,
                'reason': 'No significant change in estimated 1RM over last 4 sessions.',
                'avg_recent_1rm': round(mean_val, 1),
            }
        return {'is_plateau': False, 'reason': 'Strength is still progressing.'}

    def _detect_progression(self, est_1rms: list[float], logs: list[dict]) -> dict:
        if len(est_1rms) < 2:
            return {'direction': 'stable', 'change_pct': 0.0}
        first = max(est_1rms[0], 1)
        last = max(est_1rms[-1], 1)
        pct = ((last - first) / first) * 100
        if pct > 5:
            direction = 'improving'
        elif pct < -5:
            direction = 'declining'
        else:
            direction = 'stable'
        return {
            'direction': direction,
            'change_pct': round(pct, 1),
            'from_1rm': round(est_1rms[0], 1),
            'to_1rm': round(est_1rms[-1], 1),
        }

    def _build_summary(self, results: dict) -> str:
        improving = sum(1 for r in results.values() if r['progression']['direction'] == 'improving')
        declining = sum(1 for r in results.values() if r['progression']['direction'] == 'declining')
        plateau_count = sum(1 for r in results.values() if r['plateau']['is_plateau'])

        parts = []
        total = len(results)
        if improving:
            parts.append(f'{improving}/{total} exercises improving')
        if declining:
            parts.append(f'{declining}/{total} exercises declining')
        if plateau_count:
            parts.append(f'{plateau_count} exercise(s) in plateau')
        if not parts:
            parts.append('Stable across all exercises')
        return '. '.join(parts) + '.'
