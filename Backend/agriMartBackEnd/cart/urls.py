from django import views
from django.urls import path
from .views import available_crops

urlpatterns = [
    path('getItems/', available_crops, name="get_cart_items"),
]