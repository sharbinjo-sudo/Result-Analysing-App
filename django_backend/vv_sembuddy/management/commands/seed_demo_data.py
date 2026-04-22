from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand

from vv_sembuddy.models import Notice, Result

User = get_user_model()


class Command(BaseCommand):
    help = "Seed demo users, notices, and results for local development."

    def handle(self, *args, **options):
        admin_user, _ = User.objects.update_or_create(
            username="admin",
            defaults={
                "first_name": "College",
                "last_name": "Admin",
                "email": "admin@vvcoe.com",
                "role": "admin",
                "department": "CSE",
                "employee_id": "ADM001",
                "is_staff": True,
                "is_superuser": True,
                "is_approved": True,
            },
        )
        admin_user.set_password("admin123")
        admin_user.save()

        staff_user, _ = User.objects.update_or_create(
            username="staff",
            defaults={
                "first_name": "S",
                "last_name": "Meena",
                "email": "staff@vvcoe.com",
                "role": "staff",
                "department": "AI&DS",
                "employee_id": "FAC004",
                "is_staff": True,
                "is_approved": True,
            },
        )
        staff_user.set_password("staff123")
        staff_user.save()

        student_user, _ = User.objects.update_or_create(
            username="student",
            defaults={
                "first_name": "N",
                "last_name": "R Hacker",
                "email": "student@vvcoe.com",
                "role": "student",
                "department": "AI&DS",
                "register_number": "VV2025AIDS001",
                "year_of_study": 2,
                "section": "A",
                "is_approved": True,
            },
        )
        student_user.set_password("student123")
        student_user.save()

        results = [
            (1, "MA101", "Mathematics I", 88, "A"),
            (1, "PH101", "Physics", 78, "B+"),
            (1, "CS101", "Programming in C", 91, "A+"),
            (2, "MA102", "Mathematics II", 82, "A"),
            (2, "CS201", "Data Structures", 89, "A+"),
            (2, "AI201", "Machine Learning Basics", 93, "A+"),
        ]
        for semester, code, name, marks, grade in results:
            Result.objects.update_or_create(
                student=student_user,
                semester=semester,
                subject_code=code,
                defaults={
                    "subject_name": name,
                    "marks": marks,
                    "grade": grade,
                    "credits": 3.0,
                    "uploaded_by": staff_user,
                },
            )

        Notice.objects.get_or_create(
            title="End Semester Schedule",
            defaults={
                "description": "End semester examination schedule for all departments.",
                "created_by": admin_user,
            },
        )
        Notice.objects.get_or_create(
            title="Placement Orientation",
            defaults={
                "description": "Placement orientation will be held in the seminar hall on Monday.",
                "created_by": admin_user,
            },
        )

        self.stdout.write(self.style.SUCCESS("Demo data seeded successfully."))
