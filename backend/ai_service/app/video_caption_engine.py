"""Workout video → text captioning (microsoft/Florence-2-base, CPU INT8).

Samples a small set of frames from a workout video and generates a natural
language workout description via Florence-2's `<MORE_DETAILED_CAPTION>` task.
If the caption model is unavailable it degrades to a pose-based template
description built from `form_analyzer_engine.analyze_form_video`.
"""
import logging
import tempfile

import numpy as np

from .config import settings
from .ml.hf_utils import load_preferred_hf
from .model_registry import ModelRegistry, DEVICE

logger = logging.getLogger(__name__)

MODEL_NAME = settings.caption_model or 'microsoft/Florence-2-base'
MAX_FRAMES = 3
MAX_DECODE = 1200


def _get_caption_model():
    cached = ModelRegistry.get(MODEL_NAME)
    if cached is not None:
        return cached

    from transformers import Florence2ForConditionalGeneration
    import torch

    def factory():
        return Florence2ForConditionalGeneration.from_pretrained(
            MODEL_NAME,
            dtype=torch.float32,
            device_map={'': str(DEVICE)},
        )

    model = load_preferred_hf(MODEL_NAME, factory)
    ModelRegistry.register(f'{MODEL_NAME}-processor', _get_processor())
    return model


def _get_processor():
    processor = ModelRegistry.get(f'{MODEL_NAME}-processor')
    if processor is None:
        from transformers import AutoProcessor

        processor = AutoProcessor.from_pretrained(MODEL_NAME)
        ModelRegistry.register(f'{MODEL_NAME}-processor', processor)
    return processor


def _sample_frames(video_bytes: bytes, max_frames: int = MAX_FRAMES) -> list[dict]:
    """Decode a video and return `max_frames` evenly spaced frames as PIL Images."""
    try:
        import cv2
        from PIL import Image
    except ImportError:
        return []

    frames = []
    with tempfile.NamedTemporaryFile(suffix='.mp4') as tmp:
        tmp.write(video_bytes)
        tmp.flush()
        cap = cv2.VideoCapture(tmp.name)
        if not cap.isOpened():
            return []
        total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        total = min(total, MAX_DECODE) if total > 0 else MAX_DECODE
        step = max(1, total // max_frames)
        idx = 0
        while len(frames) < max_frames:
            ret, frame = cap.read()
            if not ret:
                break
            if idx % step == 0 or idx == total - 1:
                rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                frames.append({'frame_index': idx, 'image': Image.fromarray(rgb)})
            idx += 1
        cap.release()
    return frames[:max_frames]


def _caption_image(image, prompt: str = '<MORE_DETAILED_CAPTION>') -> str:
    model = _get_caption_model()
    processor = _get_processor()
    inputs = processor(text=prompt, images=image, return_tensors='pt').to(DEVICE)
    generated_ids = model.generate(
        input_ids=inputs['input_ids'],
        pixel_values=inputs['pixel_values'],
        max_new_tokens=100,
        do_sample=False,
        num_beams=3,
    )
    text = processor.batch_decode(generated_ids, skip_special_tokens=False)[0]
    parsed = processor.post_process_generation(text, task=prompt, image_size=(image.width, image.height))
    caption = parsed.get(prompt, '')
    if not caption:
        caption = text.replace('<pad>', '').replace('</s>', '').strip()
    return caption


def _template_description(form_result: dict) -> str:
    exercise = form_result.get('exercise', 'workout')
    display = exercise.replace('_', ' ').title() if exercise != 'workout' else 'workout'
    issues = form_result.get('top_issues', [])
    issue_text = ' '.join(f'- {i["issue"].replace("_", " ")}' for i in issues[:3]) if issues else 'None observed.'
    feedback = form_result.get('feedback', [])
    fb = ' '.join(feedback[:3]) if feedback else f'Focus on form for {display}.'
    return (
        f'A workout video of {display}. '
        f'Top form issues: {issue_text} '
        f'Coaching notes: {fb}'
    )


def describe_workout_video(video_bytes: bytes, exercise: str = 'auto') -> dict:
    """Return a natural-language description of a workout video."""
    if not video_bytes:
        return {'error': 'Empty video'}

    frames = _sample_frames(video_bytes)
    if not frames:
        return {'error': 'Could not decode video'}

    try:
        captions = []
        for f in frames:
            try:
                captions.append(_caption_image(f['image']))
            except Exception as exc:
                logger.warning('Frame %d caption failed: %s', f['frame_index'], exc)
                break

        if captions:
            # Deduplicate near-identical captions from repeated frames.
            unique = []
            for c in captions:
                if c and c not in unique:
                    unique.append(c)
            description = ' '.join(unique)
            return {
                'description': description,
                'frames_used': len(frames),
                'model': 'florence-2-base',
                'exercise': exercise,
            }
    except Exception as exc:
        logger.warning('Florence-2 caption failed (%s) — pose fallback', exc)

    # Pose-based fallback: detected exercise + form coaching notes.
    from .form_analyzer_engine import analyze_form_video

    form_result = analyze_form_video(video_bytes, exercise)
    description = _template_description(form_result)
    return {
        'description': description,
        'frames_used': len(frames),
        'model': 'pose-template',
        'exercise': form_result.get('exercise', exercise),
    }
