from django.urls import path
from rest_framework.routers import DefaultRouter
from .views import TikTokViewSet

router = DefaultRouter()
router.register(r'tiktok', TikTokViewSet, basename='tiktok')

urlpatterns = router.urls
