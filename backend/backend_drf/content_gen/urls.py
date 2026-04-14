from django.urls import path
from .views import *

urlpatterns = [
    path('generate-ideas/', generate_ideas),
    path('generate-script/', generate_script),
    path('generate-caption/', generate_caption),
    path('generate-hashtags/', generate_hashtags),
    path('save-content/', save_content),
    path('saved-content/', saved_content),
]