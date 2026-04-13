from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    GENDER_CHOICES = [
        ('male', 'Male'),
        ('female', 'Female'),
    ]

    name = models.CharField(max_length=100, default='')
    email = models.EmailField(unique=True)
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES, default='male')
    date_of_birth = models.DateField(null=True, blank=True)
    region = models.CharField(max_length=100, blank=True)

    profile_image = models.ImageField(
        upload_to='profile_images/',
        null=True,
        blank=True,
    )

    # Kolom ini sudah ada di database lama dan wajib diset saat insert.
    email_verification_token = models.CharField(
        max_length=100,
        null=True,
        blank=True,
    )
    email_verified = models.BooleanField(default=False)
    password_reset_token = models.CharField(
        max_length=100,
        null=True,
        blank=True,
    )
    
    # Instagram username for tracking
    instagram_username = models.CharField(max_length=255, blank=True, null=True, unique=True)
    instagram_connected = models.BooleanField(default=False)
    last_scraped = models.DateTimeField(null=True, blank=True)
