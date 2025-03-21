from django.urls import path
from . import views

urlpatterns = [
    path('get_user_details/', views.get_user_details, name='get_user_details'),
]
