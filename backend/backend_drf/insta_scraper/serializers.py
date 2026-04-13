from rest_framework import serializers
from .models import InstagramProfile, InstagramPost, ScrapeJob, InstagramStats

class InstagramPostSerializer(serializers.ModelSerializer):
    class Meta:
        model = InstagramPost
        fields = [
            'id',
            'post_id',
            'post_url',
            'caption',
            'image_url',
            'video_url',
            'likes',
            'comments_count',
            'shares',
            'post_timestamp',
            'created_at',
        ]


class InstagramProfileSerializer(serializers.ModelSerializer):
    posts = InstagramPostSerializer(many=True, read_only=True)

    class Meta:
        model = InstagramProfile
        fields = [
            'id',
            'username',
            'url',
            'profile_pic',
            'biography',
            'followers',
            'following',
            'posts_count',
            'is_verified',
            'posts',
            'created_at',
            'updated_at',
        ]


class InstagramStatsSerializer(serializers.ModelSerializer):
    """Serializer for dashboard statistics"""
    profile_username = serializers.CharField(source='profile.username', read_only=True)
    
    class Meta:
        model = InstagramStats
        fields = [
            'id',
            'profile_username',
            'total_posts',
            'followers_count',
            'engagement_percentage',
            'total_likes',
            'total_comments',
            'average_likes_per_post',
            'average_comments_per_post',
            'recorded_at',
        ]


class ScrapeJobSerializer(serializers.ModelSerializer):
    profile_username = serializers.CharField(source='profile.username', read_only=True)

    class Meta:
        model = ScrapeJob
        fields = [
            'id',
            'profile_username',
            'status',
            'posts_scraped',
            'engagement_percentage',
            'error_message',
            'started_at',
            'completed_at',
        ]


class ConnectInstagramSerializer(serializers.Serializer):
    """Validate Instagram username input from user"""
    instagram_username = serializers.CharField(max_length=255)
    
    def validate_instagram_username(self, value):
        # Remove leading @ if present
        username = value.lstrip('@').lower()
        if not username or len(username) < 1:
            raise serializers.ValidationError("Invalid Instagram username")
        return username


class DashboardStatsSerializer(serializers.Serializer):
    """Dashboard overview for user"""
    latest_stats = InstagramStatsSerializer(read_only=True)
    instagram_username = serializers.CharField(read_only=True)
    last_scraped = serializers.DateTimeField(read_only=True)
    instagram_connected = serializers.BooleanField(read_only=True)
