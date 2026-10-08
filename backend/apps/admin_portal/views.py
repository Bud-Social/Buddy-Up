"""Staff-only read/act endpoints, one section per domain.

Conventions, all deliberate:

* Every view is ``IsPlatformAdmin`` (or ``ScopedPlatformAdmin.for_scope(...)``,
  which authorises identically and only records the domain).
* Every list is paginated with ``common.pagination.PageNumberPagination`` and
  returns the repo envelope ``{success, data, message, errors, pagination}``.
* Filters are explicit query params with validated values. An unknown value is a
  400 naming the allowed set — never a silently empty list, which reads as
  "no data" when it actually means "you typo'd".
* Nothing here deletes a row, and nothing here writes the wallet ledger. A
  refund request is recorded as an ``OrderCase`` and stopped there.
"""
from datetime import datetime, time as dt_time, timezone as dt_tz
import uuid

from django.db.models import Count, Exists, OuterRef, Q
from django.shortcuts import get_object_or_404
from django.utils import timezone
from django.utils.dateparse import parse_date, parse_datetime
from rest_framework import status, views
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response

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
from apps.marketplace.views import _apply_fulfillment_status, allowed_order_transitions
from apps.messaging.models import Conversation
from apps.notifications.tasks import create_notification
from apps.profiles.models import BuddySearchProfile
from apps.wallet.models import ArtifactTransaction

from common.pagination import PageNumberPagination

from .permissions import IsPlatformAdmin, ScopedPlatformAdmin
from .serializers import (
    ApplicationReviewSerializer,
    DeliveryPersonnelActiveUpdateSerializer,
    GymAdminUpdateSerializer,
    OrderCaseCreateSerializer,
    OrderCaseUpdateSerializer,
    OrderNoteSerializer,
    OrderStatusChangeSerializer,
    PickupStationAdminUpdateSerializer,
    PortalCommunitySerializer,
    PortalDeliveryPersonnelApplicationSerializer,
    PortalDeliveryPersonnelSerializer,
    PortalGymSerializer,
    PortalOrderCaseSerializer,
    PortalOrderSerializer,
    PortalPickupStationSerializer,
    PortalProductSerializer,
    PortalShopCertificationSerializer,
    PortalShopSerializer,
    PortalStationApplicationSerializer,
    PortalTransactionSerializer,
    PortalUserSerializer,
    ShopAdminUpdateSerializer,
    ShopCertificationReviewSerializer,
    UserAdminUpdateSerializer,
    profile_of,
)

# ---------------------------------------------------------------------------
# Shared plumbing
# ---------------------------------------------------------------------------

TRUE_VALUES = {'true', '1', 'yes', 'on'}
FALSE_VALUES = {'false', '0', 'no', 'off'}

# Admin privilege is modelled solely by Django's is_staff / is_superuser. No
# endpoint in this app may write them — a moderator must not be able to mint a
# superuser, and a compromised staff session must not be able to demote one.
PRIVILEGE_FIELDS = ('is_staff', 'is_superuser', 'groups', 'user_permissions')


def _params(request):
    return request.query_params


def filter_text(request, queryset, fields, param='search'):
    """icontains across ``fields`` — the repo's ad-hoc search convention."""
    term = (_params(request).get(param) or '').strip()
    if not term:
        return queryset
    condition = Q()
    for field in fields:
        condition |= Q(**{f'{field}__icontains': term})
    return queryset.filter(condition)


def filter_choice(request, queryset, param, choices, field=None, exact=False):
    """Filter on a model ``choices`` list. Comma-separated. Validated."""
    raw = (_params(request).get(param) or '').strip()
    if not raw:
        return queryset
    valid = [c[0] for c in choices]
    values = [v for v in (s.strip() for s in raw.split(',')) if v]
    unknown = [v for v in values if v not in valid]
    if unknown:
        raise ValidationError(
            f'Unknown {param}: {", ".join(sorted(unknown))}. Must be one of: {valid}.'
        )
    lookup = 'exact' if exact else 'in'
    return queryset.filter(**{f'{field or param}__{lookup}': values})


def filter_bool(request, queryset, param, field=None):
    value = parse_bool(_params(request).get(param), param)
    if value is None:
        return queryset
    return queryset.filter(**{field or param: value})


def parse_bool(raw, param):
    if raw is None or raw == '':
        return None
    value = str(raw).strip().lower()
    if value in TRUE_VALUES:
        return True
    if value in FALSE_VALUES:
        return False
    raise ValidationError(f'Invalid boolean for {param}: {raw!r}. Use true/false.')


def _day_start(day):
    return datetime.combine(day, dt_time.min, tzinfo=dt_tz.utc)


def _as_uuid(value):
    """Parse a UUID, or None. Lets a slug-or-id param accept both without a 500."""
    try:
        return uuid.UUID(str(value))
    except (AttributeError, TypeError, ValueError):
        return None


def _day_end(day):
    return datetime.combine(day, dt_time.max, tzinfo=dt_tz.utc)


def _parse_bound(raw, param, end_of_day):
    raw = raw.strip()
    parsed = parse_datetime(raw)
    if parsed is None:
        day = parse_date(raw)
        if day is None:
            raise ValidationError(
                f'Invalid date for {param}: {raw!r}. Use YYYY-MM-DD or an ISO timestamp.'
            )
        return _day_end(day) if end_of_day else _day_start(day)
    if timezone.is_naive(parsed):
        parsed = timezone.make_aware(parsed, dt_tz.utc)
    return parsed


