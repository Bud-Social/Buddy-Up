"""Serializers for the admin portal.

Read serializers are deliberately narrower than the owning apps' public
serializers: they expose operational fields staff need (verification state,
status history, provider refs) while never exposing rosters, message bodies,
participant lists or ledger internals.

Write serializers exist only for the fields staff are allowed to change. The
most important one is :class:`UserAdminUpdateSerializer` — it has no
``is_staff`` / ``is_superuser`` field at all, so the privilege-escalation
surface does not exist in the schema.
"""
from rest_framework import serializers

from apps.accounts.models import User
from apps.gyms.models import Gym
from apps.marketplace.models import (
    DeliveryPersonnel,
    DeliveryPersonnelApplication,
    Order,
    OrderCase,
    PickupStation,
    Product,
    Shop,
    ShopVerificationApplication,
    StationApplication,
)
from apps.messaging.models import Conversation
from apps.profiles.models import Profile
from apps.wallet.models import ArtifactTransaction


def profile_of(user):
    """The staff user's Profile, or None.

    A superuser created through ``createsuperuser`` has no Profile row, so
    anything that wants ``request.user.profile`` (reviewed_by, requester) has
    to tolerate its absence instead of 500-ing.
    """
    return getattr(user, 'profile', None)


def _attr(obj, path):
    """``_attr(shop, 'shop.handle')`` — returns None at the first missing hop.

    Every one of these traversals crosses a nullable FK. DRF's
    ``CharField(source=...)`` stringifies a missing hop as the literal
    ``"None"``, so nullable paths go through here instead.
    """
    current = obj
    for part in path.split('.'):
        if current is None:
            return None
        current = getattr(current, part, None)
    return current


# ---------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------

class PortalUserSerializer(serializers.ModelSerializer):
    username = serializers.SerializerMethodField()
    display_name = serializers.SerializerMethodField()
    role = serializers.SerializerMethodField()
    verification_status = serializers.SerializerMethodField()
    location_city = serializers.SerializerMethodField()
    order_count = serializers.IntegerField(read_only=True, default=0)
    has_buddy_search = serializers.BooleanField(read_only=True, default=False)

    class Meta:
        model = User
        # is_staff / is_superuser are readable (staff need to see who holds
        # admin) but are NOT writable anywhere in this app.
        fields = [
            'id', 'email', 'phone', 'phone_verified', 'email_verified',
            'username', 'display_name', 'role', 'verification_status',
            'location_city', 'is_active', 'is_staff', 'is_superuser',
            'is_adult', 'totp_enabled', 'deleted_at', 'order_count',
            'has_buddy_search', 'created_at', 'last_login',
        ]

    def get_username(self, obj):
        return _attr(profile_of(obj), 'username')

    def get_display_name(self, obj):
        return _attr(profile_of(obj), 'display_name')

    def get_role(self, obj):
        return _attr(profile_of(obj), 'role')

    def get_verification_status(self, obj):
        return _attr(profile_of(obj), 'verification_status')

    def get_location_city(self, obj):
        return _attr(profile_of(obj), 'location_city') or ''


class UserAdminUpdateSerializer(serializers.Serializer):
    """The only writable surface on a user.

    Every field here maps to something a moderator legitimately owns:
    account liveness, the public trainer/practitioner label, and the
    verification badge. Privilege fields (``is_staff``, ``is_superuser``) are
    intentionally absent — the view rejects them outright rather than ignoring
    them, so a caller is never misled into thinking a privilege change stuck.
    """

    is_active = serializers.BooleanField(required=False)
    role = serializers.ChoiceField(
        choices=Profile.ROLE_CHOICES, required=False,
        help_text='Public trainer/practitioner label. Unrelated to admin rights.',
    )
    verification_status = serializers.ChoiceField(
        choices=Profile.VERIFICATION_CHOICES, required=False,
    )

    def validate(self, attrs):
        if not attrs:
            raise serializers.ValidationError(
                'Nothing to update. Provide is_active, role and/or verification_status.'
            )
        return attrs


# ---------------------------------------------------------------------------
# Shops & products
# ---------------------------------------------------------------------------

