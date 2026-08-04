import logging
from typing import Optional

import numpy as np

from .model_registry import ModelRegistry, DEVICE

logger = logging.getLogger(__name__)

MODEL_NAME = 'sentence-transformers/all-MiniLM-L6-v2'
DEFAULT_DIMENSION = 384

try:
    import faiss
    FAISS_AVAILABLE = True
except ImportError:
    faiss = None
    FAISS_AVAILABLE = False
    logger.info('faiss-cpu not installed — falling back to brute-force cosine search')

# In-memory FAISS indexes: {index_name: {'index': faiss.Index, 'ids': list[str]}}
_FAISS_INDEXES: dict[str, dict] = {}


class FaissIndex:
    @staticmethod
    def build(index_name: str, vectors: list[dict]) -> dict:
        if not FAISS_AVAILABLE:
            raise RuntimeError('faiss not installed')
        if not vectors:
            _FAISS_INDEXES[index_name] = {'index': None, 'ids': []}
            return {'index_name': index_name, 'vectors': 0}

        dim = len(vectors[0]['vector'])
        index = faiss.IndexFlatIP(dim)  # inner product == cosine on normalised vecs
        ids = []
        rows = []
        for v in vectors:
            vec = np.asarray(v['vector'], dtype=np.float32)
            norm = np.linalg.norm(vec)
            if norm > 0:
                vec = vec / norm
            rows.append(vec)
            ids.append(str(v.get('id') or v.get('profile_id') or ''))
        index.add(np.vstack(rows))
        _FAISS_INDEXES[index_name] = {'index': index, 'ids': ids}
        return {'index_name': index_name, 'vectors': len(ids), 'dimension': dim}

    @staticmethod
    def search(index_name: str, query_vec: list[float], top_k: int = 20) -> list[dict]:
        state = _FAISS_INDEXES.get(index_name)
        if not state or state['index'] is None:
            return []

        q = np.asarray(query_vec, dtype=np.float32)
        norm = np.linalg.norm(q)
        if norm > 0:
            q = q / norm
        scores, idxs = state['index'].search(q.reshape(1, -1), top_k)
        results = []
        for score, idx in zip(scores[0], idxs[0]):
            if idx < 0 or idx >= len(state['ids']):
                continue
            results.append({'id': state['ids'][idx], 'score': round(float(score), 4)})
        return results

    @staticmethod
    def list_indexes() -> list[str]:
        return list(_FAISS_INDEXES.keys())


async def build_index(index_name: str, vectors: list[dict]) -> dict:
    """Build a FAISS index, storing raw vectors for brute-force fallback."""
    try:
        return FaissIndex.build(index_name, vectors)
    except Exception as exc:
        logger.warning('FAISS build failed (%s) — storing vectors for brute force', exc)
        ids = [str(v.get('id') or v.get('profile_id') or '') for v in vectors]
        normalized = []
        for v in vectors:
            vec = np.asarray(v['vector'], dtype=np.float32)
            norm = np.linalg.norm(vec)
            normalized.append((vec / norm).tolist() if norm > 0 else vec.tolist())
        _FAISS_INDEXES[index_name] = {
            'index': None,
            'ids': ids,
            'vectors': normalized,
        }
        return {'index_name': index_name, 'vectors': len(vectors), 'method': 'brute_force'}


async def search_index(index_name: str, query_vec: list[float], top_k: int = 20) -> list[dict]:
    """Query a FAISS index; falls back to brute-force cosine if unavailable."""
    if FAISS_AVAILABLE:
        try:
            results = FaissIndex.search(index_name, query_vec, top_k)
            if results:
                return results
        except Exception as exc:
            logger.warning('FAISS search failed (%s) — brute force', exc)

    state = _FAISS_INDEXES.get(index_name)
    if not state:
        return []
    vectors = state.get('vectors')
    ids = state.get('ids')
    if not vectors or not ids:
        return []

    candidates = {
        ids[i]: vectors[i] for i in range(len(ids))
        if isinstance(vectors[i], list) and len(vectors[i]) > 0
    }
    q = np.asarray(query_vec, dtype=np.float32)
    q_norm = np.linalg.norm(q)
    query_norm = (q / q_norm).tolist() if q_norm > 0 else query_vec
    top = await find_top_matches(query_norm, candidates, top_k)
    for r in top:
        r['id'] = r.pop('profile_id')
    return top


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
