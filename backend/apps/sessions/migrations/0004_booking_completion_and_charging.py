import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('booking_sessions', '0003_bookingsession_parent_series_and_more'), ('profiles', '0008_onboarding_consent')]

    operations = [
        migrations.AddField(model_name='bookingsession', name='completion_evidence', field=models.JSONField(default=dict)),
        migrations.AddField(model_name='bookingsession', name='completion_confirmed_by_client', field=models.BooleanField(default=False)),
        migrations.AddField(model_name='bookingsession', name='completed_by', field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='completed_bookings', to='profiles.profile')),
        migrations.AddField(model_name='bookingsession', name='recurring_charge_status', field=models.CharField(default='not_applicable', max_length=20)),
    ]
