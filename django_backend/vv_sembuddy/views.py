from collections import Counter, defaultdict

from django.contrib.auth import get_user_model
from django.db import transaction
from django.db.models import Avg, Count, Q
from rest_framework.exceptions import ValidationError
from rest_framework import generics, parsers, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView

from .models import Notice, Result
from .permissions import IsActiveApprovedUser, IsAdminRole, IsStaffOrAdminRole
from .serializers import (
    CustomTokenObtainPairSerializer,
    NoticeSerializer,
    ResultSerializer,
    ResultUploadSerializer,
    UserCreateUpdateSerializer,
    UserSerializer,
)

User = get_user_model()


def _grade_points(grade):
    mapping = {
        "O": 10.0,
        "A+": 9.0,
        "A": 8.0,
        "B+": 7.0,
        "B": 6.0,
        "C": 5.0,
        "RA": 0.0,
        "F": 0.0,
    }
    return mapping.get((grade or "").upper(), 0.0)


def _result_to_card(result):
    return {
        "semester": result.semester,
        "subject_code": result.subject_code,
        "subject_name": result.subject_name,
        "marks": result.marks,
        "grade": result.grade,
        "credits": float(result.credits),
        "updated_at": result.updated_at.isoformat(),
    }


def _notice_to_card(notice):
    return {
        "id": notice.id,
        "title": notice.title,
        "description": notice.description,
        "created_at": notice.created_at.isoformat(),
        "created_by_name": notice.created_by.full_name if notice.created_by else "Admin",
        "attachment_name": notice.attachment.name.split("/")[-1] if notice.attachment else "",
    }


class LoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer
    throttle_scope = "login"


class WhoAmIView(APIView):
    permission_classes = [IsAuthenticated, IsActiveApprovedUser]

    def get(self, request):
        return Response(UserSerializer(request.user).data)


class DashboardSummaryView(APIView):
    permission_classes = [IsAuthenticated, IsActiveApprovedUser]

    def get(self, request):
        user = request.user
        recent_notices = [_notice_to_card(notice) for notice in Notice.objects.select_related("created_by")[:3]]
        payload = {
            "role": user.role,
            "welcome_name": user.full_name,
            "stats": {},
            "recent_notices": recent_notices,
        }

        if user.role == "student":
            results = Result.objects.filter(student=user).order_by("semester", "subject_code")
            semesters = sorted(results.values_list("semester", flat=True).distinct())
            subject_count = results.count()
            pass_count = results.exclude(marks__lt=50).count()
            avg_marks = round(results.aggregate(avg=Avg("marks"))["avg"] or 0, 2)
            cgpa = round(
                sum(_grade_points(result.grade) for result in results) / subject_count if subject_count else 0,
                2,
            )
            trend = []
            for semester in semesters:
                semester_results = list(results.filter(semester=semester))
                semester_avg = round(
                    sum(item.marks for item in semester_results) / len(semester_results), 2
                )
                trend.append(
                    {
                        "label": f"S{semester}",
                        "average_marks": semester_avg,
                        "gpa": round(
                            sum(_grade_points(item.grade) for item in semester_results)
                            / len(semester_results),
                            2,
                        ),
                    }
                )

            latest_semester = semesters[-1] if semesters else None
            latest_results = [
                _result_to_card(result)
                for result in results.filter(semester=latest_semester)[:5]
            ] if latest_semester else []

            payload["stats"] = {
                "semesters_completed": len(semesters),
                "subjects_cleared": pass_count,
                "average_marks": avg_marks,
                "cgpa": cgpa,
                "notices": Notice.objects.count(),
            }
            payload["student_overview"] = {
                "register_number": user.register_number or "-",
                "department": user.get_department_display() or user.department,
                "year_of_study": user.year_of_study or "-",
                "section": user.section or "-",
            }
            payload["trend"] = trend
            payload["latest_results"] = latest_results

        elif user.role == "staff":
            results = Result.objects.select_related("student").all()
            subject_rows = list(
                results.values("subject_name")
                .annotate(average_marks=Avg("marks"), entries=Count("id"))
                .order_by("-average_marks", "subject_name")[:6]
            )
            recent_uploads = [
                {
                    "student_name": result.student.full_name,
                    "register_number": result.student.register_number or result.student.username,
                    "subject_name": result.subject_name,
                    "semester": result.semester,
                    "marks": result.marks,
                    "updated_at": result.updated_at.isoformat(),
                }
                for result in Result.objects.select_related("student").filter(uploaded_by=user).order_by("-updated_at")[:6]
            ]
            total_results = results.count()
            pass_count = results.exclude(marks__lt=50).count()
            payload["stats"] = {
                "students_managed": User.objects.filter(role="student", is_active=True).count(),
                "results_uploaded": Result.objects.filter(uploaded_by=user).count(),
                "average_class_marks": round(results.aggregate(avg=Avg("marks"))["avg"] or 0, 2),
                "pass_percentage": round((pass_count / total_results * 100) if total_results else 0, 2),
                "notices": Notice.objects.count(),
            }
            payload["subject_highlights"] = [
                {
                    "subject_name": row["subject_name"],
                    "average_marks": round(row["average_marks"] or 0, 2),
                    "entries": row["entries"],
                }
                for row in subject_rows
            ]
            payload["recent_uploads"] = recent_uploads

        elif user.role == "admin":
            active_users = User.objects.filter(is_active=True)
            department_breakdown = list(
                active_users.exclude(department="")
                .values("department")
                .annotate(total=Count("id"))
                .order_by("-total", "department")
            )
            pending_users = [
                {
                    "id": account.id,
                    "name": account.full_name,
                    "role": account.get_role_display(),
                    "department": account.get_department_display() or account.department,
                    "email": account.email,
                }
                for account in active_users.filter(is_approved=False).order_by("date_joined")[:5]
            ]
            payload["stats"] = {
                "total_users": active_users.count(),
                "pending_approvals": active_users.filter(is_approved=False).count(),
                "students": active_users.filter(role="student").count(),
                "staff": active_users.filter(role="staff").count(),
                "notices": Notice.objects.count(),
            }
            payload["department_breakdown"] = [
                {
                    "department": dict(User.DEPARTMENT_CHOICES).get(row["department"], row["department"]),
                    "total": row["total"],
                }
                for row in department_breakdown
            ]
            payload["pending_users"] = pending_users

        return Response(payload)


