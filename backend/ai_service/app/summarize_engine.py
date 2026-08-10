"""Text summarization (Falconsai/text_summarization, T5-Small, CPU INT8).

Truncates long input to the model context and returns an abstractive summary.
If the seq2seq model is unavailable it degrades to a simple extractive
top-sentence summary.
"""
import logging
import re

from .config import settings
from .ml.hf_utils import load_preferred_hf
from .model_registry import ModelRegistry, DEVICE

logger = logging.getLogger(__name__)

MODEL_NAME = settings.summarizer_model or 'Falconsai/text_summarization'
MAX_CHARS = settings.summarizer_max_chars or 4000
MAX_INPUT_TOKENS = 512
MAX_OUTPUT_TOKENS = 150


def _get_summarizer():
    cached = ModelRegistry.get(MODEL_NAME)
    if cached is not None:
        return cached

    from transformers import AutoModelForSeq2SeqLM, AutoTokenizer

    tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)

    def factory():
        return AutoModelForSeq2SeqLM.from_pretrained(MODEL_NAME, torch_dtype='auto')

    model = load_preferred_hf(MODEL_NAME, factory)
    ModelRegistry.register(f'{MODEL_NAME}-tokenizer', tokenizer)
    return model


def _get_tokenizer():
    tokenizer = ModelRegistry.get(f'{MODEL_NAME}-tokenizer')
    if tokenizer is None:
        from transformers import AutoTokenizer

        tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
        ModelRegistry.register(f'{MODEL_NAME}-tokenizer', tokenizer)
    return tokenizer


def _split_sentences(text: str) -> list[str]:
    parts = re.split(r'(?<=[.!?])\s+', text.strip())
    return [p for p in parts if p.strip()]


def _extractive_summary(text: str, top_n: int = 4) -> str:
    sentences = _split_sentences(text)
    if not sentences:
        return text[:500]
    words = re.findall(r'\b\w+\b', text.lower())
    stop = {
        'the', 'a', 'an', 'and', 'or', 'but', 'of', 'to', 'in', 'on', 'for',
        'with', 'at', 'by', 'from', 'is', 'are', 'was', 'were', 'be', 'as',
        'it', 'this', 'that', 'these', 'those',
    }
    freq: dict[str, int] = {}
    for w in words:
        if w not in stop and len(w) > 2:
            freq[w] = freq.get(w, 0) + 1
    if not freq:
        return ' '.join(sentences[:top_n])
    scored = []
    for i, s in enumerate(sentences):
        score = sum(freq.get(w, 0) for w in re.findall(r'\b\w+\b', s.lower()))
        scored.append((i, score))
    top = sorted(scored, key=lambda x: x[1], reverse=True)[:top_n]
    top.sort(key=lambda x: x[0])
    return ' '.join(sentences[i] for i, _ in top)


def summarize(text: str, max_length: int = MAX_OUTPUT_TOKENS) -> dict:
    if not text or not text.strip():
        return {'error': 'Empty text'}

    try:
        model = _get_summarizer()
        tokenizer = _get_tokenizer()

        # Truncate to a manageable character budget first.
        truncated = text.strip()[:MAX_CHARS]
        inputs = tokenizer(
            truncated,
            return_tensors='pt',
            truncation=True,
            max_length=MAX_INPUT_TOKENS,
        ).to(DEVICE)
        outputs = model.generate(
            **inputs,
            max_length=max_length,
            num_beams=4,
            do_sample=False,
        )
        summary = tokenizer.decode(outputs[0], skip_special_tokens=True).strip()
        if not summary:
            raise ValueError('Empty abstractive summary')

        return {
            'summary': summary,
            'model': 't5-small',
            'truncated': len(text) > len(truncated),
            'input_chars': len(text),
            'output_chars': len(summary),
        }
    except Exception as exc:
        logger.warning('Abstractive summarization failed (%s) — extractive fallback', exc)
        summary = _extractive_summary(text)
        return {
            'summary': summary,
            'model': 'extractive',
            'truncated': len(text) > MAX_CHARS,
            'input_chars': len(text),
            'output_chars': len(summary),
        }