class PortalShopSerializer(serializers.ModelSerializer):
    # product_count / member_count / owner_count are annotated in
    # admin_portal.views._shop_queryset so the list stays at one query.
    product_count = serializers.IntegerField(read_only=True, default=0)
    member_count = serializers.IntegerField(read_only=True, default=0)
    owner_count = serializers.IntegerField(read_only=True, default=0)

    class Meta:
        model = Shop
        fields = [
            'id', 'name', 'handle', 'category', 'is_active',
            'verification_status', 'rejection_reason', 'verification_applied_at',
            'verified_at', 'contact_email', 'product_count', 'member_count',
            'owner_count', 'created_at', 'updated_at',
        ]


class ShopAdminUpdateSerializer(serializers.Serializer):
    is_active = serializers.BooleanField(required=False)
    verification_status = serializers.ChoiceField(choices=Shop.VERIFICATION_STATUS, required=False)
    rejection_reason = serializers.CharField(required=False, allow_blank=True)

    def validate(self, attrs):
        if not attrs:
            raise serializers.ValidationError(
                'Nothing to update. Provide is_active, verification_status and/or rejection_reason.'
            )
        if attrs.get('verification_status') == 'rejected' and not attrs.get('rejection_reason'):
            raise serializers.ValidationError(
                {'rejection_reason': 'A reason is required when rejecting a shop.'}
            )
        return attrs


class PortalProductSerializer(serializers.ModelSerializer):
    shop_handle = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'brand', 'category', 'is_active', 'shop',
            'shop_handle', 'price_display', 'stock_quantity',
            'stock_tracking_enabled', 'click_count', 'content_rating',
            'supplement_registration_number', 'supplement_registration_expiry',
            'supplement_claims_reviewed', 'created_at',
        ]

    def get_shop_handle(self, obj):
        return _attr(obj, 'shop.handle')


class PortalShopCertificationSerializer(serializers.ModelSerializer):
    """Review queue row. Mirrors ``apps.marketplace``'s own field names."""

    shop_handle = serializers.SerializerMethodField()
    shop_name = serializers.SerializerMethodField()
    submitted_by_username = serializers.SerializerMethodField()
    reviewed_by_username = serializers.SerializerMethodField()

    class Meta:
        model = ShopVerificationApplication
        fields = [
            'id', 'shop', 'shop_handle', 'shop_name', 'status', 'service_type',
            'legal_name', 'business_registration_number', 'country', 'phone',
            'id_document_url', 'professional_cert_url', 'website_url',
            'years_of_experience', 'specializations', 'bio_statement',
            'agreed_to_creator_policy', 'submitted_by_username',
            'reviewer_notes', 'rejection_reason', 'reviewed_by_username',
            'reviewed_at', 'created_at',
        ]

    def get_shop_handle(self, obj):
        return _attr(obj, 'shop.handle')

    def get_shop_name(self, obj):
        return _attr(obj, 'shop.name')

    def get_submitted_by_username(self, obj):
        return _attr(obj, 'submitted_by.username')

    def get_reviewed_by_username(self, obj):
        return _attr(obj, 'reviewed_by.username')


class ShopCertificationReviewSerializer(serializers.Serializer):
    """Approve / reject / request-more-info. Mirrors marketplace/views.py:466."""

    status = serializers.ChoiceField(choices=ShopVerificationApplication.STATUS_CHOICES)
    reviewer_notes = serializers.CharField(required=False, allow_blank=True)
    rejection_reason = serializers.CharField(required=False, allow_blank=True)

    def validate(self, attrs):
        if attrs.get('status') == 'rejected' and not attrs.get('rejection_reason'):
            raise serializers.ValidationError(
                {'rejection_reason': 'A reason is required when rejecting an application.'}
            )
        return attrs


# ---------------------------------------------------------------------------
# Orders
# ---------------------------------------------------------------------------

class PortalOrderItemSerializer(serializers.Serializer):
    id = serializers.UUIDField(read_only=True)
    item_type = serializers.CharField(read_only=True)
    title = serializers.CharField(read_only=True)
    quantity = serializers.IntegerField(read_only=True)
    fulfillment_status = serializers.CharField(read_only=True)
    creator_username = serializers.SerializerMethodField()
    creator_display_name = serializers.SerializerMethodField()

    def get_creator_username(self, obj):
        return _attr(obj, 'creator.username')

    def get_creator_display_name(self, obj):
        return _attr(obj, 'creator.display_name')


