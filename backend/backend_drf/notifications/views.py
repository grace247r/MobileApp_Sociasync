from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Q
from .models import Notification, NotificationSettings
from .serializers import NotificationSerializer, NotificationSettingsSerializer


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_notifications(request):
    notifications = Notification.objects.filter(
        Q(recipient=request.user) |
        Q(is_broadcast=True) |
        Q(recipient__isnull=True)
    ).order_by('-created_at')

    serializer = NotificationSerializer(notifications, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def unread_notification_count(request):
    unread_count = Notification.objects.filter(
        Q(recipient=request.user) |
        Q(is_broadcast=True) |
        Q(recipient__isnull=True),
        is_read=False,
    ).count()
    return Response({'unread_count': unread_count})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_all_notifications_read(request):
    updated = Notification.objects.filter(
        Q(recipient=request.user) |
        Q(is_broadcast=True) |
        Q(recipient__isnull=True),
        is_read=False,
    ).update(is_read=True)
    return Response({'updated': updated})


@api_view(['GET', 'PUT'])
@permission_classes([IsAuthenticated])
def notification_settings_view(request):
    settings_obj, _ = NotificationSettings.objects.get_or_create(user=request.user)

    if request.method == 'GET':
        serializer = NotificationSettingsSerializer(settings_obj)
        return Response(serializer.data)

    serializer = NotificationSettingsSerializer(
        settings_obj,
        data=request.data,
        partial=True,
    )
    serializer.is_valid(raise_exception=True)
    serializer.save()
    return Response(serializer.data)