from django.db import models
from django.contrib.auth.models import User

class ServicioInicio(models.Model):
    servicio = models.CharField(max_length=200)
    precio = models.DecimalField(max_digits=8, decimal_places=2)
    mostrar = models.BooleanField(default=True)

    def __str__(self):
        return self.servicios

    class Meta:
        db_table = 'servicios_inicio'
        managed = False  # MUY IMPORTANTE

class Cliente(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    dpi = models.CharField(max_length=15)
    telefono = models.CharField(max_length=20)
    rostro = models.ImageField(upload_to='rostros/', blank=True, null=True)

    def __str__(self):
        return f"{self.user.username} - Cliente"

class Mascota(models.Model):
    duenio = models.ForeignKey(User, on_delete=models.CASCADE, related_name="mascotas")
    nombre = models.CharField(max_length=100)
    chip_id = models.CharField(max_length=50, blank=True)
    especie = models.CharField(max_length=50)
    raza = models.CharField(max_length=50, blank=True)
    sexo = models.CharField(max_length=1, choices=[('M','Macho'),('H','Hembra')])
    edad = models.PositiveIntegerField(blank=True, null=True)
    peso = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    notas = models.TextField(blank=True)

    def __str__(self):
        return f"{self.nombre} ({self.duenio.username})"


class Servicio(models.Model):
    servicio = models.CharField(max_length=100)
    descripcion = models.TextField()
    precio = models.DecimalField(max_digits=8, decimal_places=2)

    class Meta:
        db_table = 'servicios'  # ← aquí le dices a Django que use tu tabla existente
        managed = False
    def __str__(self):
        return self.servicio

class HFDisponible(models.Model):
    hora = models.TimeField()
    fecha = models.DateField()
    disponible = models.BooleanField(default=True)

    class Meta:
        db_table = 'hf_disponibles'
        managed = False  # no dejes que Django toque esta tabla

    def __str__(self):
        return f"{self.fecha} {self.hora}"
    
class Cita(models.Model):
    ESTADO_OPCIONES = [
        ('pendiente', 'Pendiente'),
        ('completada', 'Completada'),
        ('cancelada', 'Cancelada'),
    ]

    usuario = models.ForeignKey(User, on_delete=models.CASCADE)
    mascota = models.ForeignKey(Mascota, on_delete=models.CASCADE)
    servicios = models.ManyToManyField(Servicio)
    fecha = models.DateField()
    hora = models.TimeField()
    estado = models.CharField(max_length=15, choices=ESTADO_OPCIONES, default='pendiente')
    total = models.DecimalField(max_digits=8, decimal_places=2)
    
    # Campos de facturación (simulados, no obligatorios ni persistentes)
    nit = models.CharField(max_length=20, blank=True)
    direccion = models.CharField(max_length=255, blank=True)
    forma_pago = models.CharField(max_length=50, blank=True)


    def __str__(self):
        return f"Cita de {self.mascota.nombre} ({self.fecha} {self.hora}) "
     


