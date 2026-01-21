from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import LoginView, WhoAmIView, AdminDashboardView

urlpatterns = [
    path("login/", LoginView.as_view()),
    path("refresh/", TokenRefreshView.as_view()),
    path("me/", WhoAmIView.as_view()),
    path("admin/dashboard/", AdminDashboardView.as_view()),
]
