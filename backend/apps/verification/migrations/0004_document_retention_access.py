import django.db.models.deletion
import uuid
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('verification', '0002_verificationsubmission_completed_steps_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='verificationdocument',
            name='file_url',
            field=models.URLField(blank=True),
        ),
        migrations.AddField(
            model_name='verificationdocument',
            name='purge_after',
            field=models.DateTimeField(
                blank=True, null=True,
                help_text='Operations deadline for deleting the underlying sensitive file.',
            ),
        ),
        migrations.AddField(
            model_name='verificationdocument',
            name='purged_at',
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.CreateModel(
            name='VerificationDocumentAccess',
            fields=[
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('purpose', models.CharField(max_length=120)),
                ('request_id', models.CharField(blank=True, max_length=64)),
                ('ip_address', models.GenericIPAddressField(blank=True, null=True)),
                ('actor', models.ForeignKey(
                    blank=True, null=True,
                    on_delete=django.db.models.deletion.SET_NULL,
                    related_name='verification_document_accesses',
                    to=settings.AUTH_USER_MODEL,
                )),
                ('document', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='access_events',
                    to='verification.verificationdocument',
                )),
            ],
            options={
                'db_table': 'verification_document_access',
                'ordering': ['-created_at'],
            },
        ),
        migrations.AddIndex(
            model_name='verificationdocument',
            index=models.Index(
                fields=['purge_after', 'purged_at'],
                name='verificatio_purge_a_6bde2b_idx',
            ),
        ),
    ]
