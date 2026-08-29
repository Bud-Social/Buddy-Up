import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('gyms', '0008_gym_content_rating'), ('profiles', '0008_onboarding_consent')]

    operations = [
        migrations.CreateModel(
            name='GymOnboardingChecklist',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('completed_steps', models.JSONField(default=list)),
                ('notes', models.TextField(blank=True)),
                ('completed_at', models.DateTimeField(blank=True, null=True)),
                ('gym', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='onboarding_checklist', to='gyms.gym')),
            ],
            options={'db_table': 'gyms_onboarding_checklist'},
        ),
        migrations.CreateModel(
            name='VenueLocation',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('name', models.CharField(max_length=120)),
                ('address', models.TextField(blank=True)),
                ('city', models.CharField(blank=True, max_length=100)),
                ('country', models.CharField(blank=True, max_length=100)),
                ('latitude', models.DecimalField(blank=True, decimal_places=6, max_digits=9, null=True)),
                ('longitude', models.DecimalField(blank=True, decimal_places=6, max_digits=9, null=True)),
                ('instructions', models.TextField(blank=True)),
                ('is_primary', models.BooleanField(default=False)),
                ('is_active', models.BooleanField(default=True)),
                ('gym', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='venues', to='gyms.gym')),
            ],
            options={'db_table': 'gyms_venue_location'},
        ),
        migrations.CreateModel(
            name='AttendanceRecord',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('status', models.CharField(choices=[('checked_in', 'Checked In'), ('checked_out', 'Checked Out'), ('absent', 'Absent')], default='checked_in', max_length=15)),
                ('checked_in_at', models.DateTimeField(blank=True, null=True)),
                ('checked_out_at', models.DateTimeField(blank=True, null=True)),
                ('source', models.CharField(default='partner', max_length=20)),
                ('notes', models.CharField(blank=True, max_length=300)),
                ('gym', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='attendance_records', to='gyms.gym')),
                ('member', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='gym_attendance', to='profiles.profile')),
                ('schedule_post', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='attendance_records', to='gyms.gymschedulepost')),
                ('venue', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='attendance_records', to='gyms.venuelocation')),
            ],
            options={'db_table': 'gyms_attendance_record'},
        ),
        migrations.AddIndex(model_name='venuelocation', index=models.Index(fields=['gym', 'is_active'], name='gyms_venue_gym_id_8fe6c1_idx')),
        migrations.AddIndex(model_name='attendancerecord', index=models.Index(fields=['gym', '-checked_in_at'], name='gyms_atten_gym_id_19e13e_idx')),
        migrations.AddIndex(model_name='attendancerecord', index=models.Index(fields=['member', '-checked_in_at'], name='gyms_atten_member__34012c_idx')),
    ]
