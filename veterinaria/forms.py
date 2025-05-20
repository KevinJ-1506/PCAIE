import re
from django import forms
from django.contrib.auth.models import User
from .models import Cliente, Mascota

PASSWORD_REGEX = re.compile(
    r'^(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{12,}$'
)

INPUT_CLASS = 'w-full mt-1 px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500'

class RegistroForm(forms.Form):
    # ---------- Datos de usuario ----------
    nombre = forms.CharField(
        max_length=30,
        widget=forms.TextInput(attrs={'class': INPUT_CLASS})
    )
    apellido = forms.CharField(
        max_length=30,
        widget=forms.TextInput(attrs={'class': INPUT_CLASS})
    )
    dpi = forms.CharField(
        max_length=15,
        widget=forms.TextInput(attrs={'class': INPUT_CLASS})
    )
    telefono = forms.CharField(
        max_length=20,
        widget=forms.TextInput(attrs={'class': INPUT_CLASS})
    )
    username = forms.CharField(
        max_length=30,
        widget=forms.TextInput(attrs={'class': INPUT_CLASS})
    )
    email = forms.EmailField(
        widget=forms.EmailInput(attrs={'class': INPUT_CLASS})
    )
    password = forms.CharField(
        widget=forms.PasswordInput(attrs={'class': INPUT_CLASS})
    )
    password2 = forms.CharField(
        label="Confirmar contraseña",
        widget=forms.PasswordInput(attrs={'class': INPUT_CLASS})
    )
    rostro = forms.ImageField(
        required=False,
        widget=forms.ClearableFileInput(attrs={'class': INPUT_CLASS})
    )

    # ---------- Datos de la primera mascota ----------
    nombre_mascota = forms.CharField(
        max_length=100,
        widget=forms.TextInput(attrs={'class': INPUT_CLASS})
    )
    chip_id = forms.CharField(
        max_length=50,
        required=False,
        label="ID de chip",
        widget=forms.TextInput(attrs={'class': INPUT_CLASS})
    )
    especie = forms.CharField(
        max_length=50,
        widget=forms.TextInput(attrs={'class': INPUT_CLASS})
    )
    raza = forms.CharField(
        max_length=50,
        required=False,
        widget=forms.TextInput(attrs={'class': INPUT_CLASS})
    )
    sexo = forms.ChoiceField(
        choices=[('M', 'Macho'), ('H', 'Hembra')],
        widget=forms.Select(attrs={'class': INPUT_CLASS})
    )
    edad = forms.IntegerField(
        required=False,
        min_value=0,
        widget=forms.NumberInput(attrs={'class': INPUT_CLASS})
    )
    peso = forms.DecimalField(
        required=False,
        max_digits=5,
        decimal_places=2,
        widget=forms.NumberInput(attrs={'class': INPUT_CLASS})
    )
    notas = forms.CharField(
        required=False,
        label="Historial médico",
        widget=forms.Textarea(attrs={
            'class': INPUT_CLASS,
            'rows': 4
        })
    )

    # ---------- Validaciones ----------
    def clean_username(self):
        uname = self.cleaned_data['username']
        if User.objects.filter(username=uname).exists():
            raise forms.ValidationError("Ese nombre de usuario ya existe.")
        return uname

    def clean_password(self):
        pwd = self.cleaned_data['password']
        if not PASSWORD_REGEX.match(pwd):
            raise forms.ValidationError(
                "La contraseña debe tener al menos 12 caracteres, "
                "una mayúscula, un dígito y un símbolo."
            )
        return pwd

    def clean(self):
        cleaned = super().clean()
        if cleaned.get('password') != cleaned.get('password2'):
            self.add_error('password2', "Las contraseñas no coinciden.")
        return cleaned

    # ---------- Guardar usuario, cliente y mascota ----------
    def save(self):
        cd = self.cleaned_data

        user = User.objects.create_user(
            username=cd['username'],
            email=cd['email'],
            password=cd['password'],
            first_name=cd['nombre'],
            last_name=cd['apellido'],
        )

        Cliente.objects.create(
            user=user,
            dpi=cd['dpi'],
            telefono=cd['telefono'],
            rostro=cd.get('rostro')
        )

        Mascota.objects.create(
            duenio=user,
            nombre=cd['nombre_mascota'],
            chip_id=cd['chip_id'],
            especie=cd['especie'],
            raza=cd['raza'],
            sexo=cd['sexo'],
            edad=cd['edad'] or 0,
            peso=cd['peso'] or 0,
            notas=cd['notas']
        )

        return user
