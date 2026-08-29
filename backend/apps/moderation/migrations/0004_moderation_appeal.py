import django.db.models.deletion
import uuid
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('moderation', '0003_alter_contentflag_flag_reason_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='moderationaction',
            name='action',
            field=models.CharField(choices=[
                ('warning', 'Warning'), ('content_removed', 'Content Removed'),
                ('user_suspended', 'User Suspended'), ('user_banned', 'User Banned'),
                ('report_dismissed', 'Report Dismissed'),
                ('action_reversed', 'Action Reversed on Appeal'),
            ], max_length=25),
        ),
        migrations.CreateModel(
            name='ModerationAppeal',
            fields=[
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('reason', models.TextField(max_length=1500)),
                ('status', models.CharField(choices=[
                    ('submitted', 'Submitted'), ('under_review', 'Under Review'),
                    ('approved', 'Approved / Action Reversed'), ('denied', 'Denied'),
                ], default='submitted', max_length=15)),
                ('reviewed_at', models.DateTimeField(blank=True, null=True)),
                ('resolution_note', models.TextField(blank=True, max_length=1500)),
                ('action', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='appeals', to='moderation.moderationaction')),
                ('appellant', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='moderation_appeals', to=settings.AUTH_USER_MODEL)),
                ('reviewer', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='moderation_appeal_reviews', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'db_table': 'moderation_appeal',
                'ordering': ['-created_at'],
            },
        ),
        migrations.AddConstraint(
            model_name='moderationappeal',
            constraint=models.UniqueConstraint(fields=('action', 'appellant'), name='uniq_action_appellant_appeal'),
        ),
    ]
