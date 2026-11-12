"""Stream remote post media through the backend with a BuddyUp watermark.

Used by the feed and community post download endpoints so both surfaces behave
identically: no CORS on the media host, images get a watermark, videos are
proxied as-is (watermarking video would need ffmpeg).
"""

import io

from django.http import StreamingHttpResponse
from rest_framework import status
from rest_framework.response import Response


def _error(message, status_code=status.HTTP_404_NOT_FOUND):
    return Response({
        'success': False, 'data': None, 'message': message,
        'errors': None, 'pagination': None,
    }, status=status_code)


def build_download_response(media_url, media_type='image', filename_stem='post'):
    """Return a streaming download response, or an error ``Response``."""
    import requests as http_requests

    try:
        resp = http_requests.get(media_url, stream=True, timeout=30)
        resp.raise_for_status()
    except Exception as exc:
        return _error(f'Failed to fetch media: {exc}', status.HTTP_502_BAD_GATEWAY)

    content_type = resp.headers.get('Content-Type', 'application/octet-stream')
    subtype = content_type.split(';')[0].split('/')[-1].strip().lower()
    ext_map = {'jpeg': 'jpg', 'svg+xml': 'svg', 'quicktime': 'mov', 'x-matroska': 'mkv'}
    ext = ext_map.get(subtype, subtype if subtype.isalnum() else 'bin')

    watermarked_body = None

    # For images, try to add a watermark using Pillow.
    if media_type == 'image' and content_type.split('/')[0].lower() == 'image':
        try:
            from PIL import Image, ImageDraw, ImageFont

            img = Image.open(io.BytesIO(resp.content)).convert('RGBA')
            watermark = Image.new('RGBA', img.size, (0, 0, 0, 0))
            draw = ImageDraw.Draw(watermark)
            try:
                font = ImageFont.truetype('DejaVuSans-Bold.ttf', max(14, img.height // 20))
            except Exception:
                font = ImageFont.load_default()
            text = 'Downloaded from BuddyUp'
            bbox = draw.textbbox((0, 0), text, font=font)
            tw = bbox[2] - bbox[0]
            th = bbox[3] - bbox[1]
            draw.text(
                (img.width - tw - 20, img.height - th - 20),
                text, font=font, fill=(255, 255, 255, 128),
            )
            img = Image.alpha_composite(img, watermark)
            buf = io.BytesIO()
            img.convert('RGB').save(buf, format='JPEG', quality=85)
            watermarked_body = buf.getvalue()
            content_type = 'image/jpeg'
            ext = 'jpg'
        except Exception:
            pass  # Pillow not available — proxy as-is.

    if watermarked_body is not None:
        def iter_chunks():
            yield watermarked_body
    else:
        def iter_chunks():
            for chunk in resp.iter_content(8192):
                yield chunk

    django_resp = StreamingHttpResponse(iter_chunks(), content_type=content_type)
    django_resp['Content-Disposition'] = f'attachment; filename="buddyup_{filename_stem}.{ext}"'
    django_resp['X-Content-Type-Options'] = 'nosniff'
    return django_resp
