from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Reminder
from .serializers import ReminderSerializer

# GET all reminders
@api_view(['GET'])
def get_reminders(request):
    reminders = Reminder.objects.filter(user=request.user, is_completed=False)
    serializer = ReminderSerializer(reminders, many=True)
    return Response(serializer.data)


# CREATE
@api_view(['POST'])
def create_reminder(request):
    serializer = ReminderSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(user=request.user)
        return Response(serializer.data)
    return Response(serializer.errors)


# UPDATE
@api_view(['PATCH'])
def update_reminder(request, pk):
    reminder = Reminder.objects.get(id=pk)
    serializer = ReminderSerializer(reminder, data=request.data, partial=True)  # 🔥 penting
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors)


# COMPLETE (DONE)
@api_view(['PATCH'])
def complete_reminder(request, pk):
    reminder = Reminder.objects.get(id=pk)
    reminder.is_completed = True
    reminder.save()
    return Response({"message": "Completed"})