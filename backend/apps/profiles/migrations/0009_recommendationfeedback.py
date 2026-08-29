from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    dependencies = [('profiles', '0008_onboarding_consent')]

    operations = [
        migrations.CreateModel(
            name='RecommendationFeedback',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('feedback', models.CharField(choices=[('not_interested', 'Not Interested'), ('irrelevant', 'Irrelevant'), ('already_connected', 'Already Connected'), ('helpful', 'Helpful')], max_length=20)),
                ('history', models.JSONField(blank=True, default=list)),
                ('target', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='recommendation_feedback_received', to='profiles.profile')),
                ('viewer', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='recommendation_feedback_given', to='profiles.profile')),
            ],
            options={'db_table': 'profiles_recommendation_feedback'},
        ),
        migrations.AddConstraint(
            model_name='recommendationfeedback',
            constraint=models.UniqueConstraint(fields=('viewer', 'target'), name='unique_profile_recommendation_feedback'),
        ),
        migrations.AddConstraint(
            model_name='recommendationfeedback',
            constraint=models.CheckConstraint(condition=~models.Q(('viewer', models.F('target'))), name='recommendation_feedback_not_self'),
        ),
        migrations.AddIndex(
            model_name='recommendationfeedback',
            index=models.Index(fields=['viewer', 'feedback'], name='profiles_re_viewer__4ce10b_idx'),
        ),
    ]
