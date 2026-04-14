from django.urls import path
from reminder_msg.views import (
    complete_reminder, 
    create_reminder, 
    get_reminders, 
    update_reminder
)

urlpatterns = [
    path('', get_reminders),
    path('create/', create_reminder),
    path('update/<int:pk>/', update_reminder),
    path('complete/<int:pk>/', complete_reminder),
]
