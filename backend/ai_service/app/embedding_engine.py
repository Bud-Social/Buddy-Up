import logging
from typing import Optional

import numpy as np

from .model_registry import ModelRegistry, DEVICE

logger = logging.getLogger(__name__)

MODEL_NAME = 'sentence-transformers/all-MiniLM-L6-v2'
DEFAULT_DIMENSION = 384


def _get_model():
    model = ModelRegistry.get(MODEL_NAME)
    if model is not None:
        return model
    from sentence_transformers import SentenceTransformer
    logger.info('Loading embedding model: %s on %s', MODEL_NAME, DEVICE)
    model = SentenceTransformer(MODEL_NAME, device=str(DEVICE))
    ModelRegistry.register(MODEL_NAME, model)
    return model


async def embed_text(text: str) -> tuple[list[float], int]:
    if not text or not text.strip():
        return [], DEFAULT_DIMENSION
    model = _get_model()
    embedding = model.encode(text, normalize_embeddings=True)
    vector = embedding.tolist()
    return vector, DEFAULT_DIMENSION


async def compute_similarity(vec_a: list[float], vec_b: list[float]) -> float:
    a = np.array(vec_a, dtype=np.float32)
    b = np.array(vec_b, dtype=np.float32)
    return float(np.dot(a, b))


async def find_top_matches(
    query_vec: list[float],
    candidates: dict[str, list[float]],
    top_k: int = 20,
) -> list[dict]:
    scores = []
    for profile_id, vec in candidates.items():
        score = await compute_similarity(query_vec, vec)
        scores.append({'profile_id': profile_id, 'score': round(score, 4)})
    scores.sort(key=lambda x: x['score'], reverse=True)
    return scores[:top_k]
