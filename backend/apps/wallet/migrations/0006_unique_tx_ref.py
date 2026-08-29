from django.db import migrations, models


def dedupe_tx_refs(apps, schema_editor):
    Transaction = apps.get_model('wallet', 'ArtifactTransaction')
    seen = set()
    for tx in Transaction.objects.exclude(tx_ref='').order_by('created_at', 'id'):
        if tx.tx_ref in seen:
            tx.tx_ref = f'{tx.tx_ref}-{str(tx.id)[:8]}'
            tx.save(update_fields=['tx_ref'])
        seen.add(tx.tx_ref)


class Migration(migrations.Migration):

    dependencies = [
        ('wallet', '0005_alter_artifacttransaction_transaction_type'),
    ]

    operations = [
        migrations.RunPython(dedupe_tx_refs, migrations.RunPython.noop),
        migrations.AddConstraint(
            model_name='artifacttransaction',
            constraint=models.UniqueConstraint(
                fields=('tx_ref',),
                condition=~models.Q(tx_ref=''),
                name='wallet_unique_nonblank_tx_ref',
            ),
        ),
    ]
