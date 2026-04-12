from django.urls import path
from .views import (
    confirm_password_reset,
    login_view,
    me_view,
    register_view,
    send_password_reset_code,
    update_profile,
)
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('login/', login_view),
    path('register/', register_view),
    path('me/', me_view),
    path('profile/', update_profile),
    path('password-reset/request/', send_password_reset_code),
    path('password-reset/confirm/', confirm_password_reset),
    path('refresh/', TokenRefreshView.as_view()),
]