class NoticeListCreateView(generics.ListCreateAPIView):
    queryset = Notice.objects.select_related("created_by").all()
    serializer_class = NoticeSerializer
    permission_classes = [IsAuthenticated, IsActiveApprovedUser]
    parser_classes = [parsers.MultiPartParser, parsers.FormParser, parsers.JSONParser]
    throttle_scope = "uploads"

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context["request"] = self.request
        return context

    def create(self, request, *args, **kwargs):
        if request.user.role != "admin":
            return Response(
                {"detail": "Only admins can upload notices."},
                status=status.HTTP_403_FORBIDDEN,
            )
        return super().create(request, *args, **kwargs)

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)


class StudentResultsView(APIView):
    permission_classes = [IsAuthenticated, IsActiveApprovedUser]

    def get(self, request):
        if request.user.role != "student":
            return Response(
                {"detail": "Only students can view their results here."},
                status=status.HTTP_403_FORBIDDEN,
            )

        grouped = defaultdict(list)
        results = Result.objects.filter(student=request.user)
        for result in results:
            grouped[f"Semester {result.semester}"].append(ResultSerializer(result).data)

        semester_summaries = []
        for semester_name, items in grouped.items():
            marks = [item["marks"] for item in items]
            semester_summaries.append(
                {
                    "semester": semester_name,
                    "average_marks": round(sum(marks) / len(marks), 2) if marks else 0,
                    "subjects": len(items),
                    "results": items,
                }
            )

        semester_summaries.sort(key=lambda item: int(item["semester"].split()[-1]))
        return Response({"semesters": semester_summaries})


