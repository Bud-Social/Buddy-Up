"""Shops connected to a gym — list, connect, disconnect, aggregate.

A gym connects shops so the console can answer "how is the shop doing for
this gym?". The link itself is the marketplace's GymShopLink; this view adds
orders aggregation scoped to the shop's own product line (the only thing we
can attribute today — there is no gym on Order).

Attribution is best-effort: paid orders that contain an item from the
shop, summed per artifact type from the seller's split. Item-count/order
count are exact; artifact splits are read from ``seller_split_artifacts``
on each OrderItem.
"""

import datetime

from django.db.models import Count, Sum
from django.utils import timezone
from rest_framework import views, status, permissions
from rest_framework.response import Response

from .models import Gym, GymMembership
from apps.marketplace.models import ShopGymLink, Shop, OrderItem, ShopMembership

import logging
logger = logging.getLogger(__name__)


def _notify_shop_staff(gym, shop, link, notify_status):
    from apps.notifications.tasks import create_notification

    recipients = list(
        ShopMembership.objects.filter(shop=shop, role__in=('owner', 'manager'))
        .select_related('profile').values_list('profile__user_id', flat=True)
    )
    for uid in recipients:
        try:
            create_notification.delay(
                str(uid), 'shop_gym_link_request',
                f'{gym.name} wants to connect',
                f'{gym.name} is asking to link this shop to the gym for attribution. Approve it from My Shops.',
                {'gym_handle': gym.handle, 'gym_name': gym.name,
                 'link_id': str(link.id), 'shop_id': str(shop.id)},
                dedupe_key=f'shop-gym-link-{link.id}-{notify_status}',
            )
        except Exception:
            logger.warning('shop_gym_link notification failed for %s', uid)



def _owner_gym(request, slug):
    gym = Gym.objects.filter(handle__iexact=slug).first()
    if gym is None:
        return None, None
    membership = GymMembership.objects.filter(
        gym=gym, member=request.user.profile,
        role__in=['owner', 'co_owner'],
    ).first()
    return gym, membership


def _link_payload(link: ShopGymLink):
    shop = link.shop
    return {
        'id': str(link.id),
        'shop_id': str(shop.id),
        'status': getattr(link, 'status', 'active'),
        'is_primary': link.is_primary,
        'name': shop.name,
        'handle': shop.handle,
        'description': shop.description,
        'logo_url': shop.logo_url,
        'accent_color': shop.accent_color,
        'verification_status': shop.verification_status,
        'is_active': shop.is_active,
        'products_count': shop.products.count(),
        'created_at': link.created_at.isoformat(),
        'decided_at': getattr(link, 'updated_at', None).isoformat() if getattr(link, 'updated_at', None) else None,
    }


class GymShopsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym, membership = _owner_gym(request, gym_slug)
        if gym is None or membership is None:
            return Response({'success': False, 'message': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        links = list(ShopGymLink.objects.filter(gym=gym).select_related('shop'))
        window_start = timezone.now() - datetime.timedelta(days=90)

        shops = []
        total_units_90d = 0
        total_orders_90d = 0
        artifact_totals = {}

        active_links = [link for link in links if getattr(link, 'status', 'active') == 'active']
        for link in active_links:
            shop = link.shop
            items = OrderItem.objects.filter(
                item_type='product',
                product__shop=shop,
                order__payment_status='paid',
                created_at__gte=window_start,
            )
            agg = items.aggregate(units=Sum('quantity'), orders=Count('order', distinct=True))
            units = agg['units'] or 0
            orders = agg['orders'] or 0
            total_units_90d += units
            total_orders_90d += orders
            for row in items.values_list('seller_split_artifacts', flat=True):
                for artifact, qty in (row or {}).items():
                    artifact_totals[artifact] = artifact_totals.get(artifact, 0) + int(qty or 0)
            shops.append({**_link_payload(link), 'units_sold_90d': units, 'orders_90d': orders})

        return Response({
            'success': True,
            'data': {
                'shops': shops,
                'totals': {
                    'shops': len(shops),
                    'units_sold_90d': total_units_90d,
                    'orders_90d': total_orders_90d,
                    'artifact_splits_90d': artifact_totals,
                },
                'window_days': 90,
            },
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    def post(self, request, gym_slug):
        gym, membership = _owner_gym(request, gym_slug)
        if gym is None or membership is None:
            return Response({'success': False, 'message': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        handle = (request.data.get('handle') or '').strip().lower()
        if not handle:
            return Response({'success': False, 'message': 'Shop handle required.'},
                            status=status.HTTP_400_BAD_REQUEST)
        shop = Shop.objects.filter(handle__iexact=handle, is_active=True).first()
        if shop is None:
            return Response({'success': False, 'message': f'No active shop with handle "{handle}".'},
                            status=status.HTTP_404_NOT_FOUND)
        link, created = ShopGymLink.objects.get_or_create(
            gym=gym, shop=shop,
            defaults={'requested_by': request.user.profile, 'is_primary': False},
        )
        # Only re-open if it was a decline; never silently re-approve or downgrade.
        if not created and link.status == 'declined':
            link.status = 'pending'
            link.requested_by = request.user.profile
            link.decided_by = None
            link.save(update_fields=['status', 'requested_by', 'decided_by', 'updated_at'])
        notify_status = link.status  # link.status after possible reset
        _notify_shop_staff(gym, shop, link, notify_status)
        message = (
            'Request sent — waiting on the shop to approve.' if link.status == 'pending'
            else 'Linked.'
        )
        return Response(
            {'success': True, 'data': _link_payload(link), 'message': message,
             'errors': None, 'pagination': None},
            status=status.HTTP_201_CREATED,
        )

    def delete(self, request, gym_slug):
        gym, membership = _owner_gym(request, gym_slug)
        if gym is None or membership is None:
            return Response({'success': False, 'message': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        handle = (request.data.get('handle') or '').strip().lower()
        deleted, _ = ShopGymLink.objects.filter(gym=gym, shop__handle__iexact=handle).delete()
        if not deleted:
            return Response({'success': False, 'message': 'That shop is not connected.'},
                            status=status.HTTP_404_NOT_FOUND)
        return Response({'success': True, 'data': None,
                         'message': 'Shop disconnected.', 'errors': None, 'pagination': None})
