from django.contrib import admin
from .models import Schedule


@admin.register(Schedule)
class ScheduleAdmin(admin.ModelAdmin):
	list_display = (
		'id',
		'title',
		'user',
		'platform',
		'start_time',
		'end_time',
		'repeat',
		'is_posted',
		'created_at',
	)
	list_filter = ('platform', 'repeat', 'is_posted', 'created_at')
	search_fields = ('title', 'caption', 'notes', 'user__username', 'user__email')
	ordering = ('-created_at',)
