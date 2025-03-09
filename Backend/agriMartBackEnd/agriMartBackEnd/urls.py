
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('buyerview/', include('buyerview.urls')),
    path('cart/', include('cart.urls')),
    path('api/crops/', include('crops.urls')),

]
