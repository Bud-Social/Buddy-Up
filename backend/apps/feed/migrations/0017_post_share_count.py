from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feed', '0016_postmedia_edit_meta'),
    ]

    operations = [
        migrations.AddField(
            model_name='post',
            name='share_count',
            field=models.IntegerField(default=0),
        ),
    ]
