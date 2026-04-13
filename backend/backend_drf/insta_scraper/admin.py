from django.contrib import admin
from .models import InstagramProfile, InstagramPost, ScrapeJob


@admin.register(InstagramProfile)
class InstagramProfileAdmin(admin.ModelAdmin):
    list_display = ('username', 'followers', 'posts_count', 'updated_at')
    search_fields = ('username', 'url')
    readonly_fields = ('created_at', 'updated_at')


@admin.register(InstagramPost)
class InstagramPostAdmin(admin.ModelAdmin):
    list_display = ('profile', 'post_id', 'likes', 'post_timestamp')
    search_fields = ('profile__username', 'caption')
    list_filter = ('post_timestamp', 'profile')
    readonly_fields = ('created_at', 'updated_at')


@admin.register(ScrapeJob)
class ScrapeJobAdmin(admin.ModelAdmin):
    list_display = ('user', 'profile', 'status', 'posts_scraped', 'started_at')
    list_filter = ('status', 'started_at')
    search_fields = ('user__username', 'profile__username')
    readonly_fields = ('started_at', 'completed_at')
