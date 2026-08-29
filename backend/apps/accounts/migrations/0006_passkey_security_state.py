from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('accounts', '0005_webauthncredential')]

    operations = [
        migrations.AddField(model_name='webauthncredential', name='expires_at', field=models.DateTimeField(blank=True, null=True)),
        migrations.AddField(model_name='webauthncredential', name='last_verified_at', field=models.DateTimeField(blank=True, null=True)),
        migrations.AddField(model_name='webauthncredential', name='revoked_at', field=models.DateTimeField(blank=True, null=True)),
    ]
