from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('marketplace', '0023_inventoryadjustment')]

    operations = [
        migrations.AddField(
            model_name='product', name='barcode',
            field=models.CharField(blank=True, db_index=True, max_length=64),
        ),
    ]
