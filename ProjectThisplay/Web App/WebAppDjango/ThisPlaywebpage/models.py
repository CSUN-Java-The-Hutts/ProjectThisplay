from django.db import models

# Create your models here.
class Uploads(models.Model):
    image = models.ImageField(upload_to='images/', null=True, blank=True)
    text_content = models.TextField(null=True, blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)