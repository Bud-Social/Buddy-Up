import os
from uuid import uuid4
from django.conf import settings
from django.core.cache import cache
from django.core.files.base import ContentFile
from django.core.files.storage import default_storage
from django.http import Http404
from django.shortcuts import get_object_or_404
from django.db import models as db_models, transaction
from django.utils import timezone

from rest_framework import views, permissions, status
from rest_framework.parsers import FormParser, MultiPartParser, JSONParser
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError
from rest_framework.throttling import ScopedRateThrottle

from common.pagination import PageNumberPagination
from apps.guardians.services import guardian_blocks_spends
from apps.profiles.models import BuddyRelationship
from common.age_gating import gate_mature_queryset, can_view_content
from .models import (
    Shop, ShopMembership, ShopGymLink, ShopVerificationApplication, PushDevice,
    MealPlan, MealPlanPurchase, MealPlanReview,
    TrainingProgramme, TrainingProgrammePurchase, TrainingProgrammeReview,
    ProgrammeActivityProgress,
    Product, MarketplaceEvent, EventMedia, EventTicket,
    Cart, CartItem, DiscountCode, DiscountUsage,
    Order, OrderItem, OrderFulfillment, InventoryReservation,
    CreatorPayoutSetup,
    PickupStation, StationApplication,
    DeliveryPersonnel, DeliveryPersonnelApplication,
    PaymentIntent,
)
from .serializers import (
    ShopSerializer, ShopDetailSerializer, ShopCreateSerializer,
    ShopMembershipSerializer, ShopGymLinkSerializer,
    ShopVerificationApplicationSerializer,
    PushDeviceSerializer, ProgrammeActivityProgressSerializer,
    MealPlanSerializer, MealPlanFullSerializer, MealPlanReviewSerializer,
    TrainingProgrammeSerializer, TrainingProgrammeReviewSerializer,
    UpdateTrainingProgrammeSerializer, UpdateMealPlanSerializer,
    ProductSerializer, UpdateProductSerializer, CreateProductSerializer,
    MarketplaceEventSerializer, EventMediaSerializer,
    EventTicketSerializer, CreateMealPlanSerializer, CreateTrainingProgrammeSerializer,
    CreateEventSerializer, ReviewInputSerializer,
    DiscountCodeSerializer, DiscountCodeWriteSerializer,
    OrderSerializer, SellerOrderSerializer, OrderFulfillmentSerializer,
    OrderCaseSerializer, CreatorPayoutSetupSerializer,
    PickupStationSerializer, StationApplicationSerializer,
    DeliveryPersonnelSerializer, DeliveryPersonnelApplicationSerializer,
    PaymentIntentCreateSerializer, PaymentIntentSerializer,
    resolve_item_price,
)
from apps.wallet.utils import deduct_artifacts, credit_artifacts, credit_creator_artifacts, platform_cut
from apps.wallet.models import ArtifactTransaction
from apps.wallet.serializers import PLATFORM_CUTS, ARTIFACT_VALUES
from apps.ai.client import ai_post


def _resolve_creator_shop(profile, shop_id=None):
    """Resolve the shop a creator may attach new content to.

    Returns (shop, error_message). If ``shop_id`` is provided the profile must
    own/manage that shop (otherwise ``(None, msg)``). Without a ``shop_id`` we
    fall back to the first shop the profile owns or manages. Content creation is
    gated behind an explicit creator registration (a shop membership), so a
    profile with no shop cannot publish.
    """
    if shop_id:
        try:
            shop = Shop.objects.get(id=shop_id)
        except Shop.DoesNotExist:
            return None, 'The shop no longer exists.'
        if not ShopMembership.objects.filter(
            shop=shop, profile=profile, role__in=('owner', 'manager')
        ).exists():
            return None, 'You do not have permission to publish under this shop.'
        membership_shop = shop
    else:
        membership = ShopMembership.objects.filter(
            profile=profile, role__in=('owner', 'manager')
        ).select_related('shop').first()
        if not membership:
            return None, 'Register as a creator before publishing content.'
        membership_shop = membership.shop

    application = membership_shop.verification_applications.filter(status='approved').exists()
    payout_ready = CreatorPayoutSetup.objects.filter(
        profile=profile, setup_status='ready', terms_accepted_at__isnull=False,
    ).exists()
    if membership_shop.verification_status != 'verified' and not application:
        return None, 'An approved creator application is required before publishing.'
    if not payout_ready:
        return None, 'Complete payout setup and accept the creator terms before publishing.'
    return membership_shop, None


def _order_seller_profiles(order):
    """Who must be told about this order, besides its buyer.

    A seller has to be able to react to a sale without polling. Two groups
    qualify:

    * the ``OrderItem.creator`` of every line — the account that is actually
      selling (always, even if it has no shop);
    * every owner/manager of a shop that one of those creators sells through,
      because in a real shop the person who has to ship the parcel is the shop
      operator, not always the listed creator.

Ordered by id so the fan-out is deterministic, and the buyer is never
    included (they get their own order notification).
    """
    from apps.profiles.models import Profile

    creator_ids = set(order.items.exclude(creator=None).values_list('creator_id', flat=True))
    # The shops these creators sell through, then everyone who can operate them.
    shop_ids = set(
        ShopMembership.objects.filter(profile_id__in=creator_ids).values_list('shop_id', flat=True),
    )
    shop_operator_ids = set(
        ShopMembership.objects.filter(shop_id__in=shop_ids, role__in=('owner', 'manager'))
        .values_list('profile_id', flat=True)
    )
    target_ids = (creator_ids | shop_operator_ids) - {order.buyer_id}
    if not target_ids:
        return []
    # Profile's primary key *is* the user id, so these are user ids.
    return list(Profile.objects.filter(pk__in=target_ids).order_by('pk'))


def _notify_sellers_of_new_order(order):
    """Fan a `new_purchase` notification out to everyone selling in this order.

    ``create_notification`` only writes the in-app row and pushes it over the
    websocket channel layer — it never touches a device token, which is what
    ``_push_notification_to_profile`` does. Every seller notification therefore
    invokes BOTH; without the second call a seller with the app closed sees
    nothing at all, which is the whole point of the fan-out.
    """
    from apps.notifications.tasks import create_notification
    from .tasks import _push_notification_to_profile

    seller_profiles = _order_seller_profiles(order)
    if not seller_profiles:
        return
    buyer_name = order.buyer.display_name or order.buyer.username
    title = f'New sale: order #{order.order_number}'
    body = f'{buyer_name} bought {order.items.count()} item(s). Open the order to start fulfilling it.'
    metadata = {
        'order_id': str(order.id),
        'order_number': order.order_number,
        'status': order.status,
        'fulfillment_type': order.fulfillment_type,
        'total': str(order.spent_usd or '0'),
        'buyer_username': order.buyer.username,
    }
    for profile in seller_profiles:
        create_notification.delay(
            str(profile.user_id), 'new_purchase', title, body, metadata,
            # One row per (order, seller): a retried checkout must not bury a
            # seller under duplicates of the same sale.
            dedupe_key=f'order:{order.id}:new_purchase:{profile.pk}',
        )
        _push_notification_to_profile(profile, title, body, metadata)


def _notify_order_status_change(order, new_status):
    """Tell the buyer AND every seller that the order moved.

    This is the single place an order status change notifies anybody.
    ``notifications.signals.handle_order_status_changed`` deliberately does not
    notify on status changes any more: it used to, and so did this view, so the
    buyer received two rows per seller update. The signal still covers order
    *creation* (which happens in code paths this function cannot see), and this
    function covers every transition the API can perform.
    """
    from apps.notifications.tasks import create_notification
    from .tasks import _push_notification_to_profile

    label = dict(Order.STATUS_CHOICES).get(new_status, new_status.replace('_', ' ').title())
    title = 'Order update'
    body = f'Order #{order.order_number} is now {label}.'
    metadata = {
        'order_id': str(order.id),
        'order_number': order.order_number,
        'status': new_status,
        'fulfillment_type': order.fulfillment_type,
    }
    recipients = list(_order_seller_profiles(order))
    if not any(profile.pk == order.buyer_id for profile in recipients):
        recipients.append(order.buyer)
    for profile in recipients:
        create_notification.delay(
            str(profile.user_id), 'order_status_changed', title, body, metadata,
            dedupe_key=f'order:{order.id}:status:{new_status}:{profile.pk}',
        )
        # Device push is a separate transport from the in-app row; both run.
        _push_notification_to_profile(profile, title, body, metadata)


def _create_order_for_purchase(buyer, item_type, item_obj, title, creator, price_artifacts):
    """Record a single-item Order (used by direct purchase endpoints)."""
    price_artifacts = price_artifacts or {}
    spent_usd = round(sum(ARTIFACT_VALUES.get(k, 0) * v for k, v in price_artifacts.items()), 2)
    order = Order.objects.create(
        buyer=buyer,
        fulfillment_type='digital',
        items_total_artifacts=price_artifacts,
        total_artifacts=price_artifacts,
        spent_usd=spent_usd,
        status='paid',
        paid_at=timezone.now(),
        status_history=[{
            'status': 'paid',
            'at': timezone.now().isoformat(),
            'note': 'Order placed and payment confirmed.',
        }],
    )
    OrderItem.objects.create(
        order=order,
        item_type=item_type,
        meal_plan=item_obj if item_type == 'meal_plan' else None,
        programme=item_obj if item_type == 'programme' else None,
        product=item_obj if item_type == 'product' else None,
        event=item_obj if item_type == 'event_ticket' else None,
        creator=creator,
        title=title,
        quantity=1,
        price_artifacts=price_artifacts,
        paid_artifacts=price_artifacts,
    )
    _notify_sellers_of_new_order(order)
    return order


# ===========================================================================
# Shop Views
# ===========================================================================

class ShopListView(views.APIView):
    """List all public shops or the current user's shops."""
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get(self, request):
        mine = request.query_params.get('mine') == 'true'
        if mine:
            if not request.user.is_authenticated:
                return Response({'success': False, 'data': [], 'message': 'Auth required', 'errors': None, 'pagination': None}, status=401)
            profile_ids = ShopMembership.objects.filter(profile=request.user.profile).values_list('shop_id', flat=True)
            qs = Shop.objects.filter(id__in=profile_ids, is_active=True)
        else:
            category = request.query_params.get('category', '')
            q = request.query_params.get('q', '')
            qs = Shop.objects.filter(is_active=True)
            if category:
                qs = qs.filter(category=category)
            if q:
                qs = qs.filter(name__icontains=q)

        qs = qs.prefetch_related('memberships').order_by('-created_at')
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = ShopSerializer(page, many=True, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None,
            'pagination': {'count': paginator.page.paginator.count,
                           'next': paginator.get_next_link(), 'previous': paginator.get_previous_link()},
        })

    def post(self, request):
        """Create a new shop."""
        if not request.user.is_authenticated:
            return Response({'success': False, 'data': None, 'message': 'Auth required', 'errors': None, 'pagination': None}, status=401)

        serializer = ShopCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({'success': False, 'data': None, 'message': 'Validation failed',
                             'errors': serializer.errors, 'pagination': None}, status=400)

        shop = serializer.save()

        # Handle logo/banner file uploads
        if 'logo' in request.FILES:
            shop.logo = request.FILES['logo']
        if 'banner' in request.FILES:
            shop.banner = request.FILES['banner']
        # Handle logo/banner URL fallbacks (from the upload-cover endpoint)
        if 'logo_url' in request.data:
            shop.logo_url = request.data['logo_url']
        if 'banner_url' in request.data:
            shop.banner_url = request.data['banner_url']
        shop.save()

        # Create membership: the creator is the owner
        ShopMembership.objects.create(shop=shop, profile=request.user.profile, role='owner')

        # Handle gym link if provided
        gym_id = request.data.get('gym_id')
        if gym_id:
            from apps.gyms.models import Gym
            try:
                gym = Gym.objects.get(id=gym_id)
                ShopGymLink.objects.create(shop=shop, gym=gym, is_primary=True)
            except Exception:  # noqa: BLE001
                pass

        # Notify the creator
        from apps.notifications.tasks import create_notification
        create_notification.delay(
            str(request.user.id),
            'shop_created',
            f'Your shop "{shop.name}" is live! 🛍️',
            'Start adding your services to reach buyers on BuddyUp Fit.',
            {'shop_id': str(shop.id), 'shop_handle': shop.handle},
        )

        return Response({
            'success': True,
            'data': ShopDetailSerializer(shop, context={'request': request}).data,
            'message': 'Shop created successfully.',
            'errors': None, 'pagination': None,
        }, status=201)


class ShopDetailView(views.APIView):
    """Get, update, or delete a shop by handle."""
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def _get_shop_and_check_role(self, handle, request, required_role='manager'):
        shop = get_object_or_404(Shop, handle=handle, is_active=True)
        if not request.user.is_authenticated:
            return shop, None
        membership = shop.memberships.filter(profile=request.user.profile).first()
        role = membership.role if membership else None
        return shop, role

    def get(self, request, handle):
        shop = get_object_or_404(Shop, handle=handle, is_active=True)
        serializer = ShopDetailSerializer(shop, context={'request': request})
        return Response({'success': True, 'data': serializer.data, 'message': 'OK', 'errors': None, 'pagination': None})

    def patch(self, request, handle):
        shop, role = self._get_shop_and_check_role(handle, request)
        if role not in ('owner', 'manager'):
            return Response({'success': False, 'data': None, 'message': 'Insufficient permissions.',
                             'errors': None, 'pagination': None}, status=403)

        # Handle image uploads
        if 'logo' in request.FILES:
            shop.logo = request.FILES['logo']
        if 'banner' in request.FILES:
            shop.banner = request.FILES['banner']

        for field in ('name', 'description', 'category', 'accent_color', 'contact_email',
                      'contact_phone', 'website_url', 'social_links', 'refund_policy'):
            if field in request.data:
                setattr(shop, field, request.data[field])
        shop.save()
        return Response({'success': True, 'data': ShopDetailSerializer(shop, context={'request': request}).data,
                         'message': 'Shop updated.', 'errors': None, 'pagination': None})

    def delete(self, request, handle):
        shop, role = self._get_shop_and_check_role(handle, request)
        if role != 'owner':
            return Response({'success': False, 'data': None, 'message': 'Only owners can delete a shop.',
                             'errors': None, 'pagination': None}, status=403)
        shop.is_active = False
        shop.save(update_fields=['is_active'])
        return Response({'success': True, 'data': None, 'message': 'Shop deactivated.', 'errors': None, 'pagination': None})


class ShopMembershipView(views.APIView):
    """Add/remove shop members. Only owners can manage membership."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, handle):
        shop = get_object_or_404(Shop, handle=handle)
        caller_membership = shop.memberships.filter(profile=request.user.profile, role='owner').first()
        if not caller_membership:
            return Response({'success': False, 'data': None, 'message': 'Only owners can invite members.',
                             'errors': None, 'pagination': None}, status=403)

        from apps.profiles.models import Profile
        username = request.data.get('username')
        role = request.data.get('role', 'staff')
        try:
            profile = Profile.objects.get(username=username)
        except Profile.DoesNotExist:
            return Response({'success': False, 'data': None, 'message': 'User not found.',
                             'errors': None, 'pagination': None}, status=404)

        membership, created = ShopMembership.objects.get_or_create(shop=shop, profile=profile, defaults={'role': role})
        if not created:
            membership.role = role
            membership.save(update_fields=['role'])

        # Notify invited member
        from apps.notifications.tasks import create_notification
        create_notification.delay(
            str(profile.user_id), 'shop_invite',
            f'You\'ve been added to "{shop.name}" as {role}',
            'Visit the shop to start managing services.',
            {'shop_id': str(shop.id), 'shop_handle': shop.handle, 'role': role},
        )

        return Response({'success': True, 'data': ShopMembershipSerializer(membership).data,
                         'message': 'Member added.', 'errors': None, 'pagination': None})

    def delete(self, request, handle):
        shop = get_object_or_404(Shop, handle=handle)
        caller_membership = shop.memberships.filter(profile=request.user.profile, role='owner').first()
        if not caller_membership:
            return Response({'success': False, 'data': None, 'message': 'Only owners can remove members.',
                             'errors': None, 'pagination': None}, status=403)
        from apps.profiles.models import Profile
        username = request.data.get('username')
        try:
            profile = Profile.objects.get(username=username)
        except Profile.DoesNotExist:
            return Response({'success': False, 'data': None, 'message': 'User not found.',
                             'errors': None, 'pagination': None}, status=404)
        ShopMembership.objects.filter(shop=shop, profile=profile).delete()
        return Response({'success': True, 'data': None, 'message': 'Member removed.', 'errors': None, 'pagination': None})


class ShopGymLinkView(views.APIView):
    """Link or unlink a gym from a shop."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, handle):
        shop = get_object_or_404(Shop, handle=handle)
        if not shop.memberships.filter(profile=request.user.profile, role='owner').exists():
            return Response({'success': False, 'data': None, 'message': 'Only shop owners can link gyms.',
                             'errors': None, 'pagination': None}, status=403)
        from apps.gyms.models import Gym
        gym_id = request.data.get('gym_id')
        is_primary = request.data.get('is_primary', False)
        try:
            gym = Gym.objects.get(id=gym_id)
        except Gym.DoesNotExist:
            return Response({'success': False, 'data': None, 'message': 'Gym not found.',
                             'errors': None, 'pagination': None}, status=404)
        link, _ = ShopGymLink.objects.get_or_create(shop=shop, gym=gym, defaults={'is_primary': is_primary})
        return Response({'success': True, 'data': ShopGymLinkSerializer(link).data,
                         'message': 'Gym linked.', 'errors': None, 'pagination': None})

    def delete(self, request, handle):
        shop = get_object_or_404(Shop, handle=handle)
        if not shop.memberships.filter(profile=request.user.profile, role='owner').exists():
            return Response({'success': False, 'data': None, 'message': 'Only shop owners can unlink gyms.',
                             'errors': None, 'pagination': None}, status=403)
        gym_id = request.data.get('gym_id')
        ShopGymLink.objects.filter(shop=shop, gym_id=gym_id).delete()
        return Response({'success': True, 'data': None, 'message': 'Gym unlinked.', 'errors': None, 'pagination': None})


