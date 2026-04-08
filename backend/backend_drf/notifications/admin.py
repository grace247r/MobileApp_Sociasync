from django.contrib import admin
from .models import Notification
from django.contrib.auth import get_user_model

User = get_user_model()

@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('title', 'notif_type', 'recipient', 'is_broadcast', 'created_at')
    list_filter = ('notif_type', 'is_broadcast')

    def save_model(self, request, obj, form, change):
        if obj.is_broadcast:
            users = User.objects.filter(is_staff=False)
            for user in users:
                Notification.objects.create(
                    recipient=user,
                    sender=request.user,
                    notif_type='admin',
                    title=obj.title,
                    message=obj.message
                )
        else:
            obj.sender = request.user
            super().save_model(request, obj, form, change)