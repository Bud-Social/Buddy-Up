from django.db import migrations, models


class Migration(migrations.Migration):
    initial = True
    dependencies = []
    operations = [
        migrations.CreateModel(
            name='RealtimeWebhookEvent',
            fields=[
                ('event_id', models.CharField(max_length=180, primary_key=True, serialize=False)),
                ('event_type', models.CharField(blank=True, max_length=80)),
                ('room_name', models.CharField(blank=True, db_index=True, max_length=120)),
                ('payload_hash', models.CharField(max_length=64)),
                ('received_at', models.DateTimeField(auto_now_add=True)),
            ],
            options={'db_table': 'realtime_webhook_event'},
        ),
        migrations.AddIndex(
            model_name='realtimewebhookevent',
            index=models.Index(fields=['event_type', '-received_at'], name='realtime_we_event_t_8fa0e4_idx'),
        ),
    ]
