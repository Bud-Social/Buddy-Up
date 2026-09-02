"""Small helpers shared by AI tasks."""


def _vtt_timestamp(ms: int) -> str:
    ms = max(int(ms or 0), 0)
    hours, rem = divmod(ms, 3_600_000)
    minutes, rem = divmod(rem, 60_000)
    seconds, millis = divmod(rem, 1000)
    return f'{hours:02d}:{minutes:02d}:{seconds:02d}.{millis:03d}'


def segments_to_vtt(segments: list[dict]) -> str:
    """Render transcript segments ([{start_ms, end_ms, text}]) as WebVTT."""
    lines = ['WEBVTT', '']
    for i, seg in enumerate(segments or [], start=1):
        text = str(seg.get('text') or '').strip()
        if not text:
            continue
        start_ms = seg.get('start_ms') or 0
        end_ms = seg.get('end_ms') or start_ms
        lines.append(str(i))
        lines.append(f'{_vtt_timestamp(start_ms)} --> {_vtt_timestamp(end_ms)}')
        lines.append(text)
        lines.append('')
    return '\n'.join(lines)
