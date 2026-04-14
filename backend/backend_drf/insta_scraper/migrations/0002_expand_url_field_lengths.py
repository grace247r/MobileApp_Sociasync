from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('insta_scraper', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='instagrampost',
            name='image_url',
            field=models.URLField(blank=True, max_length=1000, null=True),
        ),
        migrations.AlterField(
            model_name='instagrampost',
            name='post_url',
            field=models.URLField(max_length=1000),
        ),
        migrations.AlterField(
            model_name='instagrampost',
            name='video_url',
            field=models.URLField(blank=True, max_length=1000, null=True),
        ),
        migrations.AlterField(
            model_name='instagramprofile',
            name='profile_pic',
            field=models.URLField(blank=True, max_length=1000, null=True),
        ),
        migrations.AlterField(
            model_name='instagramprofile',
            name='url',
            field=models.URLField(max_length=1000, unique=True),
        ),
    ]