def filter_date_range(request, queryset, field='created_at', start_param='date_from',
                      end_param='date_to'):
    """Inclusive ``date_from`` / ``date_to`` on ``field``. Dates or ISO stamps."""
    raw_from = _params(request).get(start_param)
    if raw_from and raw_from.strip():
        queryset = queryset.filter(**{f'{field}__gte': _parse_bound(raw_from, start_param, False)})
    raw_to = _params(request).get(end_param)
    if raw_to and raw_to.strip():
        queryset = queryset.filter(**{f'{field}__lte': _parse_bound(raw_to, end_param, True)})
    return queryset


class PortalView(views.APIView):
    """Envelope + pagination helpers for every endpoint in this app."""

    permission_classes = [IsPlatformAdmin]

    @staticmethod
    def ok(data=None, message='OK', status_code=status.HTTP_200_OK, pagination=None):
        return Response(
            {
                'success': True,
                'data': data,
                'message': message,
                'errors': None,
                'pagination': pagination,
            },
            status=status_code,
        )

    @staticmethod
    def fail(message, status_code=status.HTTP_400_BAD_REQUEST, errors=None):
        return Response(
            {
                'success': False,
                'data': None,
                'message': message,
                'errors': errors,
                'pagination': None,
            },
            status=status_code,
        )

    def paginate(self, request, queryset, serializer_class, **serializer_kwargs):
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(queryset, request)
        data = serializer_class(page, many=True, **serializer_kwargs).data
        return self.ok(data, pagination={
            'count': paginator.page.paginator.count,
            'next': paginator.get_next_link(),
            'previous': paginator.get_previous_link(),
        })

    @staticmethod
    def reject_privilege_change(request):
        """Refuse, loudly, any attempt to write admin privileges through here.

        Returns a 400 Response when a privilege field is present, else None.
        A silent ignore would tell the caller the change stuck.
        """
        payload = request.data if isinstance(request.data, dict) else {}
        present = sorted({field for field in PRIVILEGE_FIELDS if field in payload})
        if not present:
            return None
        return PortalView.fail(
            'Refusing to change admin privileges '
            f'({", ".join(present)}) through the admin portal. Admin rights are granted '
            'outside this API — manage them with a superuser session in Django admin or '
            'a management command, so the change is auditable.',
            status_code=status.HTTP_400_BAD_REQUEST,
            errors={field: ['Not writable through the admin portal.'] for field in present},
        )


# ---------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------

def _user_queryset():
    return (
        User.objects
        .select_related('profile')
        .annotate(
            order_count=Count('profile__orders', distinct=True),
            has_buddy_search=Exists(
                BuddySearchProfile.objects.filter(profile_id=OuterRef('pk'))
            ),
        )
    )


def _filtered_users(request):
    qs = _user_queryset()
    qs = filter_text(request, qs, ['email', 'profile__username'])
    qs = filter_choice(request, qs, 'role', [
        ('user', 'Regular User'), ('trainer', 'Personal Trainer'),
        ('practitioner', 'Health Practitioner'),
    ], field='profile__role')
    qs = filter_choice(request, qs, 'verification_status', [
        ('none', 'None'), ('email', 'Email Verified'), ('id', 'ID Verified'),
        ('trainer', 'Certified Trainer'), ('practitioner', 'Health Practitioner'),
        ('shop', 'Verified Shop'), ('gym', 'Verified Gym'),
    ], field='profile__verification_status')
    qs = filter_bool(request, qs, 'is_active')
    has_search = parse_bool(_params(request).get('has_search_profile'), 'has_search_profile')
    if has_search is not None:
        qs = qs.filter(has_buddy_search=has_search)
    return qs.order_by('-created_at')


class UserListView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]
    serializer_class = PortalUserSerializer

    def get(self, request):
        return self.paginate(request, _filtered_users(request), PortalUserSerializer)


