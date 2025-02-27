# crops/urls.py
from django.urls import path
from .views import CropUploadView

urlpatterns = [
    path('upload_crop/', CropUploadView.as_view(), name='upload_crop'),
]
