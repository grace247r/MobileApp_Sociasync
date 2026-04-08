from django.db import models
from backend_drf import settings

class Notification(models.Model):
    NOTIF_TYPES = (
        ('admin', 'Admin'),
        ('like', 'Like'),
        ('follow', 'Follow'),
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