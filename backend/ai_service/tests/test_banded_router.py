"""Router + engine tests for the banded-ensemble endpoints.

Run from backend/ai_service/ with the ml-env python::

    AI_MODEL_CACHE_DIR=$PWD/models /home/peter/Desktop/ml-env/bin/python \
        -m pytest tests/test_banded_router.py -q

Requires the six .onnx artifacts in the cache dir (exported by the
banded_*/multimodal_*/rl_* notebooks).
"""

import os

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from app.routers import banded

app = FastAPI()
app.include_router(banded.router, prefix="/api/v1/banded")


@pytest.fixture(scope="module")
def client():
    assert os.environ.get("AI_MODEL_CACHE_DIR"), "set AI_MODEL_CACHE_DIR to models/"
    return TestClient(app)


def test_nlp_classify_meirl(client):
    r = client.post("/api/v1/banded/nlp/classify", json={"text": "meirl when monday hits"})
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["label"] == "meirl" and body["confidence"] > 0.5


def test_rl_nlp_act_shape(client):
    r = client.post("/api/v1/banded/rl-nlp/act", json={"text": "push day?"})
    assert r.status_code == 200, r.text
    assert r.json()["action"] in (0, 1, 2, 3)


def test_rl_jepa_act_shape(client):
    r = client.post("/api/v1/banded/rl-jepa/act", json={"obs": [0.0] * 48})
    assert r.status_code == 200, r.text
    assert r.json()["action"] in (0, 1)


def test_rl_jepa_rejects_bad_obs(client):
    r = client.post("/api/v1/banded/rl-jepa/act", json={"obs": [0.0] * 7})
    assert r.status_code == 400


def test_recsys_embed_dim(client):
    r = client.post("/api/v1/banded/recsys/embed", json={"item_ids": [0, 7, 42]})
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["dim"] == 32 and len(body["vectors"]) == 3


def test_multimodal_score_shape(client):
    r = client.post("/api/v1/banded/multimodal/score",
                    json={"embeddings": [[0.0] * 320]})
    assert r.status_code == 200, r.text
    assert len(r.json()["top_class"]) == 1


def test_vision_classify_real_nsfw(client):
    import glob

    imgs = sorted(glob.glob("data/nsfw/out/test/NSFW/*"))[:4] + \
        sorted(glob.glob("data/nsfw/out/test/Neutral/*"))[:4]
    assert len(imgs) == 8
    hits = 0
    for p in imgs:
        with open(p, "rb") as fh:
            r = client.post("/api/v1/banded/vision/classify",
                            files={"file": ("x.jpg", fh, "image/jpeg")})
        assert r.status_code == 200, r.text
        body = r.json()
        assert body["label"] in ("Neutral", "NSFW")
        if ("NSFW" in p and body["label"] == "NSFW") or \
           ("Neutral" in p and body["label"] == "Neutral"):
            hits += 1
    # prototype bar: beat the 60% majority baseline on this probe
    assert hits / len(imgs) >= 0.6, f"only {hits}/{len(imgs)} correct"