class UserDetailView(PortalView):
    """Read one user, or update the three fields staff own.

    GET and PATCH live on the same class because Django resolves a path once:
    registering two views on the same pattern would leave the second unreachable.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users')]
    serializer_class = PortalUserSerializer

    def get(self, request, user_id):
        user = get_object_or_404(_user_queryset(), pk=user_id)
        return self.ok(PortalUserSerializer(user).data)

    def patch(self, request, user_id):
        view = self
        rejection = self.reject_privilege_change(request)
        if rejection is not None:
            return rejection

        user = get_object_or_404(User, pk=user_id)
        serializer = UserAdminUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        profile = profile_of(user)
        if profile is None and ({'role', 'verification_status'} & set(data)):
            return self.fail(
                'This account has no profile row, so role and verification_status cannot '
                'be set. Fix the account provisioning first.',
                status_code=status.HTTP_409_CONFLICT,
            )

        # accounts.User has no updated_at (TimestampedModel is on Profile), so
        # user and profile are saved separately with their own field lists.
        user_fields = []
        if 'is_active' in data:
            # Guard: only a superuser may switch another admin's account off/on.
            if user.pk != request.user.pk and (user.is_staff or user.is_superuser) \
                    and not request.user.is_superuser:
                return self.fail(
                    'Only a superuser may change the active flag on another staff account.',
                    status_code=status.HTTP_403_FORBIDDEN,
                )
            user.is_active = data['is_active']
            user_fields.append('is_active')

        profile_fields = []
        if profile is not None:
            if 'role' in data:
                profile.role = data['role']
                profile_fields.append('role')
            if 'verification_status' in data:
                profile.verification_status = data['verification_status']
                profile_fields.append('verification_status')

        if user_fields:
            user.save(update_fields=user_fields)
        if profile_fields:
            profile.save(update_fields=profile_fields + ['updated_at'])

        changed = user_fields + profile_fields
        user.refresh_from_db()
        return view.ok(PortalUserSerializer(user).data,
                       message=f'Updated {", ".join(changed)}.')


def _liveness_error(request, user, is_active):
    """Guard rails shared by suspend / reinstate. Returns a Response or None."""
    verb = 'suspend' if not is_active else 'reinstate'
    if user.pk == request.user.pk:
        return PortalView.fail(
            f'You cannot {verb} your own account from the admin portal.',
            status_code=status.HTTP_400_BAD_REQUEST,
        )
    if (user.is_staff or user.is_superuser) and not request.user.is_superuser:
        return PortalView.fail(
            f'Only a superuser may {verb} another staff account.',
            status_code=status.HTTP_403_FORBIDDEN,
        )
    if user.is_active == is_active:
        return PortalView.fail(
            f'Account is already {"suspended" if not is_active else "active"}.',
            status_code=status.HTTP_400_BAD_REQUEST,
        )
    return None


class UserSuspendView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('users.write')]
    serializer_class = PortalUserSerializer

    def post(self, request, user_id):
        user = get_object_or_404(User, pk=user_id)
        error = _liveness_error(request, user, is_active=False)
        if error is not None:
            return error
        user.is_active = False
        user.save(update_fields=['is_active'])
        return self.ok(PortalUserSerializer(user).data, message='Account suspended.')


class UserReinstateView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('users.write')]
    serializer_class = PortalUserSerializer

    def post(self, request, user_id):
        user = get_object_or_404(User, pk=user_id)
        error = _liveness_error(request, user, is_active=True)
        if error is not None:
            return error
        user.is_active = True
        user.save(update_fields=['is_active'])
        return self.ok(PortalUserSerializer(user).data, message='Account reinstated.')


# ---------------------------------------------------------------------------
# Shops & products
# ---------------------------------------------------------------------------

def _shop_queryset():
    return Shop.objects.annotate(
        product_count=Count('products', distinct=True),
        member_count=Count('memberships', distinct=True),
        owner_count=Count('memberships', filter=Q(memberships__role='owner'), distinct=True),
    )


def _filtered_shops(request):
    qs = _shop_queryset()
    qs = filter_text(request, qs, ['name', 'handle'])
    qs = filter_choice(request, qs, 'verification_status', Shop.VERIFICATION_STATUS)
    qs = filter_choice(request, qs, 'category', Shop.CATEGORY_CHOICES)
    qs = filter_bool(request, qs, 'is_active')
    handle = (_params(request).get('handle') or '').strip()
    if handle:
        qs = qs.filter(handle__iexact=handle)
    return qs.order_by('-created_at')


class ShopListView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('shops.read')]
    serializer_class = PortalShopSerializer

    def get(self, request):
        return self.paginate(request, _filtered_shops(request), PortalShopSerializer)


class ShopDetailView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('shops')]
    serializer_class = PortalShopSerializer

    def get(self, request, handle):
        shop = get_object_or_404(_shop_queryset(), handle__iexact=handle)
        return self.ok(PortalShopSerializer(shop).data)

    def patch(self, request, handle):
        shop = get_object_or_404(Shop, handle__iexact=handle)
        serializer = ShopAdminUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        fields = []
        if 'is_active' in data:
            shop.is_active = data['is_active']
            fields.append('is_active')
        if 'rejection_reason' in data:
            shop.rejection_reason = data['rejection_reason']
            fields.append('rejection_reason')
        if 'verification_status' in data:
            shop.verification_status = data['verification_status']
            fields.append('verification_status')
            if data['verification_status'] == 'verified':
                shop.verified_at = shop.verified_at or timezone.now()
                fields.append('verified_at')
        if fields:
            shop.save(update_fields=fields + ['updated_at'])

        shop.refresh_from_db()
        return self.ok(PortalShopSerializer(shop).data,
                       message=f'Shop updated ({", ".join(fields)}).')


class ProductListView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('shops.read')]
    serializer_class = PortalProductSerializer

    def get(self, request):
        qs = Product.objects.select_related('shop')
        qs = filter_text(request, qs, ['name', 'brand'])
        qs = filter_choice(request, qs, 'category', Product.CATEGORIES)
        qs = filter_bool(request, qs, 'is_active')
        shop = (_params(request).get('shop') or '').strip()
        if shop:
            # Accept either a shop handle or its UUID.
            shop_id = _as_uuid(shop)
            if shop_id is None:
                qs = qs.filter(shop__handle__iexact=shop)
            else:
                qs = qs.filter(Q(shop__handle__iexact=shop) | Q(shop_id=shop_id))
        qs = qs.order_by('-created_at')
        return self.paginate(request, qs, PortalProductSerializer)


# ---------------------------------------------------------------------------
# Shop certification review queue
# ---------------------------------------------------------------------------

def _filtered_certifications(request):
    qs = ShopVerificationApplication.objects.select_related('shop', 'submitted_by', 'reviewed_by')
    qs = filter_choice(request, qs, 'status', ShopVerificationApplication.STATUS_CHOICES)
    qs = filter_choice(request, qs, 'service_type',
                       ShopVerificationApplication.SERVICE_TYPE_CHOICES)
    qs = filter_text(request, qs, ['legal_name', 'business_registration_number', 'shop__name'])
    handle = (_params(request).get('handle') or '').strip()
    if handle:
        qs = qs.filter(shop__handle__iexact=handle)
    return qs.order_by('created_at')  # oldest first: the queue is FIFO


CERT_STATUS_COPY = {
    'approved': ('Buddy Up Certified', 'Your certification application was approved.'),
    'rejected': ('Application Rejected', 'Your certification application was not approved.'),
    'more_info_needed': ('More Info Needed',
                         'We need more information before we can review your application.'),
    'under_review': ('Application Under Review',
                     'Your certification application is being reviewed.'),
    'submitted': ('Application Received', 'Your certification application is in the queue.'),
    'draft': ('Application Draft', 'Your certification application is a draft.'),
}


class ShopCertificationQueueView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('shops.certifications.read')]
    serializer_class = PortalShopCertificationSerializer

    def get(self, request):
        return self.paginate(request, _filtered_certifications(request),
                             PortalShopCertificationSerializer)


class ShopCertificationDetailView(PortalView):
    """Read one application, or review it.

    Approve / reject mirrors the semantics of the existing staff-only PATCH at
    marketplace/views.py:466 — same status vocabulary, same reviewer fields, same
    mirroring onto ``Shop.verification_status`` — but keyed on the application id
    instead of "the latest one for a handle", so a queue can be worked through.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('shops.certifications')]
    serializer_class = PortalShopCertificationSerializer

    def get(self, request, application_id):
        app = get_object_or_404(
            ShopVerificationApplication.objects.select_related('shop', 'submitted_by', 'reviewed_by'),
            pk=application_id,
        )
        return self.ok(PortalShopCertificationSerializer(app).data)

    def patch(self, request, application_id):
        app = get_object_or_404(
            ShopVerificationApplication.objects.select_related('shop'),
            pk=application_id,
        )
        serializer = ShopCertificationReviewSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        new_status = data['status']

        app.status = new_status
        if 'reviewer_notes' in data:
            app.reviewer_notes = data['reviewer_notes']
        if 'rejection_reason' in data:
            app.rejection_reason = data['rejection_reason']
        app.reviewed_by = profile_of(request.user)
        app.reviewed_at = timezone.now()
        app.save()

        # Mirror onto the shop, exactly as marketplace/views.py:466 does.
        shop = app.shop
        shop_fields = ['verification_status']
        if new_status == 'approved':
            shop.verification_status = 'verified'
            shop.verified_at = timezone.now()
            shop_fields.append('verified_at')
        elif new_status == 'rejected':
            shop.verification_status = 'rejected'
            shop.rejection_reason = app.rejection_reason
            shop_fields.append('rejection_reason')
        else:
            shop.verification_status = 'pending'
        shop.save(update_fields=shop_fields + ['updated_at'])

        title, body = CERT_STATUS_COPY.get(new_status, ('Certification Update', 'Status updated.'))
        if new_status == 'rejected' and app.rejection_reason:
            body = f'{body} Reason: {app.rejection_reason}'
        elif new_status == 'more_info_needed' and app.reviewer_notes:
            body = f'{body} {app.reviewer_notes}'
        metadata = {'shop_id': str(shop.id), 'application_id': str(app.id), 'status': new_status}
        for membership in shop.memberships.select_related('profile__user'):
            create_notification.delay(
                str(membership.profile.user_id), 'shop_cert_status', title, body, metadata,
            )
        for gym_link in shop.gym_links.select_related('gym'):
            # Gym has no `admin` column — ownership is GymMembership with an
            # owner/co_owner role, which is also what the shop-cert notify path
            # is really after.
            for membership in gym_link.gym.memberships.filter(
                role__in=('owner', 'co_owner'),
            ).select_related('member__user'):
                create_notification.delay(str(membership.member.user_id),
                                          'shop_cert_status', title, body, metadata)

        app.refresh_from_db()
        return self.ok(PortalShopCertificationSerializer(app).data,
                       message=f'Application reviewed: {new_status}.')


