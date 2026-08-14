"""Text-to-speech (microsoft/speecht5_tts + speecht5_hifigan, CPU INT8).

SpeechT5 produces 16kHz mel spectrograms from text + a speaker x-vector;
HiFi-GAN vocodes them to waveform. Speaker embeddings are bundled under
/Models/speakers/ as <name>.npy (512-dim) and selected via the `speaker` param.
Falls back to a 503-style error dict if the stack is unavailable.
"""
import io
import logging
import wave
from pathlib import Path

import numpy as np

from .config import settings
from .ml.hf_utils import load_preferred_hf
from .model_registry import ModelRegistry, DEVICE

logger = logging.getLogger(__name__)

TTS_MODEL = settings.tts_model or 'microsoft/speecht5_tts'
VOCODER_MODEL = settings.tts_vocoder or 'microsoft/speecht5_hifigan'
SPEAKER_DIR = Path(settings.tts_speaker_dir or '/models/speakers')
DEFAULT_SPEAKER = settings.tts_default_speaker or 'slt'
SAMPLE_RATE = settings.tts_sample_rate or 22050


def _get_tts():
    cached = ModelRegistry.get(TTS_MODEL)
    if cached is not None:
        return cached

    from transformers import SpeechT5Processor, SpeechT5ForTextToSpeech

    processor = SpeechT5Processor.from_pretrained(TTS_MODEL)

    def factory():
        return SpeechT5ForTextToSpeech.from_pretrained(TTS_MODEL, torch_dtype='auto')

    model = load_preferred_hf(TTS_MODEL, factory)
    ModelRegistry.register(f'{TTS_MODEL}-processor', processor)
    return model


def _get_vocoder():
    cached = ModelRegistry.get(VOCODER_MODEL)
    if cached is not None:
        return cached

    from transformers import SpeechT5HifiGan

    def factory():
        return SpeechT5HifiGan.from_pretrained(VOCODER_MODEL)

    model = load_preferred_hf(VOCODER_MODEL, factory)
    return model


def _get_processor():
    processor = ModelRegistry.get(f'{TTS_MODEL}-processor')
    if processor is None:
        from transformers import SpeechT5Processor

        processor = SpeechT5Processor.from_pretrained(TTS_MODEL)
        ModelRegistry.register(f'{TTS_MODEL}-processor', processor)
    return processor


def _load_speaker_embedding(speaker: str) -> np.ndarray:
    path = SPEAKER_DIR / f'{speaker}.npy'
    if not path.exists():
        path = SPEAKER_DIR / f'{DEFAULT_SPEAKER}.npy'
    if not path.exists():
        raise FileNotFoundError(f'No speaker embedding available ({speaker}/{DEFAULT_SPEAKER})')
    return np.load(path)


def _wav_bytes(audio, sample_rate: int) -> bytes:
    buf = io.BytesIO()
    with wave.open(buf, 'wb') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        pcm = np.clip(audio * 32767.0, -32768, 32767).astype(np.int16)
        wf.writeframes(pcm.tobytes())
    return buf.getvalue()


def list_speakers() -> list[str]:
    if not SPEAKER_DIR.exists():
        return [DEFAULT_SPEAKER]
    return sorted(p.stem for p in SPEAKER_DIR.glob('*.npy'))


def synthesize(text: str, speaker: str | None = None) -> dict:
    if not text or not text.strip():
        return {'error': 'Empty text'}
    text = text.strip()[:1000]
    name = speaker or DEFAULT_SPEAKER

    try:
        model = _get_tts()
        vocoder = _get_vocoder()
        processor = _get_processor()

        import torch

        embedding = _load_speaker_embedding(name)
        speaker_embedding = torch.tensor(embedding, dtype=torch.float32).unsqueeze(0).to(DEVICE)

        inputs = processor(text=text, return_tensors='pt').to(DEVICE)
        with torch.inference_mode():
            speech = model.generate_speech(
                inputs['input_ids'],
                speaker_embeddings=speaker_embedding,
                vocoder=vocoder,
            )
        audio = speech.squeeze().cpu().numpy()
        wav = _wav_bytes(audio, SAMPLE_RATE)
        return {
            'audio_bytes': wav,
            'sample_rate': SAMPLE_RATE,
            'speaker': name,
            'model': 'speecht5-tts',
            'media_type': 'audio/wav',
        }
    except Exception as exc:  # noqa: BLE001
        logger.warning('TTS synthesis failed: %s', exc)
        return {'error': f'TTS unavailable: {exc}'}
