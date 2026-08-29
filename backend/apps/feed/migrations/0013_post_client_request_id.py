from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('feed', '0012_draft_full_fidelity')]

    operations = [
        migrations.AddField(
            model_name='post',
            name='client_request_id',
            field=models.CharField(blank=True, max_length=128, null=True),
        ),
        migrations.AddConstraint(
            model_name='post',
            constraint=models.UniqueConstraint(condition=models.Q(('client_request_id__isnull', False)), fields=('author', 'client_request_id'), name='unique_post_client_request'),
        ),
    ]