# ---------------------------------------------------------------------------
# Orders (platform-wide)
# ---------------------------------------------------------------------------

def _order_queryset():
    return (
        Order.objects
        .select_related('buyer__user')
        .prefetch_related('items__creator', 'cases__requester')
    )


def _filtered_orders(request):
    qs = _order_queryset()
    qs = filter_choice(request, qs, 'status', Order.STATUS_CHOICES)
    qs = filter_choice(request, qs, 'fulfillment_type', Order.FULFILLMENT_CHOICES)
    qs = filter_choice(request, qs, 'payment_status', Order.PAYMENT_STATUS_CHOICES)
    qs = filter_choice(request, qs, 'payment_method', Order.PAYMENT_METHOD_CHOICES)
    order_number = (_params(request).get('order_number') or '').strip()
    if order_number:
        qs = qs.filter(order_number=order_number)
    qs = filter_text(request, qs, ['order_number', 'buyer__username', 'buyer__user__email'])
    qs = filter_date_range(request, qs, 'created_at')
    return qs.order_by('-created_at')


class OrderListView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('orders.read')]
    serializer_class = PortalOrderSerializer

    def get(self, request):
        return self.paginate(request, _filtered_orders(request), PortalOrderSerializer)


class OrderDetailView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('orders.read')]
    serializer_class = PortalOrderSerializer

    def get(self, request, order_id):
        order = get_object_or_404(_order_queryset(), pk=order_id)
        return self.ok(PortalOrderSerializer(order).data)


