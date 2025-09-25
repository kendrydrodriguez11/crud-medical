from django.contrib.auth.views import LoginView
from authentication.forms.login import LoginForm  
from django.urls import reverse_lazy
from django.views.generic import CreateView
from authentication.forms.register import RegisterForm
from django.contrib.auth import logout
from django.shortcuts import redirect
from django.urls import reverse

class AuthLoginView(LoginView):
    template_name = 'pages/auth/login.html'
    form_class = LoginForm 

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = 'Iniciar sesión'
        return context
    
    def get_success_url(self):
        return reverse_lazy('dashboard_home')
    

class AuthRegisterView(CreateView):
    template_name = 'pages/auth/register.html'  
    form_class = RegisterForm
    success_url = reverse_lazy('auth_login') 
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = 'Registro de usuario'
        return context


    

def logout_view(request):
    logout(request)  # Cierra la sesión del usuario
    return redirect(reverse_lazy('auth_login'))