from rest_framework import serializers
from .models import ArtifactTransaction


class ArtifactTransactionSerializer(serializers.ModelSerializer):
    counterparty_name = serializers.SerializerMethodField()

    class Meta:
        model = ArtifactTransaction
        fields = [
            'id', 'transaction_type', 'artifact_type', 'quantity',
            'direction', 'counterparty_id', 'counterparty_name',
            'reference_id', 'status', 'fiat_amount', 'fiat_currency',
            'description', 'clearance_at', 'created_at',
        ]

    def get_counterparty_name(self, obj):
        if obj.counterparty:
            return obj.counterparty.display_name
        return None


class TipSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=30)
    artifact_type = serializers.ChoiceField(choices=['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'])
    quantity = serializers.IntegerField(min_value=1, max_value=10000)
    message = serializers.CharField(max_length=200, required=False, allow_blank=True)
    source = serializers.ChoiceField(choices=['regular', 'creator'], default='regular')


class InitializePurchaseSerializer(serializers.Serializer):
    artifact_type = serializers.ChoiceField(choices=['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'])
    quantity = serializers.IntegerField(min_value=1, max_value=100000)
    payment_method = serializers.ChoiceField(choices=['card', 'mpesa', 'bank_transfer'])
    bundle = serializers.CharField(required=False, allow_blank=True)
    mpesa_phone = serializers.CharField(required=False, allow_blank=True)
    card_details = serializers.DictField(required=False, allow_null=True)


class ConfirmPurchaseSerializer(serializers.Serializer):
    tx_ref = serializers.CharField(max_length=100)
    flutterwave_id = serializers.CharField(max_length=100)
    otp = serializers.CharField(required=False, allow_blank=True)


class BankResolveSerializer(serializers.Serializer):
    account_number = serializers.CharField(max_length=20)
    bank_code = serializers.CharField(max_length=10)


class WithdrawSerializer(serializers.Serializer):
    artifact_type = serializers.ChoiceField(choices=['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'])
    quantity = serializers.IntegerField(min_value=1, max_value=100000)
    # Only bank transfer has a real outbound provider integration today.
    method = serializers.ChoiceField(choices=['bank_transfer'])
    phone_number = serializers.CharField(required=False, allow_blank=True)
    bank_account = serializers.CharField(required=False, allow_blank=True)
    bank_code = serializers.CharField(required=False, allow_blank=True)
    bank_name = serializers.CharField(required=False, allow_blank=True)
    account_name = serializers.CharField(required=False, allow_blank=True)


class GiftArtifactsSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=30)
    artifact_type = serializers.ChoiceField(choices=['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'])
    quantity = serializers.IntegerField(min_value=1, max_value=10000)
    message = serializers.CharField(max_length=200, required=False, allow_blank=True)
    source = serializers.ChoiceField(choices=['regular', 'creator'], default='regular')


ARTIFACT_VALUES = {
    'dumbbell': 0.10,
    'barbell': 0.50,
    'burpee': 1.00,
    'squat': 2.50,
    'sprint': 5.00,
    'pr': 10.00,
    'champion': 25.00,
}

ARTIFACT_LABELS = {
    'dumbbell': 'Dumbbell', 'barbell': 'Barbell', 'burpee': 'Burpee',
    'squat': 'Squat', 'sprint': 'Sprint', 'pr': 'PR', 'champion': 'Champion',
}

BUNDLES = {
    'dumbbell_10': {'artifact': 'dumbbell', 'qty': 10, 'price': 0.90},
    'dumbbell_50': {'artifact': 'dumbbell', 'qty': 50, 'price': 4.00},
    'barbell_10': {'artifact': 'barbell', 'qty': 10, 'price': 4.50},
    'burpee_5': {'artifact': 'burpee', 'qty': 5, 'price': 4.50},
    'squat_10': {'artifact': 'squat', 'qty': 10, 'price': 3.50},
    'sprint_10': {'artifact': 'sprint', 'qty': 10, 'price': 5.00},
    'pr_5': {'artifact': 'pr', 'qty': 5, 'price': 10.00},
    'champion_1': {'artifact': 'champion', 'qty': 1, 'price': 25.00},
}

PLATFORM_CUTS = {
    'tip': 0.20,
    'live_fee': 0.20,
    'gym_subscription': 0.20,
    'session_fee': 0.15,
    'marketplace': 0.15,
}
