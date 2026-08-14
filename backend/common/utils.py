import re
from datetime import date
from hashlib import sha256


def format_phone(phone: str, country_code: str = '+254') -> str:
    digits = re.sub(r'\D', '', phone)
    if len(digits) == 9:
        return f'{country_code}{digits[1:]}'
    if len(digits) == 10:
        return f'{country_code}{digits[1:]}'
    return f'+{digits}' if not digits.startswith('+') else digits


def hash_dob(dob: date) -> str:
    return sha256(dob.isoformat().encode()).hexdigest()


def calculate_age(dob: date) -> int:
    today = date.today()
    return today.year - dob.year - ((today.month, today.day) < (dob.month, dob.day))


MAGIC_BYTES: dict[str, bytes] = {
    '.jpg': b'\xff\xd8\xff',
    '.jpeg': b'\xff\xd8\xff',
    '.png': b'\x89PNG\r\n\x1a\n',
    '.gif': b'GIF8',
    '.webp': b'RIFF',
    '.mp4': b'\x00\x00\x00\x18ftyp',
    '.mov': b'\x00\x00\x00\x14ftypqt',
    '.webm': b'\x1a\x45\xdf\xa3',
    '.mp3': b'\xff\xfb',
    '.ogg': b'OggS',
    '.m4a': b'\x00\x00\x00\x18ftypM4A',
    '.wav': b'RIFF',
    '.pdf': b'%PDF',
    '.txt': None,
}

def validate_file_signature(file_bytes: bytes, extension: str) -> bool:
    """Check magic bytes match the declared extension."""
    expected = MAGIC_BYTES.get(extension)
    if expected is None:
        return True
    if extension in ('.mp3',):
        return file_bytes[:2] == expected or file_bytes[:3] == b'\x49\x44\x33'
    if extension == '.wav':
        return file_bytes[:4] == b'RIFF' and file_bytes[8:12] == b'WAVE'
    if extension == '.webp':
        return file_bytes[:4] == b'RIFF' and file_bytes[8:12] == b'WEBP'
    return file_bytes[:len(expected)] == expected


def validate_mime_from_bytes(file_bytes: bytes, declared_mime: str) -> bool:
    """Approximate MIME check from file signature."""
    if declared_mime.startswith('image/'):
        return any(validate_file_signature(file_bytes, ext) for ext in ('.jpg', '.jpeg', '.png', '.gif', '.webp'))
    if declared_mime.startswith('video/'):
        return any(validate_file_signature(file_bytes, ext) for ext in ('.mp4', '.mov', '.webm'))
    if declared_mime.startswith('audio/'):
        return any(validate_file_signature(file_bytes, ext) for ext in ('.mp3', '.ogg', '.m4a', '.wav'))
    if declared_mime == 'application/pdf':
        return validate_file_signature(file_bytes, '.pdf')
    return True
