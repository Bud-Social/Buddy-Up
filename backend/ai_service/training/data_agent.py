"""Data agent for the banded-ensemble notebooks: find, fetch, train, clean.

Disk-first design (this box sits at ~98% disk): every command works in small,
budgeted *batches* under ``data/batches/<task>/``. After training, the batch
is deleted so the next one can take its place::

    python training/data_agent.py status                 # disk + sources + batches
    python training/data_agent.py find --task nlp_text   # where real data lives
    python training/data_agent.py fetch --task nlp_text --budget-mb 200
    python training/data_agent.py run --task nlp_text --scale smoke   # fetch→train→clean
    python training/data_agent.py clean --task nlp_text  # delete batches now

Priority is always LOCAL data first (already on disk, no download):
Reddit IRL + jokes (text), NSFW images (vision), Food.com interactions
(recsys), workout videos (video/audio). Downloads (HF Hub streaming,
OpenFoodFacts API) are a fallback and also land inside the same budget.

Run from ``backend/ai_service/``. Training runs use the current python
(activate ml-env first) and the ``buddyup-ml`` kernel.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
AI = HERE.parent
DATA = AI / "data"
BATCHES = DATA / "batches"
NOTEBOOKS = AI / "notebooks"
sys.path.insert(0, str(HERE))

TASKS = {
    "nlp_text": {"nb": "banded_nlp_ensemble.ipynb",
                 "desc": "jokes-vs-meirl titles (real binary text)"},
    "vision": {"nb": "banded_vision_ensemble.ipynb",
               "desc": "NSFW Neutral-vs-NSFW images @32x32"},
    "multimodal": {"nb": "multimodal_jepa_bagging.ipynb",
                   "desc": "per-modality probes: image/video/audio/text/file"},
    "rl_text": {"nb": "rl_nlp_actor_critic_bagging.ipynb",
                "desc": "real IRL titles as bandit states, rule labels"},
    "recsys": {"nb": "banded_recommender.ipynb",
               "desc": "Food.com ratings>=4 + recipe-name content"},
    "rl_traj": {"nb": "rl_jepa_bagging.ipynb",
                "desc": "CartPole transition batch (real physics)"},
}

REMOTES = {
    "nlp_text": ["stanfordnlp/imdb (HF)", "ag_news (HF)", "SetFit/sst2 (HF)"],
    "vision": ["uoft-cs/cifar10 (HF mirror)", "ethz/food101 (HF, gated-ish)"],
    "multimodal": ["polyai/minds14 (tiny speech, HF)", "ucf101 subset (HF, video)"],
    "rl_text": ["mine your own engagement.csv (best); then MIND (HF)"],
    "recsys": ["mcauley-lab/Amazon-Reviews-2023 (HF, stream it)", "ml-100k (HF)"],
    "rl_traj": ["generate with gymnasium locally (no download); then D4RL (HF)"],
}

WRAPPER_DIRS = {"raw_data", "test", "verified_data", "synthetic_dataset",
                "data-btc", "data_btc_10s", "data_btc", "my_test_video_1",
                "similar_dataset"}


# ---------------------------------------------------------------- helpers

def _du(path: Path) -> int:
    tot = 0
    if path.is_file():
        return path.stat().st_size
    for p in path.rglob("*"):
        if p.is_file():
            try:
                tot += p.stat().st_size
            except OSError:
                pass
    return tot


def _mb(n: int) -> str:
    return f"{n / 1e6:.1f}MB"


def _batch_dir(task: str, batch_id: str) -> Path:
    d = BATCHES / task / f"batch_{batch_id}"
    d.mkdir(parents=True, exist_ok=True)
    return d


def _write_batch(dest: Path, manifest: dict, tensors: dict) -> Path:
    import torch

    torch.save(tensors, dest / "tensors.pt")
    manifest.update({"bytes": (dest / "tensors.pt").stat().st_size,
                     "created": time.strftime("%Y-%m-%dT%H:%M:%S")})
    (dest / "manifest.json").write_text(json.dumps(manifest, indent=1))
    return dest


def _fit_budget(build, dest: Path, budget_mb: int, seed: int):
    """Call build(frac, seed) with shrinking frac until tensors.pt fits (max 4 tries).

    build() must write dest/tensors.pt + manifest and return the manifest dict.
    """
    frac, man = 1.0, {}
    for _ in range(4):
        man = build(frac, seed)
        size = (dest / "tensors.pt").stat().st_size
        man["bytes"] = size
        (dest / "manifest.json").write_text(json.dumps(man, indent=1))
        if size <= budget_mb * 1e6:
            return man
        frac *= (budget_mb * 1e6) / size * 0.9
    return man


def _sample_csv(path: Path, usecols, n: int, seed: int, chunksize=200_000):
    """Single-pass reservoir sample of n rows (no full-file read)."""
    import pandas as pd

    rng = __import__("random").Random(seed)
    sample, seen = [], 0
    for ch in pd.read_csv(path, usecols=usecols, chunksize=chunksize, low_memory=False):
        for row in ch.itertuples(index=False):
            seen += 1
            if len(sample) < n:
                sample.append(row)
            elif (j := rng.randrange(seen)) < n:
                sample[j] = row
    cols = list(pd.read_csv(path, usecols=usecols, nrows=0).columns)
    return pd.DataFrame(sample, columns=cols)


# ---------------------------------------------------------------- fetchers

def fetch_nlp_text(dest: Path, budget_mb: int, seed: int):
    import pandas as pd
    from batch_data import hash_tokenize

    jokes = DATA / "one-million-reddit-jokes.csv"
    meirl = DATA / "the-reddit-irl-dataset-posts.csv"
    assert jokes.exists() and meirl.exists(), "missing local text corpora"

    def build(frac, seed):
        n = max(500, int(120_000 * frac))
        j = _sample_csv(jokes, ["title"], n // 2, seed).assign(y=0)
        m = _sample_csv(meirl, ["title"], n // 2, seed + 1).assign(y=1)
        df = pd.concat([j, m]).dropna().sample(frac=1, random_state=seed)
        X = hash_tokenize(df["title"].tolist(), 2000, 32)
        import torch
        y = torch.tensor(df["y"].to_numpy(), dtype=torch.long)
        k = int(0.85 * len(X))
        man = {"task": "nlp_text", "vocab": 2000, "seqlen": 32, "nclass": 2,
               "source": "jokes(title)->0 + meirl(title)->1", "n": len(X)}
        _write_batch(dest, man, {"X": X[:k], "y": y[:k],
                                 "val_X": X[k:], "val_y": y[k:]})
        return man

    info = _fit_budget(build, dest, budget_mb, seed)
    print(f"nlp_text: {info['n']} rows -> {_mb(info['bytes'])} at {dest}")
    return dest


def fetch_vision(dest: Path, budget_mb: int, seed: int):
    import random
    from PIL import Image
    import torch

    root = DATA / "nsfw" / "out"
    assert (root / "train").exists(), "missing data/nsfw/out"

    def build(frac, seed):
        rng = random.Random(seed)
        files = []
        for split in ("train", "val"):
            for label, cls in ((0, "Neutral"), (1, "NSFW")):
                d = root / split / cls
                names = sorted(p.name for p in d.iterdir() if p.suffix.lower() in
                               (".jpg", ".jpeg", ".png", ".webp"))
                rng.shuffle(names)
                take = names[: int(len(names) * frac)] if frac < 1 else names
                files += [(split, label, d / n) for n in take]
        imgs, ys, ss = [], [], []
        for split, label, p in files:
            try:
                im = Image.open(p).convert("RGB").resize((32, 32))
                import numpy as np
                imgs.append(torch.from_numpy(np.array(im)).permute(2, 0, 1))
                ys.append(label)
                ss.append(0 if split == "train" else 1)
            except OSError:
                continue
        X = torch.stack(imgs)  # uint8 kept on disk; notebook scales to float
        y = torch.tensor(ys, dtype=torch.long)
        is_tr = torch.tensor(ss) == 0
        man = {"task": "vision", "nclass": 2, "classes": ["Neutral", "NSFW"],
               "source": "data/nsfw/out", "n": len(X), "dtype": "uint8"}
        _write_batch(dest, man, {"X": X[is_tr], "y": y[is_tr],
                                 "val_X": X[~is_tr], "val_y": y[~is_tr]})
        return man

    info = _fit_budget(build, dest, budget_mb, seed)
    print(f"vision: {info['n']} images -> {_mb(info['bytes'])} at {dest}")
    return dest


def _workout_clips():
    clips = []
    for root in sorted(DATA.glob("Work out vids dataset *")):
        for mp4 in root.rglob("*.mp4"):
            parent = mp4.parent.name
            cls = (mp4.parent.parent.name if parent.endswith("_img_labels")
                   or parent in WRAPPER_DIRS else parent).strip()
            if cls and cls not in WRAPPER_DIRS:
                clips.append((mp4, cls))
    return clips


def fetch_multimodal(dest: Path, budget_mb: int, seed: int):
    import random
    import cv2
    import numpy as np
    import pandas as pd
    import torch

    rng = random.Random(seed)
    per_mod = budget_mb / 5
    mods, labels, meta = {}, {}, {"task": "multimodal", "towers": {}}

    # image tower: NSFW sample @32x32, own binary labels
    from PIL import Image
    img_files = []
    per_cls = max(200, int(per_mod * 1e6 / 12288 / 2))  # 32x32x3 float32 = 12KB
    for label, cls in ((0, "Neutral"), (1, "NSFW")):
        d = DATA / "nsfw" / "out" / "train" / cls
        names = sorted(p.name for p in d.iterdir())[:per_cls]
        img_files += [(str(d / n), label) for n in names]
    rng.shuffle(img_files)
    XI = torch.stack([torch.from_numpy(np.array(
        Image.open(p).convert("RGB").resize((32, 32)))).permute(2, 0, 1)
        for p, _ in img_files])
    mods["image"] = XI.reshape(len(XI), -1).float()  # (B, 3072), toks=1
    labels["image"] = torch.tensor([lbl for _, lbl in img_files], dtype=torch.long)
    meta["towers"]["image"] = {"feat": 3072, "toks": 1, "task": "nsfw-binary",
                               "nclass": 2}

    # video + audio towers: workout clips, exercise-class labels
    clips = _workout_clips()
    assert clips, "no workout mp4s found"
    by_cls: dict[str, list] = {}
    for p, c in clips:
        by_cls.setdefault(c, []).append(p)
    keep = sorted(by_cls, key=lambda c: -len(by_cls[c]))[:12]
    per_cls = max(2, int(per_mod * 1e6 / 90e3 / len(keep)))
    V, A, Y, classes = [], [], [], keep
    for ci, c in enumerate(keep):
        got = 0
        for p in rng.sample(by_cls[c], min(per_cls, len(by_cls[c]))):
            cap = cv2.VideoCapture(str(p))
            n = int(cap.get(cv2.CAP_PROP_FRAME_COUNT) or 0)
            if n < 4:
                cap.release()
                continue
            idxs = np.linspace(0, n - 1, 8).astype(int)
            frames = []
            for fi in idxs:
                cap.set(cv2.CAP_PROP_POS_FRAMES, int(fi))
                ok, fr = cap.read()
                if not ok:
                    break
                frames.append(cv2.resize(cv2.cvtColor(fr, cv2.COLOR_BGR2GRAY), (48, 48)))
            cap.release()
            if len(frames) != 8:
                continue
            V.append(np.stack(frames).reshape(8, -1))
            Y.append(ci)
            A.append(_clip_audio(p))
            got += 1
        print(f"  video/audio [{ci + 1}/{len(keep)}] {c}: {got} clips", flush=True)
    mods["video"] = torch.tensor(np.stack(V), dtype=torch.float32).reshape(len(V), 8, -1)
    labels["video"] = torch.tensor(Y, dtype=torch.long)
    meta["towers"]["video"] = {"feat": 48 * 48, "toks": 8, "task": "exercise-class",
                               "nclass": len(classes), "classes": classes}
    AA = [a for a in A if a is not None]
    mods["audio"] = torch.stack(AA).float()  # (B, 32000) mono 16kHz x 2s
    labels["audio"] = torch.tensor([y for y, a in zip(Y, A) if a is not None],
                                   dtype=torch.long)
    meta["towers"]["audio"] = {"feat": 32000, "toks": 1, "task": "exercise-class(audio)",
                               "nclass": len(classes)}

    # text tower: jokes-vs-meirl hash-projection rows, own binary labels
    from batch_data import hash_tokenize
    j = _sample_csv(DATA / "one-million-reddit-jokes.csv", ["title"], 4000, seed)
    m = _sample_csv(DATA / "the-reddit-irl-dataset-posts.csv", ["title"], 4000, seed + 1)
    g = torch.Generator().manual_seed(11)
    R = torch.randn(2000, 64, generator=g)
    ids = hash_tokenize(pd.concat([j["title"], m["title"]]).fillna("").tolist(), 2000, 8)
    mods["text"] = R[ids].reshape(len(ids), 8, 64)  # (B, 8, 64) word-rows
    labels["text"] = torch.tensor([0] * len(j) + [1] * len(m), dtype=torch.long)
    meta["towers"]["text"] = {"feat": 64, "toks": 8, "task": "jokes-vs-meirl",
                              "nclass": 2}

    # file tower: recipe byte-histograms -> high/low calorie (median split)
    import ast
    rr = pd.read_csv(DATA / "Food and Nutrients data 3 (Food.com)" / "RAW_recipes.csv",
                     usecols=["nutrition", "ingredients"], nrows=20000)
    cal = rr["nutrition"].apply(lambda s: ast.literal_eval(s)[0]).to_numpy(float)
    thr = float(np.median(cal))
    F = torch.zeros(len(rr), 256)
    for i, s in enumerate(rr["ingredients"].fillna("")):
        b = np.array(np.frombuffer(str(s).encode()[:2000], dtype=np.uint8),
                     dtype=np.int64)
        F[i].index_add_(0, torch.from_numpy(b).long(),
                        torch.ones(len(b)) / max(1, len(b)))
    mods["file"] = F
    labels["file"] = torch.tensor((cal > thr).astype(int), dtype=torch.long)
    meta["towers"]["file"] = {"feat": 256, "toks": 1, "task": "high-calorie",
                              "nclass": 2, "threshold": thr}

    meta.update({"source": "nsfw+workout-vids+jokes+meirl+food.com",
                 "aligned": False})
    tensors = {}
    for k in mods:
        tensors[f"{k}_X"] = mods[k]
        tensors[f"{k}_y"] = labels[k]
    return _write_batch(dest, meta, tensors)


def _clip_audio(mp4: Path, sr: int = 16000, secs: int = 2):
    """Mono s16le waveform via ffmpeg; None when the clip has no audio."""
    import subprocess
    import numpy as np
    import torch

    try:
        raw = subprocess.run(
            ["ffmpeg", "-v", "error", "-i", str(mp4), "-map", "0:a:0",
             "-ac", "1", "-ar", str(sr), "-f", "s16le", "-"],
            capture_output=True, timeout=60).stdout
    except (OSError, subprocess.TimeoutExpired):
        return None
    if len(raw) < sr * secs * 2:
        return None
    wav = np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768.0
    mid = len(wav) // 2
    return torch.tensor(wav[mid - sr: mid + sr])  # center 2s


def fetch_rl_text(dest: Path, budget_mb: int, seed: int):
    import torch
    from batch_data import hash_tokenize

    df = _sample_csv(DATA / "the-reddit-irl-dataset-posts.csv", ["title"],
                     max(2000, int(budget_mb * 1e6 / 40)), seed)
    titles = df["title"].fillna("").tolist()
    X = hash_tokenize(titles, 500, 16)

    def rule(t: str) -> int:
        t = str(t)
        if "?" in t:
            return 0
        if "!" in t:
            return 1
        if len(t.split()) > 25:
            return 2
        return 3

    y = torch.tensor([rule(t) for t in titles], dtype=torch.long)
    man = {"task": "rl_text", "vocab": 500, "seqlen": 16, "na": 4, "n": len(X),
           "source": "meirl titles, rule labels (?/!/long/other)"}
    return _write_batch(dest, man, {"X": X, "y": y})


def fetch_recsys(dest: Path, budget_mb: int, seed: int):
    import pandas as pd
    import torch
    from batch_data import hash_embed

    fc = DATA / "Food and Nutrients data 3 (Food.com)"
    tr = pd.read_csv(fc / "interactions_train.csv")
    # dense submatrix: most-active users learn fast on CPU; sparse 25k-user
    # slices never leave chance-level inside a budgeted run
    top = tr["user_id"].value_counts().head(1500).index
    tr = tr[tr["user_id"].isin(top)]
    # head items only: the 145k-item tail (mostly <5 obs) never learns on CPU;
    # budgeted batches train the dense head, tail comes with scale-out
    head_items = tr["recipe_id"].value_counts().head(8000).index
    tr = tr[tr["recipe_id"].isin(head_items)]
    cap = min(len(tr), max(60_000, int(budget_mb * 1e6 / 30)))
    tr = tr.sample(n=cap, random_state=seed)
    # leave-one-out val: hold out one liked item per user with >=2 likes
    liked = tr[tr["rating"] >= 4]
    hold = liked.groupby("user_id", group_keys=False).apply(
        lambda g: g.sample(n=1, random_state=seed) if len(g) >= 2 else g.iloc[0:0],
        include_groups=False)
    va = tr.loc[hold.index]
    tr = tr.drop(index=hold.index)
    users = {u: i for i, u in enumerate(tr["user_id"].unique())}
    items = {r: i for i, r in enumerate(tr["recipe_id"].unique())}
    va = va[va["user_id"].isin(users) & va["recipe_id"].isin(items)]
    U = torch.tensor(tr["user_id"].map(users).to_numpy(), dtype=torch.long)
    IT = torch.tensor(tr["recipe_id"].map(items).to_numpy(), dtype=torch.long)
    y = torch.tensor((tr["rating"].to_numpy(float) >= 4).astype(float))
    val = {"u": torch.tensor(va["user_id"].map(users).to_numpy(), dtype=torch.long),
           "i": torch.tensor(va["recipe_id"].map(items).to_numpy(), dtype=torch.long)}
    # 1:1 sampled negatives (unseen pairs): raw logs are ~94% positive and
    # rankers trained without negatives never leave chance-level
    import random as _r
    _rr = _r.Random(seed)
    obs = set(zip(U.tolist(), IT.tolist())) | set(zip(val["u"].tolist(),
                                                      val["i"].tolist()))
    need, neg_u, neg_i = int(y.sum().item()), [], []
    while len(neg_u) < need:
        for a, b in zip([_rr.randrange(len(users)) for _ in range(need * 2)],
                        [_rr.randrange(len(items)) for _ in range(need * 2)]):
            if (a, b) not in obs:
                obs.add((a, b))
                neg_u.append(a)
                neg_i.append(b)
                if len(neg_u) >= need:
                    break
    U = torch.cat([U, torch.tensor(neg_u)])
    IT = torch.cat([IT, torch.tensor(neg_i)])
    y = torch.cat([y, torch.zeros(len(neg_u))])
    names = pd.read_csv(fc / "RAW_recipes.csv", usecols=["id", "name"])
    name_of = dict(zip(names["id"], names["name"].fillna("")))
    inv_items = {i: r for r, i in items.items()}
    C = hash_embed([name_of.get(inv_items[i], "") for i in range(len(items))], 16)
    man = {"task": "recsys", "n_users": len(users), "n_items": len(items),
           "content_dim": 16, "source": "food.com ratings>=4 pos, recipe-name content",
           "n": len(U)}
    dest = _write_batch(dest, man, {"U": U, "I": IT, "y": y,
                                    "val_u": val["u"], "val_i": val["i"], "C": C})
    print(f"recsys: {len(U)} pairs, {len(users)} users x {len(items)} items -> "
          f"{_mb((dest / 'tensors.pt').stat().st_size)} at {dest}")
    return dest


def fetch_rl_traj(dest: Path, budget_mb: int, seed: int):
    try:
        import gymnasium as gym
    except ImportError:
        print("installing gymnasium (small, needed for real physics)...")
        subprocess.run([sys.executable, "-m", "pip", "install", "-q", "gymnasium"],
                       check=True)
        import gymnasium as gym
    import numpy as np
    import torch

    env = gym.make("CartPole-v1")
    N = min(30_000, max(3_000, int(budget_mb * 1e6 / 500)))
    OBS, A, R, O2 = [], [], [], []

    def tile(o):
        return np.tile(np.asarray(o, dtype=np.float32), 12)[:48]

    rng = np.random.default_rng(seed)
    o, _ = env.reset(seed=seed)
    for _ in range(N):
        a = int(rng.integers(2))
        o2, r, term, trunc, _ = env.step(a)
        OBS.append(tile(o))
        A.append(a)
        R.append(float(r))
        O2.append(tile(o2))
        o = o2
        if term or trunc:
            o, _ = env.reset()
    man = {"task": "rl_traj", "obs": 48, "na": 2, "n": N,
           "source": "CartPole-v1 random rollouts, obs tiled 4->48"}
    return _write_batch(dest, man, {"o": torch.tensor(np.stack(OBS)),
                                    "a": torch.tensor(A, dtype=torch.long),
                                    "r": torch.tensor(R),
                                    "o2": torch.tensor(np.stack(O2))})


FETCHERS = {"nlp_text": fetch_nlp_text, "vision": fetch_vision,
            "multimodal": fetch_multimodal, "rl_text": fetch_rl_text,
            "recsys": fetch_recsys, "rl_traj": fetch_rl_traj}


# ---------------------------------------------------------------- commands

def cmd_status(_):
    import shutil
    total, used, free = shutil.disk_usage(str(DATA))
    print(f"disk: {used/1e9:.1f}G used / {free/1e9:.1f}G free")
    print("\nlocal sources:")
    for p in sorted(DATA.iterdir()):
        if p.name in ("batches", "processed", "user"):
            continue
        print(f"  {_mb(_du(p)):>10}  {p.name}")
    print("\nbatches (delete after training to free space):")
    if not BATCHES.exists():
        print("  (none)")
        return
    for task in sorted(p.name for p in BATCHES.iterdir() if p.is_dir()):
        for b in sorted((BATCHES / task).iterdir()):
            man_p = b / "manifest.json"
            meta = json.loads(man_p.read_text()) if man_p.exists() else {}
            print(f"  {task}/{b.name} {_mb(_du(b)):>8} n={meta.get('n', '?')} "
                  f"src={str(meta.get('source', '?'))[:60]}")


def cmd_find(a):
    tasks = [a.task] if a.task else list(TASKS)
    for t in tasks:
        print(f"\n== {t}: {TASKS[t]['desc']} ==")
        print(f"   notebook: {TASKS[t]['nb']}")
        print("   local (preferred, $0 download):")
        for s in _local_source(t):
            print(f"     - {s}")
        print("   remote fallback (budgeted fetch, stream when possible):")
        for s in REMOTES[t]:
            print(f"     - {s}")
        if _have_hub() and a.live:
            for s in _hub_search(t):
                print(f"     - [hub] {s}")
    print("\n(scrapers: only ToS-safe APIs, e.g. OpenFoodFacts via "
          "`scrape openfoodfacts`. No Reddit/IG/TikTok scraping.)")


def _local_source(task: str):
    return {
        "nlp_text": ["one-million-reddit-jokes.csv + the-reddit-irl-dataset-posts.csv"],
        "vision": ["nsfw/out/{train,val,test}/{Neutral,NSFW}"],
        "multimodal": ["nsfw/out + 'Work out vids dataset *' + jokes/meirl + RAW_recipes.csv"],
        "rl_text": ["the-reddit-irl-dataset-posts.csv (titles)"],
        "recsys": ["Food.com interactions_train/validation.csv + RAW_recipes.csv"],
        "rl_traj": ["gymnasium CartPole-v1 (generated, ~15MB, no download of data)"],
    }[task]


def _have_hub() -> bool:
    try:
        import huggingface_hub  # noqa
        return True
    except ImportError:
        return False


def _hub_search(task: str):
    from huggingface_hub import HfApi
    q = {"nlp_text": "sentiment classification", "vision": "nsfw classification",
         "multimodal": "multimodal classification", "rl_text": "intent classification",
         "recsys": "recommendation", "rl_traj": "reinforcement learning offline"}[task]
    try:
        return [f"{d.id} ({d.downloads} dl)" for d in
                HfApi().list_datasets(search=q, sort="downloads",
                                      direction=-1, limit=5)]
    except Exception as e:
        return [f"(hub search failed: {e})"]


def cmd_fetch(a):
    dest = _batch_dir(a.task, time.strftime("%m%d-%H%M%S"))
    FETCHERS[a.task](dest, a.budget_mb, a.seed)
    print(f"BUDDY_BATCH={dest}  (export this to train, then `clean` to delete)")


def cmd_clean(a):
    targets = [BATCHES / a.task] if a.task else [BATCHES]
    freed = 0
    for t in targets:
        if not t.exists():
            continue
        for b in list(t.iterdir()):
            if a.batch and b.name != f"batch_{a.batch}":
                continue
            freed += _du(b)
            shutil.rmtree(b)
            print(f"deleted {b} ({_mb(freed)})")
    print(f"freed {_mb(freed)}")


def cmd_run(a):
    dest = _batch_dir(a.task, time.strftime("%m%d-%H%M%S"))
    FETCHERS[a.task](dest, a.budget_mb, a.seed)
    nb = NOTEBOOKS / TASKS[a.task]["nb"]
    env = dict(os.environ, BUDDY_SCALE=a.scale, BUDDY_BATCH=str(dest))
    print(f"training {nb.name} scale={a.scale} batch={dest}")
    r = subprocess.run(
        [sys.executable, "-m", "jupyter", "nbconvert", "--execute", "--inplace",
         "--to", "notebook", "--ExecutePreprocessor.kernel_name=buddyup-ml",
         "--ExecutePreprocessor.timeout=86400", str(nb)], env=env)
    if r.returncode == 0 and not a.keep:
        freed = _du(dest)
        shutil.rmtree(dest)
        print(f"training done; batch deleted ({_mb(freed)} freed)")
    elif a.keep:
        print(f"kept batch: export BUDDY_BATCH={dest}")
    else:
        print(f"TRAINING FAILED; batch kept for inspection: {dest}")


def cmd_scrape(a):
    if a.what == "openfoodfacts":
        import requests
        out = BATCHES / "_vendor"
        out.mkdir(parents=True, exist_ok=True)
        got = []
        page = 1
        while len(got) < a.n and page <= 10:
            r = requests.get("https://world.openfoodfacts.org/cgi/search.pl",
                             params={"search_terms": a.query, "search_simple": 1,
                                     "action": "process", "json": 1,
                                     "page_size": 50, "page": page}, timeout=30)
            r.raise_for_status()
            prods = r.json().get("products", [])
            if not prods:
                break
            got += [{"name": p.get("product_name", ""), "brands": p.get("brands", ""),
                     "nutriscore": (p.get("nutriments") or {}).get("nutrition-score-fr"),
                     "energy_kcal": (p.get("nutriments") or {}).get("energy-kcal_100g")}
                    for p in prods if p.get("product_name")]
            page += 1
        p = out / f"off-{a.query}-{len(got)}.json"
        p.write_text(json.dumps(got[:a.n], indent=1))
        print(f"{len(got[:a.n])} products -> {p} ({_mb(p.stat().st_size)})")
    else:
        raise SystemExit("unknown scrape target (only 'openfoodfacts' is supported)")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("status", help="disk + local sources + batches")
    f = sub.add_parser("find", help="where real data lives for a task")
    f.add_argument("--task", choices=list(TASKS))
    f.add_argument("--live", action="store_true", help="also query the HF Hub API")
    for name in ("fetch", "run"):
        p = sub.add_parser(name, help=f"{name} a budgeted batch")
        p.add_argument("--task", choices=list(TASKS), required=True)
        p.add_argument("--budget-mb", type=int, default=400)
        p.add_argument("--seed", type=int, default=0)
        if name == "run":
            p.add_argument("--scale", default="smoke",
                           choices=["smoke", "demo", "full"])
            p.add_argument("--keep", action="store_true",
                           help="keep the batch instead of deleting it")
    c = sub.add_parser("clean", help="delete batches to free disk")
    c.add_argument("--task", choices=list(TASKS))
    c.add_argument("--batch", help="batch id suffix (default: all)")
    s = sub.add_parser("scrape", help="ToS-safe API collection")
    s.add_argument("what", choices=["openfoodfacts"])
    s.add_argument("--query", default="protein bar")
    s.add_argument("--n", type=int, default=200)
    a = ap.parse_args()
    {"status": cmd_status, "find": cmd_find, "fetch": cmd_fetch,
     "clean": cmd_clean, "run": cmd_run, "scrape": cmd_scrape}[a.cmd](a)


if __name__ == "__main__":
    main()
