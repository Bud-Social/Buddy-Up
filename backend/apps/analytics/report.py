"""Render a comprehensive analytics report as a branded PNG with watermark.

Uses Pillow to compose a dark-themed report card from the aggregated summary,
overlays the BuddyUp logo as a watermark, and uploads the result to the
configured media storage (Cloudinary/local).
"""
import io
import os
import uuid
from datetime import date

from django.conf import settings
from django.core.files.base import ContentFile
from django.core.files.storage import default_storage

from PIL import Image, ImageDraw, ImageFont, ImageOps

_BG = (13, 13, 16)
_SURFACE = (24, 26, 32)
_GREEN = (0, 200, 150)
_ELECTRIC = (123, 97, 255)
_ORANGE = (255, 107, 53)
_WHITE = (255, 255, 255)
_MUTED = (160, 160, 160)
_LINE = (45, 48, 58)

_FONT_DIR = os.path.join(settings.BASE_DIR, 'apps', 'analytics', 'static', 'analytics')


def _font(size, bold=False):
    """Load a usable TTF (DejaVu is bundled with Pillow wheels)."""
    from PIL import ImageFont
    candidates = [
        '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf' if bold else '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
        '/usr/local/lib/python3.12/site-packages/PIL/fonts/DejaVuSans-Bold.ttf' if bold else '/usr/local/lib/python3.12/site-packages/PIL/fonts/DejaVuSans.ttf',
    ]
    for path in candidates:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def _logo():
    path = os.path.join(_FONT_DIR, 'img', 'logo.png')
    if os.path.exists(path):
        return Image.open(path).convert('RGBA')
    return None


def _fmt_duration(seconds):
    if not seconds:
        return '0m'
    hours, rem = divmod(int(seconds), 3600)
    mins, secs = divmod(rem, 60)
    if hours:
        return f'{hours}h {mins}m'
    return f'{mins}m {secs}s'


def _fmt_pace(seconds_per_km):
    if not seconds_per_km:
        return '—'
    mins, secs = divmod(int(seconds_per_km), 60)
    return f'{mins}:{secs:02d}'


def _draw_stat(draw, x, y, label, value, font_value, font_label):
    draw.text((x, y), value, font=font_value, fill=_WHITE)
    draw.text((x, y + 34), label, font=font_label, fill=_MUTED)


def _draw_section(draw, x, y, title, rows, font_title, font_row, font_val, max_w):
    draw.text((x, y), title, font=font_title, fill=_GREEN)
    y += 34
    for label, value in rows:
        draw.text((x, y), label, font=font_row, fill=_MUTED)
        draw.text((x + max_w - len(str(value)) * 10, y), str(value), font=font_row, fill=_WHITE)
        y += 26
    return y + 18


