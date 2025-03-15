# buyerview/urls.py

from django.urls import path
from .views import available_non_booked_crops
from buyerview import views

urlpatterns = [
    path('view_crops/', available_non_booked_crops, name='view_crops'),
    path('crop-details/<str:crop_id>/', views.get_crop_details, name='get_crop_details'),
    path('add-to-cart/', views.add_to_cart, name='add_to_cart'),  # Add this new endpoint
    path('users-crops-details/', views.get_user_crops_and_stats, name='get_user_crops_and_stats'),  # Add this new endpoint

]
