from django.contrib import admin
from .models import Notification
from django.contrib.auth import get_user_model
from .services import _create_notification_if_allowed

User = get_user_model()

@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('title', 'notif_type', 'recipient', 'is_broadcast', 'created_at')
    list_filter = ('notif_type', 'is_broadcast')

    def save_model(self, request, obj, form, change):
        if obj.is_broadcast:
            users = User.objects.filter(is_staff=False)
            for user in users:
                _create_notification_if_allowed(
                    request.user,
                    recipient=user,
                    sender=request.user,
                    notif_type='admin',
                    title=obj.title,
                    message=obj.message,
                    is_broadcast=True,
                )
        else:
            created = _create_notification_if_allowed(
                request.user,
                recipient=obj.recipient,
                sender=request.user,
                notif_type=obj.notif_type,
                title=obj.title,
                message=obj.message,
                is_broadcast=obj.is_broadcast,
            )
            if created is None:
                return