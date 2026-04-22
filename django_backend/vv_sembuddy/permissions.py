from rest_framework.permissions import BasePermission


class IsActiveApprovedUser(BasePermission):
    def has_permission(self, request, view):
        return (
            request.user.is_authenticated
            and request.user.is_active
            and request.user.is_approved
        )


class IsAdminRole(BasePermission):
    def has_permission(self, request, view):
        return (
            request.user.is_authenticated
            and request.user.is_active
            and request.user.is_approved
            and request.user.role == "admin"
        )


class IsStaffRole(BasePermission):
    def has_permission(self, request, view):
        return (
            request.user.is_authenticated
            and request.user.is_active
            and request.user.is_approved
            and request.user.role == "staff"
        )


class IsStaffOrAdminRole(BasePermission):
    def has_permission(self, request, view):
        return (
            request.user.is_authenticated
            and request.user.is_active
            and request.user.is_approved
            and request.user.role in {"staff", "admin"}
        )