def render_report_image(summary, period_label):
    """Render the summary dict into a branded PNG and return raw bytes."""
    width, height = 1080, 1560
    img = Image.new('RGB', (width, height), _BG)
    draw = ImageDraw.Draw(img)

    logo = _logo()
    if logo:
        img.paste(logo, (40, 36), logo)

    title_font = _font(30, bold=True)
    header_font = _font(22, bold=True)
    value_font = _font(26, bold=True)
    label_font = _font(16)
    row_font = _font(18)
    small_font = _font(14)
    muted_font = _font(16)

    # Header
    draw.text((40, 250), 'BUDDY-UP  ·  PROGRESS REPORT', font=header_font, fill=_GREEN)
    user = summary.get('user', {})
    draw.text((40, 292), f"@{user.get('username', 'you')}  ·  {period_label}",
              font=small_font, fill=_MUTED)

    y = 360
    workouts = summary.get('workouts', {})
    activity = summary.get('activity', {})
    nutrition = summary.get('nutrition', {})
    body = summary.get('body', {})
    lives = summary.get('lives', {})
    spending = summary.get('spending', {})
    programmes = summary.get('programmes', {})

    # Row 1 — big numbers
    draw.line([(40, 430), (1040, 430)], fill=_LINE, width=2)
    cols = [
        ('Workouts', str(workouts.get('count', 0)), value_font),
        ('Activity', str(activity.get('count', 0)) + ' sessions', value_font),
        ('Meals', str(nutrition.get('count', 0)), value_font),
        ('Streak', str(user.get('streak_days', 0)) + ' days', value_font),
    ]
    col_w = 250
    for i, (label, value, f) in enumerate(cols):
        x = 40 + i * col_w
        _draw_stat(draw, x, 460, label, value, f, small_font)

    # Sections
    y = 620
    left = 40
    right = 560
    col = left

    # Workouts
    rows = [
        ('Calories burned', f"{workouts.get('total_calories_burned', 0)} kcal"),
        ('Total volume', f"{workouts.get('total_volume', 0)} kg"),
        ('Most trained', workouts.get('most_trained') or '—'),
    ]
    for t in (workouts.get('by_type') or [])[:2]:
        rows.append((t.get('label'), str(t.get('count'))))
    y = _draw_section(draw, col, y, 'WORKOUTS', rows, header_font, row_font, row_font, 280)
    col = right
    y = 620

    # Activity
    rows = [
        ('Distance', f"{activity.get('total_distance_km', 0)} km"),
        ('Time', _fmt_duration(activity.get('total_duration_seconds', 0))),
        ('Avg pace', _fmt_pace(activity.get('avg_pace'))),
        ('Steps', str(activity.get('total_steps', 0))),
        ('Calories', f"{activity.get('total_calories_burned', 0)} kcal"),
    ]
    y = _draw_section(draw, col, y, 'WALKING / RUNNING', rows, header_font, row_font, row_font, 280)

    col = left
    y += 30

    # Nutrition
    rows = [
        ('Total calories', f"{nutrition.get('total_calories', 0)} kcal"),
        ('Protein', f"{nutrition.get('total_protein_g', 0)} g"),
        ('Carbs', f"{nutrition.get('total_carbs_g', 0)} g"),
        ('Fat', f"{nutrition.get('total_fat_g', 0)} g"),
    ]
    y = _draw_section(draw, col, y, 'NUTRITION', rows, header_font, row_font, row_font, 280)
    col = right
    y = 1150

    # Body
    weight_change = body.get('weight_change_kg')
    change_str = f"{weight_change:+.1f} kg" if weight_change is not None else '—'
    rows = [
        ('Start weight', f"{body.get('start_weight_kg')} kg" if body.get('start_weight_kg') else '—'),
        ('Latest weight', f"{body.get('latest_weight_kg')} kg" if body.get('latest_weight_kg') else '—'),
        ('Change', change_str),
        ('Body fat', f"{body.get('latest_body_fat_pct')}%" if body.get('latest_body_fat_pct') is not None else '—'),
    ]
    y = _draw_section(draw, col, y, 'BODY', rows, header_font, row_font, row_font, 280)

    # Lives
    col = left
    y += 30
    rows = [
        ('Lives joined', str(lives.get('joined_count', 0))),
        ('Time in lives', _fmt_duration(lives.get('total_duration_seconds', 0))),
    ]
    y = _draw_section(draw, col, y, 'LIVE SESSIONS', rows, header_font, row_font, row_font, 280)

    # Spending
    col = right
    y = 1150 + 130
    rows = [
        ('Gifts sent', str(spending.get('gifts_sent', {}).get('quantity', 0))),
        ('Gifts received', str(spending.get('gifts_received', {}).get('quantity', 0))),
        ('Live fees', str(spending.get('live_fees', {}).get('quantity', 0))),
        ('Marketplace', str(spending.get('marketplace_spend', {}).get('quantity', 0))),
    ]
    y = _draw_section(draw, col, y, 'SPENDING & GIFTS', rows, header_font, row_font, row_font, 280)

    # Programmes
    col = left
    rows = [
        ('Programmes bought', str(programmes.get('programmes_purchased', 0))),
        ('Meal plans', str(programmes.get('meal_plans_purchased', 0))),
        ('Completed', str(programmes.get('completed_enrolments', 0))),
        ('Avg progress', f"{programmes.get('avg_progress_pct', 0)}%"),
    ]
    y = _draw_section(draw, col, y + 10, 'PROGRAMMES & PURCHASES', rows, header_font, row_font, row_font, 280)

    # Footer + watermark
    draw.line([(40, y + 20), (1040, y + 20)], fill=_LINE, width=2)
    draw.text((40, y + 36), f'Generated {date.today().isoformat()} · buddyup.app',
              font=small_font, fill=_MUTED)

    # Diagonal watermark
    watermark = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    wdraw = ImageDraw.Draw(watermark)
    wfont = _font(120, bold=True)
    wtext = 'BUDDY-UP'
    bbox = wdraw.textbbox((0, 0), wtext, font=wfont)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    # repeating diagonal watermark
    for row in range(0, height, 320):
        for col_wm in range(-width, width, 720):
            wdraw.text((col_wm, row), wtext, font=wfont, fill=(255, 255, 255, 14))
    watermark = watermark.rotate(-30, expand=False)
    img = Image.alpha_composite(img.convert('RGBA'), watermark).convert('RGB')

    buf = io.BytesIO()
    img.save(buf, format='PNG', optimize=True)
    return buf.getvalue()


def save_report_image(summary, period, prefix='reports'):
    """Render + persist the report PNG, returning its public URL."""
    label = {
        'week': 'This Week', 'month': 'This Month', 'quarter': 'This Quarter',
        'year': 'This Year', 'all': 'All Time',
    }.get(period, 'All Time')
    data = render_report_image(summary, label)
    filename = f'{prefix}/{uuid.uuid4().hex}.png'
    saved = default_storage.save(filename, ContentFile(data))
    return default_storage.url(saved)


def generate_report_file(profile, period):
    """Build summary + render image; returns (summary, image_url)."""
    from . import engine
    summary = engine.build_summary(profile, period)
    image_url = save_report_image(summary, period)
    return summary, image_url
