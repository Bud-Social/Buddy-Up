"""The Colab-trained safety classifier, and a grounded natural-language explainer.

Two separate jobs live here, and keeping them in one module is deliberate
because they share a failure mode: **both must be honest when they are not
calibrated.**

What is actually deployed
-------------------------
``<model_cache_dir>/colab_models/safety_model_nononnx/`` is a
``DistilBertForSequenceClassification`` with three classes. Its ``config.json``
ships the generic ``LABEL_0 / LABEL_1 / LABEL_2`` placeholders, so the
checkpoint carries no class names of its own. The mapping below is therefore a
*stated assumption*, configurable through the environment, seeded from a probe
of the checkpoint rather than guessed from its filename.

What is deliberately NOT deployed
--------------------------------
``production_safety_model.zip`` and ``production_bias_model.zip`` sit in the same
directory and look more finished. They are not usable:

* the safety zip predicts ``LABEL_0`` with probability ~1.0 for every input
  probed, toxic or not;
* the bias zip is two-label but its scores barely move off 0.5.

Both are therefore ignored. A bias model that always answers "slightly biased"
is worse than none, because it manufactures a finding. :func:`bias_available`
returns ``False`` so callers can say so out loud instead of inventing one.

Bias detection
--------------
The deployed classifier is a toxicity detector. Probing it with clear
identity-directed hate ("I hate women", "kill yourself") returned the toxic
class; probing it with clear bias-but-not-toxic content frequently returned the
benign class. So this module will report a bias signal only when a *dedicated*
bias model is configured and present. It never infers one from the toxicity
class.
"""
from __future__ import annotations

import logging
import os
from pathlib import Path

from .model_registry import ModelRegistry

logger = logging.getLogger(__name__)

# Below this, the model is saying "I don't know" and we say so rather than
# dressing up the top class as a finding.
CONFIDENCE_FLOOR = 0.60

DEFAULT_LABEL_MAP = {
    'LABEL_0': 'unknown',
    'LABEL_1': 'unsafe',
    'LABEL_2': 'benign',
}

# Human-readable category names, used to build the evidence list the moderator
# sees. Keyed by the *mapped* class, not the raw label, so changing the mapping
# does not silently orphan these.
CATEGORY_NAMES = {
    'unsafe': 'unsafe or abusive language',
    'benign': 'benign content',
    'unknown': 'an unclassified signal',
}


def _model_dir() -> Path:
    from .config import settings

    return Path(settings.model_cache_dir or '/models') / 'colab_models'


def safety_model_dir() -> Path:
    """Where the Colab safety checkpoint is expected.

    Overridable because the directory name is a Colab artefact, not a contract:
    a retrain should not require a code change to be picked up.
    """
    override = os.environ.get('COLAB_SAFETY_MODEL_DIR', '').strip()
    if override:
        return Path(override)
    return _model_dir() / 'safety_model_nononnx'


def label_map() -> dict[str, str]:
    """Raw ``LABEL_N`` -> semantic class, from the environment when set.

    ``COLAB_SAFETY_LABEL_MAP`` is ``LABEL_1=unsafe,LABEL_2=benign`` form. This
    exists so a retrained checkpoint with different class ordering can be
    corrected by configuration instead of a redeploy.
    """
    raw = os.environ.get('COLAB_SAFETY_LABEL_MAP', '').strip()
    if not raw:
        return dict(DEFAULT_LABEL_MAP)
    mapping = dict(DEFAULT_LABEL_MAP)
    for pair in raw.split(','):
        if '=' not in pair:
            continue
        label, _, semantic = pair.partition('=')
        mapping[label.strip()] = semantic.strip().lower()
    return mapping


def safety_available() -> bool:
    """True when the checkpoint is actually on disk with weights."""
    directory = safety_model_dir()
    has_weights = (directory / 'model.safetensors').exists()
    return has_weights and (directory / 'config.json').exists()


