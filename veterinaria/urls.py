from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from. import views

urlpatterns = [
    path('',views.home, name='principal'),
    path('login/', views.login_view, name='login'),  # Página de login
    path('registro/', views.registro_view, name='registro'),
    path('registro1/', views.registro1_view, name='registro1'),
    path('menu/', views.menu_usuario, name='menu_usuario'),



]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

