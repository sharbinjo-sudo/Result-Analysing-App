from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    ROLE_CHOICES = (
        ("admin", "Admin"),
        ("staff", "Staff"),
        ("student", "Student"),
    )

    role = models.CharField(
        max_length=10,
        choices=ROLE_CHOICES,
        default="student"
    )

    def __str__(self):
        return f"{self.username} ({self.role})"
