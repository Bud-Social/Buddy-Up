"""Multistep ID + selfie verification helpers.

Face matching is pluggable and env-gated:

- ``FACE_MATCH_BACKEND=auto`` (default): try AWS Rekognition CompareFaces
  when boto3 is importable and AWS credentials are configured; otherwise
  fall back to ``manual_review`` so nothing hard-blocks.
- ``FACE_MATCH_BACKEND=manual``: always queue for manual review.

The platform never auto-rejects on a low score — ambiguous results are
routed to human reviewers.
"""
import logging
import os

import requests

logger = logging.getLogger(__name__)

REKOGNITION_MIN_CONFIDENCE = 80.0


def _face_match_backend():
    return os.environ.get('FACE_MATCH_BACKEND', 'auto').strip().lower()


def _aws_ready():
    return bool(
        os.environ.get('AWS_ACCESS_KEY_ID')
        and os.environ.get('AWS_SECRET_ACCESS_KEY')
        and os.environ.get('AWS_DEFAULT_REGION')
    )


def _fetch_image(url):
    resp = requests.get(url, timeout=10)
    resp.raise_for_status()
    return resp.content


def _rekognition_compare(id_image_bytes, selfie_bytes):
    """Return (matched: bool, score: float) using AWS Rekognition."""
    import boto3  # optional dependency — imported lazily

    client = boto3.client('rekognition')
    result = client.compare_faces(
        SourceImage={'Bytes': id_image_bytes},
        TargetImage={'Bytes': selfie_bytes},
        SimilarityThreshold=REKOGNITION_MIN_CONFIDENCE,
    )
    matches = result.get('FaceMatches') or []
    if not matches:
        return False, 0.0
    best = max(matches, key=lambda m: m.get('Similarity', 0))
    return True, float(best.get('Similarity', 0.0))


def run_face_match(id_doc_url, selfie_url):
    """Compare a face on the ID document against the liveness selfie.

    Returns (status, score) where status is one of:
    'auto_matched' | 'manual_review' | 'failed'.
    """
    backend = _face_match_backend()
    if backend in ('manual', 'off', 'disabled'):
        return 'manual_review', None

    if backend == 'auto' and not _aws_ready():
        return 'manual_review', None

    try:
        id_bytes = _fetch_image(id_doc_url)
        selfie_bytes = _fetch_image(selfie_url)
        matched, score = _rekognition_compare(id_bytes, selfie_bytes)
        if matched:
            return 'auto_matched', score
        # Below threshold — let a human decide rather than failing outright.
        return 'manual_review', score
    except Exception:
        logger.exception('Face match backend error — routing to manual review')
        return 'manual_review', None
