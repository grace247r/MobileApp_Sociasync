from django.db import models
from django.conf import settings    

class Schedule(models.Model):
    PLATFORM_CHOICES = [
        ('instagram', 'Instagram'),
        ('tiktok', 'TikTok'),
    ]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    title = models.CharField(max_length=255)
    caption = models.TextField()
    platform = models.CharField(max_length=20, choices=PLATFORM_CHOICES)
    scheduled_time = models.DateTimeField()
    is_posted = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} - {self.user.username}"