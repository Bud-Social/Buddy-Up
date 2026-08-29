from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('ai', '0003_aipredictionjob_result_url_and_more')]

    operations = [
        migrations.AddField(model_name='aipredictionjob', name='confidence', field=models.FloatField(null=True, blank=True)),
        migrations.AddField(model_name='aipredictionjob', name='correction', field=models.JSONField(default=dict, blank=True)),
        migrations.AddField(model_name='aipredictionjob', name='fallback_used', field=models.BooleanField(default=False)),
        migrations.AddField(model_name='aipredictionjob', name='fallback_reason', field=models.CharField(max_length=255, blank=True)),
        migrations.AddField(model_name='aipredictionjob', name='cost_usd', field=models.DecimalField(max_digits=10, decimal_places=6, null=True, blank=True)),
        migrations.AddField(model_name='aipredictionjob', name='latency_ms', field=models.PositiveIntegerField(null=True, blank=True)),
        migrations.AddField(model_name='aipredictionjob', name='safety_notice', field=models.CharField(max_length=255, default='AI output is informational only, not medical advice.')),
    ]
