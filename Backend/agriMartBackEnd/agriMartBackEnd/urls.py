
from django.contrib import admin
from django.urls import include, path

from register import views
from django.urls import include, path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('register.urls')),  # Add users app URLs here
    path('buyerview/', include('buyerview.urls')),
    path('cart/', include('cart.urls')),
    path('api/crops/', include('crops.urls')),
    path('auth/', include('user_details.urls')),
]