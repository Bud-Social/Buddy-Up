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
from apps.marketplace.models import ShopGymLink, Shop, OrderItem


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
        'name': shop.name,
        'handle': shop.handle,
        'description': shop.description,
        'logo_url': shop.logo_url,
        'accent_color': shop.accent_color,
        'verification_status': shop.verification_status,
        'is_active': shop.is_active,
        'products_count': shop.products.count(),
        'created_at': link.created_at.isoformat(),
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

        for link in links:
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
            return Response({'success': False, 'message': f'No active shop with handle “{handle}”.'},
                            status=status.HTTP_404_NOT_FOUND)
        if ShopGymLink.objects.filter(gym=gym, shop=shop).exists():
            return Response({'success': False, 'message': 'That shop is already connected.'},
                            status=status.HTTP_409_CONFLICT)
        link = ShopGymLink.objects.create(gym=gym, shop=shop)
        return Response({
            'success': True,
            'data': _link_payload(link),
            'message': f'{shop.name} connected to this gym.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)

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
