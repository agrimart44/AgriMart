from django.urls import path
from .views import CropListingView

urlpatterns = [
    path('list-crop/', CropListingView.as_view(), name='list_crop'),
]
