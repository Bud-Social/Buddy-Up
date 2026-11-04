"""Local caption correction engine (keyless, offline fallback).

Fixes common grammatical issues in social media captions before posting.
Mirrors ai_service/app/caption_engine.py so the Django backend can correct
captions without a network call when the AI microservice is unavailable.
"""

import re
from typing import List


_CAPTION_FIXES = [
    (r'\bi\b', 'I', 'capitalized "i"'),
    (r'\s{2,}', ' ', 'collapsed double spaces'),
    (r'([.!?])\s*([a-zA-Z])', r'\1 \2', 'added space after sentence end'),
    (r'([,\;])([^\s])', r'\1 \2', 'added space after comma'),
    (r'\s+([.!?,])', r'\1', 'removed space before punctuation'),
    (r'\bdont\b', "don't", "added apostrophe in don't"),
    (r'\bcant\b', "can't", "added apostrophe in can't"),
    (r'\bwont\b', "won't", "added apostrophe in won't"),
    (r'\bim\b', "I'm", "added apostrophe in I'm"),
    (r'\bive\b', "I've", "added apostrophe in I've"),
    (r'\bid\b', "I'd", "added apostrophe in I'd"),
    (r'\bisnt\b', "isn't", "added apostrophe in isn't"),
    (r'\barent\b', "aren't", "added apostrophe in aren't"),
    (r'\bwasnt\b', "wasn't", "added apostrophe in wasn't"),
    (r'\bwerent\b', "weren't", "added apostrophe in weren't"),
    (r'\bhasnt\b', "hasn't", "added apostrophe in hasn't"),
    (r'\bhavent\b', "haven't", "added apostrophe in haven't"),
    (r'\bhadnt\b', "hadn't", "added apostrophe in hadn't"),
    (r'^([a-z])', lambda m: m.group(1).upper(), 'capitalized first letter'),
    (r'(\d+)(km)\b', r'\1 \2', 'added space before km'),
    (r'(\d+)(min)\b', r'\1 \2', 'added space before min'),
    (r'!{3,}', '!!', 'reduced excessive exclamation marks'),
    (r'\?{3,}', '??', 'reduced excessive question marks'),
]


def correct_caption(caption: str, context: str = '') -> dict:
    """Correct grammar in a social caption.

    Returns {'corrected': str, 'changes': list[str]}. Never crashes.
    """
    if not caption or not caption.strip():
        return {'corrected': caption or '', 'changes': []}

    try:
        text = caption.strip()
        changes: List[str] = []
        for pattern, replacement, desc in _CAPTION_FIXES:
            new_text, n = re.subn(pattern, replacement, text, flags=re.IGNORECASE)
            if n > 0:
                changes.append(desc)
                text = new_text
        if text == caption.strip():
            changes = []
        return {'corrected': text, 'changes': changes}
    except Exception:  # noqa: BLE001 — never crash the caller
        return {'corrected': caption, 'changes': []}
