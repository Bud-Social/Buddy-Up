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
