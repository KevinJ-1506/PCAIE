from django.shortcuts import render, redirect
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login
from django.contrib.auth.decorators import login_required
from .models import Mascota, ServicioInicio
from .forms import RegistroForm
from .models import Servicio
from .models import HFDisponible  # asegúrate de importar
import base64
from django.core.files.base import ContentFile
from django.contrib import messages
from django.contrib.auth import logout
from .forms import MascotaForm
from .models import Cliente
from .forms import CitaForm
from .models import Cita
from decimal import Decimal
from django.core.serializers import serialize
from django.core.mail import send_mail
from django.conf import settings


def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')  # o 'email' según tu formulario
        password = request.POST.get('password')

        user = authenticate(request, username=username, password=password)

        if user is not None:
            login(request, user)
            return redirect('menu_usuario')  # ← redirige al menú
        else:
            messages.error(request, 'Usuario o contraseña incorrectos.')

    return render(request, 'vet/login.html')



def logout_view(request):
    logout(request)
    return redirect('login')

def home(request):
    servicios_mostrar = ServicioInicio.objects.filter(mostrar=True)
    return render(request, 'vet/home.html', {'servicios_mostrar': servicios_mostrar})

def registro1_view(request):
    return render(request, 'vet/registro1.html')


@login_required(login_url='login')  # redirige a la vista login si no ha iniciado sesión
def menu_usuario(request):
    servicios = Servicio.objects.all()
    fechas_horas = HFDisponible.objects.filter(disponible=True).order_by('fecha', 'hora')
    mascotas = Mascota.objects.filter(duenio=request.user)

    try:
        cliente = Cliente.objects.get(user=request.user)
    except Cliente.DoesNotExist:
        cliente = None

    return render(request, 'vet/menu_usuario.html', {
        'servicios': servicios,
        'fechas_horas': fechas_horas,
        'mascotas': mascotas,
        'cliente': cliente
    })


def registro_view(request):
    if request.method == 'POST':
        form = RegistroForm(request.POST, request.FILES)
        if form.is_valid():
            user = form.save()

            # Autenticar y loguear al usuario automáticamente
            login(request, user)

            # Redirigir al menú de usuario
            return redirect('menu_usuario')
    else:
        form = RegistroForm()

    return render(request, 'vet/registro.html', {'form': form})

@login_required
def agregar_mascota(request):
    if request.method == 'POST':
        form = MascotaForm(request.POST)
        if form.is_valid():
            mascota = form.save(commit=False)
            mascota.duenio = request.user
            mascota.save()
            return redirect('menu_usuario')
    else:
        form = MascotaForm()

    return render(request, 'vet/mascota_form.html', {'form': form})



@login_required
def agendar_cita(request):
    if request.method == 'POST':
        form = CitaForm(request.POST, user=request.user)
        if form.is_valid():
            cd = form.cleaned_data

            # Separar fecha y hora
            fecha_str, hora_str = cd['fecha_hora'].split('|')

            # Calcular el total
            ids_servicios = request.POST.getlist('servicio')
            servicios_seleccionados = Servicio.objects.filter(id__in=ids_servicios)

            total = sum([s.precio for s in servicios_seleccionados])
            

            # Crear la cita
            cita = form.save(commit=False)
            cita.usuario = request.user
            cita.fecha = fecha_str
            cita.hora = hora_str
            cita.total = Decimal(total)
            cita.save()
            form.save_m2m()  # Guardar los servicios

            # Marcar horario como ocupado
            HFDisponible.objects.filter(fecha=fecha_str, hora=hora_str).update(disponible=False)

            # Enviar correo de confirmación
            servicios = ", ".join([s.servicio for s in servicios_seleccionados])
            mensaje = f"""
Hola {request.user.first_name},

Tu cita ha sido confirmada:

🗓 Fecha: {cita.fecha}
🕒 Hora: {cita.hora}
🐾 Mascota: {cita.mascota.nombre}
🧾 Servicios: {servicios}
💰 Total: Q{cita.total}

Gracias por confiar en Veterinaria Santa Lucía.
"""

            send_mail(
                subject='Confirmación de Cita - Veterinaria Santa Lucía',
                message=mensaje,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[request.user.email],
                fail_silently=False
            )

            return redirect('menu_usuario')
    else:
        form = CitaForm(user=request.user)

    servicios_json = serialize('json', Servicio.objects.all())
    return render(request, 'vet/cita_form.html', {
        'form': form,
        'servicios_json': servicios_json
    })
