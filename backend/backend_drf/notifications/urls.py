from django.urls import path
from .views import (
    get_notifications,
    mark_all_notifications_read,
    notification_settings_view,
    unread_notification_count,
)

urlpatterns = [
    path('', get_notifications),
    path('unread-count/', unread_notification_count),
    path('read-all/', mark_all_notifications_read),
    path('settings/', notification_settings_view),
]