class OrderStatusView(PortalView):
    """Force a status change, but only along legal forward transitions.

    ``allowed_order_transitions`` (marketplace/views.py) is the single source
    of truth for what may follow what, and it is fulfillment-aware: a digital
    order cannot be shipped and a pickup order cannot go out for delivery. An
    illegal jump is a 400 naming the current state and the allowed ones —
    never a silent write.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('orders.write')]
    serializer_class = PortalOrderSerializer

    def patch(self, request, order_id):
        order = get_object_or_404(Order, pk=order_id)
        serializer = OrderStatusChangeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        new_status = serializer.validated_data['status']
        note = serializer.validated_data.get('note') or ''

        if new_status == order.status:
            return self.fail(
                f'Order is already {order.status}.', status_code=status.HTTP_400_BAD_REQUEST,
            )
        allowed = allowed_order_transitions(order)
        if new_status not in allowed:
            allowed_text = ', '.join(allowed) if allowed else 'none — this is a terminal state'
            return self.fail(
                f'Cannot move order from {order.status} to {new_status}. '
                f'Allowed next states: {allowed_text}.',
                status_code=status.HTTP_400_BAD_REQUEST,
                errors={'status': [f'{new_status} is not a valid transition from {order.status}.']},
            )

        if not note:
            note = f'Status set to {new_status} by platform admin.'

        # Reuse the seller path's transition helper when a fulfillment record
        # already exists, so status_history and the fulfillment timeline/milestones
        # stay in step. It never creates the row — fulfillment records belong to
        # the seller-facing endpoints.
        fulfillment = order.fulfillment
        if fulfillment is not None:
            _apply_fulfillment_status(order, fulfillment, new_status, note=note)
            fulfillment.save()
        else:
            order.set_status(new_status, note=note)

        order.refresh_from_db()

        message = f'Order {order.order_number} is now {new_status}.'
        create_notification.delay(
            str(order.buyer.user_id), 'new_purchase', 'Order update', message,
            {'order_id': str(order.id), 'order_number': order.order_number, 'status': new_status},
        )
        return self.ok(PortalOrderSerializer(order).data, message=message)


class OrderNoteView(PortalView):
    """Append an operator note to ``Order.status_history`` without changing state.

    Goes through ``Order.set_status`` so the history entry has the same shape
    as every other entry the platform writes.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('orders.write')]
    serializer_class = PortalOrderSerializer

    def post(self, request, order_id):
        order = get_object_or_404(Order, pk=order_id)
        serializer = OrderNoteSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        order.set_status(order.status, note=serializer.validated_data['note'])
        order.refresh_from_db()
        return self.ok(PortalOrderSerializer(order).data, message='Note recorded.')


class OrderCaseListView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('orders.cases.read')]
    serializer_class = PortalOrderCaseSerializer

    def get(self, request):
        qs = OrderCase.objects.select_related('order', 'requester')
        qs = filter_choice(request, qs, 'status', OrderCase.STATUS_CHOICES)
        qs = filter_choice(request, qs, 'case_type', OrderCase.CASE_TYPES)
        order_id = (_params(request).get('order') or '').strip()
        if order_id:
            parsed = _as_uuid(order_id)
            if parsed is None:
                raise ValidationError(f'Invalid order UUID: {order_id!r}.')
            qs = qs.filter(order_id=parsed)
        qs = filter_date_range(request, qs, 'created_at')
        return self.paginate(request, qs.order_by('created_at'), PortalOrderCaseSerializer)


