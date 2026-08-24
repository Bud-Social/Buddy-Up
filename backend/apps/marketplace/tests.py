from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.marketplace.models import Order, OrderItem


class BuyerDeliveryConfirmationTests(TestCase):
    """Buyers may confirm delivery; sellers keep full fulfillment control."""

    def setUp(self):
        self.buyer_user = User.objects.create_user(email='buyer@example.com', password='TestPass123!')
        self.seller_user = User.objects.create_user(email='seller@example.com', password='TestPass123!')
        self.buyer = Profile.objects.create(user=self.buyer_user, username='buyer', display_name='Buyer')
        self.seller = Profile.objects.create(user=self.seller_user, username='seller', display_name='Seller')

        self.order = Order.objects.create(buyer=self.buyer, status='shipped')
        OrderItem.objects.create(
            order=self.order, item_type='product', title='Grips', quantity=1, creator=self.seller,
        )
        self.url = f'/api/v1/marketplace/orders/{self.order.id}/fulfillment/'

    def _client_for(self, profile):
        client = APIClient()
        refresh = RefreshToken.for_user(profile.user)
        client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        return client

    def test_buyer_can_confirm_delivery(self):
        resp = self._client_for(self.buyer).patch(self.url, {'status': 'delivered'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'delivered')

    def test_buyer_cannot_set_arbitrary_status_or_edit_shipping(self):
        client = self._client_for(self.buyer)
        resp = client.patch(self.url, {'status': 'cancelled'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)

        resp = client.patch(self.url, {'status': 'delivered', 'tracking_number': 'FAKE-123'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'shipped')

    def test_seller_can_advance_status(self):
        resp = self._client_for(self.seller).patch(
            self.url,
            {'status': 'out_for_delivery', 'carrier': 'Sendy', 'tracking_number': 'TRK-9'},
            format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'out_for_delivery')

    def test_outsider_gets_403(self):
        stranger_user = User.objects.create_user(email='stranger@example.com', password='TestPass123!')
        Profile.objects.create(user=stranger_user, username='stranger', display_name='Stranger')
        resp = self._client_for(
            Profile.objects.get(user=stranger_user),
        ).patch(self.url, {'status': 'delivered'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
