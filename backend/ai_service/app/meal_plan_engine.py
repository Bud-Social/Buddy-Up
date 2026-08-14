import json
import logging
import re
from typing import Any

import httpx

from .config import settings

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = (
    'You are a senior sports nutritionist and meal-plan personalisation engine for '
    'a fitness platform. You receive a user profile summary, goals, dietary '
    'preferences, allergies, a calorie target, and a base meal plan template. '
    'Return a JSON object with exactly these keys:\n'
    '{\n'
    '  "adjusted_portions": bool,\n'
    '  "substitutions": [{"original": str, "replacement": str, "reason": str}],\n'
    '  "macro_summary": {"calories": number, "protein_g": number, "carbs_g": number, "fat_g": number},\n'
    '  "shopping_list": [str],\n'
    '  "notes": str\n'
    '}\n'
    'Adjust portion sizes when the user calorie target differs from the plan range. '
    'Substitute ingredients that violate allergies or dietary preferences. '
    'Keep the shopping list practical and complete. Notes must be concise and motivating.'
)


def _extract_calorie_midpoint(calorie_range: str | None) -> float | None:
    if not calorie_range:
        return None
    numbers = [float(n) for n in re.findall(r'\d+', calorie_range)]
    if not numbers:
        return None
    return sum(numbers) / len(numbers)


def _fallback_personalisation(req: dict) -> dict:
    """Deterministic rule-based personalisation used when no LLM is configured."""
    plan = req.get('plan_template') or {}
    calorie_range = plan.get('calorie_range') or ''
    midpoint = _extract_calorie_midpoint(calorie_range)
    calorie_target = req.get('calorie_target')

    adjusted_portions = False
    notes = (
        'Personalisation engine is running in offline mode. '
        'Set AI_OPENAI_API_KEY to enable GPT-4o powered personalisation.'
    )
    macro_summary: dict[str, Any] = {}
    scale = 1.0

    if midpoint and calorie_target and calorie_target > 0:
        scale = calorie_target / midpoint
        adjusted_portions = abs(scale - 1.0) > 0.05
        calories = calorie_target
        macro_summary = {
            'calories': round(calories),
            'protein_g': round(calories * 0.30 / 4),
            'carbs_g': round(calories * 0.40 / 4),
            'fat_g': round(calories * 0.30 / 9),
        }
        direction = 'increase' if scale > 1.0 else 'decrease'
        notes = (
            f'Portions adjusted to hit ~{calorie_target} kcal/day ({direction} vs the '
            f'plan range {calorie_range}). Macros: 30% protein / 40% carbs / 30% fat.'
        )
    elif midpoint and not adjusted_portions:
        macro_summary = {
            'calories': round(midpoint),
            'protein_g': round(midpoint * 0.30 / 4),
            'carbs_g': round(midpoint * 0.40 / 4),
            'fat_g': round(midpoint * 0.30 / 9),
        }

    return {
        'adjusted_portions': adjusted_portions,
        'substitutions': [],
        'macro_summary': macro_summary,
        'shopping_list': list(plan.get('shopping_list') or []),
        'notes': notes,
    }


def _build_rag_context(req: dict) -> str:
    plan = req.get('plan_template') or {}
    parts = []
    if plan.get('title'):
        parts.append(f'Plan: {plan["title"]}')
    if plan.get('description'):
        parts.append(f'Description: {plan["description"]}')
    if plan.get('duration_weeks'):
        parts.append(f'Duration: {plan["duration_weeks"]} weeks')
    if plan.get('calorie_range'):
        parts.append(f'Calorie range: {plan["calorie_range"]}')
    if plan.get('full_plan'):
        parts.append(f'Meal plan:\n{plan["full_plan"]}')
    if plan.get('shopping_list'):
        parts.append('Base shopping list:\n' + '\n'.join(plan['shopping_list']))
    return '\n\n'.join(parts)


def _build_user_prompt(req: dict) -> str:
    lines = [
        f'Profile summary: {req.get("profile_summary") or "Not provided"}',
        f'Goals: {req.get("goals") or "Not provided"}',
        f'Dietary preferences: {", ".join(req.get("dietary_preferences") or []) or "None"}',
        f'Allergies / restrictions: {", ".join(req.get("allergies") or []) or "None"}',
        f'Calorie target: {req.get("calorie_target") or "Not specified"}',
        'Base plan template:',
        _build_rag_context(req),
    ]
    return '\n'.join(lines)


def _validate_result(data: Any) -> dict | None:
    if not isinstance(data, dict):
        return None
    required = ('adjusted_portions', 'substitutions', 'macro_summary', 'shopping_list', 'notes')
    if not all(k in data for k in required):
        return None
    return {
        'adjusted_portions': bool(data.get('adjusted_portions', True)),
        'substitutions': data.get('substitutions') or [],
        'macro_summary': data.get('macro_summary') or {},
        'shopping_list': data.get('shopping_list') or [],
        'notes': str(data.get('notes') or ''),
    }


async def _call_openai(req: dict) -> dict | None:
    if not settings.openai_api_key:
        return None

    url = f'{settings.openai_base_url.rstrip("/")}/chat/completions'
    payload = {
        'model': settings.openai_model,
        'temperature': 0.4,
        'max_tokens': 1600,
        'response_format': {'type': 'json_object'},
        'messages': [
            {'role': 'system', 'content': SYSTEM_PROMPT},
            {'role': 'user', 'content': _build_user_prompt(req)},
        ],
    }
    headers = {
        'Authorization': f'Bearer {settings.openai_api_key}',
        'Content-Type': 'application/json',
    }
    try:
        async with httpx.AsyncClient(timeout=45) as client:
            resp = await client.post(url, headers=headers, json=payload)
            resp.raise_for_status()
            data = resp.json()
        content = data['choices'][0]['message']['content']
        parsed = json.loads(content)
        return _validate_result(parsed)
    except Exception as exc:  # noqa: BLE001
        logger.warning('OpenAI meal-plan personalisation failed: %s', exc)
        return None


async def personalise_meal_plan(req: dict) -> dict:
    if not req.get('plan_template'):
        return _fallback_personalisation(req)

    result = await _call_openai(req)
    if result is None:
        return _fallback_personalisation(req)
    return result
