from django.urls import path

from authentication.views import AuthLoginView, AuthRegisterView, logout_view

urlpatterns = [
    path('login/', AuthLoginView.as_view(), name='auth_login'),
    path('register/', AuthRegisterView.as_view(), name='auth_register'),
    path("logout/", logout_view, name="user_logout")

]

