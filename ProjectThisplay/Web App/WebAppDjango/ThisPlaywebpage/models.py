from django.db import models
from django.contrib import admin
# Create your models here.
class Uploads(models.Model):
    file = models.FileField(upload_to='uploads/', null=True, blank=True)
    text_content = models.TextField(null=True, blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)