class StudentAnalysisView(APIView):
    permission_classes = [IsAuthenticated, IsActiveApprovedUser]

    def get(self, request):
        if request.user.role != "student":
            return Response(
                {"detail": "Only students can view analysis here."},
                status=status.HTTP_403_FORBIDDEN,
            )

        results = list(Result.objects.filter(student=request.user).order_by("semester", "subject_name"))
        semester_trend = []
        last_semester_subjects = []
        grade_distribution = Counter()
        subject_summary = {}

        semesters = sorted({result.semester for result in results})
        for semester in semesters:
            semester_results = [item for item in results if item.semester == semester]
            avg_marks = round(sum(item.marks for item in semester_results) / len(semester_results), 2)
            avg_gpa = round(
                sum(_grade_points(item.grade) for item in semester_results) / len(semester_results),
                2,
            )
            semester_trend.append(
                {
                    "label": f"S{semester}",
                    "cgpa": avg_gpa,
                    "average_marks": avg_marks,
                    "subject_count": len(semester_results),
                }
            )

        latest_semester = semesters[-1] if semesters else None
        if latest_semester:
            last_semester_subjects = [
                {
                    "subject_name": item.subject_name,
                    "marks": item.marks,
                    "subject_code": item.subject_code,
                    "grade": item.grade,
                }
                for item in results
                if item.semester == latest_semester
            ]

        for item in results:
            grade_distribution[item.grade] += 1
            summary = subject_summary.setdefault(
                item.subject_name,
                {"subject_name": item.subject_name, "marks_total": 0, "count": 0},
            )
            summary["marks_total"] += item.marks
            summary["count"] += 1

        strengths = [
            {
                "subject_name": summary["subject_name"],
                "average_marks": round(summary["marks_total"] / summary["count"], 2),
            }
            for summary in subject_summary.values()
        ]
        strengths.sort(key=lambda item: (-item["average_marks"], item["subject_name"]))

        return Response(
            {
                "overview": {
                    "overall_average_marks": round(
                        sum(item.marks for item in results) / len(results), 2
                    )
                    if results
                    else 0,
                    "overall_cgpa": round(
                        sum(_grade_points(item.grade) for item in results) / len(results), 2
                    )
                    if results
                    else 0,
                    "total_subjects": len(results),
                },
                "semester_trend": semester_trend,
                "last_semester_subjects": last_semester_subjects,
                "grade_distribution": dict(sorted(grade_distribution.items())),
                "strengths": strengths[:6],
            }
        )


class ResultUploadView(APIView):
    permission_classes = [IsAuthenticated, IsStaffOrAdminRole]
    throttle_scope = "uploads"

    def post(self, request):
        serializer = ResultUploadSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        saved_rows = []
        with transaction.atomic():
            for entry in serializer.validated_data["entries"]:
                student = User.objects.filter(
                    Q(username=entry["student_identifier"])
                    | Q(register_number=entry["student_identifier"]),
                    role="student",
                ).first()
                if student is None:
                    return Response(
                        {"detail": f"Student '{entry['student_identifier']}' was not found."},
                        status=status.HTTP_400_BAD_REQUEST,
                    )

                result, _ = Result.objects.update_or_create(
                    student=student,
                    semester=entry["semester"],
                    subject_code=entry["subject_code"],
                    defaults={
                        "subject_name": entry["subject_name"],
                        "marks": entry["marks"],
                        "grade": entry["grade"],
                        "credits": entry["credits"],
                        "uploaded_by": request.user,
                    },
                )
                saved_rows.append(ResultSerializer(result).data)

        return Response(
            {
                "message": f"Saved {len(saved_rows)} result entrie(s).",
                "results": saved_rows,
            },
            status=status.HTTP_200_OK,
        )


