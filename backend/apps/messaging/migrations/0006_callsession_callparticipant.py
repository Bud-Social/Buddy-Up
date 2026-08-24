# Hand-written for CallSession / CallParticipant (multi-party LiveKit calls).
# Mirrors what `makemigrations messaging` would generate for models 0006.

import django.db.models.deletion
import uuid
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('messaging', '0005_conversation_cover_url_conversation_description_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='CallSession',
            fields=[
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('call_type', models.CharField(choices=[('audio', 'Audio'), ('video', 'Video')], default='audio', max_length=10)),
                ('status', models.CharField(choices=[('ringing', 'Ringing'), ('active', 'Active'), ('ended', 'Ended'), ('missed', 'Missed')], default='ringing', max_length=15)),
                ('room_name', models.CharField(blank=True, db_index=True, max_length=80)),
                ('started_at', models.DateTimeField(blank=True, null=True)),
                ('ended_at', models.DateTimeField(blank=True, null=True)),
                ('conversation', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='call_sessions', to='messaging.conversation')),
                ('initiated_by', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='initiated_call_sessions', to='profiles.profile')),
            ],
            options={
                'db_table': 'messaging_call_session',
            },
        ),
        migrations.CreateModel(
            name='CallParticipant',
            fields=[
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('joined_at', models.DateTimeField(blank=True, null=True)),
                ('left_at', models.DateTimeField(blank=True, null=True)),
                ('declined', models.BooleanField(default=False)),
                ('profile', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='call_participations', to='profiles.profile')),
                ('session', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='participants', to='messaging.callsession')),
            ],
            options={
                'db_table': 'messaging_call_participant',
            },
        ),
        migrations.AddIndex(
            model_name='callsession',
            index=models.Index(fields=['conversation', '-created_at'], name='messaging_c_convers_fa104c_idx'),
        ),
        migrations.AddIndex(
            model_name='callsession',
            index=models.Index(fields=['status'], name='messaging_c_status_57fe7d_idx'),
        ),
        migrations.AlterUniqueTogether(
            name='callparticipant',
            unique_together={('session', 'profile')},
        ),
    ]
