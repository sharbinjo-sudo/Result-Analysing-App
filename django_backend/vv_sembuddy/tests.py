from django.conf import settings
from django.contrib.auth import get_user_model
from django.test import override_settings
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from .models import Notice, Result

User = get_user_model()


TEST_REST_FRAMEWORK = {
    **settings.REST_FRAMEWORK,
    "DEFAULT_THROTTLE_RATES": {
        **settings.REST_FRAMEWORK.get("DEFAULT_THROTTLE_RATES", {}),
        "anon": "1000/minute",
        "login": "1000/minute",
        "uploads": "1000/minute",
        "user": "1000/minute",
    },
}


@override_settings(REST_FRAMEWORK=TEST_REST_FRAMEWORK)
class VVSemBuddyApiTests(APITestCase):
    def setUp(self):
        self.admin_user = User.objects.create_user(
            username="admin",
            password="admin123",
            first_name="College",
            last_name="Admin",
            role="admin",
            employee_id="ADM001",
            is_staff=True,
        )
        self.staff_user = User.objects.create_user(
            username="staff",
            password="staff123",
            first_name="S",
            last_name="Meena",
            role="staff",
            employee_id="FAC001",
            department="AI&DS",
            is_staff=True,
        )
        self.student_user = User.objects.create_user(
            username="student",
            password="student123",
            first_name="N",
            last_name="R Hacker",
            role="student",
            register_number="VV2025AIDS001",
            department="AI&DS",
            year_of_study=2,
            section="A",
        )
        self.notice = Notice.objects.create(
            title="Internal Assessment",
            description="IA timetable published.",
            created_by=self.admin_user,
        )
        Result.objects.create(
            student=self.student_user,
            semester=1,
            subject_code="MA101",
            subject_name="Mathematics I",
            marks=88,
            grade="A",
            credits="4.0",
            uploaded_by=self.staff_user,
        )
        Result.objects.create(
            student=self.student_user,
            semester=1,
            subject_code="CS101",
            subject_name="Programming",
            marks=92,
            grade="A+",
            credits="3.0",
            uploaded_by=self.staff_user,
        )

    def authenticate(self, username, password, via_login=False):
        if not via_login:
            user = User.objects.get(username=username)
            self.client.force_authenticate(user=user)
            return user

        response = self.client.post(
            "/api/auth/login/",
            {"username": username, "password": password},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['access']}")
        return response

    def test_login_includes_role_and_profile_payload(self):
        response = self.authenticate("student", "student123", via_login=True)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["role"], "student")
        self.assertEqual(response.data["user"]["register_number"], "VV2025AIDS001")

    def test_student_can_fetch_profile_results_and_analysis(self):
        self.authenticate("student", "student123")

        me_response = self.client.get("/api/auth/me/")
        results_response = self.client.get("/api/auth/results/my/")
        analysis_response = self.client.get("/api/auth/results/analysis/")
        dashboard_response = self.client.get("/api/auth/dashboard/")

        self.assertEqual(me_response.status_code, status.HTTP_200_OK)
        self.assertEqual(results_response.status_code, status.HTTP_200_OK)
        self.assertEqual(analysis_response.status_code, status.HTTP_200_OK)
        self.assertEqual(dashboard_response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(results_response.data["semesters"]), 1)
        self.assertEqual(analysis_response.data["semester_trend"][0]["label"], "S1")
        self.assertIn("recent_notices", dashboard_response.data)
        self.assertIn("trend", dashboard_response.data)
        self.assertIn("grade_distribution", analysis_response.data)

    def test_staff_can_upload_results_and_see_class_analysis(self):
        self.authenticate("staff", "staff123")

        upload_response = self.client.post(
            "/api/auth/results/upload/",
            {
                "entries": [
                    {
                        "student_identifier": "VV2025AIDS001",
                        "semester": 2,
                        "subject_code": "AI201",
                        "subject_name": "ML Basics",
                        "marks": 95,
                        "grade": "A+",
                        "credits": "3.0",
                    }
                ]
            },
            format="json",
        )
        class_response = self.client.get("/api/auth/results/class-analysis/")
        insights_response = self.client.get("/api/auth/results/student-insights/")

        self.assertEqual(upload_response.status_code, status.HTTP_200_OK)
        self.assertEqual(class_response.status_code, status.HTTP_200_OK)
        self.assertEqual(insights_response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(class_response.data["subject_averages"]), 1)
        self.assertEqual(insights_response.data["students"][0]["regNo"], "VV2025AIDS001")
        self.assertIn("marks_bands", class_response.data)
        self.assertIn("average_marks", insights_response.data["students"][0])

    def test_duplicate_result_upload_is_rejected(self):
        self.authenticate("staff", "staff123")

        response = self.client.post(
            "/api/auth/results/upload/",
            {
                "entries": [
                    {
                        "student_identifier": "VV2025AIDS001",
                        "semester": 2,
                        "subject_code": "AI201",
                        "subject_name": "ML Basics",
                        "marks": 95,
                        "grade": "A+",
                        "credits": "3.0",
                    },
                    {
                        "student_identifier": "VV2025AIDS001",
                        "semester": 2,
                        "subject_code": "ai201",
                        "subject_name": "ML Basics",
                        "marks": 96,
                        "grade": "A+",
                        "credits": "3.0",
                    },
                ]
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_staff_uploaded_result_syncs_to_student_views(self):
        self.authenticate("staff", "staff123")

        upload_response = self.client.post(
            "/api/auth/results/upload/",
            {
                "entries": [
                    {
                        "student_identifier": "VV2025AIDS001",
                        "semester": 2,
                        "subject_code": "DB201",
                        "subject_name": "Database Systems",
                        "marks": 87,
                        "grade": "A",
                        "credits": "3.0",
                    }
                ]
            },
            format="json",
        )
        self.assertEqual(upload_response.status_code, status.HTTP_200_OK)

        self.client.force_authenticate(user=self.student_user)
        results_response = self.client.get("/api/auth/results/my/")
        analysis_response = self.client.get("/api/auth/results/analysis/")
        dashboard_response = self.client.get("/api/auth/dashboard/")

        self.assertEqual(results_response.status_code, status.HTTP_200_OK)
        self.assertEqual(analysis_response.status_code, status.HTTP_200_OK)
        self.assertEqual(dashboard_response.status_code, status.HTTP_200_OK)
        semester_two = next(
            item
            for item in results_response.data["semesters"]
            if item["semester"] == "Semester 2"
        )
        self.assertTrue(
            any(result["subject_code"] == "DB201" for result in semester_two["results"])
        )
        self.assertEqual(analysis_response.data["semester_trend"][-1]["label"], "S2")
        self.assertTrue(
            any(
                result["subject_code"] == "DB201"
                for result in dashboard_response.data["latest_results"]
            )
        )

    def test_admin_notice_is_visible_to_students_and_staff(self):
        self.authenticate("admin", "admin123")

        create_response = self.client.post(
            "/api/auth/notices/",
            {
                "title": "Library Hours",
                "description": "Library timing has been updated for exam preparation.",
            },
            format="json",
        )
        self.assertEqual(create_response.status_code, status.HTTP_201_CREATED)

        self.client.force_authenticate(user=self.student_user)
        student_response = self.client.get("/api/auth/notices/")
        self.client.force_authenticate(user=self.staff_user)
        staff_response = self.client.get("/api/auth/notices/")

        self.assertEqual(student_response.status_code, status.HTTP_200_OK)
        self.assertEqual(staff_response.status_code, status.HTTP_200_OK)
        self.assertEqual(student_response.data[0]["title"], "Library Hours")
        self.assertEqual(staff_response.data[0]["title"], "Library Hours")

    def test_admin_can_manage_users_and_notice_list(self):
        self.authenticate("admin", "admin123")

        users_response = self.client.get("/api/auth/users/")
        create_user_response = self.client.post(
            "/api/auth/users/",
            {
                "username": "newstudent",
                "password": "change123",
                "first_name": "New",
                "last_name": "Student",
                "email": "newstudent@vvcoe.com",
                "role": "student",
                "department": "CSE",
                "register_number": "VV2025CSE777",
                "year_of_study": 1,
                "section": "B",
                "is_approved": False,
            },
            format="json",
        )
        notices_response = self.client.get("/api/auth/notices/")
        dashboard_response = self.client.get("/api/auth/dashboard/")

        self.assertEqual(users_response.status_code, status.HTTP_200_OK)
        self.assertEqual(create_user_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(notices_response.status_code, status.HTTP_200_OK)
        self.assertEqual(notices_response.data[0]["title"], "Internal Assessment")
        self.assertEqual(dashboard_response.status_code, status.HTTP_200_OK)
        self.assertIn("department_breakdown", dashboard_response.data)

    def test_admin_cannot_delete_own_account(self):
        self.authenticate("admin", "admin123")

        response = self.client.delete(f"/api/auth/users/{self.admin_user.id}/")

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
