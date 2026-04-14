from django.db import models
from django.conf import settings

class Reminder(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    to = models.CharField(max_length=100)
    message = models.TextField()
    day = models.CharField(max_length=20)
    time = models.TimeField()
    is_completed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.to} - {self.message[:20]}"