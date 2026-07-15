import hashlib
import hmac
import urllib.parse
from datetime import datetime, timedelta, timezone
from django.conf import settings


def generate_presigned_url(
    object_key: str,
    expiration_seconds: int = 3600,
    method: str = 'GET',
) -> str | None:
    endpoint = getattr(settings, 'LIVE_RECORDING_S3_ENDPOINT', '')
    bucket = getattr(settings, 'LIVE_RECORDING_S3_BUCKET', '')
    access_key = getattr(settings, 'LIVE_RECORDING_S3_ACCESS_KEY', '')
    secret_key = getattr(settings, 'LIVE_RECORDING_S3_SECRET_KEY', '')

    if not all((endpoint, bucket, access_key, secret_key)):
        return None

    endpoint = endpoint.rstrip('/')
    host = endpoint.replace('http://', '').replace('https://', '')
    use_https = endpoint.startswith('https')

    now = datetime.now(timezone.utc)
    expires = int(now.timestamp()) + expiration_seconds
    date_stamp = now.strftime('%Y%m%d')
    amz_date = now.strftime('%Y%m%dT%H%M%SZ')

    key = object_key.lstrip('/')
    canonical_uri = f'/{bucket}/{key}'
    canonical_querystring = (
        f'X-Amz-Algorithm=AWS4-HMAC-SHA256'
        f'&X-Amz-Credential={urllib.parse.quote(access_key + "/" + date_stamp + "/us-east-1/s3/aws4_request", safe="")}'
        f'&X-Amz-Date={amz_date}'
        f'&X-Amz-Expires={expiration_seconds}'
        f'&X-Amz-SignedHeaders=host'
    )
    canonical_headers = f'host:{host}\n'
    signed_headers = 'host'
    payload_hash = hashlib.sha256(b'').hexdigest()
    canonical_request = (
        f'{method}\n'
        f'{canonical_uri}\n'
        f'{canonical_querystring}\n'
        f'{canonical_headers}\n'
        f'{signed_headers}\n'
        f'{payload_hash}'
    )

    algorithm = 'AWS4-HMAC-SHA256'
    credential_scope = f'{date_stamp}/us-east-1/s3/aws4_request'
    string_to_sign = (
        f'{algorithm}\n'
        f'{amz_date}\n'
        f'{credential_scope}\n'
        f'{hashlib.sha256(canonical_request.encode()).hexdigest()}'
    )

    def _sign(key_bytes, msg):
        return hmac.new(key_bytes, msg.encode(), hashlib.sha256).digest()

    date_key = _sign(('AWS4' + secret_key).encode(), date_stamp)
    region_key = _sign(date_key, 'us-east-1')
    service_key = _sign(region_key, 's3')
    signing_key = _sign(service_key, 'aws4_request')
    signature = hmac.new(signing_key, string_to_sign.encode(), hashlib.sha256).hexdigest()

    scheme = 'https' if use_https else 'http'
    presigned_url = (
        f'{scheme}://{host}{canonical_uri}'
        f'?{canonical_querystring}'
        f'&X-Amz-Signature={signature}'
    )
    return presigned_url
