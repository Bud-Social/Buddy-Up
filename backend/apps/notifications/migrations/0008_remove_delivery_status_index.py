from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [('notifications', '0007_delivery_policy')]

    operations = [
        migrations.RemoveIndex(
            model_name='notification',
            name='notif_recipient_delivery_idx',
        ),
    ]
