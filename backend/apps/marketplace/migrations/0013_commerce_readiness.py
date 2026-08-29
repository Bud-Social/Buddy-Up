import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('marketplace', '0012_mealplan_visibility'), ('profiles', '0008_onboarding_consent')]

    operations = [
        migrations.AddField(model_name='product', name='stock_quantity', field=models.PositiveIntegerField(default=0)),
        migrations.AddField(model_name='product', name='stock_tracking_enabled', field=models.BooleanField(default=False)),
        migrations.AddField(model_name='product', name='supplement_registration_number', field=models.CharField(blank=True, max_length=100)),
        migrations.AddField(model_name='product', name='supplement_registration_expiry', field=models.DateField(blank=True, null=True)),
        migrations.AddField(model_name='product', name='supplement_claims_reviewed', field=models.BooleanField(default=False)),
        migrations.AddField(model_name='product', name='supplement_label_url', field=models.URLField(blank=True)),
        migrations.AddField(model_name='orderitem', name='seller_split_artifacts', field=models.JSONField(default=dict)),
        migrations.AddField(model_name='orderitem', name='fulfillment_status', field=models.CharField(default='pending', max_length=20)),
        migrations.AddField(model_name='orderfulfillment', name='seller_split_artifacts', field=models.JSONField(default=dict)),
        migrations.CreateModel(
            name='CreatorPayoutSetup',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('provider', models.CharField(default='flutterwave', max_length=30)),
                ('account_reference', models.CharField(blank=True, max_length=120)),
                ('is_verified', models.BooleanField(default=False)),
                ('terms_accepted_at', models.DateTimeField(blank=True, null=True)),
                ('setup_status', models.CharField(default='not_started', max_length=20)),
                ('profile', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='payout_setup', to='profiles.profile')),
            ], options={'db_table': 'marketplace_creator_payout_setup'},
        ),
        migrations.CreateModel(
            name='InventoryReservation',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('quantity', models.PositiveIntegerField()),
                ('status', models.CharField(choices=[('reserved', 'Reserved'), ('released', 'Released'), ('consumed', 'Consumed'), ('expired', 'Expired')], default='reserved', max_length=10)),
                ('expires_at', models.DateTimeField(blank=True, null=True)),
                ('order', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='inventory_reservations', to='marketplace.order')),
                ('product', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='inventory_reservations', to='marketplace.product')),
            ], options={'db_table': 'marketplace_inventory_reservation'},
        ),
        migrations.CreateModel(
            name='OrderCase',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('case_type', models.CharField(choices=[('refund', 'Refund'), ('return', 'Return'), ('dispute', 'Dispute')], max_length=10)),
                ('status', models.CharField(choices=[('requested', 'Requested'), ('under_review', 'Under Review'), ('approved', 'Approved'), ('rejected', 'Rejected'), ('resolved', 'Resolved')], default='requested', max_length=15)),
                ('reason', models.TextField()),
                ('evidence', models.JSONField(default=list)),
                ('resolution', models.TextField(blank=True)),
                ('resolved_at', models.DateTimeField(blank=True, null=True)),
                ('order', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='cases', to='marketplace.order')),
                ('requester', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='marketplace_cases', to='profiles.profile')),
            ], options={'db_table': 'marketplace_order_case'},
        ),
        migrations.AddIndex(model_name='inventoryreservation', index=models.Index(fields=['product', 'status'], name='marketplace_product_2a0f6f_idx')),
        migrations.AddIndex(model_name='ordercase', index=models.Index(fields=['order', 'status'], name='marketplace_order_i_b76ca1_idx')),
        migrations.AddIndex(model_name='ordercase', index=models.Index(fields=['requester', '-created_at'], name='marketplace_request_4b95aa_idx')),
    ]
