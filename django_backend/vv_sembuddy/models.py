from django.conf import settings
from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    ROLE_CHOICES = (
        ("admin", "Admin"),
        ("staff", "Staff"),
        ("student", "Student"),
    )
    DEPARTMENT_CHOICES = (
        ("AI&DS", "Artificial Intelligence and Data Science"),
        ("CSE", "Computer Science and Engineering"),
        ("ECE", "Electronics and Communication Engineering"),
        ("EEE", "Electrical and Electronics Engineering"),
        ("IT", "Information Technology"),
        ("MECH", "Mechanical Engineering"),
    )

    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default="student")
    department = models.CharField(max_length=20, choices=DEPARTMENT_CHOICES, blank=True)
    register_number = models.CharField(max_length=30, blank=True, unique=True, null=True)
    employee_id = models.CharField(max_length=30, blank=True, unique=True, null=True)
    year_of_study = models.PositiveSmallIntegerField(blank=True, null=True)
    section = models.CharField(max_length=5, blank=True)
    phone_number = models.CharField(max_length=20, blank=True)
    is_approved = models.BooleanField(default=True)

    @property
    def full_name(self):
        name = f"{self.first_name} {self.last_name}".strip()
        return name or self.username

    def __str__(self):
        return f"{self.username} ({self.role})"


class Notice(models.Model):
    title = models.CharField(max_length=200)
    description = models.TextField()
    attachment = models.FileField(upload_to="notices/", blank=True, null=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="created_notices",
        blank=True,
        null=True,
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-created_at",)

    def __str__(self):
        return self.title


class Result(models.Model):
    student = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="results",
        limit_choices_to={"role": "student"},
    )
    semester = models.PositiveSmallIntegerField()
    subject_code = models.CharField(max_length=20)
    subject_name = models.CharField(max_length=200)
    marks = models.PositiveSmallIntegerField()
    grade = models.CharField(max_length=5)
    credits = models.DecimalField(max_digits=4, decimal_places=1)
    uploaded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="uploaded_results",
        blank=True,
        null=True,
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("semester", "subject_code")
        unique_together = ("student", "semester", "subject_code")

    def __str__(self):
        return f"{self.student.username} - S{self.semester} - {self.subject_code}"
