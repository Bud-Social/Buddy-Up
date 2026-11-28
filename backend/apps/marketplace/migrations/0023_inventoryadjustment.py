from django.db import migrations, models
import django.db.models.deletion
import uuid


class Migration(migrations.Migration):
    dependencies = [('marketplace', '0022_marketplaceevent_visibility')]

    operations = [
        migrations.CreateModel(
            name='InventoryAdjustment',
            fields=[
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('previous_quantity', models.PositiveIntegerField()),
                ('quantity', models.PositiveIntegerField()),
                ('delta', models.IntegerField()),
                ('reason', models.CharField(blank=True, max_length=200)),
                ('actor', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='inventory_adjustments', to='profiles.profile')),
                ('product', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='inventory_adjustments', to='marketplace.product')),
                ('shop', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='inventory_adjustments', to='marketplace.shop')),
            ],
            options={'db_table': 'marketplace_inventory_adjustment'},
        ),
        migrations.AddIndex(model_name='inventoryadjustment', index=models.Index(fields=['shop', '-created_at'], name='marketplace_inventory_shop_id_6f4a4c_idx')),
        migrations.AddIndex(model_name='inventoryadjustment', index=models.Index(fields=['product', '-created_at'], name='marketplace_inventory_product_4cf17d_idx')),
    ]
