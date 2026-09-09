from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('accounts', '0007_alter_accountevent_event_type')]

    operations = [
        migrations.AddField(
            model_name='user',
            name='hard_delete_at',
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='devicesession',
            name='device_id',
            field=models.CharField(blank=True, db_index=True, max_length=64),
        ),
    ]
