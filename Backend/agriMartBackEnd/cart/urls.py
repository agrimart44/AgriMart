from django import views
from django.urls import path
from .views import available_crops, clear_cart

urlpatterns = [
    path('getItems/', available_crops, name="get_cart_items"),
    path('clearCart/', clear_cart, name="clear_cart"),
]