class OrderCaseUpdateView(PortalView):
    """Move a case along. Deliberately does not move money.

    Approving a refund case is a decision record. Artifacts and fiat only move
    through the wallet ledger's posting path, so this endpoint never claims a
    refund happened — the response says so explicitly.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('orders.cases.write')]
    serializer_class = PortalOrderCaseSerializer

    def patch(self, request, case_id):
        case = get_object_or_404(OrderCase.objects.select_related('order'), pk=case_id)
        serializer = OrderCaseUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        case.status = data['status']
        if 'resolution' in data:
            case.resolution = data['resolution']
        fields = ['status', 'resolution']
        if case.status in ('approved', 'rejected', 'resolved'):
            case.resolved_at = timezone.now()
            fields.append('resolved_at')
        case.save(update_fields=fields + ['updated_at'])
        case.refresh_from_db()
        return self.ok(
            PortalOrderCaseSerializer(case).data,
            message=(f'Case set to {case.status}. No ledger entry was created — '
                     'settle refunds through the wallet posting path.'),
        )


class OrderCaseView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('orders.cases.write')]
    serializer_class = PortalOrderCaseSerializer

    def get(self, request, order_id):
        order = get_object_or_404(Order, pk=order_id)
        cases = order.cases.select_related('requester').order_by('-created_at')
        return self.ok(PortalOrderCaseSerializer(cases, many=True).data)

    def post(self, request, order_id):
        order = get_object_or_404(Order, pk=order_id)
        serializer = OrderCaseCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        requester = profile_of(request.user)
        if requester is None:
            return self.fail(
                'Your admin account has no profile row, so a case cannot be attributed. '
                'Provision the profile first.',
                status_code=status.HTTP_409_CONFLICT,
            )
        case = serializer.save(order=order, requester=requester)
        return self.ok(PortalOrderCaseSerializer(case).data,
                       message='Case recorded. Recording it moves no money.',
                       status_code=status.HTTP_201_CREATED)


# ---------------------------------------------------------------------------
# Gyms
# ---------------------------------------------------------------------------

class GymListView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('gyms.read')]
    serializer_class = PortalGymSerializer

    def get(self, request):
        qs = Gym.objects.all()
        qs = filter_text(request, qs, ['name', 'handle', 'location_city'])
        qs = filter_choice(request, qs, 'access_type', Gym.ACCESS_CHOICES)
        category = (_params(request).get('category') or '').strip()
        if category:
            qs = qs.filter(category__icontains=category)
        qs = filter_bool(request, qs, 'is_verified')
        qs = filter_bool(request, qs, 'is_deleted')
        # member_count is a denormalised column on the row. The GymMembership
        # roster is deliberately never selected or serialised here.
        qs = qs.order_by('-created_at')
        return self.paginate(request, qs, PortalGymSerializer)


class GymDetailView(PortalView):
    """Read one gym, or update the fields staff own.

    Gym has no ``is_active`` column — liveness is ``SoftDeleteModel.is_deleted``
    — so that is what PATCH accepts. Never invent an is_active here.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('gyms')]
    serializer_class = PortalGymSerializer

    def get(self, request, gym_id):
        gym = get_object_or_404(Gym, pk=gym_id)
        return self.ok(PortalGymSerializer(gym).data)

    def patch(self, request, gym_id):
        gym = get_object_or_404(Gym, pk=gym_id)
        serializer = GymAdminUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        fields = []
        for field in ('is_verified', 'access_type', 'is_deleted'):
            if field in data:
                setattr(gym, field, data[field])
                fields.append(field)
        if 'is_deleted' in data:
            gym.deleted_at = timezone.now() if data['is_deleted'] else None
            fields.append('deleted_at')
        if fields:
            gym.save(update_fields=fields + ['updated_at'])
        gym.refresh_from_db()
        return self.ok(PortalGymSerializer(gym).data,
                       message=f'Gym updated ({", ".join(fields)}).')


# ---------------------------------------------------------------------------
# Communities (Conversation rows, private ones included)
# ---------------------------------------------------------------------------

class CommunityListView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('communities.read')]
    serializer_class = PortalCommunitySerializer

    def get(self, request):
        qs = Conversation.objects.annotate(
            member_count=Count('memberships', distinct=True),
            post_count=Count('community_posts', distinct=True),
        )
        qs = filter_text(request, qs, ['group_name', 'description'])
        qs = filter_bool(request, qs, 'is_public')
        qs = filter_bool(request, qs, 'is_community')
        qs = filter_bool(request, qs, 'is_group')
        qs = filter_choice(request, qs, 'origin', Conversation.ORIGIN_CHOICES)
        qs = qs.order_by('-created_at')
        # `participants` is never prefetched and never serialised: this list is
        # a count, not a roster.
        return self.paginate(request, qs, PortalCommunitySerializer)


class CommunityDetailView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('communities.read')]
    serializer_class = PortalCommunitySerializer

    def get(self, request, conversation_id):
        conversation = get_object_or_404(
            Conversation.objects.annotate(
                member_count=Count('memberships', distinct=True),
                post_count=Count('community_posts', distinct=True),
            ),
            pk=conversation_id,
        )
        return self.ok(PortalCommunitySerializer(conversation).data)


# ---------------------------------------------------------------------------
# Pickup stations & delivery personnel
# ---------------------------------------------------------------------------

class PickupStationListView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('logistics.read')]
    serializer_class = PortalPickupStationSerializer

    def get(self, request):
        qs = PickupStation.objects.select_related('shop', 'gym')
        qs = filter_text(request, qs, ['name', 'city', 'address'])
        qs = filter_bool(request, qs, 'is_active')
        qs = filter_bool(request, qs, 'is_primary')
        qs = filter_choice(request, qs, 'owner_type', PickupStation.OWNER_TYPE_CHOICES)
        city = (_params(request).get('city') or '').strip()
        if city:
            qs = qs.filter(city__iexact=city)
        qs = qs.order_by('-created_at')
        return self.paginate(request, qs, PortalPickupStationSerializer)


class PickupStationDetailView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('logistics')]
    serializer_class = PortalPickupStationSerializer

    def get(self, request, station_id):
        station = get_object_or_404(PickupStation.objects.select_related('shop', 'gym'), pk=station_id)
        return self.ok(PortalPickupStationSerializer(station).data)

    def patch(self, request, station_id):
        station = get_object_or_404(PickupStation, pk=station_id)
        serializer = PickupStationAdminUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        fields = []
        for field in ('is_active', 'is_primary'):
            if field in data:
                setattr(station, field, data[field])
                fields.append(field)
        if fields:
            station.save(update_fields=fields + ['updated_at'])
        station.refresh_from_db()
        return self.ok(PortalPickupStationSerializer(station).data,
                       message=f'Station updated ({", ".join(fields)}).')


