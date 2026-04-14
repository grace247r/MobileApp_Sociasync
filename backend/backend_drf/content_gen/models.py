from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class Content(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)

    topic = models.CharField(max_length=255)
    platform = models.CharField(max_length=50)

    idea_title = models.CharField(max_length=255)
    idea_description = models.TextField()

    hook = models.TextField()
    body = models.TextField()
    cta = models.TextField()

    caption = models.TextField()
    hashtags = models.JSONField()

    created_at = models.DateTimeField(auto_now_add=True)