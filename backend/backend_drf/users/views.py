from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import RegisterSerializer, ProfileSerializer
from .models import User
from django.contrib.auth import authenticate


def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        "refresh": str(refresh),
        "access": str(refresh.access_token),
    }

@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    serializer = RegisterSerializer(data=request.data)

    if serializer.is_valid():
        user = serializer.save()

        return Response({
            "tokens": get_tokens_for_user(user),
            "user": serializer.data
        }, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    email = request.data.get('email')
    password = request.data.get('password')

    user = authenticate(username=email, password=password)

    if user is not None:
        tokens = get_tokens_for_user(user)
        user_data = ProfileSerializer(user).data
        return Response({
            "tokens": tokens,
            "user": user_data
        })

    return Response({"error": "Invalid credentials"}, status=400)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_profile(request):
    serializer = ProfileSerializer(
        request.user,
        data=request.data,
        partial=True
    )

    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)

    return Response(serializer.errors, status=400)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def me_view(request):
    serializer = ProfileSerializer(request.user)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_regions(request):
    regions = [{'value': choice[0], 'label': choice[1]} for choice in User.REGION_CHOICES]
    return Response({'regions': regions})