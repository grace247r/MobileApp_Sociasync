from rest_framework import serializers
from .models import TikTokProfile, TikTokVideo, TikTokScrapeJob, TikTokStats


class TikTokVideoSerializer(serializers.ModelSerializer):
    class Meta:
        model = TikTokVideo
        fields = [
            'id',
            'video_id',
            'video_url',
            'caption',
            'thumbnail_url',
            'likes',
            'comments_count',
            'shares',
            'views',
            'video_timestamp',
            'created_at',
        ]


class TikTokProfileSerializer(serializers.ModelSerializer):
    videos = TikTokVideoSerializer(many=True, read_only=True)

    class Meta:
        model = TikTokProfile
        fields = [
            'id',
            'username',
            'url',
            'profile_pic',
            'biography',
            'followers',
            'following',
            'videos_count',
            'likes_count',
            'is_verified',
            'videos',
            'created_at',
            'updated_at',
        ]


class TikTokStatsSerializer(serializers.ModelSerializer):
    """Serializer for dashboard statistics"""
    profile_username = serializers.CharField(source='profile.username', read_only=True)
    
    class Meta:
        model = TikTokStats
        fields = [
            'id',
            'profile_username',
            'total_videos',
            'followers_count',
            'engagement_percentage',
            'total_likes',
            'total_comments',
            'total_views',
            'total_shares',
            'average_likes_per_video',
            'average_views_per_video',
            'recorded_at',
        ]


class TikTokScrapeJobSerializer(serializers.ModelSerializer):
    profile_username = serializers.CharField(source='profile.username', read_only=True)

    class Meta:
        model = TikTokScrapeJob
        fields = [
            'id',
            'profile_username',
            'status',
            'videos_scraped',
            'engagement_percentage',
            'error_message',
            'started_at',
            'completed_at',
        ]


class ConnectTikTokSerializer(serializers.Serializer):
    """Validate TikTok username input from user"""
    tiktok_username = serializers.CharField(max_length=255)
    
    def validate_tiktok_username(self, value):
        # Remove leading @ if present
        username = value.lstrip('@').lower()
        if not username or len(username) < 1:
            raise serializers.ValidationError("Invalid TikTok username")
        return username


class TikTokDashboardStatsSerializer(serializers.Serializer):
    """Dashboard overview for user"""
    latest_stats = TikTokStatsSerializer(read_only=True)
    tiktok_username = serializers.CharField(read_only=True)
    last_scraped = serializers.DateTimeField(read_only=True)
    tiktok_connected = serializers.BooleanField(read_only=True)
