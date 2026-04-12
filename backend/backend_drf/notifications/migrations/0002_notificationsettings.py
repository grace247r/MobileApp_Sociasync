from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('notifications', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='NotificationSettings',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('likes_enabled', models.BooleanField(default=False)),
                ('comments_enabled', models.BooleanField(default=False)),
                ('new_followers_enabled', models.BooleanField(default=False)),
                ('profile_views_enabled', models.BooleanField(default=False)),
                ('post_interacted_enabled', models.BooleanField(default=True)),
                ('in_app_all_enabled', models.BooleanField(default=True)),
                ('in_app_sound', models.BooleanField(default=True)),
                ('in_app_vibration', models.BooleanField(default=False)),
                ('in_app_banner', models.BooleanField(default=True)),
                ('push_schedule', models.CharField(choices=[('always', 'Always'), ('work_hours', 'During work hours (9AM - 6PM)'), ('custom', 'Custom schedule')], default='always', max_length=20)),
                ('email_newsletter', models.BooleanField(default=True)),
                ('email_activity_summary', models.BooleanField(default=False)),
                ('email_security_alerts', models.BooleanField(default=True)),
                ('email_promotions', models.BooleanField(default=False)),
                ('sms_enabled', models.BooleanField(default=False)),
                ('sms_frequency', models.CharField(choices=[('instantly', 'Instantly'), ('daily', 'Daily digest'), ('weekly', 'Weekly digest')], default='instantly', max_length=20)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('user', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='notification_settings', to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