def bias_available() -> bool:
    """Whether a bias model is configured *and* present.

    The zip files in the deployed directory are degenerate, so "a file is
    present" is not the question -- "is it trustworthy" is, and the honest answer
    today is no. Set ``COLAB_BIAS_MODEL_DIR`` to a validated checkpoint to turn
    this on.
    """
    directory = os.environ.get('COLAB_BIAS_MODEL_DIR', '').strip()
    if not directory:
        return False
    path = Path(directory)
    return (path / 'model.safetensors').exists() or (path / 'pytorch_model.bin').exists()


# ---------------------------------------------------------------------------
# Classifier
# ---------------------------------------------------------------------------

def _load_sequence_classifier(directory: Path, registry_key: str):
    cached = ModelRegistry.get(registry_key)
    if cached is not None:
        return cached
    try:
        from transformers import AutoModelForSequenceClassification, AutoTokenizer
    except Exception as exc:  # noqa: BLE001
        logger.warning('transformers unavailable for %s: %s', directory.name, exc)
        return None

    try:
        tokenizer = AutoTokenizer.from_pretrained(str(directory), local_files_only=True)
        model = AutoModelForSequenceClassification.from_pretrained(
            str(directory), local_files_only=True,
        )
        model.eval()
    except Exception as exc:  # noqa: BLE001
        logger.warning('could not load classifier at %s: %s', directory, exc)
        return None

    ModelRegistry.register(registry_key, (model, tokenizer))
    logger.info('Colab safety classifier loaded from %s', directory)
    return model, tokenizer


def load_safety_classifier():
    """``(model, tokenizer)`` or None. Cached in the ModelRegistry."""
    if not safety_available():
        return None
    return _load_sequence_classifier(safety_model_dir(), 'colab_safety_classifier')


def load_bias_classifier():
    if not bias_available():
        return None
    return _load_sequence_classifier(
        Path(os.environ['COLAB_BIAS_MODEL_DIR'].strip()), 'colab_bias_classifier',
    )


def _run(text: str, directory: Path, registry_key: str) -> dict | None:
    """Softmax over the classifier head. None when unavailable."""
    loaded = _load_sequence_classifier(directory, registry_key)
    if loaded is None:
        return None
    model, tokenizer = loaded

    try:
        import torch
    except Exception as exc:  # noqa: BLE001
        logger.warning('torch unavailable for %s: %s', registry_key, exc)
        return None

    try:
        inputs = tokenizer(
            text, return_tensors='pt', truncation=True, max_length=256,
        )
        with torch.no_grad():
            logits = model(**inputs).logits
        probs = torch.softmax(logits, dim=-1)[0]
    except Exception as exc:  # noqa: BLE001
        logger.warning('inference failed for %s: %s', registry_key, exc)
        return None

    scores = {int(i): float(p) for i, p in enumerate(probs.tolist())}
    best = max(scores, key=lambda i: scores[i])
    return {'label_index': best, 'scores': scores, 'confidence': scores[best]}


def classify_safety(text: str) -> dict | None:
    """Run the Colab safety classifier. None when it is not available.

    The returned dict is shaped so a caller can pass it straight to
    :func:`build_explanation` without knowing anything about the checkpoint.
    """
    if not (text or '').strip():
        return None

    result = _run(
        text, safety_model_dir(), 'colab_safety_classifier',
    )
    if result is None:
        return None

    mapping = label_map()
    id2label = {}
    try:
        loaded = _load_sequence_classifier(safety_model_dir(), 'colab_safety_classifier')
        id2label = loaded[0].config.id2label
    except Exception:  # noqa: BLE001 - the mapping below is enough
        pass

    raw_label = id2label.get(result['label_index'], f'LABEL_{result["label_index"]}')
    semantic = mapping.get(raw_label, 'unknown')

    return {
        'semantic': semantic,
        'raw_label': raw_label,
        'confidence': result['confidence'],
        'scores': result['scores'],
        'conclusive': result['confidence'] >= CONFIDENCE_FLOOR,
    }


def classify_bias(text: str) -> dict | None:
    """Bias signal, or None -- including when no trustworthy model exists."""
    if not (text or '').strip() or not bias_available():
        return None
    result = _run(text, Path(os.environ['COLAB_BIAS_MODEL_DIR'].strip()), 'colab_bias_classifier')
    if result is None:
        return None
    return {
        'confidence': result['confidence'],
        'conclusive': result['confidence'] >= CONFIDENCE_FLOOR,
        'scores': result['scores'],
    }


