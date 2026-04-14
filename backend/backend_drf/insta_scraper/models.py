from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class InstagramProfile(models.Model):
    """Store Instagram profile/hashtag data"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='instagram_profile', null=True, blank=True)
    username = models.CharField(max_length=255)
    url = models.URLField(max_length=1000, unique=True)
    profile_pic = models.URLField(max_length=1000, blank=True, null=True)
    biography = models.TextField(blank=True)
    followers = models.IntegerField(default=0)
    following = models.IntegerField(default=0)
    posts_count = models.IntegerField(default=0)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.username

    class Meta:
        ordering = ['-updated_at']


class InstagramPost(models.Model):
    """Store Instagram posts data"""
    profile = models.ForeignKey(InstagramProfile, on_delete=models.CASCADE, related_name='posts')
    post_id = models.CharField(max_length=255, unique=True)
    post_url = models.URLField(max_length=1000)
    caption = models.TextField(blank=True)
    image_url = models.URLField(max_length=1000, blank=True, null=True)
    video_url = models.URLField(max_length=1000, blank=True, null=True)
    likes = models.IntegerField(default=0)
    comments_count = models.IntegerField(default=0)
    shares = models.IntegerField(default=0)
    post_timestamp = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.profile.username} - {self.post_id}"

    class Meta:
        ordering = ['-post_timestamp']


class InstagramStats(models.Model):
    """Store aggregated stats for dashboard - snapshot in time"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='instagram_stats')
    profile = models.ForeignKey(InstagramProfile, on_delete=models.CASCADE, related_name='stats')
    
    # Key metrics
    total_posts = models.IntegerField(default=0)
    followers_count = models.IntegerField(default=0)
    engagement_percentage = models.FloatField(default=0.0)  # Calculated metric
    
    # Additional metrics
    total_likes = models.IntegerField(default=0)
    total_comments = models.IntegerField(default=0)
    average_likes_per_post = models.FloatField(default=0.0)
    average_comments_per_post = models.FloatField(default=0.0)
    
    recorded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.profile.username} - {self.recorded_at}"

    class Meta:
        ordering = ['-recorded_at']


class ScrapeJob(models.Model):
    """Track scraping jobs and their status"""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('running', 'Running'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='scrape_jobs')
    profile = models.ForeignKey(InstagramProfile, on_delete=models.CASCADE, related_name='scrape_jobs')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    apify_run_id = models.CharField(max_length=255, blank=True, null=True)
    posts_scraped = models.IntegerField(default=0)
    engagement_percentage = models.FloatField(default=0.0)
    error_message = models.TextField(blank=True)
    started_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.user.username} - {self.profile.username} - {self.status}"

    class Meta:
        ordering = ['-started_at']
