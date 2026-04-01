from django.urls import path
from .views import schedule_list_create, schedule_detail

urlpatterns = [
    path('', schedule_list_create),
    path('<int:pk>/', schedule_detail),
]