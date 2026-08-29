import django.db.models.deletion
import uuid
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('profiles', '0008_onboarding_consent'),
        ('wallet', '0006_unique_tx_ref'),
    ]

    operations = [
        migrations.CreateModel(
            name='JournalEntry',
            fields=[
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('operation', models.CharField(db_index=True, max_length=40)),
                ('idempotency_key', models.CharField(max_length=180, unique=True)),
                ('request_hash', models.CharField(max_length=64)),
                ('description', models.CharField(blank=True, max_length=255)),
                ('metadata', models.JSONField(blank=True, default=dict)),
                ('posted_at', models.DateTimeField(auto_now_add=True)),
            ],
            options={'db_table': 'wallet_journal_entry', 'ordering': ['-posted_at'], 'verbose_name_plural': 'journal entries'},
        ),
        migrations.CreateModel(
            name='LedgerAccount',
            fields=[
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('account_type', models.CharField(choices=[('platform', 'Platform'), ('buyer', 'Buyer'), ('seller', 'Seller'), ('escrow', 'Escrow')], max_length=10)),
                ('wallet_bucket', models.CharField(choices=[('system', 'System'), ('regular', 'Regular wallet'), ('creator', 'Creator wallet')], max_length=10)),
                ('artifact_type', models.CharField(max_length=30)),
                ('name', models.CharField(max_length=120)),
                ('is_active', models.BooleanField(default=True)),
                ('profile', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.PROTECT, related_name='ledger_accounts', to='profiles.profile')),
            ],
            options={'db_table': 'wallet_ledger_account'},
        ),
        migrations.CreateModel(
            name='JournalLine',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('direction', models.CharField(choices=[('debit', 'Debit'), ('credit', 'Credit')], max_length=6)),
                ('amount', models.PositiveBigIntegerField()),
                ('account', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='journal_lines', to='wallet.ledgeraccount')),
                ('journal_entry', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='lines', to='wallet.journalentry')),
            ],
            options={'db_table': 'wallet_journal_line'},
        ),
        migrations.AddField(
            model_name='artifacttransaction', name='journal_entry',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.PROTECT, related_name='artifact_transactions', to='wallet.journalentry'),
        ),
        migrations.AddConstraint(model_name='ledgeraccount', constraint=models.UniqueConstraint(fields=('account_type', 'profile', 'wallet_bucket', 'artifact_type'), name='wallet_unique_profile_ledger_account')),
        migrations.AddConstraint(model_name='ledgeraccount', constraint=models.UniqueConstraint(condition=models.Q(('profile__isnull', True)), fields=('account_type', 'wallet_bucket', 'artifact_type'), name='wallet_unique_system_ledger_account')),
        migrations.AddIndex(model_name='ledgeraccount', index=models.Index(fields=['profile', 'artifact_type'], name='wallet_ledg_profile_45afaa_idx')),
        migrations.AddConstraint(model_name='journalline', constraint=models.CheckConstraint(condition=models.Q(('amount__gt', 0)), name='wallet_line_amount_gt_zero')),
        migrations.AddIndex(model_name='journalline', index=models.Index(fields=['account', 'direction'], name='wallet_journ_account_6f43e2_idx')),
        migrations.AddIndex(model_name='journalline', index=models.Index(fields=['journal_entry', 'direction'], name='wallet_journ_journal_841f46_idx')),
    ]
