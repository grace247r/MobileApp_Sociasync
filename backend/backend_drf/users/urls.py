from django.urls import path
from .views import login_view, register_view, me_view, update_profile
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('login/', login_view),
    path('register/', register_view),
    path('me/', me_view),
    path('profile/', update_profile),
    path('refresh/', TokenRefreshView.as_view()),
]