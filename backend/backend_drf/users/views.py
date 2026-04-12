from rest_framework.decorators import api_view, permission_classes
from rest_framework.decorators import parser_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import RegisterSerializer, ProfileSerializer
from .models import User
from django.contrib.auth import authenticate
from django.core.mail import send_mail
from django.conf import settings
import random


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
    identifier = (request.data.get('email') or request.data.get('username') or '').strip()
    password = request.data.get('password')

    if not identifier or not password:
        return Response({"error": "Email/username dan password wajib diisi"}, status=400)

    user_obj = User.objects.filter(email__iexact=identifier).first()
    if user_obj is None:
        user_obj = User.objects.filter(username__iexact=identifier).first()

    user = None
    if user_obj is not None and user_obj.check_password(password) and user_obj.is_active:
        user = user_obj
    else:
        username_for_auth = user_obj.username if user_obj is not None else identifier
        user = authenticate(username=username_for_auth, password=password)

    if user is not None:
        return Response({
            "tokens": get_tokens_for_user(user),
            "user": ProfileSerializer(user).data,
        })

    return Response({"error": "Invalid credentials"}, status=400)


@api_view(['PUT', 'PATCH', 'DELETE'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser, JSONParser])
def update_profile(request):
    if request.method == 'DELETE':
        request.user.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

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


def _find_user_by_identifier(identifier):
    identifier = (identifier or '').strip()
    if not identifier:
        return None

    user = User.objects.filter(email__iexact=identifier).first()
    if user is not None:
        return user

    return User.objects.filter(username__iexact=identifier).first()


@api_view(['POST'])
@permission_classes([AllowAny])
def send_password_reset_code(request):
    identifier = (request.data.get('email') or request.data.get('username') or '').strip()
    user = _find_user_by_identifier(identifier)

    if user is None:
        return Response({'error': 'Akun tidak ditemukan.'}, status=status.HTTP_404_NOT_FOUND)

    code = f"{random.randint(0, 999999):06d}"
    user.password_reset_token = code
    user.save(update_fields=['password_reset_token'])

    try:
        send_mail(
            subject='Sociasync - Password Reset Code',
            message=(
                f'Halo {user.name or user.username},\n\n'
                f'Kode reset password kamu: {code}\n\n'
                'Jika kamu tidak merasa meminta reset password, abaikan email ini.'
            ),
            from_email=getattr(settings, 'DEFAULT_FROM_EMAIL', 'noreply@sociasync.local'),
            recipient_list=[user.email],
            fail_silently=False,
        )
    except Exception as exc:
        error_message = 'Gagal mengirim email kode reset password.'
        if settings.DEBUG:
            error_message = f'{error_message} Detail: {exc}'
        return Response(
            {'error': error_message},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )

    return Response({'message': 'Kode reset password telah dikirim ke email kamu.'})


@api_view(['POST'])
@permission_classes([AllowAny])
def confirm_password_reset(request):
    identifier = (request.data.get('email') or request.data.get('username') or '').strip()
    code = (request.data.get('code') or '').strip()
    new_password = request.data.get('new_password') or ''
    confirm_password = request.data.get('confirm_password') or ''

    if not identifier or not code or not new_password or not confirm_password:
        return Response(
            {'error': 'Email/username, kode, dan password baru wajib diisi.'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    if new_password != confirm_password:
        return Response({'error': 'Konfirmasi password tidak cocok.'}, status=status.HTTP_400_BAD_REQUEST)

    user = _find_user_by_identifier(identifier)
    if user is None:
        return Response({'error': 'Akun tidak ditemukan.'}, status=status.HTTP_404_NOT_FOUND)

    if (user.password_reset_token or '').strip() != code:
        return Response({'error': 'Kode reset password tidak valid.'}, status=status.HTTP_400_BAD_REQUEST)

    user.set_password(new_password)
    user.password_reset_token = None
    user.save(update_fields=['password', 'password_reset_token'])

    return Response({'message': 'Password berhasil direset. Silakan login kembali.'})