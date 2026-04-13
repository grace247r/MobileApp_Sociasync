from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('schedules', '0001_initial'),
    ]

    operations = [
        migrations.RenameField(
            model_name='schedule',
            old_name='scheduled_time',
            new_name='start_time',
        ),
        migrations.AddField(
            model_name='schedule',
            name='end_time',
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='schedule',
            name='is_daily',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='schedule',
            name='notes',
            field=models.TextField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='schedule',
            name='reminder_type',
            field=models.CharField(default='Never', max_length=50),
        ),
        migrations.AddField(
            model_name='schedule',
            name='repeat',
            field=models.CharField(
                choices=[
                    ('never', 'Never'),
                    ('daily', 'Daily'),
                    ('weekly', 'Weekly'),
                    ('monthly', 'Monthly'),
                ],
                default='never',
                max_length=20,
            ),
        ),
    ]
