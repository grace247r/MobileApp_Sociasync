from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .models import Schedule
from .serializers import ScheduleSerializer


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def schedule_list_create(request):
    if request.method == 'GET':
        schedules = Schedule.objects.filter(user=request.user)
        serializer = ScheduleSerializer(schedules, many=True)
        return Response(serializer.data)

    elif request.method == 'POST':
        serializer = ScheduleSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)


@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
@permission_classes([IsAuthenticated])
def schedule_detail(request, pk):
    try:
        schedule = Schedule.objects.get(pk=pk, user=request.user)
    except Schedule.DoesNotExist:
        return Response(status=404)

    if request.method == 'GET':
        serializer = ScheduleSerializer(schedule)
        return Response(serializer.data)

    elif request.method in ['PUT', 'PATCH']:
        serializer = ScheduleSerializer(
            schedule,
            data=request.data,
            partial=request.method == 'PATCH',
        )
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)

    elif request.method == 'DELETE':
        schedule.delete()
        return Response(status=204)