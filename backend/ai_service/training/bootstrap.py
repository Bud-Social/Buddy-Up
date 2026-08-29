"""Shared training bootstrap for Buddy-Up notebooks + pipelines.

Import this FIRST in any notebook (``from training.bootstrap import *``) so the
thread/seed/determinism environment is configured before TensorFlow is
imported. Reads the BUDDY_* env vars, seeds every RNG, and exposes the resolved
run paths (DATA_ROOT / OUTPUT_ROOT / MODEL_ROOT).

Environment knobs
-----------------
BUDDY_ENV             local | colab | kaggle | ci (auto-detects kaggle via /kaggle)
BUDDY_SCALE           smoke | demo | full         (default: smoke)
BUDDY_SEED            int seed for python/numpy/TF/torch (default: 42)
BUDDY_DETERMINISTIC   1 = TF deterministic ops on (default)
BUDDY_DATA_ROOT       data root (default <ai_service>/data; on Kaggle
                      /kaggle/input/buddy-up-data when that dir exists)
BUDDY_OUTPUT_ROOT     output root (default <ai_service>/outputs; on Kaggle
                      /kaggle/working/buddyup-output)
BUDDY_MODEL_ROOT      artifact root (default <ai_service>/models; on Kaggle
                      <output_root>/models)
BUDDY_CPU_THREADS     intra-op thread cap (default: 2)
BUDDY_INTEROP_THREADS inter-op thread cap (default: 1)
"""
from __future__ import annotations

import os
import platform
import random
import subprocess
from pathlib import Path

# --- thread caps: MUST be applied before numpy/TF initialise their pools ----
# (module import time is the last safe moment — TF is imported lazily by
# notebooks/tf_utils only after `from training.bootstrap import *`).
_CPU_THREADS = os.environ.get('BUDDY_CPU_THREADS', '2')
_INTEROP_THREADS = os.environ.get('BUDDY_INTEROP_THREADS', '1')
for _var in ('OMP_NUM_THREADS', 'MKL_NUM_THREADS', 'OPENBLAS_NUM_THREADS',
             'TF_NUM_INTRAOP_THREADS'):
    os.environ.setdefault(_var, _CPU_THREADS)
os.environ.setdefault('TF_NUM_INTEROP_THREADS', _INTEROP_THREADS)

KAGGLE = Path('/kaggle').exists()
BUDDY_ENV = os.environ.get('BUDDY_ENV') or ('kaggle' if KAGGLE else 'local')
BUDDY_SCALE = os.environ.get('BUDDY_SCALE', 'smoke')
BUDDY_SEED = int(os.environ.get('BUDDY_SEED', '42'))
BUDDY_DETERMINISTIC = os.environ.get('BUDDY_DETERMINISTIC', '1') not in ('0', 'false', 'False')

if BUDDY_DETERMINISTIC:
    os.environ.setdefault('TF_DETERMINISTIC_OPS', '1')
    os.environ.setdefault('TF_CUDNN_DETERMINISTIC', '1')

AI_ROOT = Path(__file__).resolve().parent.parent

_kaggle_data = Path('/kaggle/input/buddy-up-data')
_default_data = _kaggle_data if KAGGLE and _kaggle_data.is_dir() else AI_ROOT / 'data'
DATA_ROOT = Path(os.environ.get('BUDDY_DATA_ROOT', _default_data))

_default_output = (Path('/kaggle/working/buddyup-output') if KAGGLE
                   else AI_ROOT / 'outputs')
OUTPUT_ROOT = Path(os.environ.get('BUDDY_OUTPUT_ROOT', _default_output))

_default_model = OUTPUT_ROOT / 'models' if KAGGLE else AI_ROOT / 'models'
MODEL_ROOT = Path(os.environ.get('BUDDY_MODEL_ROOT', _default_model))

__all__ = [
    'KAGGLE', 'BUDDY_ENV', 'BUDDY_SCALE', 'BUDDY_SEED', 'BUDDY_DETERMINISTIC',
    'DATA_ROOT', 'OUTPUT_ROOT', 'MODEL_ROOT',
    'init', 'seed_everything', 'environment', 'save_run_metadata',
]


def _ensure_dir(path: Path) -> None:
    """mkdir -p, tolerating read-only mounts (e.g. /kaggle/input)."""
    try:
        path.mkdir(parents=True, exist_ok=True)
    except OSError:
        pass


