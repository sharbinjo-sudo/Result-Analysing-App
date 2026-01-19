from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.views import TokenObtainPairView

from .serializers import CustomTokenObtainPairSerializer
from .permissions import IsAdminRole


class LoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer


class WhoAmIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response({
            "id": request.user.id,
            "username": request.user.username,
            "role": request.user.role,
        })


class AdminDashboardView(APIView):
    permission_classes = [IsAdminRole]

    def get(self, request):
        return Response({
            "message": "Welcome Admin",
            "stats": {
                "total_users": 100,
                "students": 80,
                "staff": 15,
                "admins": 5
            }
        })