class CoverImageUploadView(views.APIView):
    """Upload a cover image to Cloudinary (falls back to Django media). Returns URL."""
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        image_file = request.FILES.get('image')
        if not image_file:
            return Response({'success': False, 'data': None, 'message': 'No image provided.',
                             'errors': None, 'pagination': None}, status=400)

        # Try Cloudinary first
        try:
            import cloudinary.uploader
            folder = request.data.get('folder', 'marketplace/covers')
            result = cloudinary.uploader.upload(
                image_file,
                folder=folder,
                resource_type='image',
                transformation=[{'quality': 'auto', 'fetch_format': 'auto'}],
            )
            return Response({
                'success': True,
                'data': {'url': result['secure_url'], 'public_id': result['public_id'], 'provider': 'cloudinary'},
                'message': 'Image uploaded.', 'errors': None, 'pagination': None,
            })
        except Exception:  # noqa: BLE001
            pass

        # Fallback: save to Django media
        from django.core.files.storage import default_storage
        from django.core.files.base import ContentFile
        import os
        ext = os.path.splitext(image_file.name)[1]
        path = default_storage.save(f'marketplace/covers/{uuid4().hex}{ext}', ContentFile(image_file.read()))
        url = request.build_absolute_uri(f'{settings.MEDIA_URL}{path}')
        return Response({
            'success': True,
            'data': {'url': url, 'public_id': path, 'provider': 'django'},
            'message': 'Image uploaded.', 'errors': None, 'pagination': None,
        })


class ShopVerificationApplicationView(views.APIView):
    """CRUD for Buddy Up certification applications."""
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get(self, request, handle):
        shop = get_object_or_404(Shop, handle=handle)
        if not shop.memberships.filter(profile=request.user.profile).exists():
            return Response({'success': False, 'data': None, 'message': 'Not a shop member.',
                             'errors': None, 'pagination': None}, status=403)
        app = shop.verification_applications.order_by('-created_at').first()
        if not app:
            return Response({'success': True, 'data': None, 'message': 'No application found.',
                             'errors': None, 'pagination': None})
        return Response({'success': True, 'data': ShopVerificationApplicationSerializer(app).data,
                         'message': 'OK', 'errors': None, 'pagination': None})

    def post(self, request, handle):
        """Create or update a certification application (upsert)."""
        shop = get_object_or_404(Shop, handle=handle)
        if not shop.memberships.filter(profile=request.user.profile, role__in=['owner', 'manager']).exists():
            return Response({'success': False, 'data': None, 'message': 'Insufficient permissions.',
                             'errors': None, 'pagination': None}, status=403)

        # Get or create draft application
        app, _ = ShopVerificationApplication.objects.get_or_create(
            shop=shop, status='draft',
            defaults={'submitted_by': request.user.profile},
        )

        serializer = ShopVerificationApplicationSerializer(app, data=request.data, partial=True)
        if not serializer.is_valid():
            return Response({'success': False, 'data': None, 'message': 'Validation failed',
                             'errors': serializer.errors, 'pagination': None}, status=400)
        serializer.save()

        # Handle document uploads
        if 'id_document' in request.FILES:
            f = request.FILES['id_document']
            # Server-generated storage name — never persist the client's
            # (potentially revealing or path-crafting) filename.
            ext = os.path.splitext(f.name)[1].lower()[:10] or '.pdf'
            p = default_storage.save(f'certs/id_docs/{uuid4().hex}{ext}', ContentFile(f.read()))
            app.id_document_url = request.build_absolute_uri(f'{settings.MEDIA_URL}{p}')

        if 'professional_cert' in request.FILES:
            f = request.FILES['professional_cert']
            ext = os.path.splitext(f.name)[1].lower()[:10] or '.pdf'
            p = default_storage.save(f'certs/prof_certs/{uuid4().hex}{ext}', ContentFile(f.read()))
            app.professional_cert_url = request.build_absolute_uri(f'{settings.MEDIA_URL}{p}')

        # If submission requested, move from draft → submitted
        if request.data.get('submit') == 'true':
            app.status = 'submitted'
            shop.verification_status = 'pending'
            shop.verification_applied_at = timezone.now()
            shop.save(update_fields=['verification_status', 'verification_applied_at'])

            # Notify all shop owners
            from apps.notifications.tasks import create_notification
            for m in shop.memberships.filter(role='owner').select_related('profile'):
                create_notification.delay(
                    str(m.profile.user_id), 'shop_cert_status',
                    f'Certification application submitted for "{shop.name}" ✅',
                    'Your application is under review. We\'ll update you soon.',
                    {'shop_id': str(shop.id), 'application_id': str(app.id), 'status': 'submitted'},
                )

        app.save()
        return Response({'success': True, 'data': ShopVerificationApplicationSerializer(app).data,
                         'message': 'Application saved.', 'errors': None, 'pagination': None})

    def patch(self, request, handle):
        """Admin updates application status (approve / reject / request more info)."""
        if not request.user.is_staff:
            return Response({'success': False, 'data': None, 'message': 'Admin only.',
                             'errors': None, 'pagination': None}, status=403)
        shop = get_object_or_404(Shop, handle=handle)
        app = shop.verification_applications.order_by('-created_at').first()
        if not app:
            return Response({'success': False, 'data': None, 'message': 'No application.',
                             'errors': None, 'pagination': None}, status=404)

        new_status = request.data.get('status')
        valid = [c[0] for c in ShopVerificationApplication.STATUS_CHOICES]
        if new_status not in valid:
            return Response({'success': False, 'data': None,
                             'message': f'Invalid status. Must be one of: {valid}',
                             'errors': None, 'pagination': None}, status=400)

        app.status = new_status
        app.reviewer_notes = request.data.get('reviewer_notes', app.reviewer_notes)
        app.rejection_reason = request.data.get('rejection_reason', app.rejection_reason)
        app.reviewed_by = request.user.profile
        app.reviewed_at = timezone.now()
        app.save()

        # Mirror status to the shop's verification_status
        if new_status == 'approved':
            shop.verification_status = 'verified'
            shop.verified_at = timezone.now()
        elif new_status == 'rejected':
            shop.verification_status = 'rejected'
            shop.rejection_reason = app.rejection_reason
        elif new_status == 'more_info_needed':
            shop.verification_status = 'pending'
        shop.save()

        # Notify ALL shop members of status change
        from apps.notifications.tasks import create_notification
        status_labels = {
            'approved': ('🏅 Buddy Up Certified!', 'Your shop is now Buddy Up certified. Congrats!'),
            'rejected': ('Application Rejected', f'Your application was not approved: {app.rejection_reason}'),
            'more_info_needed': ('More Info Needed', app.reviewer_notes or 'Please provide additional information.'),
            'under_review': ('Under Review', 'Your certification application is being reviewed.'),
        }
        notif_title, notif_body = status_labels.get(new_status, ('Certification Update', 'Your application status has changed.'))
        for m in shop.memberships.select_related('profile'):
            create_notification.delay(
                str(m.profile.user_id), 'shop_cert_status',
                notif_title, notif_body,
                {'shop_id': str(shop.id), 'application_id': str(app.id), 'status': new_status},
            )

        # Also notify linked gyms
        for gym_link in shop.gym_links.select_related('gym__admin'):
            if hasattr(gym_link.gym, 'admin') and gym_link.gym.admin:
                create_notification.delay(
                    str(gym_link.gym.admin.user_id), 'shop_cert_status',
                    notif_title, notif_body,
                    {'shop_id': str(shop.id), 'application_id': str(app.id), 'status': new_status},
                )

        return Response({'success': True, 'data': ShopVerificationApplicationSerializer(app).data,
                         'message': f'Application status updated to {new_status}.',
                         'errors': None, 'pagination': None})


SHOP_STATION_ROLES = ('owner', 'manager')
GYM_STATION_ROLES = ('owner', 'co_owner')


def _resolve_station_owner(profile, shop_id=None, gym_id=None):
    """Resolve the shop/gym a station belongs to and authorise the caller.

    Returns ``(shop, gym, error_message)``. A station is a shop's or a gym's
    business location, so writing one requires the same authority as editing
    that shop/gym: an owner or manager for a shop, an owner or co-owner for a
    gym. ``staff``/``trainer`` memberships and unrelated profiles get ``error``.

    The error is a message rather than a boolean because the caller-facing
    reason differs: a stranger must not learn whether the shop exists.
    """
    from apps.gyms.models import Gym, GymMembership

    if shop_id and gym_id:
        return None, None, 'A station belongs to a shop OR a gym, not both.'
    if not shop_id and not gym_id:
        return None, None, 'Name the shop or the gym this pickup station belongs to.'

    if shop_id:
        try:
            shop = Shop.objects.get(id=shop_id)
        except (Shop.DoesNotExist, ValueError, TypeError):
            return None, None, 'Shop not found.'
        if not ShopMembership.objects.filter(
            shop=shop, profile=profile, role__in=SHOP_STATION_ROLES,
        ).exists():
            return None, None, 'You need to be an owner or manager of this shop to add pickup stations.'
        return shop, None, None

    try:
        gym = Gym.objects.get(id=gym_id)
    except (Gym.DoesNotExist, ValueError, TypeError):
        return None, None, 'Gym not found.'
    if not GymMembership.objects.filter(
        gym=gym, member=profile, role__in=GYM_STATION_ROLES,
    ).exists():
        return None, None, 'You need to be an owner or co-owner of this gym to add pickup stations.'
    return None, gym, None


def _can_manage_station(profile, station):
    """Whether ``profile`` may edit ``station`` (its owner's authority)."""
    if station.shop_id:
        return ShopMembership.objects.filter(
            shop_id=station.shop_id, profile=profile, role__in=SHOP_STATION_ROLES,
        ).exists()
    if station.gym_id:
        from apps.gyms.models import GymMembership
        return GymMembership.objects.filter(
            gym_id=station.gym_id, member=profile, role__in=GYM_STATION_ROLES,
        ).exists()
    return False


def _apply_geo_params(request, queryset, lat_field='latitude', lng_field='longitude'):
    """House-style nearby plumbing, copied from ``EventListView``.

    Returns ``(queryset, geo, origin)`` where ``geo`` is the top-level block the
    events endpoint already returns (``None`` when no coordinates were sent),
    ``origin`` is the ``(lat, lng)`` pair used for distance (``None`` without
    coordinates), and every returned row carries a ``distance_km`` (1 dp,
    ``None`` when its own coordinates are missing).

    Explicit ``radius_km`` always wins; without one the radius adapts to how
    many places are close by, and the chosen radius is reported so the UI can
    explain itself.
    """
    from common.geo import (
        NEAR_RADIUS_KM, adaptive_message, bbox_deltas,
        count_within_latlng, pick_adaptive_radius,
    )

    lat = lng = None
    try:
        if request.query_params.get('lat') not in (None, ''):
            lat = float(request.query_params.get('lat'))
        if request.query_params.get('lng') not in (None, ''):
            lng = float(request.query_params.get('lng'))
    except (TypeError, ValueError):
        lat = lng = None

    radius_param = request.query_params.get('radius_km', '')
    radius_explicit = str(radius_param).strip() != ''
    try:
        radius_km = float(radius_param or 25)
    except (TypeError, ValueError):
        radius_km = 25
        radius_explicit = False
    radius_km = min(max(radius_km, 1), 200)

    geo_auto = False
    geo_density = None
    geo_count_in_near = None
    if lat is not None and lng is not None and not radius_explicit:
        geo_count_in_near = count_within_latlng(
            queryset, lat, lng, NEAR_RADIUS_KM, lat_field=lat_field, lng_field=lng_field,
        )
        radius_km, geo_density = pick_adaptive_radius(geo_count_in_near)
        geo_auto = True

    geo = None
    origin = (lat, lng) if (lat is not None and lng is not None) else None
    if origin is None:
        return queryset, None, None

    lat_delta, lng_delta = bbox_deltas(lat, radius_km)
    queryset = queryset.filter(
        **{f'{lat_field}__isnull': False, f'{lng_field}__isnull': False},
    ).filter(
        **{
            f'{lat_field}__gte': lat - lat_delta, f'{lat_field}__lte': lat + lat_delta,
            f'{lng_field}__gte': lng - lng_delta, f'{lng_field}__lte': lng + lng_delta,
        }
    )
    geo = {
        'lat': lat, 'lng': lng, 'radius_km': radius_km, 'auto': geo_auto,
        'density': geo_density, 'count_in_near': geo_count_in_near,
        'message': adaptive_message(radius_km, geo_density or 'sparse', geo_count_in_near or 0)
        if geo_auto else None,
    }
    return queryset, geo, origin


