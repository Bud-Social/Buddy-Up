from django.db import migrations, models
import django.db.models.deletion
import uuid


class Migration(migrations.Migration):
    dependencies = [('analytics', '0003_provenance_pause_and_dedupe')]

    operations = [
        migrations.CreateModel(
            name='AnalyticsEvent',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('event_name', models.CharField(db_index=True, max_length=64)),
                ('event_version', models.PositiveSmallIntegerField(default=1)),
                ('occurred_at', models.DateTimeField(blank=True, null=True)),
                ('received_at', models.DateTimeField(auto_now_add=True)),
                ('anonymous_id', models.CharField(blank=True, db_index=True, max_length=128)),
                ('session_id', models.CharField(blank=True, max_length=64)),
                ('platform', models.CharField(blank=True, max_length=16)),
                ('surface', models.CharField(blank=True, max_length=32)),
                ('object_type', models.CharField(blank=True, max_length=32)),
                ('object_id', models.CharField(blank=True, db_index=True, max_length=64)),
                ('properties', models.JSONField(blank=True, default=dict)),
                ('consent', models.JSONField(blank=True, default=dict)),
                ('schema_version', models.PositiveSmallIntegerField(default=1)),
                ('actor', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='analytics_events', to='profiles.profile')),
            ],
            options={
                'db_table': 'analytics_event',
                'ordering': ['-received_at'],
            },
        ),
        migrations.AddIndex(
            model_name='analyticsevent',
            index=models.Index(fields=['event_name', '-received_at'], name='analytics_e_event_n_7fa622_idx'),
        ),
        migrations.AddIndex(
            model_name='analyticsevent',
            index=models.Index(fields=['actor', '-received_at'], name='analytics_e_actor_i_0169c9_idx'),
        ),
    ]
