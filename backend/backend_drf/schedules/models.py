from django.db import models
from django.conf import settings    

class Schedule(models.Model):
    PLATFORM_CHOICES = [
        ('instagram', 'Instagram'),
        ('tiktok', 'TikTok'),
    ]

    # Tambahkan pilihan untuk Repeat/Pengulangan
    REPEAT_CHOICES = [
        ('never', 'Never'),
        ('daily', 'Daily'),
        ('weekly', 'Weekly'),
        ('monthly', 'Monthly'),
    ]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    title = models.CharField(max_length=255)
    caption = models.TextField()
    platform = models.CharField(max_length=20, choices=PLATFORM_CHOICES)
    
    # DI UI ADA START & END
    start_time = models.DateTimeField() # Ini scheduled_time kamu tadi
    end_time = models.DateTimeField(null=True, blank=True) # Tambahkan ini untuk slot waktu
    
    # DI UI ADA REPEAT & REMINDER
    is_daily = models.BooleanField(default=False) # Untuk switch "Daily" di UI
    repeat = models.CharField(max_length=20, choices=REPEAT_CHOICES, default='never')
    reminder_type = models.CharField(max_length=50, default='Never') # Misal: "10 mins before"
    
    # DI UI ADA NOTES
    notes = models.TextField(null=True, blank=True)
    
    is_posted = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        # Perbaiki format __str__ (hapus slash yang typo tadi)
        return f"{self.title} - {self.user.username}"