def seed_everything(seed: int | None = None) -> int:
    """Seed python/numpy/TF/torch RNGs; enable deterministic TF ops.

    Each framework is optional — whatever is installed gets seeded, the rest
    is skipped so the bootstrap works in any environment.
    """
    global BUDDY_SEED
    seed = BUDDY_SEED if seed is None else int(seed)
    BUDDY_SEED = seed

    random.seed(seed)
    try:
        import numpy as np

        np.random.seed(seed)
    except ImportError:
        pass
    try:
        import tensorflow as tf

        tf.keras.utils.set_random_seed(seed)
        if BUDDY_DETERMINISTIC:
            tf.config.experimental.enable_op_determinism()
    except ImportError:
        pass
    except Exception:  # noqa: BLE001 — op determinism is best-effort
        pass
    try:
        import torch

        torch.manual_seed(seed)
        if torch.cuda.is_available():
            torch.cuda.manual_seed_all(seed)
    except ImportError:
        pass
    return seed


def init(scale: str | None = None, seed: int | None = None) -> dict:
    """Prepare a reproducible run (idempotent) and return the resolved config.

    Ensures OUTPUT_ROOT/MODEL_ROOT exist, seeds all RNGs, and reports the
    effective environment so notebooks can print/branch on it.
    """
    global BUDDY_SCALE
    if scale:
        BUDDY_SCALE = scale
        os.environ['BUDDY_SCALE'] = scale
    if seed is not None:
        os.environ['BUDDY_SEED'] = str(int(seed))
    _ensure_dir(OUTPUT_ROOT)
    _ensure_dir(MODEL_ROOT)
    seed_everything(seed)
    return {
        'env': BUDDY_ENV,
        'scale': BUDDY_SCALE,
        'seed': BUDDY_SEED,
        'deterministic': BUDDY_DETERMINISTIC,
        'data_root': str(DATA_ROOT),
        'output_root': str(OUTPUT_ROOT),
        'model_root': str(MODEL_ROOT),
        'cpu_threads': _CPU_THREADS,
        'interop_threads': _INTEROP_THREADS,
    }


def _git_commit() -> str:
    """Short HEAD sha of the repo containing this file ('' when not git)."""
    try:
        out = subprocess.run(
            ['git', 'rev-parse', '--short', 'HEAD'], cwd=AI_ROOT,
            capture_output=True, text=True, timeout=5, check=True,
        )
        return out.stdout.strip()
    except Exception:  # noqa: BLE001 — zip uploads / Kaggle have no .git
        return ''


def environment() -> dict:
    """Platform + library version snapshot for run metadata.

    Missing optional libs (tf/torch/onnxruntime) are simply omitted.
    """
    info = {
        'env': BUDDY_ENV,
        'scale': BUDDY_SCALE,
        'seed': BUDDY_SEED,
        'deterministic': BUDDY_DETERMINISTIC,
        'python': platform.python_version(),
        'platform': platform.platform(),
        'cpu_count': os.cpu_count(),
        'data_root': str(DATA_ROOT),
        'output_root': str(OUTPUT_ROOT),
        'model_root': str(MODEL_ROOT),
        'git_commit': _git_commit(),
    }
    for mod in ('tensorflow', 'torch', 'numpy', 'onnxruntime'):
        try:
            info[mod] = __import__(mod).__version__
        except ImportError:
            pass
    return info


def save_run_metadata(extra: dict | None = None) -> dict:
    """Write OUTPUT_ROOT/environment.json + OUTPUT_ROOT/run-metadata.json.

    `extra` (metrics, artifact paths, notebook name, ...) is merged into
    run-metadata.json. Best-effort: a read-only OUTPUT_ROOT never raises.
    Returns the written paths.
    """
    import datetime
    import json

    info = environment()
    _ensure_dir(OUTPUT_ROOT)
    written: dict[str, str] = {}
    try:
        env_path = OUTPUT_ROOT / 'environment.json'
        env_path.write_text(json.dumps(info, indent=2))
        written['environment'] = str(env_path)

        run = {
            'timestamp': datetime.datetime.now().isoformat(timespec='seconds'),
            'env': BUDDY_ENV,
            'scale': BUDDY_SCALE,
            'seed': BUDDY_SEED,
            'deterministic': BUDDY_DETERMINISTIC,
            'git_commit': info['git_commit'],
        }
        if extra:
            run.update(extra)
        run_path = OUTPUT_ROOT / 'run-metadata.json'
        run_path.write_text(json.dumps(run, indent=2, default=str))
        written['run_metadata'] = str(run_path)
    except OSError:
        pass
    return written