class DeliveryPersonnelListView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('logistics.read')]
    serializer_class = PortalDeliveryPersonnelSerializer

    def get(self, request):
        qs = DeliveryPersonnel.objects.select_related('profile__user')
        qs = filter_text(request, qs, ['profile__username', 'profile__display_name'])
        qs = filter_choice(request, qs, 'vehicle_type', DeliveryPersonnel.VEHICLE_TYPE_CHOICES)
        qs = filter_bool(request, qs, 'is_active')
        qs = qs.order_by('-created_at')
        return self.paginate(request, qs, PortalDeliveryPersonnelSerializer)


class DeliveryPersonnelDetailView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('logistics')]
    serializer_class = PortalDeliveryPersonnelSerializer

    def get(self, request, personnel_id):
        person = get_object_or_404(DeliveryPersonnel.objects.select_related('profile__user'),
                                   pk=personnel_id)
        return self.ok(PortalDeliveryPersonnelSerializer(person).data)

    def patch(self, request, personnel_id):
        person = get_object_or_404(DeliveryPersonnel, pk=personnel_id)
        serializer = DeliveryPersonnelActiveUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        person.is_active = serializer.validated_data['is_active']
        person.save(update_fields=['is_active', 'updated_at'])
        person.refresh_from_db()
        return self.ok(PortalDeliveryPersonnelSerializer(person).data,
                       message='Courier updated.')


# ---------------------------------------------------------------------------
# Application review queues (stations & couriers)
# ---------------------------------------------------------------------------

def _notify(profile, notification_type, title, body, metadata):
    """Fire a notification at a profile, matching marketplace/views.py:500-523."""
    if profile is None:
        return
    create_notification.delay(str(profile.user_id), notification_type, title, body, metadata)


STATION_STATUS_COPY = {
    'approved': ('Station Application Approved',
                 'Your pickup station application was approved.'),
    'rejected': ('Station Application Rejected',
                 'Your pickup station application was not approved.'),
    'more_info_needed': ('Station Application — More Info Needed',
                         'We need more information to review your station application.'),
    'under_review': ('Station Application Under Review',
                     'Your pickup station application is being reviewed.'),
    'submitted': ('Station Application Received',
                  'Your pickup station application is in the queue.'),
}


class StationApplicationQueueView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('logistics.applications.read')]
    serializer_class = PortalStationApplicationSerializer

    def get(self, request):
        qs = StationApplication.objects.select_related('shop', 'gym', 'submitted_by', 'reviewed_by')
        qs = filter_choice(request, qs, 'status', StationApplication.STATUS_CHOICES)
        qs = filter_text(request, qs, ['business_registration_number', 'contact_phone', 'city'])
        city = (_params(request).get('city') or '').strip()
        if city:
            qs = qs.filter(city__iexact=city)
        handle = (_params(request).get('handle') or '').strip()
        if handle:
            qs = qs.filter(Q(shop__handle__iexact=handle) | Q(gym__handle__iexact=handle))
        return self.paginate(request, qs.order_by('created_at'), PortalStationApplicationSerializer)


class StationApplicationReviewView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('logistics.applications.write')]
    serializer_class = PortalStationApplicationSerializer

    def get(self, request, application_id):
        app = get_object_or_404(
            StationApplication.objects.select_related('shop', 'gym', 'submitted_by', 'reviewed_by'),
            pk=application_id,
        )
        return self.ok(PortalStationApplicationSerializer(app).data)

    def patch(self, request, application_id):
        app = get_object_or_404(
            StationApplication.objects.select_related('submitted_by__user'), pk=application_id,
        )
        serializer = ApplicationReviewSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        app.status = data['status']
        if 'reviewer_notes' in data:
            app.reviewer_notes = data['reviewer_notes']
        if 'rejection_reason' in data:
            app.rejection_reason = data['rejection_reason']
        app.reviewed_by = profile_of(request.user)
        app.reviewed_at = timezone.now()
        app.save()

        title, body = STATION_STATUS_COPY.get(
            data['status'], ('Station Application Update', 'Your station application status changed.'),
        )
        if data['status'] == 'rejected' and app.rejection_reason:
            body = f'{body} Reason: {app.rejection_reason}'
        elif data['status'] == 'more_info_needed' and app.reviewer_notes:
            body = f'{body} {app.reviewer_notes}'
        _notify(app.submitted_by, 'station_application_status', title, body,
                {'station_application_id': str(app.id), 'status': app.status})

        app.refresh_from_db()
        return self.ok(PortalStationApplicationSerializer(app).data,
                       message=f'Station application reviewed: {app.status}.')


COURIER_STATUS_COPY = {
    'approved': ('Courier Application Approved',
                 'You are approved to deliver orders.'),
    'rejected': ('Courier Application Rejected',
                 'Your delivery application was not approved.'),
    'more_info_needed': ('Courier Application — More Info Needed',
                         'We need more information to review your application.'),
    'under_review': ('Courier Application Under Review',
                     'Your delivery application is being reviewed.'),
    'submitted': ('Courier Application Received', 'Your delivery application is in the queue.'),
}