class PickupStationListView(views.APIView):
    """Public list of active pickup stations + owner-gated creation.

    Station data is a business location (an address a buyer has to be able to
    find), so it is readable by anyone, authenticated or not. Nothing private
    is exposed: no buyer, order or member data is reachable from a station row.
    """

    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get(self, request):
        qs = PickupStation.objects.filter(is_active=True).select_related('shop', 'gym')

        owner_type = (request.query_params.get('owner_type') or '').strip()
        if owner_type:
            if owner_type not in dict(PickupStation.OWNER_TYPE_CHOICES):
                return Response({'success': False, 'data': None, 'message':
                                 f'owner_type must be one of: '
                                 f'{[c[0] for c in PickupStation.OWNER_TYPE_CHOICES]}.',
                                 'errors': None, 'pagination': None}, status=400)
            qs = qs.filter(owner_type=owner_type)

        query = (request.query_params.get('q') or '').strip()
        if query:
            qs = qs.filter(db_models.Q(name__icontains=query) | db_models.Q(city__icontains=query))

        geo_result = _apply_geo_params(request, qs)
        qs, geo, origin = geo_result
        qs = qs.order_by('-is_primary', '-created_at')

        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(qs, request)
        data = list(PickupStationSerializer(page, many=True, context={'request': request}).data)

        if geo is not None:
            lat, lng = origin
            from common.geo import haversine_km
            for row in data:
                try:
                    # DecimalField columns serialise as strings.
                    row['distance_km'] = round(
                        haversine_km(lat, lng, float(row['latitude']), float(row['longitude'])), 1,
                    )
                except (TypeError, ValueError, KeyError):
                    # Same rule as the serializer: no measured distance means no
                    # key, not a null one.
                    row.pop('distance_km', None)
            # Nearest first; rows we could not measure sink to the bottom.
            data.sort(key=lambda r: (r.get('distance_km') is None, r.get('distance_km') or 0))

        return Response({
            'success': True, 'data': data, 'message': 'OK', 'errors': None,
            'geo': geo,
            'pagination': {
                'count': paginator.page.paginator.count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })

    def post(self, request):
        profile = request.user.profile
        shop, gym, error = _resolve_station_owner(
            profile, request.data.get('shop'), request.data.get('gym'),
        )
        if error:
            return Response({'success': False, 'data': None, 'message': error,
                             'errors': None, 'pagination': None}, status=403)

        payload = {k: v for k, v in request.data.items() if k not in ('shop', 'gym', 'owner_type')}
        payload['shop' if shop else 'gym'] = (shop or gym).id
        serializer = PickupStationSerializer(data=payload)
        if not serializer.is_valid():
            return Response({'success': False, 'data': None, 'message': 'Validation failed.',
                             'errors': serializer.errors, 'pagination': None}, status=400)
        station = serializer.save()
        return Response({
            'success': True, 'data': PickupStationSerializer(station, context={'request': request}).data,
            'message': 'Pickup station created.', 'errors': None, 'pagination': None,
        }, status=201)


class PickupStationDetailView(views.APIView):
    """Read one station; owners/managers may edit it."""

    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_object(self, request, station_id):
        station = get_object_or_404(
            PickupStation.objects.select_related('shop', 'gym'), id=station_id,
        )
        # An inactive station is only meaningful to the people who operate it;
        # everyone else sees the same 404 a deleted one would.
        if not station.is_active and not (
            request.user.is_authenticated
            and _can_manage_station(request.user.profile, station)
        ):
            raise Http404
        return station

    def get(self, request, station_id):
        station = self.get_object(request, station_id)
        lat = request.query_params.get('lat')
        lng = request.query_params.get('lng')
        context = {'request': request}
        if lat not in (None, '') and lng not in (None, ''):
            context['origin_latitude'] = lat
            context['origin_longitude'] = lng
        return Response({
            'success': True, 'data': PickupStationSerializer(station, context=context).data,
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    def patch(self, request, station_id):
        station = self.get_object(request, station_id)
        if not request.user.is_authenticated:
            return Response({'success': False, 'data': None, 'message': 'Auth required.',
                             'errors': None, 'pagination': None}, status=401)
        if not _can_manage_station(request.user.profile, station):
            return Response({
                'success': False, 'data': None,
                'message': 'You need to be an owner/manager of the shop or owner/co-owner of the '
                           'gym that owns this pickup station.',
                'errors': None, 'pagination': None,
            }, status=403)

        # Re-parenting a station would silently move a public collection point
        # (and every order pointing at it) to an owner the caller may not even
        # control, so the owner is immutable after creation.
        for locked in ('shop', 'gym', 'owner_type'):
            if locked in request.data:
                return Response({
                    'success': False, 'data': None,
                    'message': f'A pickup station\'s {locked} cannot be changed after it is created.',
                    'errors': None, 'pagination': None,
                }, status=400)

        serializer = PickupStationSerializer(
            station, data=request.data, partial=True, context={'request': request},
        )
        if not serializer.is_valid():
            return Response({'success': False, 'data': None, 'message': 'Validation failed.',
                             'errors': serializer.errors, 'pagination': None}, status=400)
        station = serializer.save()
        return Response({
            'success': True, 'data': PickupStationSerializer(station, context={'request': request}).data,
            'message': 'Pickup station updated.', 'errors': None, 'pagination': None,
        })


def _notify_station_owners(gym=None, shop=None, title='', body='', metadata=None):
    """Tell whoever operates the entity that it just applied to be a station.

    Same fan-out shape as the shop-cert review notification (views.py above):
    create the in-app row AND push to the owner's devices, because
    ``create_notification`` alone never reaches a device token.
    """
    from apps.notifications.tasks import create_notification
    from .tasks import _push_notification_to_profile
    from apps.profiles.models import Profile

    recipient_ids = set()
    if shop:
        recipient_ids.update(
            shop.memberships.filter(role='owner').values_list('profile__user_id', flat=True),
        )
    if gym:
        recipient_ids.update(
            gym.memberships.filter(role__in=GYM_STATION_ROLES).values_list('member__user_id', flat=True),
        )
        # Gym has no `admin` column of its own (see the shop-cert fan-out, which
        # guards the same access with hasattr), so nothing else to add.
    if not recipient_ids:
        return
    profiles = {p.user_id: p for p in Profile.objects.filter(user_id__in=recipient_ids)}
    for user_id, profile in profiles.items():
        create_notification.delay(str(user_id), 'verification_update', title, body, metadata or {})
        _push_notification_to_profile(profile, title, body, metadata or {})


class StationApplicationView(views.APIView):
    """A shop or gym applies to become a pickup / delivery station.

    Mirrors ``ShopVerificationApplicationView.post``: one live draft per
    applicant, ``?submit=true`` moves it to 'submitted' and tells the owners.
    Only staff can move it past 'submitted' (see the review PATCH), so a client
    cannot apply its way to an approved station.
    """

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        profile = request.user.profile
        shop, gym, error = _resolve_station_owner(
            profile, request.data.get('shop'), request.data.get('gym'),
        )
        if error:
            return Response({'success': False, 'data': None, 'message': error,
                             'errors': None, 'pagination': None}, status=403)

        owner_field = 'shop' if shop else 'gym'
        owner = shop or gym
        app, _ = StationApplication.objects.get_or_create(
            **{owner_field: owner, 'status': 'draft'},
            defaults={'submitted_by': profile},
        )
        if app.submitted_by_id != profile.pk:
            return Response({
                'success': False, 'data': None,
                'message': 'Another user already has a draft application for this shop or gym.',
                'errors': None, 'pagination': None,
            }, status=403)

        payload = {k: v for k, v in request.data.items() if k not in ('shop', 'gym')}
        serializer = StationApplicationSerializer(app, data=payload, partial=True)
        if not serializer.is_valid():
            return Response({'success': False, 'data': None, 'message': 'Validation failed.',
                             'errors': serializer.errors, 'pagination': None}, status=400)
        app = serializer.save()

        if str(request.query_params.get('submit', '')).lower() == 'true' or \
                str(request.data.get('submit', '')).lower() == 'true':
            app.status = 'submitted'
            app.save(update_fields=['status', 'updated_at'])
            _notify_station_owners(
                gym=gym, shop=shop,
                title=f'Pickup station application submitted for "{owner.name}"',
                body='Your station application is under review. We\'ll update you soon.',
                metadata={
                    'application_id': str(app.id),
                    'application_kind': 'station',
                    'status': 'submitted',
                    **({'shop_id': str(shop.id)} if shop else {'gym_id': str(gym.id)}),
                },
            )

        return Response({
            'success': True, 'data': StationApplicationSerializer(app).data,
            'message': f'Application {app.status}.', 'errors': None, 'pagination': None,
        }, status=201 if app.status == 'submitted' else 200)


class DeliveryPersonnelSelfView(views.APIView):
    """A courier registers / updates their own ``DeliveryPersonnel`` record.

    Self-service only. ``profile`` is read-only on the serializer *and* checked
    here, so a caller can never mint or rewrite another user's courier record —
    that would be a way to appear as somebody else's courier (and, with it, to
    receive their orders).
    """

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        profile = request.user.profile
        target = request.data.get('profile')
        if target and str(target) != str(profile.pk):
            return Response({'success': False, 'data': None,
                             'message': 'You can only register yourself as delivery personnel.',
                             'errors': None, 'pagination': None}, status=403)

        payload = {
            k: v for k, v in request.data.items()
            if k in ('vehicle_type', 'service_zones', 'is_active', 'bio')
        }
        personnel = DeliveryPersonnel.objects.filter(profile=profile).first()
        created = personnel is None
        # Validate against the database only after validation passes: creating
        # the row first would leave a half-filled courier record behind every
        # rejected request.
        serializer = DeliveryPersonnelSerializer(
            personnel, data=payload, partial=not created,
        )
        if not serializer.is_valid():
            return Response({'success': False, 'data': None, 'message': 'Validation failed.',
                             'errors': serializer.errors, 'pagination': None}, status=400)
        personnel = serializer.save(profile=profile) if created else serializer.save()
        return Response({
            'success': True,
            'data': DeliveryPersonnelSerializer(personnel, context={'request': request}).data,
            'message': 'Courier profile saved.' if created else 'Courier profile updated.',
            'errors': None, 'pagination': None,
        }, status=201 if created else 200)


class DeliveryPersonnelApplicationView(views.APIView):
    """Apply to be approved as delivery personnel (draft → submitted)."""

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        profile = request.user.profile
        target = request.data.get('profile')
        if target and str(target) != str(profile.pk):
            return Response({'success': False, 'data': None,
                             'message': 'You can only apply for yourself.',
                             'errors': None, 'pagination': None}, status=403)

        app, _ = DeliveryPersonnelApplication.objects.get_or_create(
            profile=profile, status='draft',
        )
        payload = {
            k: v for k, v in request.data.items()
            if k in ('vehicle_type', 'service_zones', 'id_document_url',
                     'licence_document_url', 'phone', 'bio', 'submit')
        }
        serializer = DeliveryPersonnelApplicationSerializer(app, data=payload, partial=True)
        if not serializer.is_valid():
            return Response({'success': False, 'data': None, 'message': 'Validation failed.',
                             'errors': serializer.errors, 'pagination': None}, status=400)
        app = serializer.save()

        submit = (str(request.query_params.get('submit', '')).lower() == 'true'
                  or str(request.data.get('submit', '')).lower() == 'true')
        if submit and app.status != 'submitted':
            app.status = 'submitted'
            app.save(update_fields=['status', 'updated_at'])

        return Response({
            'success': True, 'data': DeliveryPersonnelApplicationSerializer(app).data,
            'message': f'Application {app.status}.', 'errors': None, 'pagination': None,
        }, status=201 if app.status == 'submitted' else 200)


class PushDeviceView(views.APIView):
    """Register / update / delete push notification device tokens."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        token = request.data.get('token')
        platform = request.data.get('platform', 'fcm')
        device_name = request.data.get('device_name', '')

        if not token:
            return Response({'success': False, 'data': None, 'message': 'Token required.',
                             'errors': None, 'pagination': None}, status=400)

        device, _ = PushDevice.objects.update_or_create(
            profile=request.user.profile,
            token=token,
            defaults={'platform': platform, 'device_name': device_name, 'is_active': True},
        )
        return Response({'success': True, 'data': PushDeviceSerializer(device).data,
                         'message': 'Device registered.', 'errors': None, 'pagination': None})

    def delete(self, request):
        token = request.data.get('token')
        PushDevice.objects.filter(profile=request.user.profile, token=token).update(is_active=False)
        return Response({'success': True, 'data': None, 'message': 'Device deregistered.',
                         'errors': None, 'pagination': None})


class ProgrammeActivityProgressView(views.APIView):
    """Get or update progress for a specific activity in a programme purchase."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, programme_id):
        purchase = get_object_or_404(
            TrainingProgrammePurchase, programme_id=programme_id, buyer=request.user.profile
        )
        progress = purchase.activity_progress.all()
        return Response({
            'success': True,
            'data': ProgrammeActivityProgressSerializer(progress, many=True).data,
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    def patch(self, request, programme_id):
        purchase = get_object_or_404(
            TrainingProgrammePurchase, programme_id=programme_id, buyer=request.user.profile
        )
        activity_key = request.data.get('activity_key')
        new_status = request.data.get('status', 'in_progress')
        notes = request.data.get('notes', '')

        progress, _ = ProgrammeActivityProgress.objects.get_or_create(
            purchase=purchase, activity_key=activity_key
        )
        progress.status = new_status
        if new_status == 'completed':
            progress.completed_at = timezone.now()
        progress.notes = notes
        progress.save()

        return Response({
            'success': True,
            'data': ProgrammeActivityProgressSerializer(progress).data,
            'message': 'Progress updated.', 'errors': None, 'pagination': None,
        })


# ===========================================================================
# My Shops (convenience endpoint)
# ===========================================================================

class MyShopsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        memberships = ShopMembership.objects.filter(
            profile=request.user.profile
        ).select_related('shop').prefetch_related('shop__memberships')

        shops_data = []
        for m in memberships:
            s = ShopDetailSerializer(m.shop, context={'request': request}).data
            s['my_role'] = m.role
            shops_data.append(s)

        return Response({'success': True, 'data': shops_data, 'message': 'OK',
                         'errors': None, 'pagination': None})



class RegisterCreatorView(views.APIView):
    """Explicitly register the current user as a marketplace creator by
    provisioning a shop they own. This replaces the old silent auto-create hack."""
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def post(self, request):
        profile = request.user.profile
        if ShopMembership.objects.filter(profile=profile, role__in=('owner', 'manager')).exists():
            return Response({
                'success': False, 'data': None,
                'message': 'You are already registered as a creator.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        name = (request.data.get('name') or '').strip() or f"{profile.display_name or profile.username}'s Shop"
        handle_base = (request.data.get('handle') or '').strip().lower() or f"{profile.username.lower().replace(' ', '-')}-shop"
        handle = handle_base
        suffix = 1
        while Shop.objects.filter(handle=handle).exists():
            suffix += 1
            handle = f"{handle_base}-{suffix}"

        shop = Shop.objects.create(
            name=name,
            handle=handle,
            description=request.data.get('description', ''),
            category=request.data.get('category', 'mixed'),
        )
        ShopMembership.objects.create(shop=shop, profile=profile, role='owner')

        from apps.notifications.tasks import create_notification
        create_notification.delay(
            str(request.user.id),
            'shop_created',
            f'Your shop "{shop.name}" is live! 🛍️',
            'Start adding your services to reach buyers on BuddyUp Fit.',
            {'shop_id': str(shop.id), 'shop_handle': shop.handle},
        )

        return Response({
            'success': True,
            'data': ShopDetailSerializer(shop, context={'request': request}).data,
            'message': 'You are now a creator.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class MealPlanListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        diet_type = request.query_params.get('diet_type', '')
        profile = request.user.profile
        qs = MealPlan.objects.filter(is_published=True).select_related('creator')
        # Audience scope: public plans for discovery; buddies/private plans
        # only surface to their intended audience (creator sees their own).
        buddy_ids = set(
            BuddyRelationship.objects.filter(
                (db_models.Q(from_user=profile) | db_models.Q(to_user=profile)),
                status='confirmed',
            ).values_list(
                db_models.Case(db_models.When(from_user=profile, then='to_user_id'), default='from_user_id'),
                flat=True,
            )
        )
        audience_q = (
            db_models.Q(visibility='public')
            | db_models.Q(creator=profile)
            | (db_models.Q(visibility='buddies') & db_models.Q(creator_id__in=buddy_ids))
        )
        qs = qs.filter(audience_q)
        if diet_type:
            qs = qs.filter(diet_type=diet_type)
        qs = gate_mature_queryset(request, qs)
        qs = qs.order_by('-purchase_count', '-average_rating')

        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = MealPlanSerializer(page, many=True, context={'request': request})

        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None,
            'pagination': {'count': paginator.page.paginator.count, 'next': paginator.get_next_link(), 'previous': paginator.get_previous_link()},
        })

    def post(self, request):
        serializer = CreateMealPlanSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        shop_id = data.pop('shop_id', None)
        shop, error = _resolve_creator_shop(request.user.profile, shop_id)
        if error:
            return Response({
                'success': False, 'data': None, 'message': error,
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)
        plan = MealPlan.objects.create(
            creator=request.user.profile,
            shop=shop,
            **data,
        )
        output = MealPlanFullSerializer(plan, context={'request': request})
        return Response({
            'success': True, 'data': output.data,
            'message': 'Meal plan created.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class MealPlanDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, plan_id):
        plan = get_object_or_404(MealPlan, id=plan_id, is_published=True)
        profile = request.user.profile
        is_owner = profile == plan.creator
        is_purchased = MealPlanPurchase.objects.filter(meal_plan=plan, buyer=profile).exists()

        if not is_owner:
            # Audience scope check before any other logic.
            if plan.visibility == 'private':
                return Response({
                    'success': False, 'data': None, 'message': 'Not found.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_404_NOT_FOUND)
            if plan.visibility == 'buddies':
                is_buddy = BuddyRelationship.objects.filter(
                    (db_models.Q(from_user=profile) | db_models.Q(to_user=profile)),
                    status='confirmed',
                ).filter(
                    db_models.Q(from_user=plan.creator) | db_models.Q(to_user=plan.creator)
                ).exists()
                if not is_buddy and not is_purchased:
                    return Response({
                        'success': False, 'data': None, 'message': 'Not found.',
                        'errors': None, 'pagination': None,
                    }, status=status.HTTP_404_NOT_FOUND)

        if not is_owner and not can_view_content(request, plan):
            return Response({
                'success': False, 'data': None, 'message': 'Not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)

        if is_owner or is_purchased:
            serializer = MealPlanFullSerializer(plan, context={'request': request})
        else:
            serializer = MealPlanSerializer(plan, context={'request': request})

        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def put(self, request, plan_id):
        plan = get_object_or_404(MealPlan, id=plan_id, creator=request.user.profile)
        serializer = UpdateMealPlanSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        for k, v in serializer.validated_data.items():
            setattr(plan, k, v)
        plan.save()
        output = MealPlanFullSerializer(plan, context={'request': request})
        return Response({
            'success': True, 'data': output.data,
            'message': 'Meal plan updated.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, plan_id):
        plan = get_object_or_404(MealPlan, id=plan_id, creator=request.user.profile)
        plan.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Meal plan deleted.',
            'errors': None, 'pagination': None,
        })


class PurchaseMealPlanView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, plan_id):
        plan = get_object_or_404(MealPlan, id=plan_id, is_published=True)
        buyer = request.user.profile

        if plan.creator == buyer:
            return Response({
                'success': False, 'data': None,
                'message': 'You cannot purchase your own meal plan.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        purchase, created = MealPlanPurchase.objects.get_or_create(
            meal_plan=plan, buyer=buyer,
        )
        if not created:
            return Response({
                'success': False, 'data': None,
                'message': 'You already purchased this meal plan.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if plan.price_artifacts:
            platform_cut_rate = PLATFORM_CUTS.get('marketplace', 0.15)
            with transaction.atomic():
                for at, qty in plan.price_artifacts.items():
                    if not deduct_artifacts(buyer, at, qty):
                        raise ValidationError(f'Insufficient {at} tokens.')

                    cut_qty = max(1, int(qty * platform_cut_rate))
                    creator_qty = qty - cut_qty
                    if creator_qty > 0:
                        credit_artifacts(plan.creator, at, creator_qty)

                    ArtifactTransaction.objects.create(
                        user=buyer, transaction_type='marketplace',
                        artifact_type=at, quantity=qty, direction='debit',
                        counterparty=plan.creator, status='completed',
                        reference_id=f'mp_mp_{plan.id}',
                    )
                    if creator_qty > 0:
                        ArtifactTransaction.objects.create(
                            user=plan.creator, transaction_type='marketplace',
                            artifact_type=at, quantity=creator_qty, direction='credit',
                            counterparty=buyer, status='completed',
                            reference_id=f'mp_mp_{plan.id}',
                        )
                    if cut_qty > 0:
                        ArtifactTransaction.objects.create(
                            user=plan.creator, transaction_type='platform_cut',
                            artifact_type=at, quantity=cut_qty, direction='debit',
                            status='completed',
                            description=f'Platform fee ({int(platform_cut_rate * 100)}%)',
                        )

                first_tx = ArtifactTransaction.objects.filter(
                    user=buyer, transaction_type='marketplace',
                    reference_id=f'mp_mp_{plan.id}',
                ).first()
                if first_tx:
                    purchase.tx_id = str(first_tx.id)
                    purchase.save(update_fields=['tx_id'])

        plan.purchase_count = db_models.F('purchase_count') + 1
        plan.save(update_fields=['purchase_count'])

        order = _create_order_for_purchase(
            buyer, 'meal_plan', plan, plan.title, plan.creator, plan.price_artifacts,
        )

        serializer = MealPlanFullSerializer(plan, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data,
            'message': 'Meal plan purchased! Enjoy your plan.',
            'errors': None, 'pagination': None,
            'order_id': str(order.id),
            'order_number': order.order_number,
        })


class MealPlanReviewView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, plan_id):
        get_object_or_404(MealPlan, id=plan_id)
        reviews = MealPlanReview.objects.filter(meal_plan_id=plan_id).select_related('buyer').order_by('-created_at')
        serializer = MealPlanReviewSerializer(reviews, many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def post(self, request, plan_id):
        purchase = get_object_or_404(MealPlanPurchase, meal_plan_id=plan_id, buyer=request.user.profile)
        if MealPlanReview.objects.filter(purchase=purchase).exists():
            return Response({
                'success': False, 'data': None,
                'message': 'You already reviewed this meal plan.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        serializer = ReviewInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        review = MealPlanReview.objects.create(
            purchase=purchase, buyer=request.user.profile,
            meal_plan=purchase.meal_plan,
            rating=serializer.validated_data['rating'],
            body=serializer.validated_data.get('body', '')[:500],
        )

        plan = purchase.meal_plan
        avg = MealPlanReview.objects.filter(meal_plan=plan).aggregate(avg=db_models.Avg('rating'))['avg'] or 0
        plan.average_rating = round(avg, 1)
        plan.review_count = db_models.F('review_count') + 1
        plan.save(update_fields=['average_rating', 'review_count'])

        return Response({
            'success': True,
            'data': MealPlanReviewSerializer(review).data,
            'message': 'Review submitted!',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class PersonaliseMealPlanView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, plan_id):
        plan = get_object_or_404(MealPlan, id=plan_id, is_published=True)
        purchase = get_object_or_404(MealPlanPurchase, meal_plan=plan, buyer=request.user.profile)

        from .tasks import personalise_meal_plan
        personalise_meal_plan.delay(str(purchase.id), str(request.user.profile.user_id))

        return Response({
            'success': True, 'data': {'status': 'processing'},
            'message': 'Personalising your meal plan... You\'ll be notified when it\'s ready.',
            'errors': None, 'pagination': None,
        })


class TrainingProgrammeListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        category = request.query_params.get('category', '')
        qs = TrainingProgramme.objects.filter(is_published=True).select_related('creator')
        if category:
            qs = qs.filter(category=category)
        qs = gate_mature_queryset(request, qs)

        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(qs.order_by('-purchase_count'), request)
        serializer = TrainingProgrammeSerializer(page, many=True, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None,
            'pagination': {'count': paginator.page.paginator.count, 'next': paginator.get_next_link(), 'previous': paginator.get_previous_link()},
        })

    def post(self, request):
        serializer = CreateTrainingProgrammeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        shop_id = data.pop('shop_id', None)
        shop, error = _resolve_creator_shop(request.user.profile, shop_id)
        if error:
            return Response({
                'success': False, 'data': None, 'message': error,
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)
        programme = TrainingProgramme.objects.create(
            creator=request.user.profile,
            shop=shop,
            **data,
        )
        output = TrainingProgrammeSerializer(programme, context={'request': request})
        return Response({
            'success': True, 'data': output.data,
            'message': 'Programme created.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class TrainingProgrammeDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, programme_id):
        programme = get_object_or_404(TrainingProgramme, id=programme_id, is_published=True)
        if programme.creator != request.user.profile and not can_view_content(request, programme):
            return Response({
                'success': False, 'data': None, 'message': 'Not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)
        serializer = TrainingProgrammeSerializer(programme, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def put(self, request, programme_id):
        programme = get_object_or_404(TrainingProgramme, id=programme_id, creator=request.user.profile)
        serializer = UpdateTrainingProgrammeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        for k, v in serializer.validated_data.items():
            setattr(programme, k, v)
        programme.save()
        output = TrainingProgrammeSerializer(programme, context={'request': request})
        return Response({
            'success': True, 'data': output.data,
            'message': 'Programme updated.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, programme_id):
        programme = get_object_or_404(TrainingProgramme, id=programme_id, creator=request.user.profile)
        programme.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Programme deleted.',
            'errors': None, 'pagination': None,
        })


class PurchaseTrainingProgrammeView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, programme_id):
        programme = get_object_or_404(TrainingProgramme, id=programme_id, is_published=True)
        buyer = request.user.profile

        if programme.creator == buyer:
            return Response({
                'success': False, 'data': None,
                'message': 'You cannot purchase your own programme.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        purchase, created = TrainingProgrammePurchase.objects.get_or_create(
            programme=programme, buyer=buyer,
        )
        if not created:
            return Response({
                'success': False, 'data': None,
                'message': 'You already purchased this programme.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if programme.price_artifacts:
            platform_cut_rate = PLATFORM_CUTS.get('marketplace', 0.15)
            with transaction.atomic():
                for at, qty in programme.price_artifacts.items():
                    if not deduct_artifacts(buyer, at, qty):
                        raise ValidationError(f'Insufficient {at} tokens.')

                    cut_qty = max(1, int(qty * platform_cut_rate))
                    creator_qty = qty - cut_qty
                    if creator_qty > 0:
                        credit_artifacts(programme.creator, at, creator_qty)

                    ArtifactTransaction.objects.create(
                        user=buyer, transaction_type='marketplace',
                        artifact_type=at, quantity=qty, direction='debit',
                        counterparty=programme.creator, status='completed',
                        reference_id=f'mp_tp_{programme.id}',
                    )
                    if creator_qty > 0:
                        ArtifactTransaction.objects.create(
                            user=programme.creator, transaction_type='marketplace',
                            artifact_type=at, quantity=creator_qty, direction='credit',
                            counterparty=buyer, status='completed',
                            reference_id=f'mp_tp_{programme.id}',
                        )
                    if cut_qty > 0:
                        ArtifactTransaction.objects.create(
                            user=programme.creator, transaction_type='platform_cut',
                            artifact_type=at, quantity=cut_qty, direction='debit',
                            status='completed',
                            description=f'Platform fee ({int(platform_cut_rate * 100)}%)',
                        )

                first_tx = ArtifactTransaction.objects.filter(
                    user=buyer, transaction_type='marketplace',
                    reference_id=f'mp_tp_{programme.id}',
                ).first()
                if first_tx:
                    purchase.tx_id = str(first_tx.id)
                    purchase.save(update_fields=['tx_id'])

        programme.purchase_count = db_models.F('purchase_count') + 1
        programme.save(update_fields=['purchase_count'])

        order = _create_order_for_purchase(
            buyer, 'programme', programme, programme.title, programme.creator, programme.price_artifacts,
        )

        serializer = TrainingProgrammeSerializer(programme, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data,
            'message': 'Programme purchased!',
            'errors': None, 'pagination': None,
            'order_id': str(order.id),
            'order_number': order.order_number,
        })


class TrainingProgrammeReviewView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, programme_id):
        get_object_or_404(TrainingProgramme, id=programme_id)
        reviews = TrainingProgrammeReview.objects.filter(programme_id=programme_id).select_related('buyer').order_by('-created_at')
        serializer = TrainingProgrammeReviewSerializer(reviews, many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def post(self, request, programme_id):
        purchase = get_object_or_404(TrainingProgrammePurchase, programme_id=programme_id, buyer=request.user.profile)
        if TrainingProgrammeReview.objects.filter(purchase=purchase).exists():
            return Response({
                'success': False, 'data': None,
                'message': 'You already reviewed this programme.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        serializer = ReviewInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        review = TrainingProgrammeReview.objects.create(
            purchase=purchase, buyer=request.user.profile,
            programme=purchase.programme,
            rating=serializer.validated_data['rating'],
            body=serializer.validated_data.get('body', '')[:500],
        )

        serializer = TrainingProgrammeReviewSerializer(review)
        return Response({
            'success': True, 'data': serializer.data,
            'message': 'Review submitted!',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class ProductListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        category = request.query_params.get('category', '')
        qs = Product.objects.filter(is_active=True).filter(
            ~db_models.Q(category='supplement') |
            (
                db_models.Q(category='supplement', supplement_registration_number__gt='',
                            supplement_claims_reviewed=True) &
                (db_models.Q(supplement_registration_expiry__isnull=True) |
                 db_models.Q(supplement_registration_expiry__gte=timezone.now().date()))
            )
        ).select_related('recommended_by')
        if category:
            qs = qs.filter(category=category)
        qs = gate_mature_queryset(request, qs)

        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(qs.order_by('-click_count'), request)
        serializer = ProductSerializer(page, many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None,
            'pagination': {'count': paginator.page.paginator.count, 'next': paginator.get_next_link(), 'previous': paginator.get_previous_link()},
        })

    def post(self, request):
        serializer = CreateProductSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        shop_id = data.pop('shop_id', None)
        shop, error = _resolve_creator_shop(request.user.profile, shop_id)
        if error:
            return Response({
                'success': False, 'data': None, 'message': error,
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)
        product = Product.objects.create(
            recommended_by=request.user.profile,
            shop=shop,
            **data,
        )
        output = ProductSerializer(product)
        return Response({
            'success': True, 'data': output.data,
            'message': 'Product created.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class ProductDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, product_id):
        product = get_object_or_404(
            Product.objects.filter(is_active=True).filter(
                ~db_models.Q(category='supplement') |
                (
                    db_models.Q(category='supplement', supplement_registration_number__gt='',
                                supplement_claims_reviewed=True) &
                    (db_models.Q(supplement_registration_expiry__isnull=True) |
                     db_models.Q(supplement_registration_expiry__gte=timezone.now().date()))
                )
            ),
            id=product_id,
        )
        if product.recommended_by != request.user.profile and not can_view_content(request, product):
            return Response({
                'success': False, 'data': None, 'message': 'Not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)
        serializer = ProductSerializer(product)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def put(self, request, product_id):
        product = get_object_or_404(Product, id=product_id, recommended_by=request.user.profile)
        serializer = UpdateProductSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = dict(serializer.validated_data)
        shop_id = data.pop('shop_id', None)
        if shop_id:
            shop, error = _resolve_creator_shop(request.user.profile, shop_id)
            if error:
                return Response({
                    'success': False, 'data': None, 'message': error,
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_403_FORBIDDEN)
            product.shop = shop
        for k, v in data.items():
            setattr(product, k, v)
        product.save()
        output = ProductSerializer(product)
        return Response({
            'success': True, 'data': output.data,
            'message': 'Product updated.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, product_id):
        product = get_object_or_404(Product, id=product_id, recommended_by=request.user.profile)
        product.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Product deleted.',
            'errors': None, 'pagination': None,
        })


class ProductClickView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, product_id):
        get_object_or_404(Product, id=product_id, is_active=True)
        Product.objects.filter(id=product_id).update(click_count=db_models.F('click_count') + 1)
        return Response({
            'success': True, 'data': None,
            'message': 'Click tracked.',
            'errors': None, 'pagination': None,
        })


class EventListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = MarketplaceEvent.objects.filter(is_published=True, is_cancelled=False)
        category = request.query_params.get('category')
        event_type = request.query_params.get('event_type')
        gym_id = request.query_params.get('gym_id')
        gym_handle = (request.query_params.get('gym') or '').strip()
        shop_id = request.query_params.get('shop_id')
        query = (request.query_params.get('q') or '').strip()
        city = (request.query_params.get('city') or '').strip()
        verified_only = request.query_params.get('verified') == 'true'
        free_only = request.query_params.get('is_free') == 'true'
        upcoming_only = request.query_params.get('upcoming', 'true').lower() == 'true'
        scope = request.query_params.get('scope', '')
        if category:
            qs = qs.filter(category=category)
        if event_type:
            qs = qs.filter(event_type=event_type)
        if gym_id:
            qs = qs.filter(gym_id=gym_id)
        if gym_handle:
            qs = qs.filter(gym__handle__iexact=gym_handle)
        if shop_id:
            qs = qs.filter(shop_id=shop_id)
        if query:
            from django.db.models import Q
            qs = qs.filter(
                Q(title__icontains=query) | Q(description__icontains=query)
                | Q(location__icontains=query)
            )
        if city:
            from django.db.models import Q
            qs = qs.filter(
                Q(location__icontains=city)
                | Q(gym__location_city__icontains=city)
                | Q(gym__venues__city__icontains=city, gym__venues__is_active=True)
            )
        if verified_only:
            from django.db.models import Q
            qs = qs.filter(
                Q(shop__verification_status='verified')
                | Q(gym__is_verified=True)
                | Q(creator__verification_status__in=['trainer', 'practitioner', 'id'])
            )
        if free_only:
            qs = qs.filter(is_free=True)
        # Note: events carry no ratings of their own; quality facets come
        # from the affiliated gym/shop/creator verification instead.
        lat = lng = None
        try:
            if request.query_params.get('lat') not in (None, ''):
                lat = float(request.query_params.get('lat'))
            if request.query_params.get('lng') not in (None, ''):
                lng = float(request.query_params.get('lng'))
        except (TypeError, ValueError):
            lat = lng = None
        radius_param = request.query_params.get('radius_km', '')
        radius_explicit = str(radius_param).strip() != ''
        try:
            radius_km = float(radius_param or 25)
        except (TypeError, ValueError):
            radius_km = 25
            radius_explicit = False
        radius_km = min(max(radius_km, 1), 200)
        geo_auto = False
        geo_density = None
        geo_count_in_near = None
        if lat is not None and lng is not None and not radius_explicit:
            from common.geo import NEAR_RADIUS_KM, count_within_latlng, pick_adaptive_radius
            geo_count_in_near = count_within_latlng(
                MarketplaceEvent.objects.all(), lat, lng, NEAR_RADIUS_KM,
                lat_field='location_lat', lng_field='location_lng',
            )
            radius_km, geo_density = pick_adaptive_radius(geo_count_in_near)
            geo_auto = True
        if lat is not None and lng is not None:
            from common.geo import bbox_deltas
            lat_delta, lng_delta = bbox_deltas(lat, radius_km)
            qs = qs.filter(
                location_lat__isnull=False, location_lng__isnull=False,
                location_lat__gte=lat - lat_delta, location_lat__lte=lat + lat_delta,
                location_lng__gte=lng - lng_delta, location_lng__lte=lng + lng_delta,
            )
        from django.utils import timezone as tz
        if scope == 'past':
            qs = qs.filter(start_datetime__lt=tz.now())
        elif scope == 'all':
            pass
        elif upcoming_only:
            qs = qs.filter(start_datetime__gte=tz.now())
        qs = qs.distinct().order_by('start_datetime')
        qs = gate_mature_queryset(request, qs)
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = MarketplaceEventSerializer(page, many=True, context={'request': request})
        data = list(serializer.data)

        if lat is not None and lng is not None and data:
            from common.geo import adaptive_message, haversine_km
            for ev in data:
                try:
                    elat, elng = float(ev['location_lat']), float(ev['location_lng'])
                    ev['distance_km'] = round(haversine_km(lat, lng, elat, elng), 1)
                except (TypeError, ValueError, KeyError):
                    ev['distance_km'] = None
            data.sort(key=lambda e: (e['distance_km'] is None, e['distance_km'] or 0))

        geo = None
        if lat is not None and lng is not None:
            from common.geo import adaptive_message
            message = None
            if geo_auto:
                message = adaptive_message(radius_km, geo_density or 'sparse', geo_count_in_near or 0)
            geo = {
                'lat': lat, 'lng': lng, 'radius_km': radius_km, 'auto': geo_auto,
                'density': geo_density, 'count_in_near': geo_count_in_near,
                'message': message,
            }

        return Response({
            'success': True,
            'data': data,
            'geo': geo,
            'pagination': {
                'count': paginator.page.paginator.count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })

    def post(self, request):
        ser = CreateEventSerializer(data=request.data)
        if not ser.is_valid():
            return Response({'success': False, 'errors': ser.errors}, status=400)
        data = ser.validated_data
        gym = None
        gym_id = data.pop('gym_id', None)
        if gym_id:
            try:
                from apps.gyms.models import Gym
                gym = Gym.objects.get(id=gym_id)
            except Exception:  # noqa: BLE001
                pass
        
        shop_id = data.pop('shop_id', None)
        shop, error = _resolve_creator_shop(request.user.profile, shop_id)
        if error:
            return Response({'success': False, 'data': None, 'message': error,
                             'errors': None, 'pagination': None}, status=403)

        event = MarketplaceEvent.objects.create(
            creator=request.user.profile,
            gym=gym,
            shop=shop,
            **data
        )
        return Response({'success': True, 'data': MarketplaceEventSerializer(event, context={'request': request}).data}, status=201)


class EventDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self, event_id):
        try:
            return MarketplaceEvent.objects.get(id=event_id)
        except MarketplaceEvent.DoesNotExist:
            return None

    def get(self, request, event_id):
        event = self.get_object(event_id)
        if not event:
            return Response({'success': False, 'message': 'Event not found.'}, status=404)
        if event.creator != request.user.profile and not can_view_content(request, event):
            return Response({'success': False, 'data': None, 'message': 'Not found.'},
                            status=status.HTTP_404_NOT_FOUND)
        return Response({'success': True, 'data': MarketplaceEventSerializer(event, context={'request': request}).data})

    def put(self, request, event_id):
        event = self.get_object(event_id)
        if not event:
            return Response({'success': False, 'message': 'Event not found.'}, status=404)
        if event.creator != request.user.profile:
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)
        updatable = ['title', 'description', 'cover_image_url', 'promo_video_url', 'gallery_urls',
                     'event_type', 'location', 'location_lat', 'location_lng', 'online_url',
                     'start_datetime', 'end_datetime',
                     'timezone', 'capacity', 'ticket_price_artifacts', 'is_free', 'is_published',
                     'tags', 'category', 'agenda', 'recurrence', 'ticket_tiers',
                     'early_bird_enabled', 'early_bird_deadline', 'early_bird_price_artifacts',
                     'cancellation_policy', 'is_draft']
        for field in updatable:
            if field in request.data:
                setattr(event, field, request.data[field])
        event.save()
        return Response({'success': True, 'data': MarketplaceEventSerializer(event, context={'request': request}).data})

    def delete(self, request, event_id):
        event = self.get_object(event_id)
        if not event:
            return Response({'success': False, 'message': 'Event not found.'}, status=404)
        if event.creator != request.user.profile:
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)
        event.is_cancelled = True
        event.save()
        return Response({'success': True, 'message': 'Event cancelled.'})


class PurchaseEventTicketView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, event_id):
        try:
            event = MarketplaceEvent.objects.get(id=event_id)
        except MarketplaceEvent.DoesNotExist:
            return Response({'success': False, 'message': 'Event not found.'}, status=404)

        if event.is_cancelled:
            return Response({'success': False, 'message': 'This event has been cancelled.'}, status=400)

        profile = request.user.profile
        if event.creator == profile:
            return Response({'success': False, 'message': 'You cannot purchase your own event.'}, status=400)

        if EventTicket.objects.filter(event=event, holder=profile, status='active').exists():
            return Response({'success': False, 'message': 'You already have a ticket for this event.'}, status=400)

        if event.capacity > 0 and event.attendee_count >= event.capacity:
            return Response({'success': False, 'message': 'This event is sold out.'}, status=400)

        tier_name = (request.data.get('tier') or '').strip()
        tier_entry = None
        if tier_name:
            for t in (event.ticket_tiers or []):
                if str(t.get('name', '')).lower() == tier_name.lower():
                    tier_entry = t
                    break
            if tier_entry is None:
                return Response({'success': False, 'message': f'Unknown ticket tier: {tier_name}.'}, status=400)

        price_artifacts = (tier_entry.get('price_artifacts') if tier_entry else None) or event.ticket_price_artifacts
        if price_artifacts and not event.is_free:
            from apps.wallet.utils import credit_artifacts
            platform_cut_rate = PLATFORM_CUTS.get('marketplace', 0.15)
            with transaction.atomic():
                for at, qty in price_artifacts.items():
                    if not deduct_artifacts(profile, at, qty):
                        raise ValidationError(f'Insufficient {at} tokens.')
                    ArtifactTransaction.objects.create(
                        user=profile, transaction_type='marketplace', artifact_type=at,
                        quantity=qty, direction='debit', counterparty=event.creator,
                        status='completed', reference_id=f'mp_et_{event.id}',
                        fiat_amount=round(qty * ARTIFACT_VALUES.get(at, 0), 2),
                        fiat_currency='USD',
                    )
                    cut_qty = max(1, int(qty * platform_cut_rate))
                    creator_qty = qty - cut_qty
                    if creator_qty > 0:
                        credit_artifacts(event.creator, at, creator_qty)
                        ArtifactTransaction.objects.create(
                            user=event.creator, transaction_type='marketplace', artifact_type=at,
                            quantity=creator_qty, direction='credit', counterparty=profile,
                            status='completed', reference_id=f'mp_et_{event.id}',
                            fiat_amount=round(creator_qty * ARTIFACT_VALUES.get(at, 0), 2),
                            fiat_currency='USD',
                        )
                    if cut_qty > 0:
                        ArtifactTransaction.objects.create(
                            user=event.creator, transaction_type='platform_cut', artifact_type=at,
                            quantity=cut_qty, direction='debit', status='completed',
                            reference_id=f'mp_et_{event.id}',
                            fiat_amount=round(cut_qty * ARTIFACT_VALUES.get(at, 0), 2),
                            fiat_currency='USD',
                        )

        ticket, created = EventTicket.objects.get_or_create(
            event=event, holder=profile, defaults={
                'status': 'active', 'price_paid_artifacts': price_artifacts if not event.is_free else {},
                'tier': (tier_entry.get('name') if tier_entry else None) or 'Standard',
            }
        )
        if not created and ticket.status != 'active':
            ticket.status = 'active'
            ticket.save(update_fields=['status'])
        event.attendee_count = EventTicket.objects.filter(event=event, status='active').count()
        event.save(update_fields=['attendee_count'])

        order = _create_order_for_purchase(
            profile, 'event_ticket', event, event.title, event.creator,
            {} if event.is_free else price_artifacts,
        )

        from .tasks import send_ticket_confirmation
        send_ticket_confirmation.delay(str(ticket.id))

        return Response({
            'success': True,
            'data': EventTicketSerializer(ticket, context={'request': request}).data,
            'order_id': str(order.id),
            'order_number': order.order_number,
        }, status=201 if created else 200)


class MyEventTicketsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        tickets = EventTicket.objects.filter(
            holder=request.user.profile, status='active'
        ).select_related('event').order_by('event__start_datetime')
        return Response({'success': True, 'data': EventTicketSerializer(tickets, many=True, context={'request': request}).data})


class EventTicketDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, ticket_id):
        try:
            ticket = EventTicket.objects.get(id=ticket_id, holder=request.user.profile)
        except EventTicket.DoesNotExist:
            return Response({'success': False, 'message': 'Ticket not found.'}, status=404)
        return Response({'success': True, 'data': EventTicketSerializer(ticket, context={'request': request}).data})


class EventMediaManageView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get(self, request, event_id):
        try:
            event = MarketplaceEvent.objects.get(id=event_id)
        except MarketplaceEvent.DoesNotExist:
            return Response({'success': False, 'message': 'Event not found.'}, status=404)
        media = event.media.all()
        return Response({'success': True, 'data': EventMediaSerializer(media, many=True).data})

    def post(self, request, event_id):
        try:
            event = MarketplaceEvent.objects.get(id=event_id)
        except MarketplaceEvent.DoesNotExist:
            return Response({'success': False, 'message': 'Event not found.'}, status=404)
        if event.creator != request.user.profile:
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)

        media_type = request.data.get('media_type', 'image')
        sort_order = int(request.data.get('sort_order', 0))
        alt_text = request.data.get('alt_text', '')

        em = EventMedia.objects.create(
            event=event,
            media_type=media_type,
            sort_order=sort_order,
            alt_text=alt_text,
        )
        if 'file' in request.FILES:
            em.file = request.FILES['file']
            em.save()
        elif 'url' in request.data:
            em.url = request.data['url']
            em.save()

        return Response({'success': True, 'data': EventMediaSerializer(em).data}, status=201)

    def delete(self, request, event_id, **kwargs):
        media_id = kwargs.get('media_id')
        try:
            em = EventMedia.objects.get(id=media_id, event_id=event_id)
        except EventMedia.DoesNotExist:
            return Response({'success': False, 'message': 'Media not found.'}, status=404)
        if em.event.creator != request.user.profile:
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)
        em.delete()
        return Response({'success': True, 'message': 'Media removed.'})


class FoodRecognizeView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        file = request.FILES.get('file')
        if not file:
            return Response({
                'success': False, 'data': None,
                'message': 'No image file provided.',
                'errors': 'file field is required.', 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if not file.content_type.startswith('image/'):
            return Response({
                'success': False, 'data': None,
                'message': 'File must be an image.',
                'errors': 'invalid content type.', 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        ai_url = f'{settings.AI_SERVICE_URL}/api/v1/food/recognize'
        try:
            resp = ai_post(
                ai_url, files={'file': (file.name, file.read(), file.content_type)},
                timeout=30,
            )
            resp.raise_for_status()
            data = resp.json()
            return Response({
                'success': True, 'data': data,
                'message': 'Food recognition complete.',
                'errors': None, 'pagination': None,
            })
        except Exception as e:  # noqa: BLE001
            return Response({
                'success': False, 'data': None,
                'message': 'Food recognition service unavailable.',
                'errors': str(e), 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)


class MyMarketplaceServicesView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        from django.db.models import Count
        profile = request.user.profile

        membership = ShopMembership.objects.filter(profile=profile).first()

        meal_plans = MealPlan.objects.filter(creator=profile).annotate(abandoned_cart_count=Count('cartitem'))
        programmes = TrainingProgramme.objects.filter(creator=profile).annotate(abandoned_cart_count=Count('cartitem'))
        events = MarketplaceEvent.objects.filter(creator=profile).annotate(abandoned_cart_count=Count('cartitem'))
        products = Product.objects.filter(shop_id=membership.shop_id if membership else None).annotate(abandoned_cart_count=Count('cartitem'))
        discount_codes = DiscountCode.objects.filter(creator=profile).order_by('-created_at')

        meal_plan_data = MealPlanSerializer(meal_plans, many=True, context={'request': request}).data
        programme_data = TrainingProgrammeSerializer(programmes, many=True, context={'request': request}).data
        event_data = MarketplaceEventSerializer(events, many=True, context={'request': request}).data
        product_data = ProductSerializer(products, many=True, context={'request': request}).data
        discount_data = DiscountCodeSerializer(discount_codes, many=True, context={'request': request}).data
        shop_data = ShopDetailSerializer(membership.shop, context={'request': request}).data if membership else None

        for i, obj in enumerate(meal_plans):
            meal_plan_data[i]['abandoned_cart_count'] = obj.abandoned_cart_count
        for i, obj in enumerate(programmes):
            programme_data[i]['abandoned_cart_count'] = obj.abandoned_cart_count
        for i, obj in enumerate(events):
            event_data[i]['abandoned_cart_count'] = obj.abandoned_cart_count
        for i, obj in enumerate(products):
            product_data[i]['abandoned_cart_count'] = obj.abandoned_cart_count

        return Response({
            'success': True,
            'data': {
                'shop': shop_data,
                'meal_plans': meal_plan_data,
                'programmes': programme_data,
                'events': event_data,
                'products': product_data,
                'discount_codes': discount_data,
            },
            'message': 'Drafts and services fetched.',
        })


class CreatorAnalyticsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        from django.db.models.functions import TruncMonth
        from collections import defaultdict
        profile = request.user.profile

        meal_plans = MealPlan.objects.filter(creator=profile)
        programmes = TrainingProgramme.objects.filter(creator=profile)
        events = MarketplaceEvent.objects.filter(creator=profile)

        total_sales = 0
        total_revenue = 0.0
        category_sales = defaultdict(int)
        category_revenue = defaultdict(float)

        for mp in meal_plans:
            cnt = mp.purchase_count
            total_sales += cnt
            if cnt > 0 and mp.price_artifacts:
                rev = sum(ARTIFACT_VALUES.get(k, 0) * v for k, v in mp.price_artifacts.items()) * cnt
                total_revenue += rev
                category_sales['meal_plan'] += cnt
                category_revenue['meal_plan'] += rev

        for p in programmes:
            cnt = p.purchase_count
            total_sales += cnt
            if cnt > 0 and p.price_artifacts:
                rev = sum(ARTIFACT_VALUES.get(k, 0) * v for k, v in p.price_artifacts.items()) * cnt
                total_revenue += rev
                category_sales['programme'] += cnt
                category_revenue['programme'] += rev

        for e in events:
            cnt = e.attendee_count
            total_sales += cnt
            if cnt > 0 and e.ticket_price_artifacts:
                rev = sum(ARTIFACT_VALUES.get(k, 0) * v for k, v in e.ticket_price_artifacts.items()) * cnt
                total_revenue += rev
                category_sales['event'] += cnt
                category_revenue['event'] += rev

        from apps.wallet.models import ArtifactTransaction
        revenue_txs = ArtifactTransaction.objects.filter(
            user=profile,
            transaction_type='marketplace',
            direction='credit',
            status='completed',
        )
        monthly_qs = (
            revenue_txs.annotate(month=TruncMonth('created_at'))
            .values('month')
            .annotate(total=db_models.Sum(db_models.F('quantity') * db_models.Value(1)))
            .order_by('month')
        )
        revenue_over_time = [
            {'month': m['month'].strftime('%Y-%m') if m['month'] else '', 'total': float(m['total'] or 0)}
            for m in monthly_qs
        ]

        top_services = sorted(
            [{'id': str(mp.id), 'title': mp.title, 'type': 'meal_plan', 'sales': mp.purchase_count}
             for mp in meal_plans if mp.purchase_count > 0]
            + [{'id': str(p.id), 'title': p.title, 'type': 'programme', 'sales': p.purchase_count}
               for p in programmes if p.purchase_count > 0]
            + [{'id': str(e.id), 'title': e.title, 'type': 'event', 'sales': e.attendee_count}
               for e in events if e.attendee_count > 0],
            key=lambda x: x['sales'], reverse=True
        )[:10]

        return Response({
            'success': True,
            'data': {
                'total_revenue_usd': round(total_revenue, 2),
                'total_sales': total_sales,
                'category_sales': dict(category_sales),
                'category_revenue': {k: round(v, 2) for k, v in category_revenue.items()},
                'revenue_over_time': revenue_over_time,
                'total_views': sum(mp.purchase_count for mp in meal_plans)
                             + sum(p.purchase_count for p in programmes)
                             + sum(e.attendee_count for e in events),
                'top_services': top_services,
            },
            'message': 'Creator analytics fetched.',
        })


class UserShopView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, handle):
        try:
            shop = Shop.objects.get(handle=handle, is_active=True)
        except Shop.DoesNotExist:
            return Response({'success': False, 'message': 'Shop not found.'}, status=404)

        profile_ids = ShopMembership.objects.filter(shop=shop).values_list('profile_id', flat=True)
        meal_plans = MealPlan.objects.filter(creator_id__in=profile_ids, is_active=True).order_by('-created_at')
        programmes = TrainingProgramme.objects.filter(creator_id__in=profile_ids, is_active=True).order_by('-created_at')
        events = MarketplaceEvent.objects.filter(creator_id__in=profile_ids, is_published=True, is_cancelled=False).order_by('-created_at')
        products = Product.objects.filter(shop_id=shop.id, is_active=True).order_by('-created_at')

        return Response({
            'success': True,
            'data': {
                'shop': ShopDetailSerializer(shop, context={'request': request}).data,
                'meal_plans': MealPlanSerializer(meal_plans, many=True, context={'request': request}).data,
                'programmes': TrainingProgrammeSerializer(programmes, many=True, context={'request': request}).data,
                'events': MarketplaceEventSerializer(events, many=True, context={'request': request}).data,
                'products': ProductSerializer(products, many=True, context={'request': request}).data,
            },
        })


class CartView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        cart, _ = Cart.objects.get_or_create(buyer=request.user.profile)
        from .serializers import CartSerializer
        from apps.wallet.serializers import ARTIFACT_VALUES
        rates = {
            'rates': ARTIFACT_VALUES,
            'base_currency': 'USD',
            'local_currency': 'KES',
            'conversion_rate': 129.5,
        }
        data = CartSerializer(cart, context={'request': request, 'rates': rates}).data
        data['suggested_fulfillment'] = self._suggested_fulfillment(cart)
        return Response({
            'success': True,
            'data': data,
            'message': 'Cart fetched.',
        })

    @staticmethod
    def _suggested_fulfillment(cart) -> dict:
        """Auto-detect fulfillment from cart composition.

        Tickets/plans/programmes are always digital. Products contribute
        their allowed delivery_modes (+ details); prefer delivery, then
        pickup, else digital. In-house vs user-premises is resolved at
        checkout from the product's fulfillment_details.
        """
        modes: list[str] = []
        details: dict = {}
        has_product = False
        for item in cart.items.select_related('product').all():
            if item.item_type != 'product' or not item.product:
                continue
            has_product = True
            for m in (item.product.delivery_modes or ['digital']):
                if m not in modes:
                    modes.append(m)
            for k, v in (item.product.fulfillment_details or {}).items():
                details.setdefault(k, v)
        if not has_product:
            return {'type': 'digital', 'available': ['digital'], 'detail': {}}
        preferred = 'digital'
        for candidate in ('delivery', 'pickup', 'digital'):
            if candidate in modes:
                preferred = candidate
                break
        return {'type': preferred, 'available': modes or ['digital'], 'detail': details}

    def post(self, request):
        cart, _ = Cart.objects.get_or_create(buyer=request.user.profile)
        item_type = request.data.get('item_type')
        try:
            quantity = int(request.data.get('quantity', 1))
        except (TypeError, ValueError):
            return Response({'success': False, 'message': 'Quantity must be an integer.'}, status=400)
        # Clamp server-side: negative or absurd quantities would corrupt totals.
        quantity = max(1, min(quantity, 99))

        # Determine the target ID key
        target_id_map = {
            'meal_plan': ('meal_plan_id', MealPlan),
            'programme': ('programme_id', TrainingProgramme),
            'product': ('product_id', Product),
            'event_ticket': ('event_id', MarketplaceEvent),
        }
        
        if item_type not in target_id_map:
            return Response({'success': False, 'message': 'Invalid item type.'}, status=400)
            
        key_name, model_class = target_id_map[item_type]
        target_id = request.data.get(key_name)
        try:
            target_obj = model_class.objects.get(id=target_id)
        except model_class.DoesNotExist:
            return Response({'success': False, 'message': 'Item not found.'}, status=404)
            
        # Add to cart (event tickets may carry a tier variant).
        kwargs = {'cart': cart, 'item_type': item_type, key_name.replace('_id', ''): target_obj}
        if item_type == 'event_ticket':
            tier_name = (request.data.get('tier') or '').strip()
            if tier_name:
                match = next(
                    (t for t in (target_obj.ticket_tiers or [])
                     if str(t.get('name', '')).lower() == tier_name.lower()),
                    None,
                )
                if match is None:
                    return Response({'success': False, 'message': f'Unknown ticket tier: {tier_name}.'}, status=400)
                kwargs['meta'] = {'tier': match.get('name')}
            else:
                kwargs['meta'] = {}
        item, created = CartItem.objects.get_or_create(**kwargs)
        if not created:
            item.quantity += quantity
            item.save(update_fields=['quantity'])
        else:
            item.quantity = quantity
            item.save()
            
        from .serializers import CartSerializer
        return Response({'success': True, 'data': CartSerializer(cart, context={'request': request}).data, 'message': 'Added to cart.'})

    def delete(self, request):
        cart, _ = Cart.objects.get_or_create(buyer=request.user.profile)
        item_id = request.data.get('item_id')
        if item_id:
            CartItem.objects.filter(cart=cart, id=item_id).delete()
        else:
            cart.items.all().delete()
        from .serializers import CartSerializer
        return Response({'success': True, 'data': CartSerializer(cart, context={'request': request}).data, 'message': 'Cart updated.'})


class CheckoutCartView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = 'checkout'
    throttle_classes = [ScopedRateThrottle]

    @transaction.atomic
    def post(self, request):
        if guardian_blocks_spends(request.user.profile):
            return Response({
                'success': False, 'data': None,
                'message': 'Your parental co-owner has disabled spending.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        # Idempotency guard: replaying the same checkout key is a no-op.
        idempotency_key = str(request.data.get('idempotency_key') or '')[:128]
        if idempotency_key:
            cache_key = f'checkout_idem:{request.user.profile.id}:{idempotency_key}'
            if not cache.add(cache_key, '1', timeout=300):
                return Response({'success': False, 'message': 'Checkout already in progress for this request.'},
                                status=status.HTTP_409_CONFLICT)

        cart, _ = Cart.objects.get_or_create(buyer=request.user.profile)
        items = list(cart.items.all())
        if not items:
            return Response({'success': False, 'data': None, 'message': 'Cart is empty.',
                             'errors': None, 'pagination': None}, status=400)

        fulfillment_type = request.data.get('fulfillment_type', 'digital')
        if fulfillment_type not in dict(Order.FULFILLMENT_CHOICES):
            fulfillment_type = 'digital'
        delivery_address = request.data.get('delivery_address') or {}
        pickup_details = request.data.get('pickup_details') or {}

        payment_method = request.data.get('payment_method') or 'artifacts'
        if payment_method not in dict(Order.PAYMENT_METHOD_CHOICES):
            return Response({'success': False, 'data': None,
                             'message': f'payment_method must be one of: '
                                        f'{[c[0] for c in Order.PAYMENT_METHOD_CHOICES]}.',
                             'errors': None, 'pagination': None}, status=400)
        # Real money is a promise, not a settlement: nothing is deducted and
        # nothing is provisioned until the provider confirms. Only the artifacts
        # rail settles inside checkout (and it is unchanged below).
        defer_settlement = payment_method != 'artifacts'

        pickup_station = None
        pickup_station_id = request.data.get('pickup_station_id')
        if pickup_station_id:
            try:
                pickup_station = PickupStation.objects.get(id=pickup_station_id)
            except (PickupStation.DoesNotExist, ValueError, TypeError):
                return Response({'success': False, 'data': None,
                                 'message': 'That pickup station does not exist.',
                                 'errors': None, 'pagination': None}, status=400)
            if not pickup_station.is_active:
                return Response({'success': False, 'data': None,
                                 'message': f'"{pickup_station.name}" is not an active pickup station.',
                                 'errors': None, 'pagination': None}, status=400)

        def _has_delivery_address():
            return any(
                str(value).strip() for key, value in (delivery_address or {}).items()
                if key in ('line1', 'line2', 'address', 'city', 'postal_code')
            )

        def _item_price(item):
            price = resolve_item_price(item)
            if item.item_type == 'meal_plan' and item.meal_plan:
                return price, item.meal_plan.title, item.meal_plan.creator
            if item.item_type == 'programme' and item.programme:
                return price, item.programme.title, item.programme.creator
            if item.item_type == 'event_ticket' and item.event:
                return price, item.event.title, item.event.creator
            if item.item_type == 'product' and item.product:
                return None, item.product.name, None
            return None, None, None

        # ---- Phase 1: validate every item before any deduction ----
        event_qty = {}
        product_qty = {}
        locked_products = {}
        for item in items:
            price, title, creator = _item_price(item)
            if item.item_type == 'event_ticket' and item.event:
                ev = item.event
                if ev.is_cancelled:
                    return Response({'success': False, 'data': None,
                                     'message': f'Event "{ev.title}" has been cancelled. Please remove it from your cart.',
                                     'errors': None, 'pagination': None}, status=400)
                if ev.creator == request.user.profile:
                    return Response({'success': False, 'data': None,
                                     'message': 'You cannot buy a ticket to your own event.',
                                     'errors': None, 'pagination': None}, status=400)
                if EventTicket.objects.filter(event=ev, holder=request.user.profile, status='active').exists():
                    return Response({'success': False, 'data': None,
                                     'message': f'You already have a ticket for "{ev.title}".',
                                     'errors': None, 'pagination': None}, status=400)
                event_qty[str(ev.id)] = event_qty.get(str(ev.id), 0) + item.quantity
            if item.item_type == 'product' and item.product and item.product.stock_tracking_enabled:
                product_qty[str(item.product.id)] = product_qty.get(str(item.product.id), 0) + item.quantity
            if item.item_type == 'product' and item.product and fulfillment_type != 'digital':
                # `delivery_modes` is the seller's own declaration of how this
                # product may be handed over. It was stored but never checked, so
                # a seller who marked a product digital-only still shipped it.
                # An empty list means the seller never declared anything
                # (legacy rows), which stays permissive rather than becoming an
                # accidental checkout block.
                modes = [str(m).strip().lower() for m in (item.product.delivery_modes or [])]
                if modes and fulfillment_type not in modes:
                    return Response({'success': False, 'data': None,
                                     'message': f'"{item.product.name}" is {"/".join(modes)} only '
                                                f'and cannot be checked out as {fulfillment_type}.',
                                     'errors': None, 'pagination': None}, status=400)
            if not price:
                continue

        # A pickup order without a station and a delivery order without an
        # address are unfulfillable orders: both used to be accepted and left
        # the seller to discover the problem.
        if fulfillment_type == 'pickup' and pickup_station is None:
            return Response({'success': False, 'data': None,
                             'message': 'Choose an active pickup station for this order.',
                             'errors': None, 'pagination': None}, status=400)
        if fulfillment_type == 'delivery' and not _has_delivery_address():
            return Response({'success': False, 'data': None,
                             'message': 'A delivery address is required for delivery orders.',
                             'errors': None, 'pagination': None}, status=400)

        # Capacity / sold-out check per event (aggregate across cart rows)
        for event_id, qty in event_qty.items():
            try:
                ev = MarketplaceEvent.objects.get(id=event_id)
            except MarketplaceEvent.DoesNotExist:
                continue
            if ev.capacity > 0 and (ev.attendee_count + qty) > ev.capacity:
                return Response({'success': False, 'data': None,
                                 'message': f'"{ev.title}" has insufficient remaining spots.',
                                 'errors': None, 'pagination': None}, status=400)
        for product_id, qty in product_qty.items():
            product = Product.objects.select_for_update().get(id=product_id)
            locked_products[product_id] = product
            reserved = InventoryReservation.objects.filter(product=product, status='reserved').aggregate(
                total=db_models.Sum('quantity'))['total'] or 0
            if product.stock_quantity - reserved < qty:
                return Response({'success': False, 'data': None,
                                 'message': f'{product.name} is out of stock.',
                                 'errors': None, 'pagination': None}, status=400)
        for item in items:
            if item.product and str(item.product.id) in locked_products:
                item.product = locked_products[str(item.product.id)]

        # ---- Phase 2: compute totals ----
        total_artifacts = {}
        item_totals = []
        for item in items:
            price, title, creator = _item_price(item)
            item_artifacts = {}
            if price:
                for k, v in price.items():
                    subtotal = v * item.quantity
                    item_artifacts[k] = subtotal
                    total_artifacts[k] = total_artifacts.get(k, 0) + subtotal
            item_totals.append({'item': item, 'price': price or {}, 'title': title,
                                'creator': creator, 'artifacts': item_artifacts})

        original_artifacts = dict(total_artifacts)

        discount = cart.discount_code
        pct_applied = 0
        artifacts_applied = {}
        savings_artifacts = {}
        discounted_artifacts = dict(total_artifacts)
        if discount and discount.is_active:
            if discount.valid_from and discount.valid_from > timezone.now():
                return Response({'success': False, 'data': None, 'message': 'Discount code is not yet valid.',
                                 'errors': None, 'pagination': None}, status=400)
            if discount.valid_until and discount.valid_until < timezone.now():
                return Response({'success': False, 'data': None, 'message': 'Discount code has expired.',
                                 'errors': None, 'pagination': None}, status=400)
            if discount.usage_limit > 0 and discount.times_used >= discount.usage_limit:
                return Response({'success': False, 'data': None, 'message': 'Discount code usage limit reached.',
                                 'errors': None, 'pagination': None}, status=400)
            if discount.creator == request.user.profile:
                return Response({'success': False, 'data': None, 'message': 'Cannot use your own discount code.',
                                 'errors': None, 'pagination': None}, status=400)
            if discount.max_uses_per_user > 0:
                user_uses = DiscountUsage.objects.filter(discount=discount, user=request.user.profile).count()
                if user_uses >= discount.max_uses_per_user:
                    return Response({'success': False, 'data': None,
                                     'message': 'You have already used this code the maximum number of times.',
                                     'errors': None, 'pagination': None}, status=400)
            if discount.min_purchase_artifacts and any(v > 0 for v in discount.min_purchase_artifacts.values()):
                for at, needed in discount.min_purchase_artifacts.items():
                    if needed > 0 and total_artifacts.get(at, 0) < needed:
                        return Response({'success': False, 'data': None,
                                         'message': f'Minimum purchase of {needed} {at} required for this code.',
                                         'errors': None, 'pagination': None}, status=400)

            if discount.discount_type == 'percentage' and discount.discount_pct > 0:
                pct_applied = discount.discount_pct
                factor = pct_applied / 100.0
                for k in total_artifacts:
                    discounted = max(1, int(total_artifacts[k] * (1 - factor)))
                    savings_artifacts[k] = total_artifacts[k] - discounted
                    discounted_artifacts[k] = discounted
            elif discount.discount_type == 'fixed_artifacts' and discount.discount_artifacts:
                artifacts_applied = dict(discount.discount_artifacts)
                for k, v in discount.discount_artifacts.items():
                    if k in total_artifacts:
                        discounted = max(1, total_artifacts[k] - v)
                        savings_artifacts[k] = total_artifacts[k] - discounted
                        discounted_artifacts[k] = discounted

        # ---- Phase 3: deduct buyer + record debit transactions ----
        # Skipped entirely for mpesa/card: deducting artifacts as well would
        # charge the buyer twice, and marking the order paid before the money
        # lands would let them walk away with unpaid goods.
        for at, qty in (discounted_artifacts.items() if not defer_settlement else ()):
            if qty <= 0:
                continue
            if not deduct_artifacts(request.user.profile, at, qty):
                raise ValidationError(f'Insufficient {at} tokens.')
            ArtifactTransaction.objects.create(
                user=request.user.profile,
                transaction_type='purchase',
                artifact_type=at,
                quantity=qty,
                direction='debit',
                status='completed',
                reference_id=f'co_{cart.id}',
                description=f'Checkout: {len(items)} item(s) from marketplace',
            )

        # ---- Phase 4: allocate discounted amounts per item (proportional, remainder-adjusted) ----
        for t in item_totals:
            t['allocated'] = {}
        for at in discounted_artifacts:
            discounted_total = discounted_artifacts[at]
            eligible = [t for t in item_totals if t['artifacts'].get(at, 0) > 0]
            if not eligible:
                continue
            original_total = total_artifacts.get(at, 0) or 1
            allocated = {}
            for t in eligible:
                share = (t['artifacts'][at] * discounted_total) // original_total
                allocated[id(t)] = share
            remainder = discounted_total - sum(allocated.values())
            for t in sorted(eligible, key=lambda t: t['artifacts'][at], reverse=True):
                if remainder <= 0:
                    break
                allocated[id(t)] += 1
                remainder -= 1
            for t in eligible:
                t['allocated'][at] = allocated.get(id(t), 0)

        # ---- Phase 4.5: persist the Order ledger ----
        spent_usd = round(sum(ARTIFACT_VALUES.get(k, 0) * v for k, v in discounted_artifacts.items()), 2)
        order_status = 'pending' if defer_settlement else 'paid'
        status_note = (
            'Order placed. Awaiting payment confirmation.'
            if defer_settlement else 'Order placed and payment confirmed.'
        )
        order = Order.objects.create(
            buyer=request.user.profile,
            fulfillment_type=fulfillment_type,
            delivery_address=delivery_address,
            pickup_details=pickup_details,
            pickup_station=pickup_station,
            items_total_artifacts=original_artifacts,
            discount_artifacts=savings_artifacts,
            total_artifacts=discounted_artifacts,
            spent_usd=spent_usd,
            discount_code=discount,
            status=order_status,
            payment_method=payment_method,
            payment_status='pending' if defer_settlement else 'paid',
            paid_at=None if defer_settlement else timezone.now(),
            status_history=[{
                'status': order_status,
                'at': timezone.now().isoformat(),
                'note': status_note,
            }],
        )
        if fulfillment_type != 'digital':
            fulfillment = OrderFulfillment.objects.create(order=order)
            if fulfillment_type == 'pickup' and pickup_details.get('location'):
                fulfillment.pickup_location = pickup_details.get('location')
            elif fulfillment_type == 'pickup' and pickup_station:
                fulfillment.pickup_location = pickup_station.name
            if fulfillment_type == 'delivery' and delivery_address:
                fulfillment.notes = 'Delivery to: ' + ', '.join(
                    str(v) for k, v in delivery_address.items() if v and k != 'notes'
                )
            fulfillment.add_timeline_entry(order_status, status_note, commit=False)
            fulfillment.save()

        # ---- Phase 5: create purchases, credit creators on post-discount price ----
        # Provisioning (purchases, tickets, stock consumption) and every ledger
        # movement are skipped while a real-money payment is still in flight: a
        # ticket handed out before the charge settles is a free ticket, and a
        # credited creator who is never paid is a hole in the ledger. The order
        # and its line items exist, so the seller can see the demand.
        purchase_rows = []
        purchase_rows_created_tickets = []
        for t in item_totals:
            item = t['item']
            discounted_item = t.get('allocated', {})
            if defer_settlement:
                pass  # charge in flight: provision nothing (see the comment above)
            elif item.item_type == 'meal_plan' and item.meal_plan:
                for _ in range(item.quantity):
                    MealPlanPurchase.objects.get_or_create(meal_plan=item.meal_plan, buyer=request.user.profile)
                item.meal_plan.purchase_count += item.quantity
                item.meal_plan.save(update_fields=['purchase_count'])
            elif item.item_type == 'programme' and item.programme:
                for _ in range(item.quantity):
                    TrainingProgrammePurchase.objects.get_or_create(programme=item.programme, buyer=request.user.profile)
                item.programme.purchase_count += item.quantity
                item.programme.save(update_fields=['purchase_count'])
            elif item.item_type == 'event_ticket' and item.event:
                tier_name = ((item.meta or {}).get('tier') if hasattr(item, 'meta') else None) or 'Standard'
                for _ in range(item.quantity):
                    created_ticket = EventTicket.objects.create(
                        event=item.event,
                        holder=request.user.profile,
                        tier=tier_name,
                        price_paid_artifacts={
                            k: v // item.quantity for k, v in discounted_item.items() if v >= item.quantity
                        } if discounted_item else {},
                    )
                    purchase_rows_created_tickets.append(created_ticket)
                item.event.attendee_count += item.quantity
                item.event.save(update_fields=['attendee_count'])
            elif item.item_type == 'product' and item.product:
                item.product.click_count += item.quantity
                if item.product.stock_tracking_enabled:
                    item.product.stock_quantity -= item.quantity
                    item.product.save(update_fields=['click_count', 'stock_quantity'])
                    InventoryReservation.objects.create(product=item.product, order=order, quantity=item.quantity, status='consumed')
                else:
                    item.product.save(update_fields=['click_count'])

            # Credit creator on the discounted amount
            if not defer_settlement and t['creator'] and t['price']:
                for at, item_total in t['artifacts'].items():
                    paid_total = discounted_item.get(at, item_total)
                    if paid_total <= 0:
                        continue
                    cut = platform_cut('marketplace', at, paid_total)
                    creator_qty = paid_total - cut
                    if creator_qty > 0:
                        credit_creator_artifacts(t['creator'], at, creator_qty)
                        ArtifactTransaction.objects.create(
                            user=t['creator'],
                            transaction_type='marketplace',
                            artifact_type=at,
                            quantity=creator_qty,
                            direction='credit',
                            counterparty=request.user.profile,
                            status='completed',
                            clearance_at=timezone.now(),
                            reference_id=f'co_{cart.id}',
                            description=f'Sale: {item.item_type} to @{request.user.profile.username}',
                        )
                    if cut > 0:
                        ArtifactTransaction.objects.create(
                            user=t['creator'],
                            transaction_type='platform_cut',
                            artifact_type=at,
                            quantity=cut,
                            direction='debit',
                            status='completed',
                            reference_id=f'co_{cart.id}',
                            description=f'Platform fee (15%) on {item.item_type} sale',
                        )
            purchase_rows.append({
                'item_type': item.item_type,
                'title': t['title'],
                'quantity': item.quantity,
                'price_artifacts': t['price'],
                'total_artifacts': t['artifacts'],
                'paid_artifacts': discounted_item,
                'creator_name': t['creator'].display_name if t['creator'] else None,
            })

            # Order line item (snapshot of what was paid)
            OrderItem.objects.create(
                order=order,
                item_type=item.item_type,
                meal_plan=item.meal_plan if item.item_type == 'meal_plan' else None,
                programme=item.programme if item.item_type == 'programme' else None,
                product=item.product if item.item_type == 'product' else None,
                event=item.event if item.item_type == 'event_ticket' else None,
                creator=t['creator'],
                title=t['title'],
                quantity=item.quantity,
                price_artifacts=t['price'],
                paid_artifacts=discounted_item,
            )

        # ---- Phase 6: record discount usage ----
        savings_usd = round(sum(ARTIFACT_VALUES.get(k, 0) * v for k, v in savings_artifacts.items()), 2)
        # A discount is only "used" once the money actually moved; burning a
        # single-use code on an unpaid order would lock a real customer out.
        if discount and not defer_settlement:
            DiscountUsage.objects.create(
                discount=discount,
                user=request.user.profile,
                cart=cart,
                order_artifacts=original_artifacts,
                discount_pct_applied=pct_applied,
                discount_artifacts_applied=artifacts_applied,
                savings_artifacts=savings_artifacts,
                savings_usd=savings_usd,
                was_successful=True,
            )
            discount.times_used += 1
            discount.save(update_fields=['times_used'])

        cart.items.all().delete()
        cart.discount_code = None
        cart.save()

        if purchase_rows_created_tickets:
            from .tasks import send_ticket_confirmation
            for created_ticket in purchase_rows_created_tickets:
                send_ticket_confirmation.delay(str(created_ticket.id))

        # Sellers learn about the sale here rather than by polling: the Order
        # post_save signal cannot do it because line items (and therefore the
        # seller of each) do not exist yet at that point.
        _notify_sellers_of_new_order(order)

        from apps.profiles.models import Profile as _BuyerProfile
        new_balance = _BuyerProfile.objects.filter(pk=request.user.profile.pk).values_list(
            'artifact_balance', flat=True,
        ).first() or {}

        return Response({
            'success': True,
            'message': ('Cart checkout successful. Items have been purchased!'
                        if not defer_settlement else
                        'Cart checkout successful. Complete payment to confirm your order.'),
            'data': {
                'order_id': str(order.id),
                'order_number': order.order_number,
                'status': order.status,
                'fulfillment_type': order.fulfillment_type,
                'pickup_station_id': str(order.pickup_station_id) if order.pickup_station_id else None,
                'payment_method': order.payment_method,
                'payment_status': order.payment_status,
                'payment_required': defer_settlement,
                'items': purchase_rows,
                'total_artifacts': discounted_artifacts,
                'original_artifacts': original_artifacts,
                'savings_artifacts': savings_artifacts,
                'savings_usd': savings_usd,
                'discount_code': discount.code if discount else None,
                'spent_usd': spent_usd,
                'new_balance': new_balance,
            },
        })


# ---------------------------------------------------------------------------
# Orders & tracking
# ---------------------------------------------------------------------------

ORDER_FORWARD_STATES = {
    'paid': ['processing', 'shipped', 'out_for_delivery', 'ready_for_pickup', 'delivered', 'cancelled'],
    'processing': ['shipped', 'out_for_delivery', 'ready_for_pickup', 'delivered', 'cancelled'],
    'shipped': ['out_for_delivery', 'delivered', 'cancelled'],
    'out_for_delivery': ['delivered', 'cancelled'],
    'ready_for_pickup': ['delivered', 'cancelled'],
    'delivered': ['completed'],
}

# ---------------------------------------------------------------------------
# Fulfillment-aware status machine
# ---------------------------------------------------------------------------
# The flat map above treated every order as a parcel: a `pickup` order could be
# marked "shipped"/"out_for_delivery" and a `digital` one could be "en route",
# neither of which means anything. Sellers (and the buyer-facing timeline) read
# those states literally, so they are now vocabulary of the fulfillment type
# and nothing else.
#
#   digital  : nothing is moved, so there is no transport. paid -> processing ->
#              completed (cancellable at every step).
#   pickup   : the buyer collects. ready_for_pickup / delivered only.
#   delivery : a courier moves it. shipped / out_for_delivery / delivered.
#
# 'cancelled' is legal from every non-terminal state of every type, and
# delivered -> completed is the shared close-out.
ORDER_TRANSITIONS_BY_FULFILLMENT = {
    'digital': {
        'pending': ['paid', 'cancelled'],
        'paid': ['processing', 'completed', 'cancelled'],
        'processing': ['completed', 'cancelled'],
    },
    'pickup': {
        'pending': ['paid', 'cancelled'],
        'paid': ['processing', 'ready_for_pickup', 'delivered', 'completed', 'cancelled'],
        'processing': ['ready_for_pickup', 'delivered', 'completed', 'cancelled'],
        'ready_for_pickup': ['delivered', 'completed', 'cancelled'],
        'delivered': ['completed'],
    },
    'delivery': {
        'pending': ['paid', 'cancelled'],
        'paid': ['processing', 'shipped', 'out_for_delivery', 'delivered', 'completed', 'cancelled'],
        'processing': ['shipped', 'out_for_delivery', 'delivered', 'completed', 'cancelled'],
        'shipped': ['out_for_delivery', 'delivered', 'cancelled'],
        'out_for_delivery': ['delivered', 'cancelled'],
        'delivered': ['completed'],
    },
}

# Orders placed before fulfillment_type was meaningful default to 'digital'
# while sitting in a transport state (the old flat map let that happen). Those
# rows must still be closeable, so from a *current* state that the order's own
# fulfillment does not define, the generic transport chain is also allowed.
# Entering such a state from a legal one is still rejected — that is the case
# this table exists to catch.
_LEGACY_TRANSPORT_CHAIN = ['out_for_delivery', 'delivered', 'completed', 'cancelled']

# Closed states. Nothing follows them — the legacy widening below must never
# resurrect a transition out of a cancelled or completed order.
_ORDER_TERMINAL_STATES = ('cancelled', 'completed')


def allowed_order_transitions(order):
    """Statuses ``order`` may move to, given its fulfillment type."""
    if order.status in _ORDER_TERMINAL_STATES:
        return []
    table = ORDER_TRANSITIONS_BY_FULFILLMENT.get(
        getattr(order, 'fulfillment_type', None) or 'digital',
        ORDER_TRANSITIONS_BY_FULFILLMENT['digital'],
    )
    if order.status in table:
        return table[order.status]
    # The order sits in a state its own fulfillment does not define (see
    # _LEGACY_TRANSPORT_CHAIN), so fall back to the old flat map widened by the
    # transport chain, purely so the order can still be closed out.
    return list(dict.fromkeys(ORDER_FORWARD_STATES.get(order.status, []) + _LEGACY_TRANSPORT_CHAIN))


def _is_order_seller(order, profile):
    return order.items.filter(creator=profile).exists()


def _assign_delivery_personnel(order, profile, personnel_id):
    """Assign (or clear) the courier on an order. Returns an error message or None.

    Only a seller of *this* order may assign: the buyer picking their own
    courier would let them redirect a parcel, and a random third party could
    attach themselves to someone else's delivery.

    An inactive courier is rejected rather than accepted-and-ignored. They can
    also be one with no approved application behind them — ``is_active`` is the
    availability flag, and an inactive one is not available, full stop.
    """
    if personnel_id in (None, '', 'null'):
        order.delivery_personnel = None
        order.save(update_fields=['delivery_personnel', 'updated_at'])
        return None

    try:
        personnel = DeliveryPersonnel.objects.select_related('profile').get(id=personnel_id)
    except (DeliveryPersonnel.DoesNotExist, ValueError, TypeError):
        return 'That courier does not exist.'
    if not personnel.is_active:
        return (
            f'{personnel.profile.display_name or personnel.profile.username} is not an active '
            'courier and cannot be assigned to an order.'
        )
    order.delivery_personnel = personnel
    order.save(update_fields=['delivery_personnel', 'updated_at'])
    return None


def _assign_pickup_station(order, profile, station_id):
    """Assign (or clear) the pickup station on an order."""
    if station_id in (None, '', 'null'):
        order.pickup_station = None
        order.save(update_fields=['pickup_station', 'updated_at'])
        return None

    try:
        station = PickupStation.objects.get(id=station_id)
    except (PickupStation.DoesNotExist, ValueError, TypeError):
        return 'That pickup station does not exist.'
    if not station.is_active:
        return f'"{station.name}" is not an active pickup station.'
    order.pickup_station = station
    order.save(update_fields=['pickup_station', 'updated_at'])
    return None


def _apply_fulfillment_status(order, fulfillment, new_status, note=''):
    """Apply a forward status transition, updating the fulfillment timeline + milestones."""
    order.set_status(new_status, note=note)
    now = timezone.now()
    if new_status == 'shipped' and not fulfillment.shipped_at:
        fulfillment.shipped_at = now
    if new_status == 'out_for_delivery' and not fulfillment.out_for_delivery_at:
        fulfillment.out_for_delivery_at = now
    if new_status == 'ready_for_pickup' and not fulfillment.ready_for_pickup_at:
        fulfillment.ready_for_pickup_at = now
    if new_status == 'delivered' and not fulfillment.delivered_at:
        fulfillment.delivered_at = now
    fulfillment.add_timeline_entry(new_status, note=note)


class OrderListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = Order.objects.filter(buyer=request.user.profile).prefetch_related('items').select_related(
            'discount_code'
        )
        status_filter = request.query_params.get('status', '')
        if status_filter:
            qs = qs.filter(status=status_filter)
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = OrderSerializer(page, many=True, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK', 'errors': None,
            'pagination': {
                'count': paginator.page.paginator.count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })


class SellerOrdersView(views.APIView):
    """Orders the caller sells in, scoped to the caller's own line items.

    Every seller of an order used to receive the *whole* order: all of the other
    sellers' line items (titles, unit prices, what they were paid) and the
    order-wide totals that are the sum of everyone's revenue. Both are
    narrowed here — see ``SellerOrderSerializer``. What stays is what a seller
    genuinely needs to fulfil: their own items, the order status, and the
    buyer's delivery address for the parcel they are shipping.
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        profile = request.user.profile
        seller_items = OrderItem.objects.filter(creator=profile)
        qs = (
            Order.objects.filter(items__in=seller_items)
            .prefetch_related(
                # Only the caller's rows are materialised, so the serializer
                # cannot leak another seller's item even by accident.
                db_models.Prefetch('items', queryset=seller_items),
            )
            .select_related('discount_code')
            .distinct()
        )
        status_filter = request.query_params.get('status', '')
        if status_filter:
            qs = qs.filter(status=status_filter)
        fulfillment_filter = request.query_params.get('fulfillment_type', '')
        if fulfillment_filter:
            if fulfillment_filter not in dict(Order.FULFILLMENT_CHOICES):
                return Response({'success': False, 'data': None,
                                 'message': f'fulfillment_type must be one of: '
                                            f'{[c[0] for c in Order.FULFILLMENT_CHOICES]}.',
                                 'errors': None, 'pagination': None}, status=400)
            qs = qs.filter(fulfillment_type=fulfillment_filter)
        payment_filter = request.query_params.get('payment_status', '')
        if payment_filter:
            if payment_filter not in dict(Order.PAYMENT_STATUS_CHOICES):
                return Response({'success': False, 'data': None,
                                 'message': f'payment_status must be one of: '
                                            f'{[c[0] for c in Order.PAYMENT_STATUS_CHOICES]}.',
                                 'errors': None, 'pagination': None}, status=400)
            qs = qs.filter(payment_status=payment_filter)
        qs = qs.order_by('-created_at')
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = SellerOrderSerializer(page, many=True, context={'request': request, 'viewer': profile})
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK', 'errors': None,
            'pagination': {
                'count': paginator.page.paginator.count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })


def _order_delivery_coords(order, request=None):
    """Coordinates the order is being delivered to, if the buyer supplied any.

    Read from ``Order.delivery_address`` (latitude/longitude or lat/lng), with
    explicit ``?lat=&lng=`` query parameters winning so a seller can check
    "how far is this from where I am" without editing the order.
    """
    if request is not None:
        raw_lat = request.query_params.get('lat')
        raw_lng = request.query_params.get('lng')
        if raw_lat not in (None, '') and raw_lng not in (None, ''):
            try:
                return float(raw_lat), float(raw_lng)
            except (TypeError, ValueError):
                pass
    address = order.delivery_address or {}
    raw_lat = address.get('latitude', address.get('lat'))
    raw_lng = address.get('longitude', address.get('lng'))
    if raw_lat in (None, '') or raw_lng in (None, ''):
        return None
    try:
        return float(raw_lat), float(raw_lng)
    except (TypeError, ValueError):
        return None


class OrderCourierListView(views.APIView):
    """The couriers a seller may assign to one of their orders.

    There is no order weight, size or "needs a motorbike" field anywhere on the
    order, so this endpoint deliberately does NOT pretend to fit vehicles to
    orders: it returns every active courier, summarised by vehicle type, and
    lets the seller choose. Inventing a compatibility rule from nothing would
    hide couriers a seller legitimately wants.
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, order_id):
        profile = request.user.profile
        order = get_object_or_404(Order, id=order_id)
        if not _is_order_seller(order, profile):
            return Response({'success': False, 'data': None, 'message': 'Permission denied.',
                             'errors': None, 'pagination': None}, status=403)

        couriers = list(
            DeliveryPersonnel.objects.filter(is_active=True)
            .select_related('profile', 'profile__search_profile')
            .order_by('vehicle_type', 'id')
        )
        origin = _order_delivery_coords(order, request)
        data = DeliveryPersonnelSerializer(couriers, many=True, context={'request': request}).data
        for row, courier in zip(data, couriers):
            row.pop('distance_km', None)
            if origin is None:
                continue
            # DeliveryPersonnel stores no coordinates, so the only place a
            # courier can have one is their opt-in buddy search profile — which
            # is documented as radius-only and never exposed for other users.
            # It is honoured here only when that profile is not incognito, and
            # only as a distance (never as coordinates). Otherwise the seller
            # gets no distance and picks on service zones instead.
            search = getattr(courier.profile, 'search_profile', None)
            if (search is None or search.visibility == 'incognito'
                    or search.latitude is None or search.longitude is None):
                continue
            try:
                lat, lng = origin
                from common.geo import haversine_km
                row['distance_km'] = round(
                    haversine_km(lat, lng, float(search.latitude), float(search.longitude)), 1,
                )
            except (TypeError, ValueError):
                continue

        by_vehicle = {}
        for row in data:
            entry = by_vehicle.setdefault(row['vehicle_type'], {
                'vehicle_type': row['vehicle_type'],
                'vehicle_label': row['vehicle_label'],
                'count': 0, 'couriers': [],
            })
            entry['count'] += 1
            entry['couriers'].append(row)

        return Response({
            'success': True,
            'data': {
                'order_id': str(order.id),
                'order_number': order.order_number,
                'fulfillment_type': order.fulfillment_type,
                'delivery_personnel': str(order.delivery_personnel_id) if order.delivery_personnel_id else None,
                'origin': {'lat': origin[0], 'lng': origin[1]} if origin else None,
                'couriers': data,
                'by_vehicle': list(by_vehicle.values()),
            },
            'message': 'OK', 'errors': None, 'pagination': None,
        })


class OrderPaymentIntentView(views.APIView):
    """Start a real-money (M-Pesa / card) payment for one of your orders.

    Safe without live provider credentials: when the Flutterwave keys are absent
    the intent is recorded as ``initiated``, the provider is NOT called, and the
    response says the rail is not configured. Checkout therefore degrades to the
    artifacts rail instead of 500-ing on a half-configured deployment.

    The order is only ever moved to ``payment_status='pending'`` here. Nothing
    in this app marks an order ``paid`` from a client request; that requires a
    provider confirmation, and the existing ``FlutterwaveWebhookView`` still only
    resolves wallet top-ups, so an order payment is confirmed out of band for
    now (see ``PaymentIntent``'s docstring).
    """

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = PaymentIntentCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({'success': False, 'data': None, 'message': 'Validation failed.',
                             'errors': serializer.errors, 'pagination': None}, status=400)
        data = serializer.data
        order = get_object_or_404(Order, id=data['order_id'])
        if order.buyer != request.user.profile:
            return Response({'success': False, 'data': None,
                             'message': 'Only the buyer can pay for this order.',
                             'errors': None, 'pagination': None}, status=403)
        if order.payment_status in ('paid', 'refunded'):
            return Response({'success': False, 'data': None,
                             'message': f'Order #{order.order_number} is already '
                                        f'{order.payment_status}.',
                             'errors': None, 'pagination': None}, status=400)

        amount = order.spent_usd or 0
        if amount <= 0:
            return Response({'success': False, 'data': None,
                             'message': 'This order has no fiat amount to charge. Pay with artifacts.',
                             'errors': None, 'pagination': None}, status=400)

        secret = getattr(settings, 'FLUTTERWAVE_SECRET_KEY', '')
        public = getattr(settings, 'FLUTTERWAVE_PUBLIC_KEY', '')
        method = data['method']
        rail_configured = bool(secret and public)

        tx_ref = f'pi-{uuid4().hex[:12]}'
        intent = PaymentIntent.objects.create(
            order=order,
            method=method,
            amount=amount,
            currency='KES' if method == 'mpesa' else 'USD',
            # We send this reference to the provider and Flutterwave echoes it
            # back on the webhook, so it is the handle a future confirmation
            # path resolves the intent by.
            provider_reference=tx_ref,
            status='initiated',
            created_by=request.user.profile,
        )

        if not rail_configured:
            intent.raw_response = {'skipped': 'provider_not_configured'}
            intent.save(update_fields=['raw_response', 'updated_at'])
            order.payment_method = method
            order.payment_provider = ''
            order.save(update_fields=['payment_method', 'payment_provider', 'updated_at'])
            return Response({
                'success': True,
                'data': {
                    'intent': PaymentIntentSerializer(intent).data,
                    'rail_configured': False,
                },
                'message': f'{method.upper()} is not configured on this deployment, so no charge '
                           'was started. Pay with artifacts instead.',
                'errors': None, 'pagination': None,
            }, status=201)

        from apps.wallet.flutterwave import FlutterwaveClient

        fw = FlutterwaveClient()
        card_fields = (data.get('card_number'), data.get('cvv'),
                       data.get('expiry_month'), data.get('expiry_year'))

        if method == 'mpesa':
            resp = fw.mpesa_stk_push(data.get('phone'), float(amount), tx_ref, request.user.email)
        elif all(card_fields):
            resp = fw.charge_card(
                data['card_number'], data['cvv'], data['expiry_month'], data['expiry_year'],
                float(amount), tx_ref, request.user.email, request.user.profile.display_name,
            )
        else:
            # Hosted checkout: the PAN never reaches this service. Same posture
            # as the wallet top-up card path.
            resp = None

        if resp is None:
            intent.status = 'awaiting_confirmation'
            intent.raw_response = {'mode': 'hosted_checkout', 'public_key': public}
            intent.save(update_fields=['status', 'raw_response', 'updated_at'])
            order.payment_method = 'card'
            order.payment_provider = 'flutterwave'
            order.payment_status = 'pending'
            order.payment_reference = tx_ref
            order.save(update_fields=['payment_method', 'payment_provider',
                                      'payment_status', 'payment_reference', 'updated_at'])
            return Response({
                'success': True,
                'data': {
                    'intent': PaymentIntentSerializer(intent).data,
                    'tx_ref': tx_ref,
                    'public_key': public,
                    'amount': str(amount),
                    'currency': 'USD',
                    'customer_email': request.user.email,
                    'customer_name': request.user.profile.display_name,
                },
                'message': 'Card payment initialised. Complete via Flutterwave checkout.',
                'errors': None, 'pagination': None,
            }, status=201)

        intent.status = 'awaiting_confirmation' if (resp.success or resp.status == 'pending') else 'failed'
        # Only the reference we sent is trusted for lookups; the provider's own
        # id is kept in raw_response for support, not as the binding key.
        intent.raw_response = resp.data if resp.data else {'error': resp.message}
        intent.save(update_fields=['status', 'raw_response', 'updated_at'])

        if intent.status == 'failed':
            return Response({'success': False, 'data': None,
                             'message': resp.message or 'Payment could not be started.',
                             'errors': None, 'pagination': None}, status=402)

        order.payment_method = method
        order.payment_provider = 'flutterwave'
        order.payment_status = 'pending'
        order.payment_reference = tx_ref
        order.save(update_fields=['payment_method', 'payment_provider',
                                  'payment_status', 'payment_reference', 'updated_at'])

        return Response({
            'success': True,
            'data': {
                'intent': PaymentIntentSerializer(intent).data,
                'tx_ref': tx_ref,
                'status': resp.status,
            },
            'message': 'M-Pesa payment prompt sent. Complete on your phone.' if method == 'mpesa'
                       else 'Card payment started.',
            'errors': None, 'pagination': None,
        }, status=201)


def _order_serializer_for(order, profile, request):
    """Pick the order representation the viewer is entitled to.

    The buyer sees their whole order. A seller sees the same shape but scoped
    to their own lines (``SellerOrderSerializer``) — the same narrowing
    ``SellerOrdersView`` applies, so the detail endpoint is not a way around it.
    """
    if order.buyer_id != profile.pk and _is_order_seller(order, profile):
        return SellerOrderSerializer(order, context={'request': request, 'viewer': profile})
    return OrderSerializer(order, context={'request': request, 'viewer': profile})


class OrderDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, order_id):
        try:
            order = Order.objects.get(id=order_id)
        except Order.DoesNotExist:
            return Response({'success': False, 'data': None, 'message': 'Order not found.',
                             'errors': None, 'pagination': None}, status=404)
        profile = request.user.profile
        if order.buyer != profile and not _is_order_seller(order, profile):
            return Response({'success': False, 'data': None, 'message': 'Permission denied.',
                             'errors': None, 'pagination': None}, status=403)
        serializer = _order_serializer_for(order, profile, request)
        return Response({'success': True, 'data': serializer.data, 'message': 'OK',
                         'errors': None, 'pagination': None})


class OrderFulfillmentView(views.APIView):
    """Sellers update shipping/pickup/delivery tracking on their orders.

    Also the single place an order status change notifies anyone (see
    ``_notify_order_status_change``): the buyer and every seller hear about it
    once, with a device push each.
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, order_id):
        try:
            order = Order.objects.get(id=order_id)
        except Order.DoesNotExist:
            return Response({'success': False, 'message': 'Order not found.'}, status=404)
        if order.buyer != request.user.profile and not _is_order_seller(order, request.user.profile):
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)
        fulfillment, _ = OrderFulfillment.objects.get_or_create(order=order)
        return Response({'success': True, 'data': OrderFulfillmentSerializer(fulfillment).data})

    @transaction.atomic
    def patch(self, request, order_id):
        profile = request.user.profile
        try:
            order = Order.objects.get(id=order_id)
        except Order.DoesNotExist:
            return Response({'success': False, 'message': 'Order not found.'}, status=404)
        is_seller = _is_order_seller(order, profile)
        is_buyer = order.buyer == profile
        if not is_seller and not is_buyer:
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)

        fulfillment, _ = OrderFulfillment.objects.get_or_create(order=order)
        new_status = request.data.get('status')
        note = request.data.get('note', '')

        if is_buyer and not is_seller:
            # Buyers may only confirm receipt — nothing else.
            if new_status != 'delivered' or order.status not in ('shipped', 'out_for_delivery', 'ready_for_pickup'):
                return Response({'success': False,
                                 'message': 'Buyers can only confirm delivery of an en-route order.'}, status=403)
            if any(request.data.get(f) is not None for f in ('carrier', 'tracking_number', 'tracking_url', 'pickup_location')):
                return Response({'success': False, 'message': 'Only sellers can edit shipping details.'}, status=403)
            _apply_fulfillment_status(order, fulfillment, 'delivered', note or 'Confirmed by buyer')
            fulfillment.save()
            order.refresh_from_db()
            _notify_order_status_change(order, 'delivered')
            return Response({'success': True,
                             'data': _order_serializer_for(order, profile, request).data})

        if carrier := request.data.get('carrier'):
            fulfillment.carrier = carrier
        if tracking_number := request.data.get('tracking_number'):
            fulfillment.tracking_number = tracking_number
        if tracking_url := request.data.get('tracking_url'):
            fulfillment.tracking_url = tracking_url
        pickup_location = request.data.get('pickup_location')
        if pickup_location is not None:
            fulfillment.pickup_location = pickup_location
        notes = request.data.get('notes')
        if notes is not None:
            fulfillment.notes = notes

        # ---- Reject an illegal transition before anything is written ----
        # The assignment helpers below each save the order immediately, and a
        # returned Response does not roll back the surrounding atomic block, so
        # validating after them would let a rejected transition half-apply the
        # courier/station change it was sent alongside.
        previous_status = order.status
        changing_status = bool(new_status) and new_status != previous_status
        if changing_status and new_status not in allowed_order_transitions(order):
            return Response({'success': False, 'message': (
                f'Cannot move order from {order.status} to {new_status}: '
                f'{new_status} is not a valid status for a '
                f'{order.fulfillment_type} order.'
            )}, status=400)

        # ---- Physical logistics assignment (sellers only) ----
        if 'delivery_personnel_id' in request.data:
            error = _assign_delivery_personnel(order, profile, request.data.get('delivery_personnel_id'))
            if error:
                return Response({'success': False, 'message': error}, status=400)
        if 'pickup_station_id' in request.data:
            error = _assign_pickup_station(order, profile, request.data.get('pickup_station_id'))
            if error:
                return Response({'success': False, 'message': error}, status=400)

        if changing_status:
            _apply_fulfillment_status(order, fulfillment, new_status, note)
        fulfillment.save()
        order.refresh_from_db()

        # Notify once per real transition. Previously this fired on the four
        # "en route" statuses only, while the post_save signal covered the rest
        # — which is exactly how the buyer ended up with two rows per change.
        if changing_status:
            _notify_order_status_change(order, new_status)

        return Response({
            'success': True,
            'data': _order_serializer_for(order, profile, request).data,
        })


class OrderCaseView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def _get_order(self, order_id, profile):
        order = get_object_or_404(Order, id=order_id)
        if order.buyer != profile and not _is_order_seller(order, profile):
            return None
        return order

    def get(self, request, order_id):
        order = self._get_order(order_id, request.user.profile)
        if order is None:
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)
        cases = order.cases.select_related('requester').order_by('-created_at')
        return Response({'success': True, 'data': OrderCaseSerializer(cases, many=True).data})

    def post(self, request, order_id):
        order = self._get_order(order_id, request.user.profile)
        if order is None:
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)
        serializer = OrderCaseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        case = serializer.save(order=order, requester=request.user.profile)
        return Response({'success': True, 'data': OrderCaseSerializer(case).data}, status=201)


class CreatorPayoutSetupView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request):
        setup, _ = CreatorPayoutSetup.objects.get_or_create(profile=request.user.profile)
        serializer = CreatorPayoutSetupSerializer(setup, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        accept_terms = serializer.validated_data.pop('accept_terms', False)
        if accept_terms:
            setup.terms_accepted_at = setup.terms_accepted_at or timezone.now()
        setup = serializer.save()
        setup.setup_status = 'ready' if setup.account_reference and setup.terms_accepted_at else 'in_progress'
        setup.save(update_fields=['terms_accepted_at', 'setup_status', 'updated_at'])
        return Response({'success': True, 'data': CreatorPayoutSetupSerializer(setup).data})


class DiscountCodeView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def _cart_total_artifacts(self, cart):
        total = {}
        for item in cart.items.all():
            price = resolve_item_price(item)
            if price:
                for k, v in price.items():
                    total[k] = total.get(k, 0) + (v * item.quantity)
        return total

    def post(self, request):
        code = request.data.get('code')
        try:
            discount = DiscountCode.objects.get(code=code, is_active=True, is_retired=False)
            if discount.valid_until and discount.valid_until < timezone.now():
                return Response({'success': False, 'message': 'Discount code has expired.'}, status=400)
            if discount.usage_limit > 0 and discount.times_used >= discount.usage_limit:
                return Response({'success': False, 'message': 'Code limit reached.'}, status=400)
            if discount.creator == request.user.profile:
                return Response({'success': False, 'message': 'Cannot use your own discount code.'}, status=400)
            if discount.max_uses_per_user > 0:
                from_profile = request.user.profile
                user_uses = DiscountUsage.objects.filter(discount=discount, user=from_profile).count()
                if user_uses >= discount.max_uses_per_user:
                    return Response({'success': False, 'message': 'You have already used this code the maximum number of times.'}, status=400)
            cart, _ = Cart.objects.get_or_create(buyer=request.user.profile)
            if discount.min_purchase_artifacts and any(v > 0 for v in discount.min_purchase_artifacts.values()):
                cart_total = self._cart_total_artifacts(cart)
                for at, needed in discount.min_purchase_artifacts.items():
                    if needed > 0 and cart_total.get(at, 0) < needed:
                        return Response({'success': False, 'message': f'Minimum purchase of {needed} {at} required for this code.'}, status=400)
            cart.discount_code = discount
            cart.save()
            return Response({'success': True, 'message': f'Discount {discount.code} applied.'})
        except DiscountCode.DoesNotExist:
            return Response({'success': False, 'message': 'Invalid discount code.'}, status=400)

    def delete(self, request):
        cart, _ = Cart.objects.get_or_create(buyer=request.user.profile)
        cart.discount_code = None
        cart.save()
        return Response({'success': True, 'message': 'Discount code removed.'})


class DiscountCodeManageView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, code_id=None):
        profile = request.user.profile
        if code_id:
            try:
                code = DiscountCode.objects.get(id=code_id, creator=profile)
            except DiscountCode.DoesNotExist:
                return Response({'success': False, 'message': 'Discount code not found.'}, status=404)
            return Response({
                'success': True,
                'data': DiscountCodeSerializer(code, context={'request': request}).data,
            })
        codes = DiscountCode.objects.filter(creator=profile).order_by('-created_at')
        page = self._paginate(codes, request)
        return Response({
            'success': True,
            'data': DiscountCodeSerializer(page, many=True, context={'request': request}).data,
            'pagination': page.pagination if hasattr(page, 'pagination') else None,
        })

    def post(self, request):
        profile = request.user.profile
        serializer = DiscountCodeWriteSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({'success': False, 'message': 'Validation failed.', 'errors': serializer.errors}, status=400)
        discount = serializer.save(creator=profile)
        return Response({
            'success': True,
            'data': DiscountCodeSerializer(discount, context={'request': request}).data,
            'message': 'Discount code created.',
        }, status=201)

    def put(self, request, code_id):
        profile = request.user.profile
        try:
            discount = DiscountCode.objects.get(id=code_id, creator=profile)
        except DiscountCode.DoesNotExist:
            return Response({'success': False, 'message': 'Discount code not found.'}, status=404)
        serializer = DiscountCodeWriteSerializer(discount, data=request.data, partial=True)
        if not serializer.is_valid():
            return Response({'success': False, 'message': 'Validation failed.', 'errors': serializer.errors}, status=400)
        serializer.save()
        return Response({
            'success': True,
            'data': DiscountCodeSerializer(discount, context={'request': request}).data,
            'message': 'Discount code updated.',
        })

    def patch(self, request, code_id):
        profile = request.user.profile
        try:
            discount = DiscountCode.objects.get(id=code_id, creator=profile)
        except DiscountCode.DoesNotExist:
            return Response({'success': False, 'message': 'Discount code not found.'}, status=404)
        action = request.data.get('action', 'reactivate')
        if action == 'reactivate':
            discount.is_active = True
            discount.is_retired = False
            discount.retired_at = None
            discount.retired_reason = ''
            discount.save(update_fields=['is_active', 'is_retired', 'retired_at', 'retired_reason'])
            return Response({'success': True, 'message': 'Discount code reactivated.'})
        elif action == 'suspend':
            discount.is_active = False
            discount.save(update_fields=['is_active'])
            return Response({'success': True, 'message': 'Discount code suspended.'})
        return Response({'success': False, 'message': 'Invalid action.'}, status=400)

    def delete(self, request, code_id):
        profile = request.user.profile
        try:
            discount = DiscountCode.objects.get(id=code_id, creator=profile)
        except DiscountCode.DoesNotExist:
            return Response({'success': False, 'message': 'Discount code not found.'}, status=404)
        discount.is_active = False
        discount.is_retired = True
        discount.retired_at = timezone.now()
        discount.retired_reason = 'Deleted by creator'
        discount.save(update_fields=['is_active', 'is_retired', 'retired_at', 'retired_reason'])
        return Response({'success': True, 'message': 'Discount code retired.'})

    def _paginate(self, qs, request):
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(qs, request)
        if page is not None:
            page.pagination = {
                'count': paginator.page.paginator.count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            }
            return page
        return qs


class DiscountCodeAnalyticsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, code_id):
        profile = request.user.profile
        try:
            discount = DiscountCode.objects.get(id=code_id, creator=profile)
        except DiscountCode.DoesNotExist:
            return Response({'success': False, 'message': 'Discount code not found.'}, status=404)

        usages = DiscountUsage.objects.filter(discount=discount)
        total_uses = usages.count()
        successful_uses = usages.filter(was_successful=True).count()
        total_savings_usd = sum(u.savings_usd for u in usages)

        from django.db.models.functions import TruncDate
        usage_over_time = (
            usages.annotate(date=TruncDate('created_at'))
            .values('date')
            .annotate(count=db_models.Count('id'))
            .order_by('date')
        )

        # ---- Retention analytics ----
        user_usage_counts = (
            usages.filter(was_successful=True)
            .values('user_id')
            .annotate(count=db_models.Count('id'))
        )
        unique_users = user_usage_counts.count()
        returning_users = sum(1 for row in user_usage_counts if row['count'] >= 2)
        retention_rate = round((returning_users / unique_users * 100), 1) if unique_users else 0.0
        repeat_usage_distribution = [
            {'uses': n, 'users': sum(1 for row in user_usage_counts if row['count'] == n)}
            for n in range(1, max([row['count'] for row in user_usage_counts], default=0) + 1)
        ]
        top_users = (
            usages.filter(was_successful=True)
            .values('user__username', 'user__display_name')
            .annotate(uses=db_models.Count('id'), savings=db_models.Sum('savings_usd'))
            .order_by('-uses')[:5]
        )
        avg_savings_per_user = round(total_savings_usd / unique_users, 2) if unique_users else 0.0
        total_order_value_usd = sum(
            sum(ARTIFACT_VALUES.get(k, 0) * v for k, v in (u.order_artifacts or {}).items())
            for u in usages.filter(was_successful=True)
        )

        return Response({
            'success': True,
            'data': {
                'total_uses': total_uses,
                'successful_uses': successful_uses,
                'total_savings_usd': total_savings_usd,
                'share_count': discount.share_count,
                'times_used': discount.times_used,
                'usage_over_time': list(usage_over_time),
                'unique_users': unique_users,
                'returning_users': returning_users,
                'retention_rate': retention_rate,
                'repeat_usage_distribution': repeat_usage_distribution,
                'avg_savings_per_user': avg_savings_per_user,
                'total_order_value_usd': round(total_order_value_usd, 2),
                'top_users': list(top_users),
                'code': DiscountCodeSerializer(discount, context={'request': request}).data,
            },
        })


class DiscountCodeShareView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, code_id):
        profile = request.user.profile
        try:
            discount = DiscountCode.objects.get(id=code_id, creator=profile)
        except DiscountCode.DoesNotExist:
            return Response({'success': False, 'message': 'Discount code not found.'}, status=404)
        discount.share_count += 1
        discount.save(update_fields=['share_count'])
        share_data = {
            'code': discount.code,
            'discount_pct': discount.discount_pct,
            'discount_type': discount.discount_type,
            'description': discount.description,
            'qr_code': discount.qr_code if discount.code_type == 'qr' else None,
        }
        return Response({
            'success': True,
            'data': share_data,
            'message': 'Share count incremented.',
        })
