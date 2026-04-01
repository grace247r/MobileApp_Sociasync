from django.urls import path
from .views import (
    register_view,
    update_profile,
    login_view,
    me_view
)

urlpatterns = [
    path('register/', register_view, name='register'),
    path('profile/', update_profile, name='update_profile'),
    path('login/', login_view, name='login'),
    path('me/', me_view, name='me'),
]