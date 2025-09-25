from django import forms
from django.contrib.auth import get_user_model
from django.contrib.auth.forms import UserCreationForm

class RegisterForm(UserCreationForm):
    dni = forms.CharField(label="Cédula")
    first_name = forms.CharField(label="Nombres")
    last_name = forms.CharField(label="Apellidos")
    email = forms.EmailField(label="Correo electrónico")

    class Meta:
        model = get_user_model()
        fields = ['dni', 'first_name', 'last_name', 'email', 'password1', 'password2']
