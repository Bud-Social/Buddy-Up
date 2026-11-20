import uuid

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('messaging', '0018_unique_pair_key'),
    ]

    operations = [
        migrations.CreateModel(
            name='ConversationPreference',
            fields=[
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('is_archived', models.BooleanField(db_index=True, default=False)),
                ('is_muted', models.BooleanField(default=False)),
                ('is_pinned', models.BooleanField(default=False)),
                ('conversation', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='preferences', to='messaging.conversation')),
                ('profile', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='conversation_preferences', to='profiles.profile')),
            ],
            options={
                'db_table': 'messaging_conversation_preference',
                'indexes': [models.Index(fields=['profile', 'is_archived'], name='messaging_c_profile_2d080a_idx')],
                'constraints': [models.UniqueConstraint(fields=['conversation', 'profile'], name='unique_conversation_preference')],
            },
        ),
    ]
