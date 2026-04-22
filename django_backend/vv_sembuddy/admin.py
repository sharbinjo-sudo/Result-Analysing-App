from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from .models import Notice, Result, User


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    fieldsets = UserAdmin.fieldsets + (
        (
            "College details",
            {
                "fields": (
                    "role",
                    "department",
                    "register_number",
                    "employee_id",
                    "year_of_study",
                    "section",
                    "phone_number",
                    "is_approved",
                )
            },
        ),
    )
    list_display = ("username", "email", "role", "department", "is_approved", "is_active")
    list_filter = ("role", "department", "is_approved", "is_active")


@admin.register(Result)
class ResultAdmin(admin.ModelAdmin):
    list_display = ("student", "semester", "subject_code", "marks", "grade", "uploaded_by")
    list_filter = ("semester", "student__department")
    search_fields = ("student__username", "student__register_number", "subject_code", "subject_name")


@admin.register(Notice)
class NoticeAdmin(admin.ModelAdmin):
    list_display = ("title", "created_by", "created_at")
    search_fields = ("title", "description")
