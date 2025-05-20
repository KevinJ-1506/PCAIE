from django.shortcuts import render, redirect
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login
from django.contrib.auth.decorators import login_required
from .models import Mascota, ServicioInicio
from .forms import RegistroForm
from .models import Servicio
from .models import HFDisponible  # asegúrate de importar

def login_view(request):
    return render(request, 'vet/login.html')

def home(request):
    servicios_mostrar = ServicioInicio.objects.filter(mostrar=True)
    return render(request, 'vet/home.html', {'servicios_mostrar': servicios_mostrar})

def registro1_view(request):
    return render(request, 'vet/registro1.html')

def menuusuario_view(request):
    return render(request, 'vet/menu_usuario.html')

def registro_view(request):
    if request.method == "POST":
        form = RegistroForm(request.POST, request.FILES)
        if form.is_valid():
            usuario = form.save()          # crea usuario+cliente+mascota
            # Autenticar y entrar automáticamente
            login(request, usuario)
            return redirect('home')        # o a donde prefieras
    else:
        form = RegistroForm()

    return render(request, 'vet/registro.html', {'form': form})


def menu_usuario(request):
    servicios = Servicio.objects.all()
    return render(request, 'vet/menu_usuario.html', {
        'servicios': servicios
    })



def menu_usuario(request):
    servicios = Servicio.objects.all()
    fechas_horas = HFDisponible.objects.filter(disponible=True).order_by('fecha', 'hora')
    return render(request, 'vet/menu_usuario.html', {
        'servicios': servicios,
        'fechas_horas': fechas_horas
    })
