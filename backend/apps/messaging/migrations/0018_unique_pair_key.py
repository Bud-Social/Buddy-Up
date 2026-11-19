from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('messaging', '0017_backfill_pair_key'),
    ]

    operations = [
        migrations.AddConstraint(
            model_name='conversation',
            constraint=models.UniqueConstraint(condition=models.Q(('pair_key__gt', '')), fields=('pair_key',), name='unique_conversation_pair_key'),
        ),
    ]
