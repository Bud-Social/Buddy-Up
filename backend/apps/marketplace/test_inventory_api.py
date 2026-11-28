from django.test import TestCase
from rest_framework import status

from apps.marketplace.models import InventoryAdjustment, Product, ShopMembership
from apps.marketplace.test_commerce_permissions import client_for, make_profile, make_shop


class ShopInventoryApiTests(TestCase):
    def setUp(self):
        self.owner = make_profile('inventory-owner')
        self.manager = make_profile('inventory-manager')
        self.outsider = make_profile('inventory-outsider')
        self.shop = make_shop('inventory-shop')
        ShopMembership.objects.create(shop=self.shop, profile=self.owner, role='owner')
        ShopMembership.objects.create(shop=self.shop, profile=self.manager, role='manager')
        self.product = Product.objects.create(
            name='Tracked bands', brand='BuddyUp', category='gear',
            affiliate_url='https://example.test/bands', shop=self.shop,
            stock_tracking_enabled=True, stock_quantity=4,
            recommended_by=self.owner,
        )
        self.url = f'/api/v1/marketplace/shops/{self.shop.handle}/inventory/'

    def test_owner_can_adjust_and_audit_stock(self):
        response = client_for(self.owner).patch(
            f'{self.url}{self.product.id}/',
            {'quantity': 12, 'stock_tracking_enabled': True, 'reason': 'Received shipment'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.product.refresh_from_db()
        self.assertEqual(self.product.stock_quantity, 12)
        adjustment = InventoryAdjustment.objects.get(product=self.product)
        self.assertEqual(adjustment.previous_quantity, 4)
        self.assertEqual(adjustment.delta, 8)
        self.assertEqual(adjustment.actor, self.owner)

    def test_manager_can_list_inventory_but_outsider_cannot(self):
        response = client_for(self.manager).get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data'][0]['id'], str(self.product.id))

        response = client_for(self.outsider).get(self.url)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_product_must_belong_to_shop(self):
        other = make_shop('other-inventory-shop')
        product = Product.objects.create(
            name='Other bands', brand='Other', category='gear',
            affiliate_url='https://example.test/other', shop=other,
            recommended_by=self.owner,
        )
        response = client_for(self.owner).patch(
            f'{self.url}{product.id}/', {'quantity': 2}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
