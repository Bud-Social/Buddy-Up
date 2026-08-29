from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [('wallet', '0007_double_entry_ledger')]

    operations = [
        migrations.RenameIndex(
            model_name='ledgeraccount',
            new_name='wallet_ledg_profile_b87592_idx',
            old_name='wallet_ledg_profile_45afaa_idx',
        ),
        migrations.RenameIndex(
            model_name='journalline',
            new_name='wallet_jour_account_9c51ce_idx',
            old_name='wallet_journ_account_6f43e2_idx',
        ),
        migrations.RenameIndex(
            model_name='journalline',
            new_name='wallet_jour_journal_5606f1_idx',
            old_name='wallet_journ_journal_841f46_idx',
        ),
    ]