class DeliveryPersonnelApplicationQueueView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('logistics.applications.read')]
    serializer_class = PortalDeliveryPersonnelApplicationSerializer

    def get(self, request):
        qs = DeliveryPersonnelApplication.objects.select_related('profile__user', 'reviewed_by')
        qs = filter_choice(request, qs, 'status', DeliveryPersonnelApplication.STATUS_CHOICES)
        qs = filter_choice(request, qs, 'vehicle_type',
                           DeliveryPersonnelApplication.VEHICLE_TYPE_CHOICES)
        qs = filter_text(request, qs, ['profile__username', 'profile__display_name', 'phone'])
        return self.paginate(request, qs.order_by('created_at'),
                             PortalDeliveryPersonnelApplicationSerializer)


class DeliveryPersonnelApplicationReviewView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('logistics.applications.write')]
    serializer_class = PortalDeliveryPersonnelApplicationSerializer

    def get(self, request, application_id):
        app = get_object_or_404(
            DeliveryPersonnelApplication.objects.select_related('profile__user', 'reviewed_by'),
            pk=application_id,
        )
        return self.ok(PortalDeliveryPersonnelApplicationSerializer(app).data)

    def patch(self, request, application_id):
        app = get_object_or_404(
            DeliveryPersonnelApplication.objects.select_related('profile__user'), pk=application_id,
        )
        serializer = ApplicationReviewSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        app.status = data['status']
        if 'reviewer_notes' in data:
            app.reviewer_notes = data['reviewer_notes']
        if 'rejection_reason' in data:
            app.rejection_reason = data['rejection_reason']
        app.reviewed_by = profile_of(request.user)
        app.reviewed_at = timezone.now()
        app.save()

        title, body = COURIER_STATUS_COPY.get(
            data['status'], ('Delivery Application Update',
                             'Your delivery application status changed.'),
        )
        if data['status'] == 'rejected' and app.rejection_reason:
            body = f'{body} Reason: {app.rejection_reason}'
        elif data['status'] == 'more_info_needed' and app.reviewer_notes:
            body = f'{body} {app.reviewer_notes}'
        _notify(app.profile, 'delivery_application_status', title, body,
                {'delivery_application_id': str(app.id), 'status': app.status})

        app.refresh_from_db()
        return self.ok(PortalDeliveryPersonnelApplicationSerializer(app).data,
                       message=f'Delivery application reviewed: {app.status}.')


# ---------------------------------------------------------------------------
# Wallet — read only. There is no write path in this app, by design.
# ---------------------------------------------------------------------------

class TransactionListView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('wallet.read')]
    serializer_class = PortalTransactionSerializer

    def get(self, request):
        qs = ArtifactTransaction.objects.select_related('user__user', 'counterparty')
        qs = filter_choice(request, qs, 'transaction_type', ArtifactTransaction.TRANSACTION_TYPES)
        qs = filter_choice(request, qs, 'direction', ArtifactTransaction.DIRECTION_CHOICES)
        qs = filter_choice(request, qs, 'status', ArtifactTransaction.STATUS_CHOICES)
        email = (_params(request).get('email') or '').strip()
        if email:
            qs = qs.filter(user__user__email__icontains=email)
        qs = filter_text(request, qs, ['tx_ref', 'reference_id', 'user__username'])
        qs = filter_date_range(request, qs, 'created_at')
        qs = qs.order_by('-created_at')
        return self.paginate(request, qs, PortalTransactionSerializer)


class TransactionDetailView(PortalView):
    permission_classes = [ScopedPlatformAdmin.for_scope('wallet.read')]
    serializer_class = PortalTransactionSerializer

    def get(self, request, transaction_id):
        tx = get_object_or_404(
            ArtifactTransaction.objects.select_related('user__user', 'counterparty'),
            pk=transaction_id,
        )
        return self.ok(PortalTransactionSerializer(tx).data)


class WalletReconciliationView(PortalView):
    """Provider-vs-ledger reconciliation, read-only.

    Wraps ``apps.wallet.management.commands.reconcile_wallet``, which delegates
    to ``reconcile_flutterwave_transactions.run()``. That function only reads
    and logs — it never posts a ledger entry — so calling it here is safe.

    The ``local`` block is the same drift check that needs no provider call at
    all (Flutterwave rows with no provider id to verify against, and pending
    transactions nobody ever cleared).
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('wallet.reconcile')]

    def get(self, request):
        from apps.wallet.tasks import reconcile_flutterwave_transactions

        try:
            provider_summary = reconcile_flutterwave_transactions.run()
        except Exception as exc:  # noqa: BLE001 — report, never 500 the portal
            provider_summary = {
                'checked': 0, 'matched': 0, 'pending': 0, 'mismatched': 0, 'errors': 1,
                'provider_error': str(exc) or exc.__class__.__name__,
            }

        stale_cutoff = timezone.now() - timezone.timedelta(days=7)
        local = {
            'flutterwave_rows_without_provider_id': ArtifactTransaction.objects.filter(
                payment_provider='flutterwave', flutterwave_id='',
            ).count(),
            'pending_older_than_7_days': ArtifactTransaction.objects.filter(
                status='pending', created_at__lt=stale_cutoff,
            ).count(),
            'completed_without_journal_entry': ArtifactTransaction.objects.filter(
                status='completed', journal_entry__isnull=True,
            ).count(),
        }
        local['mismatched'] = sum(local.values())

        data = {
            'provider': provider_summary,
            'local': local,
            'window_days': 30,
            'writes_ledger': False,
        }
        message = 'Reconciliation complete.'
        if provider_summary.get('mismatched') or local['mismatched']:
            message = 'Reconciliation found discrepancies — see mismatched counts.'
        return self.ok(data, message=message)
