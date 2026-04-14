from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class TikTokProfile(models.Model):
    """Store TikTok profile data"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='tiktok_profile', null=True, blank=True)
    username = models.CharField(max_length=255)
    url = models.URLField(unique=True)
    profile_pic = models.URLField(blank=True, null=True)
    biography = models.TextField(blank=True)
    followers = models.IntegerField(default=0)
    following = models.IntegerField(default=0)
    videos_count = models.IntegerField(default=0)
    likes_count = models.IntegerField(default=0)  # Total likes on all videos
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.username

    class Meta:
        ordering = ['-updated_at']


class TikTokVideo(models.Model):
    """Store TikTok videos data"""
    profile = models.ForeignKey(TikTokProfile, on_delete=models.CASCADE, related_name='videos')
    video_id = models.CharField(max_length=255, unique=True)
    video_url = models.URLField()
    caption = models.TextField(blank=True)
    thumbnail_url = models.URLField(blank=True, null=True)
    likes = models.IntegerField(default=0)
    comments_count = models.IntegerField(default=0)
    shares = models.IntegerField(default=0)
    views = models.IntegerField(default=0)
    video_timestamp = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.profile.username} - {self.video_id}"

    class Meta:
        ordering = ['-video_timestamp']


class TikTokStats(models.Model):
    """Store aggregated stats for dashboard - snapshot in time"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tiktok_stats')
    profile = models.ForeignKey(TikTokProfile, on_delete=models.CASCADE, related_name='stats')
    
    # Key metrics
    total_videos = models.IntegerField(default=0)
    followers_count = models.IntegerField(default=0)
    engagement_percentage = models.FloatField(default=0.0)  # Calculated metric
    
    # Additional metrics
    total_likes = models.IntegerField(default=0)
    total_comments = models.IntegerField(default=0)
    total_views = models.IntegerField(default=0)
    total_shares = models.IntegerField(default=0)
    average_likes_per_video = models.FloatField(default=0.0)
    average_views_per_video = models.FloatField(default=0.0)
    
    recorded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.profile.username} - {self.recorded_at}"

    class Meta:
        ordering = ['-recorded_at']


class TikTokScrapeJob(models.Model):
    """Track TikTok scraping jobs and their status"""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('running', 'Running'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tiktok_scrape_jobs')
    profile = models.ForeignKey(TikTokProfile, on_delete=models.CASCADE, related_name='scrape_jobs')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    apify_run_id = models.CharField(max_length=255, blank=True, null=True)
    videos_scraped = models.IntegerField(default=0)
    engagement_percentage = models.FloatField(default=0.0)
    error_message = models.TextField(blank=True)
    started_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.user.username} - {self.profile.username} - {self.status}"

    class Meta:
        ordering = ['-started_at']
