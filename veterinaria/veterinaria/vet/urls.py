from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from . import views
urlpatterns = [
    path('',views.home, name='principal'),
    path('login/', views.login_view, name='login'),  # Página de login
    path('registro/', views.registro_view, name='registro'),
    path('registro1/', views.registro1_view, name='registro1'),
    path('usuario/menu/', views.menu_usuario, name='menu_usuario'),  # o /menu/
    path('logout/', views.logout_view, name='logout'),
    path('agregar-mascota/', views.agregar_mascota, name='agregar_mascota'),
    path('agendar-cita/', views.agendar_cita, name='agendar_cita'),

]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

