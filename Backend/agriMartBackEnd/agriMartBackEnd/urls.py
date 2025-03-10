# 
from django.contrib import admin
from django.urls import path

from agriMartBackEnd.views import get_stream_jwt

urlpatterns = [
    path('admin/', admin.site.urls),
    path('get-stream-jwt/', get_stream_jwt, name='get_stream_jwt'),

]

