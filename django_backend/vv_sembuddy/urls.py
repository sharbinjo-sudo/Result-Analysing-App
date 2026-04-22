from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    AdminUserDetailView,
    AdminUsersView,
    ClassAnalysisView,
    DashboardSummaryView,
    LoginView,
    NoticeListCreateView,
    ResultUploadView,
    StudentAnalysisView,
    StudentInsightsView,
    StudentResultsView,
    WhoAmIView,
)

urlpatterns = [
    path("login/", LoginView.as_view()),
    path("refresh/", TokenRefreshView.as_view()),
    path("me/", WhoAmIView.as_view()),
    path("dashboard/", DashboardSummaryView.as_view()),
    path("results/my/", StudentResultsView.as_view()),
    path("results/analysis/", StudentAnalysisView.as_view()),
    path("results/upload/", ResultUploadView.as_view()),
    path("results/class-analysis/", ClassAnalysisView.as_view()),
    path("results/student-insights/", StudentInsightsView.as_view()),
    path("notices/", NoticeListCreateView.as_view()),
    path("users/", AdminUsersView.as_view()),
    path("users/<int:pk>/", AdminUserDetailView.as_view()),
]
