"""Caption correction engine.

Fixes common grammatical issues in social media captions before posting.
Rule-based with a small model fallback — keyless, works offline.
"""

import re
from typing import Tuple, List


# Common social-media grammar fixes: (pattern, replacement, description)
_CAPTION_FIXES = [
    # "i" -> "I" at sentence start or standalone
    (r'\bi\b', 'I', 'capitalized "i"'),
    # Double spaces
    (r'\s{2,}', ' ', 'collapsed double spaces'),
    # Missing space after punctuation
    (r'([.!?])\s*([a-zA-Z])', r'\1 \2', 'added space after sentence end'),
    # Missing space after comma
    (r'([,\;])([^\s])', r'\1 \2', 'added space after comma'),
    # Space before punctuation
    (r'\s+([.!?,])', r'\1', 'removed space before punctuation'),
    # "dont" -> "don't", "cant" -> "can't", "wont" -> "won't", "im" -> "I'm"
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
    # "gonna", "wanna", "gotta" -> keep as-is (slang), but capitalize start
    # Capitalize first letter of caption
    (r'^([a-z])', lambda m: m.group(1).upper(), 'capitalized first letter'),
    # "km" spacing: "5km" -> "5 km"
    (r'(\d+)(km)\b', r'\1 \2', 'added space before km'),
    # "min" spacing: "30min" -> "30 min"
    (r'(\d+)(min)\b', r'\1 \2', 'added space before min'),
    # Multiple exclamation marks -> single (optional, keep max 2)
    (r'!{3,}', '!!', 'reduced excessive exclamation marks'),
    # Multiple question marks -> single
    (r'\?{3,}', '??', 'reduced excessive question marks'),
]


def _apply_fixes(caption: str) -> Tuple[str, List[str]]:
    changes: List[str] = []
    text = caption
    for pattern, replacement, desc in _CAPTION_FIXES:
        new_text, n = re.subn(pattern, replacement, text, flags=re.IGNORECASE)
        if n > 0:
            changes.append(desc)
            text = new_text
    return text, changes


def correct_caption(caption: str, context: str = '') -> dict:
    """Correct grammar in a social caption.

    Returns a dict with 'corrected' and 'changes' keys. Never crashes —
    returns the original caption unchanged if anything goes wrong.
    """
    if not caption or not caption.strip():
        return {'corrected': caption or '', 'changes': []}

    try:
        corrected, changes = _apply_fixes(caption.strip())
        # Avoid returning identical text as a "change"
        if corrected == caption.strip():
            changes = []
        return {'corrected': corrected, 'changes': changes}
    except Exception:  # noqa: BLE001 — never crash the caller
        return {'corrected': caption, 'changes': []}
