from django.contrib import admin
from .models import TikTokProfile, TikTokVideo, TikTokStats, TikTokScrapeJob


@admin.register(TikTokProfile)
class TikTokProfileAdmin(admin.ModelAdmin):
    list_display = ('username', 'followers', 'videos_count', 'is_verified', 'updated_at')
    list_filter = ('is_verified', 'updated_at')
    search_fields = ('username', 'biography')
    readonly_fields = ('created_at', 'updated_at')


@admin.register(TikTokVideo)
class TikTokVideoAdmin(admin.ModelAdmin):
    list_display = ('video_id', 'profile', 'likes', 'comments_count', 'views', 'video_timestamp')
    list_filter = ('profile', 'video_timestamp')
    search_fields = ('video_id', 'caption')
    readonly_fields = ('created_at', 'updated_at')


@admin.register(TikTokStats)
class TikTokStatsAdmin(admin.ModelAdmin):
    list_display = ('profile', 'followers_count', 'total_likes', 'engagement_percentage', 'recorded_at')
    list_filter = ('profile', 'recorded_at')
    search_fields = ('profile__username',)
    ordering = ('-recorded_at',)


@admin.register(TikTokScrapeJob)
class TikTokScrapeJobAdmin(admin.ModelAdmin):
    list_display = ('profile', 'status', 'videos_scraped', 'engagement_percentage', 'started_at')
    list_filter = ('status', 'started_at')
    search_fields = ('profile__username', 'error_message')
    readonly_fields = ('started_at', 'completed_at')