class PortalOrderSerializer(serializers.ModelSerializer):
    items = PortalOrderItemSerializer(many=True, read_only=True)
    buyer_username = serializers.SerializerMethodField()
    buyer_display_name = serializers.SerializerMethodField()
    buyer_email = serializers.SerializerMethodField()
    status_label = serializers.SerializerMethodField()
    allowed_next_statuses = serializers.SerializerMethodField()
    cases = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = [
            'id', 'order_number', 'status', 'status_label', 'allowed_next_statuses',
            'fulfillment_type', 'payment_method', 'payment_status',
            'payment_reference', 'payment_provider', 'buyer_username',
            'buyer_display_name', 'buyer_email', 'delivery_address',
            'pickup_details', 'pickup_station', 'delivery_personnel',
            'items', 'items_total_artifacts', 'discount_artifacts',
            'total_artifacts', 'spent_usd', 'status_history', 'cases',
            'paid_at', 'created_at', 'updated_at',
        ]

    def get_buyer_username(self, obj):
        return _attr(obj, 'buyer.username')

    def get_buyer_display_name(self, obj):
        return _attr(obj, 'buyer.display_name')

    def get_buyer_email(self, obj):
        return _attr(obj, 'buyer.user.email')

    def get_status_label(self, obj):
        return dict(Order.STATUS_CHOICES).get(obj.status, obj.status)

    def get_allowed_next_statuses(self, obj):
        """From ORDER_FORWARD_STATES — lets a client render only valid buttons."""
        from apps.marketplace.views import ORDER_FORWARD_STATES
        return ORDER_FORWARD_STATES.get(obj.status, [])

    def get_cases(self, obj):
        return PortalOrderCaseSerializer(obj.cases.all(), many=True).data


class OrderStatusChangeSerializer(serializers.Serializer):
    """Force a status change. Transition legality is checked in the view
    against ``ORDER_FORWARD_STATES`` so the error can name both ends."""

    status = serializers.CharField()
    note = serializers.CharField(required=False, allow_blank=True, default='')

    def validate_status(self, value):
        valid = [c[0] for c in Order.STATUS_CHOICES]
        if value not in valid:
            raise serializers.ValidationError(
                f'Unknown status {value!r}. Must be one of: {valid}.'
            )
        return value


class OrderNoteSerializer(serializers.Serializer):
    note = serializers.CharField()


class PortalOrderCaseSerializer(serializers.ModelSerializer):
    requester_username = serializers.SerializerMethodField()
    order_number = serializers.SerializerMethodField()
    affects_ledger = serializers.SerializerMethodField()

    class Meta:
        model = OrderCase
        fields = [
            'id', 'order', 'order_number', 'case_type', 'status', 'reason',
            'evidence', 'resolution', 'resolved_at', 'requester_username',
            'affects_ledger', 'created_at', 'updated_at',
        ]
        read_only_fields = ['order', 'requester', 'resolved_at']

    def get_requester_username(self, obj):
        return _attr(obj, 'requester.username')

    def get_order_number(self, obj):
        return _attr(obj, 'order.order_number')

    def get_affects_ledger(self, obj):
        """Always False, stated explicitly.

        Approving a case is a bookkeeping decision. Nothing in the platform
        moves money or artifacts as a result, and this endpoint never will —
        a refund has to run through the ledger's own posting path.
        """
        return False


class OrderCaseCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderCase
        fields = ['case_type', 'reason', 'evidence']


class OrderCaseUpdateSerializer(serializers.Serializer):
    """Move a case along. Explicitly does NOT touch the ledger."""

    status = serializers.ChoiceField(choices=OrderCase.STATUS_CHOICES)
    resolution = serializers.CharField(required=False, allow_blank=True)


# ---------------------------------------------------------------------------
# Gyms
# ---------------------------------------------------------------------------