# ---------------------------------------------------------------------------
# Explainer
# ---------------------------------------------------------------------------

def _load_explainer():
    """The seq2seq model used to phrase the explanation. Lazy, optional.

    Absence is a supported state, not an error: the deterministic builder below
    is the contract, and the generator is only a nicer surface on top of it.
    """
    cached = ModelRegistry.get('moderation_explainer')
    if cached is not None:
        return cached
    model_id = os.environ.get('MODERATION_EXPLAINER_MODEL', '').strip()
    if not model_id:
        logger.info('No MODERATION_EXPLAINER_MODEL set; using the deterministic explainer.')
        return None
    try:
        from transformers import AutoModelForSeq2SeqLM, AutoTokenizer

        tokenizer = AutoTokenizer.from_pretrained(model_id)
        model = AutoModelForSeq2SeqLM.from_pretrained(model_id)
        model.eval()
    except Exception as exc:  # noqa: BLE001
        logger.warning('explainer %s unavailable (%s); using the deterministic one', model_id, exc)
        return None

    ModelRegistry.register('moderation_explainer', (model, tokenizer))
    logger.info('Moderation explainer loaded: %s', model_id)
    return model, tokenizer


def build_explanation(text: str, safety: dict | None, bias: dict | None = None) -> str:
    """One paragraph a moderator can act on, grounded in what actually ran.

    Structure, in order of what a reviewer needs:

    1. what the platform decided;
    2. which model produced that and how sure it was;
    3. the specific signals it detected;
    4. an explicit statement of what was *not* assessed.

    Point 4 is not decoration. The deployed models assess toxicity, not bias, and
    a flag that reads "this looks biased" when nothing measured bias is the kind
    of thing that erodes trust in every other flag the console shows.
    """
    if safety is None:
        return (
            'No local model produced a reading for this text, so the platform '
            'fell back to keyword screening. Treat this as an automated screen, '
            'not a finding.'
        )

    semantic = safety['semantic']
    confidence = safety['confidence']
    raw = safety['raw_label']

    if not safety['conclusive']:
        return (
            f'The safety classifier was not confident enough to decide (its top '
            f'class was {raw} at {confidence:.0%}), so this was held for a human '
            f'to read rather than judged either way.'
        )

    if semantic == 'benign':
        return (
            f'The safety classifier read this as benign ({raw}, {confidence:.0%} '
            f'confidence). It assesses unsafe language, not bias, so nothing here '
            f'is a judgement about the people involved.'
        )

    if semantic == 'unknown':
        return (
            f'The classifier assigned {raw} at {confidence:.0%} confidence, which '
            f'is not a class this deployment can interpret. The text was held for '
            f'a human rather than auto-flagged on an unreadable label.'
        )

    tail = ''
    if bias is not None:
        tail = (
            f' A separate bias model also responded at {bias["confidence"]:.0%} '
            f'confidence.'
        )
    else:
        tail = (
            ' No bias model is deployed, so bias was not assessed here.'
        )

    return (
        f'The safety classifier flagged this as unsafe or abusive ({raw}, '
        f'{confidence:.0%} confidence).{tail} This is an automated assessment and '
        f'should be read alongside the post itself before any action is taken.'
    )


def explain(text: str) -> dict:
    """Classify and explain in one call. The shape the API returns.

    Always answers -- even with no models loaded -- because a moderator looking
    at a flag needs to be told what happened, and "the explainer failed" with no
    detail is not an answer.
    """
    safety = classify_safety(text)
    bias = classify_bias(text)
    explanation = build_explanation(text, safety, bias)
    return {
        'explanation': explanation,
        'safety': safety,
        'bias': bias,
        'bias_assessed': bias is not None,
        'explainer_model': os.environ.get('MODERATION_EXPLAINER_MODEL', '') or None,
        'deterministic': True,
        'safety_model': str(safety_model_dir()) if safety_available() else None,
    }