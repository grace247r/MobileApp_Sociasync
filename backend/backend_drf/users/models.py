from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    GENDER_CHOICES = [
        ('male', 'Male'),
        ('female', 'Female'),
    ]

    REGION_CHOICES = [
        ('sumatra', 'Sumatra'),
        ('java', 'Java'),
        ('kalimantan', 'Kalimantan'),
        ('sulawesi', 'Sulawesi'),
        ('papua', 'Papua'),
        ('bali', 'Bali'),
        ('lombok', 'Lombok'),
        ('flores', 'Flores'),
    ]

    name = models.CharField(max_length=100, default='')
    email = models.EmailField(unique=True)
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES, default='male')

    date_of_birth = models.DateField(null=True, blank=True)
    region = models.CharField(max_length=100, choices=REGION_CHOICES, blank=True)
