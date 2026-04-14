from django.contrib import admin
from .models import Content


@admin.register(Content)
class ContentAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'topic', 'platform', 'idea_title', 'created_at')
    list_filter = ('platform', 'created_at')
    search_fields = ('topic', 'idea_title', 'idea_description')
    readonly_fields = ('created_at',)
    
    fieldsets = (
        ('User & Topic', {
            'fields': ('user', 'topic', 'platform')
        }),
        ('Idea', {
            'fields': ('idea_title', 'idea_description')
        }),
        ('Script', {
            'fields': ('hook', 'body', 'cta')
        }),
        ('Caption & Hashtags', {
            'fields': ('caption', 'hashtags')
        }),
        ('Metadata', {
            'fields': ('created_at',),
            'classes': ('collapse',)
        }),
    )
