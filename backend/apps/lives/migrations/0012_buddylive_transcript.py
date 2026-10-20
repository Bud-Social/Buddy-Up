from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('lives', '0011_livereplayview'),
    ]

    operations = [
        migrations.AddField(
            model_name='buddylive',
            name='transcript',
            field=models.TextField(blank=True),
        ),
    ]
