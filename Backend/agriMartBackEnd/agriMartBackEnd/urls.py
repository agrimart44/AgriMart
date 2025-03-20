
# 
from django.contrib import admin
from django.urls import include, path

from register import views
from django.urls import include, path

from agriMartBackEnd.views import get_access_token, get_stream_jwt, get_user_details, send_fcm_notification

urlpatterns = [
    path('admin/', admin.site.urls),
    path('get-stream-jwt/', get_stream_jwt, name='get_stream_jwt'),
    path('api/', include('register.urls')),  # Add users app URLs here
    path('buyerview/', include('buyerview.urls')),
    path('cart/', include('cart.urls')),
    path('api/crops/', include('crops.urls')),
    path('auth/', include('user_details.urls')),
     path('get_user_details/', get_user_details, name='get_user_details'),
    path('get_access_token/',get_access_token, name='get_access_token'),
    path('send_fcm_notification/',send_fcm_notification, name='send_fcm_notification'),
    
]

