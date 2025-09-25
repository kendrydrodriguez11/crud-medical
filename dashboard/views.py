from django.shortcuts import render
from django.contrib.auth.decorators import login_required

@login_required(login_url='auth_login') 
def home_view(request):
    return render(request, 'home.html')
