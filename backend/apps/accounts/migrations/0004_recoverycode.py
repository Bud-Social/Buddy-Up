# Hand-written for RecoveryCode (single-use 2FA backup codes, hashed).

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0003_user_guardian_email_user_guardian_name_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='RecoveryCode',
            fields=[
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('code_hash', models.CharField(db_index=True, max_length=64)),
                ('is_used', models.BooleanField(default=False)),
                ('user', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='recovery_codes',
                    to=settings.AUTH_USER_MODEL,
                )),
            ],
            options={
                'db_table': 'accounts_recovery_code',
            },
        ),
        migrations.AddIndex(
            model_name='recoverycode',
            index=models.Index(fields=['user', 'is_used'], name='accounts_re_user_id_8fe35a_idx'),
        ),
    ]