class PortalGymSerializer(serializers.ModelSerializer):
    """Gym has no ``is_active`` column — liveness is SoftDeleteModel's
    ``is_deleted``, and that is what this exposes.

    ``member_count`` is the denormalised integer on the row. Gym memberships
    (the roster itself) are never serialised here — see apps.gyms' own member
    endpoints for that.
    """

    class Meta:
        model = Gym
        fields = [
            'id', 'name', 'handle', 'category', 'access_type',
            'subscription_type', 'is_verified', 'is_deleted', 'deleted_at',
            'member_count', 'location_city', 'location_country', 'created_at',
        ]


class GymAdminUpdateSerializer(serializers.Serializer):
    is_verified = serializers.BooleanField(required=False)
    access_type = serializers.ChoiceField(choices=Gym.ACCESS_CHOICES, required=False)
    is_deleted = serializers.BooleanField(
        required=False,
        help_text="Gym has no is_active column; liveness is SoftDeleteModel's is_deleted.",
    )

    def validate(self, attrs):
        if not attrs:
            raise serializers.ValidationError(
                'Nothing to update. Provide is_verified, access_type and/or is_deleted.'
            )
        return attrs


# ---------------------------------------------------------------------------
# Communities
# ---------------------------------------------------------------------------

class PortalCommunitySerializer(serializers.ModelSerializer):
    """A Conversation row for staff triage, including private communities.

    ``member_count`` is a COUNT, never the roster. ``participants`` and
    ``participants_data`` are not part of this serializer at all, so neither
    can leak from here.
    """

    member_count = serializers.IntegerField(read_only=True, default=0)
    post_count = serializers.SerializerMethodField()
    created_by_username = serializers.SerializerMethodField()
    gym_handle = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = [
            'id', 'group_name', 'is_group', 'is_community', 'is_public',
            'origin', 'invite_code', 'description', 'gym_handle',
            'created_by_username', 'member_count', 'post_count',
            'last_message_at', 'created_at',
        ]

    def get_post_count(self, obj):
        return getattr(obj, 'post_count', None) or 0

    def get_created_by_username(self, obj):
        return _attr(obj, 'created_by.username')

    def get_gym_handle(self, obj):
        return _attr(obj, 'group_gym.handle')


# ---------------------------------------------------------------------------
# Pickup stations & delivery personnel
# ---------------------------------------------------------------------------

class PortalPickupStationSerializer(serializers.ModelSerializer):
    owner_name = serializers.SerializerMethodField()

    class Meta:
        model = PickupStation
        fields = [
            'id', 'name', 'description', 'address', 'city', 'country',
            'owner_type', 'owner_name', 'shop', 'gym', 'is_active',
            'is_primary', 'phone', 'opening_hours', 'latitude', 'longitude',
            'created_at',
        ]

    def get_owner_name(self, obj):
        if obj.shop_id:
            return obj.shop.name
        if obj.gym_id:
            return obj.gym.name
        return None


class PickupStationAdminUpdateSerializer(serializers.Serializer):
    is_active = serializers.BooleanField(required=False)
    is_primary = serializers.BooleanField(required=False)

    def validate(self, attrs):
        if not attrs:
            raise serializers.ValidationError('Nothing to update.')
        return attrs


class DeliveryPersonnelActiveUpdateSerializer(serializers.Serializer):
    """Only liveness. A courier's rating and zones are earned, not typed in."""

    is_active = serializers.BooleanField()


class PortalStationApplicationSerializer(serializers.ModelSerializer):
    shop_handle = serializers.SerializerMethodField()
    gym_handle = serializers.SerializerMethodField()
    submitted_by_username = serializers.SerializerMethodField()
    reviewed_by_username = serializers.SerializerMethodField()

    class Meta:
        model = StationApplication
        fields = [
            'id', 'shop', 'shop_handle', 'gym', 'gym_handle', 'status',
            'business_registration_number', 'contact_phone', 'address', 'city',
            'country', 'latitude', 'longitude', 'opening_hours', 'documents',
            'agreed_to_policy', 'submitted_by_username', 'reviewer_notes',
            'rejection_reason', 'reviewed_by_username', 'reviewed_at',
            'created_at',
        ]

    def get_shop_handle(self, obj):
        return _attr(obj, 'shop.handle')

    def get_gym_handle(self, obj):
        return _attr(obj, 'gym.handle')

    def get_submitted_by_username(self, obj):
        return _attr(obj, 'submitted_by.username')

    def get_reviewed_by_username(self, obj):
        return _attr(obj, 'reviewed_by.username')


