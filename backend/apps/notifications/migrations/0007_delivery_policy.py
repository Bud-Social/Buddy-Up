from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('notifications', '0006_notification_pin_dismiss')]

    operations = [
        migrations.AddField(model_name='notification', name='priority', field=models.CharField(max_length=10, choices=[('low', 'Low'), ('normal', 'Normal'), ('high', 'High'), ('critical', 'Critical')], default='normal')),
        migrations.AddField(model_name='notification', name='dedupe_key', field=models.CharField(max_length=200, blank=True)),
        migrations.AddField(model_name='notification', name='aggregation_count', field=models.PositiveIntegerField(default=1)),
        migrations.AddField(model_name='notification', name='expires_at', field=models.DateTimeField(null=True, blank=True)),
        migrations.AddField(model_name='notification', name='delivery_status', field=models.CharField(max_length=10, choices=[('pending', 'Pending'), ('delivered', 'Delivered'), ('failed', 'Failed'), ('skipped', 'Skipped')], default='pending')),
        migrations.AddField(model_name='notification', name='delivered_at', field=models.DateTimeField(null=True, blank=True)),
        migrations.AddField(model_name='notificationpreference', name='timezone', field=models.CharField(max_length=60, default='UTC')),
        migrations.AddField(model_name='notificationpreference', name='category_frequency', field=models.JSONField(default=dict, blank=True)),
        migrations.AddIndex(model_name='notification', index=models.Index(fields=['recipient', 'delivery_status'], name='notif_recipient_delivery_idx')),
    ]