class ClassAnalysisView(APIView):
    permission_classes = [IsAuthenticated, IsStaffOrAdminRole]

    def get(self, request):
        results = list(Result.objects.select_related("student").all())
        total_count = len(results)
        pass_count = len([result for result in results if result.marks >= 50])
        subject_breakdown = (
            Result.objects.values("subject_name")
            .annotate(average_marks=Avg("marks"), total=Count("id"))
            .order_by("subject_name")
        )

        toppers = list(
            User.objects.filter(role="student", results__isnull=False)
            .annotate(avg_marks=Avg("results__marks"))
            .order_by("-avg_marks", "first_name", "username")[:5]
            .values("id", "first_name", "last_name", "username", "register_number", "avg_marks")
        )

        marks_bands = {
            "90-100": len([result for result in results if result.marks >= 90]),
            "75-89": len([result for result in results if 75 <= result.marks < 90]),
            "50-74": len([result for result in results if 50 <= result.marks < 75]),
            "Below 50": len([result for result in results if result.marks < 50]),
        }
        semester_stats = []
        for semester in sorted({result.semester for result in results}):
            semester_results = [item for item in results if item.semester == semester]
            semester_stats.append(
                {
                    "semester": semester,
                    "average_marks": round(
                        sum(item.marks for item in semester_results) / len(semester_results), 2
                    ),
                    "pass_percentage": round(
                        len([item for item in semester_results if item.marks >= 50])
                        / len(semester_results)
                        * 100,
                        2,
                    ),
                }
            )

        recent_results = [
            {
                "student_name": result.student.full_name,
                "register_number": result.student.register_number or result.student.username,
                "subject_name": result.subject_name,
                "semester": result.semester,
                "marks": result.marks,
            }
            for result in sorted(results, key=lambda item: item.updated_at, reverse=True)[:6]
        ]

        return Response(
            {
                "pass_percentage": round((pass_count / total_count * 100) if total_count else 0, 2),
                "fail_percentage": round(
                    ((total_count - pass_count) / total_count * 100) if total_count else 0,
                    2,
                ),
                "subject_averages": [
                    {
                        "subject_name": item["subject_name"],
                        "average_marks": round(item["average_marks"] or 0, 2),
                        "entries": item["total"],
                    }
                    for item in subject_breakdown
                ],
                "top_performers": [
                    {
                        "name": f"{item['first_name']} {item['last_name']}".strip()
                        or item["username"],
                        "register_number": item["register_number"],
                        "cgpa": round((item["avg_marks"] or 0) / 10, 2),
                    }
                    for item in toppers
                ],
                "marks_bands": marks_bands,
                "semester_stats": semester_stats,
                "recent_results": recent_results,
            }
        )


class StudentInsightsView(APIView):
    permission_classes = [IsAuthenticated, IsStaffOrAdminRole]

    def get(self, request):
        query = request.query_params.get("q", "").strip()
        students = User.objects.filter(role="student", is_active=True)
        if query:
            students = students.filter(
                Q(first_name__icontains=query)
                | Q(last_name__icontains=query)
                | Q(username__icontains=query)
                | Q(register_number__icontains=query)
            )

        payload = []
        for student in students[:25]:
            student_results = list(Result.objects.filter(student=student).order_by("semester", "subject_name"))
            semester_series = []
            semesters = sorted({item.semester for item in student_results})
            for semester in semesters:
                semester_items = [item for item in student_results if item.semester == semester]
                avg_marks = sum(item.marks for item in semester_items) / len(semester_items)
                semester_series.append(
                    {
                        "label": f"S{semester}",
                        "gpa": round(sum(_grade_points(item.grade) for item in semester_items) / len(semester_items), 2),
                        "average_marks": round(avg_marks, 2),
                    }
                )

            latest_semester = semesters[-1] if semesters else None
            latest_subjects = {
                item.subject_name: item.marks
                for item in student_results
                if latest_semester is not None and item.semester == latest_semester
            }
            avg_marks = round(
                sum(item.marks for item in student_results) / len(student_results), 2
            ) if student_results else 0
            payload.append(
                {
                    "id": student.id,
                    "name": student.full_name,
                    "regNo": student.register_number or student.username,
                    "dept": student.get_department_display() or student.department,
                    "section": student.section or "-",
                    "year_of_study": student.year_of_study or "-",
                    "cgpa": round(
                        sum(_grade_points(item.grade) for item in student_results) / len(student_results),
                        2,
                    ) if student_results else 0,
                    "average_marks": avg_marks,
                    "semesters": semester_series,
                    "subjects": latest_subjects,
                    "total_subjects": len(student_results),
                    "latest_semester": latest_semester,
                }
            )

        return Response({"students": payload})


class AdminUsersView(generics.ListCreateAPIView):
    queryset = User.objects.filter(is_active=True).order_by("role", "first_name", "username")
    permission_classes = [IsAuthenticated, IsAdminRole]

    def get_serializer_class(self):
        if self.request.method == "POST":
            return UserCreateUpdateSerializer
        return UserSerializer


class AdminUserDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = User.objects.filter(is_active=True)
    permission_classes = [IsAuthenticated, IsAdminRole]

    def get_serializer_class(self):
        if self.request.method in {"PUT", "PATCH"}:
            return UserCreateUpdateSerializer
        return UserSerializer

    def perform_destroy(self, instance):
        if instance.id == self.request.user.id:
            raise ValidationError(
                {"detail": "You cannot delete your own administrator account."}
            )
        instance.is_active = False
        instance.save(update_fields=["is_active"])
