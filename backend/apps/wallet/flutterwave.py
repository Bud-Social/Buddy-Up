import requests
import uuid
from django.conf import settings
from dataclasses import dataclass


@dataclass
class FlutterwaveResponse:
    success: bool
    status: str
    message: str
    data: dict | None
    flutterwave_ref: str | None


class FlutterwaveClient:
    BASE_URL = 'https://api.flutterwave.com/v3'

    def __init__(self):
        self.secret_key = settings.FLUTTERWAVE_SECRET_KEY
        self.public_key = settings.FLUTTERWAVE_PUBLIC_KEY
        self.encryption_key = settings.FLUTTERWAVE_ENCRYPTION_KEY
        self.headers = {
            'Authorization': f'Bearer {self.secret_key}',
            'Content-Type': 'application/json',
        }

    def _request(self, method, path, **kwargs):
        url = f'{self.BASE_URL}/{path.lstrip("/")}'
        try:
            res = requests.request(method, url, headers=self.headers, timeout=30, **kwargs)
            data = res.json()
            return FlutterwaveResponse(
                success=data.get('status') == 'success',
                status=data.get('status', 'error'),
                message=data.get('message', ''),
                data=data.get('data'),
                flutterwave_ref=str(data.get('data', {}).get('id', '')),
            )
        except requests.RequestException as e:
            return FlutterwaveResponse(
                success=False, status='error',
                message=str(e), data=None, flutterwave_ref=None,
            )

    def verify_transaction(self, transaction_id: str) -> FlutterwaveResponse:
        return self._request('GET', f'transactions/{transaction_id}/verify')

    def get_banks(self, country: str = 'KE') -> FlutterwaveResponse:
        return self._request('GET', f'banks/{country}')

    def resolve_account(self, account_number: str, bank_code: str) -> FlutterwaveResponse:
        return self._request('POST', 'accounts/resolve', json={
            'account_number': account_number,
            'account_bank': bank_code,
        })

    def create_transfer_recipient(self, bank_code: str, account_number: str, name: str) -> FlutterwaveResponse:
        return self._request('POST', 'transferrecipients', json={
            'type': 'nuban',
            'bank_code': bank_code,
            'account_number': account_number,
            'name': name,
            'currency': 'KES',
        })

    def initiate_transfer(self, recipient_id: str, amount: float, narration: str = '') -> FlutterwaveResponse:
        return self._request('POST', 'transfers', json={
            'account_bank': recipient_id,
            'amount': amount,
            'narration': narration or 'BuddyUp withdrawal',
            'currency': 'KES',
            'reference': f'bw-{uuid.uuid4().hex[:12]}',
        })

    def mpesa_stk_push(self, phone: str, amount: float, tx_ref: str, email: str = '') -> FlutterwaveResponse:
        return self._request('POST', 'charges?type=mpesa', json={
            'tx_ref': tx_ref,
            'amount': amount,
            'currency': 'KES',
            'phone_number': phone,
            'email': email or 'customer@buddyup.app',
        })

    def charge_card(self, card_number: str, cvv: str, expiry_mm: str, expiry_yy: str,
                    amount: float, tx_ref: str, email: str, fullname: str = '') -> FlutterwaveResponse:
        return self._request('POST', 'charges?type=card', json={
            'card_number': card_number,
            'cvv': cvv,
            'expiry_month': expiry_mm,
            'expiry_year': expiry_yy,
            'amount': amount,
            'tx_ref': tx_ref,
            'currency': 'USD',
            'email': email,
            'fullname': fullname,
        })

    def charge_ng_bank(self, account_number: str, bank_code: str, amount: float,
                       tx_ref: str, email: str) -> FlutterwaveResponse:
        return self._request('POST', 'charges?type=bank_transfer', json={
            'tx_ref': tx_ref,
            'amount': amount,
            'currency': 'NGN',
            'email': email,
            'account_bank': bank_code,
            'account_number': account_number,
        })