class PortalDeliveryPersonnelSerializer(serializers.ModelSerializer):
    username = serializers.SerializerMethodField()
    display_name = serializers.SerializerMethodField()
    email = serializers.SerializerMethodField()
    active_order_count = serializers.SerializerMethodField()

    class Meta:
        model = DeliveryPersonnel
        fields = [
            'id', 'username', 'display_name', 'email', 'vehicle_type',
            'service_zones', 'is_active', 'rating', 'bio',
            'active_order_count', 'created_at',
        ]

    def get_username(self, obj):
        return _attr(obj, 'profile.username')

    def get_display_name(self, obj):
        return _attr(obj, 'profile.display_name')

    def get_email(self, obj):
        return _attr(obj, 'profile.user.email')

    def get_active_order_count(self, obj):
        # A count of in-flight orders, not the orders themselves.
        return obj.orders.exclude(
            status__in=('delivered', 'completed', 'cancelled'),
        ).count()


class PortalDeliveryPersonnelApplicationSerializer(serializers.ModelSerializer):
    username = serializers.SerializerMethodField()
    display_name = serializers.SerializerMethodField()
    reviewed_by_username = serializers.SerializerMethodField()

    class Meta:
        model = DeliveryPersonnelApplication
        fields = [
            'id', 'profile', 'username', 'display_name', 'vehicle_type',
            'service_zones', 'id_document_url', 'licence_document_url',
            'phone', 'bio', 'status', 'reviewer_notes', 'rejection_reason',
            'reviewed_by_username', 'reviewed_at', 'created_at',
        ]

    def get_username(self, obj):
        return _attr(obj, 'profile.username')

    def get_display_name(self, obj):
        return _attr(obj, 'profile.display_name')

    def get_reviewed_by_username(self, obj):
        return _attr(obj, 'reviewed_by.username')


class ApplicationReviewSerializer(serializers.Serializer):
    """Shared approve/reject body for the two application queues.

    Both models point at ``APPLICATION_STATUS_CHOICES``, deliberately identical,
    so one serializer covers both.
    """

    status = serializers.ChoiceField(choices=StationApplication.STATUS_CHOICES)
    reviewer_notes = serializers.CharField(required=False, allow_blank=True)
    rejection_reason = serializers.CharField(required=False, allow_blank=True)

    def validate(self, attrs):
        if attrs.get('status') == 'rejected' and not attrs.get('rejection_reason'):
            raise serializers.ValidationError(
                {'rejection_reason': 'A reason is required when rejecting an application.'}
            )
        return attrs


# ---------------------------------------------------------------------------
# Wallet — read only, forever
# ---------------------------------------------------------------------------

class PortalTransactionSerializer(serializers.ModelSerializer):
    """Read-only. There is deliberately no write serializer for the ledger.

    Mirrors wallet/admin.py's posture: a transaction row is evidence that a
    balance movement already happened. Corrections go through the ledger's
    posting path, never through an admin PATCH.
    """

    user_username = serializers.SerializerMethodField()
    user_email = serializers.SerializerMethodField()
    counterparty_username = serializers.SerializerMethodField()

    class Meta:
        model = ArtifactTransaction
        fields = [
            'id', 'tx_ref', 'transaction_type', 'direction', 'status',
            'artifact_type', 'quantity', 'user_username', 'user_email',
            'counterparty_username', 'reference_id', 'fiat_amount',
            'fiat_currency', 'payment_provider', 'flutterwave_id',
            'phone_number', 'bank_account', 'description', 'journal_entry',
            'clearance_at', 'created_at',
        ]

    def get_user_username(self, obj):
        return _attr(obj, 'user.username')

    def get_user_email(self, obj):
        return _attr(obj, 'user.user.email')

    def get_counterparty_username(self, obj):
        return _attr(obj, 'counterparty.username')
