from django.contrib.auth.base_user import AbstractBaseUser
from django.contrib.auth.models import PermissionsMixin, UserManager, Group, Permission
from django.db import models
from django.utils import timezone
from rest_framework.authtoken.models import Token
from core.user.utilities.media import user_directory_path


class User(AbstractBaseUser, PermissionsMixin):
    first_name = models.TextField(null=True, blank=True, verbose_name='Nombres')
    last_name = models.TextField(null=True, blank=True, verbose_name='Apellidos')
    username = models.TextField(unique=True, verbose_name='Username')
    dni = models.TextField(unique=True, verbose_name='Número de cédula')
    image = models.ImageField(upload_to=user_directory_path, null=True, blank=True, verbose_name='Imagen')
    email = models.EmailField(null=True, blank=True, verbose_name='Correo electrónico')
    is_active = models.BooleanField(default=True, verbose_name='Estado')
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)

    groups = models.ManyToManyField(
        Group,
        related_name="custom_user_set",
        blank=True,
        help_text="The groups this user belongs to."
    )
    user_permissions = models.ManyToManyField(
        Permission,
        related_name="custom_user_permissions_set",
        blank=True,
        help_text="Specific permissions for this user."
    )

    objects = UserManager()

    EMAIL_FIELD = 'email'
    USERNAME_FIELD = 'dni'
    REQUIRED_FIELDS = ['email']
