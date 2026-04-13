from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import InstagramViewSet

router = DefaultRouter()
router.register(r'instagram', InstagramViewSet, basename='instagram')

urlpatterns = [
    path('', include(router.urls)),
]
