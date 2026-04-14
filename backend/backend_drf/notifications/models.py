from django.db import models
from backend_drf import settings

class Notification(models.Model):
    NOTIF_TYPES = (
        ('admin', 'Admin'),
        ('like', 'Like'),
        ('follow', 'Follow'),
        ('engagement', 'Engagement'),
        ('followers', 'New Followers'),
        ('activity', 'Activity Update'),
    )

    recipient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications',
        null=True,
        blank=True
    )  # null = broadcast ke semua user

    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )

    notif_type = models.CharField(max_length=20, choices=NOTIF_TYPES, default='admin')
    title = models.CharField(max_length=255)
    message = models.TextField()

    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    is_broadcast = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.title} - {self.notif_type}"


class NotificationSettings(models.Model):
    PUSH_SCHEDULE_CHOICES = (
        ('always', 'Always'),
        ('work_hours', 'During work hours (9AM - 6PM)'),
        ('custom', 'Custom schedule'),
    )

    SMS_FREQUENCY_CHOICES = (
        ('instantly', 'Instantly'),
        ('daily', 'Daily digest'),
        ('weekly', 'Weekly digest'),
    )

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notification_settings',
    )

    likes_enabled = models.BooleanField(default=False)
    comments_enabled = models.BooleanField(default=False)
    new_followers_enabled = models.BooleanField(default=False)
    profile_views_enabled = models.BooleanField(default=False)
    post_interacted_enabled = models.BooleanField(default=True)

    in_app_all_enabled = models.BooleanField(default=True)
    in_app_sound = models.BooleanField(default=True)
    in_app_vibration = models.BooleanField(default=False)
    in_app_banner = models.BooleanField(default=True)

    push_schedule = models.CharField(
        max_length=20,
        choices=PUSH_SCHEDULE_CHOICES,
        default='always',
    )

    email_newsletter = models.BooleanField(default=True)
    email_activity_summary = models.BooleanField(default=False)
    email_security_alerts = models.BooleanField(default=True)
    email_promotions = models.BooleanField(default=False)

    sms_enabled = models.BooleanField(default=False)
    sms_frequency = models.CharField(
        max_length=20,
        choices=SMS_FREQUENCY_CHOICES,
        default='instantly',
    )

    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Notification settings for {self.user}"