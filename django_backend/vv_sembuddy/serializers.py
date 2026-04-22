from decimal import Decimal

from django.contrib.auth import get_user_model
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from .models import Notice, Result

User = get_user_model()


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token["role"] = user.role
        token["name"] = user.full_name
        return token

    def validate(self, attrs):
        data = super().validate(attrs)
        if not self.user.is_active:
            raise serializers.ValidationError(
                {"detail": "Your account is inactive. Please contact the administrator."}
            )
        if not self.user.is_approved:
            raise serializers.ValidationError(
                {"detail": "Your account is awaiting admin approval."}
            )

        data["role"] = self.user.role
        data["user"] = UserSerializer(self.user).data
        return data


class UserSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source="full_name", read_only=True)
    department_name = serializers.SerializerMethodField()
    role_name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = (
            "id",
            "username",
            "name",
            "first_name",
            "last_name",
            "email",
            "role",
            "role_name",
            "department",
            "department_name",
            "register_number",
            "employee_id",
            "year_of_study",
            "section",
            "phone_number",
            "is_approved",
        )
        read_only_fields = ("id",)

    def get_department_name(self, obj):
        return obj.get_department_display() or obj.department

    def get_role_name(self, obj):
        return obj.get_role_display() or obj.role


class UserCreateUpdateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, min_length=6)

    class Meta:
        model = User
        fields = (
            "id",
            "username",
            "password",
            "first_name",
            "last_name",
            "email",
            "role",
            "department",
            "register_number",
            "employee_id",
            "year_of_study",
            "section",
            "phone_number",
            "is_approved",
        )
        read_only_fields = ("id",)

    def create(self, validated_data):
        password = validated_data.pop("password", None)
        if not password:
            raise serializers.ValidationError(
                {"password": "Password is required when creating a user."}
            )
        user = User(**validated_data)
        user.is_staff = user.role in {"staff", "admin"}
        user.is_superuser = user.role == "admin"
        user.set_password(password)
        user.save()
        return user

    def update(self, instance, validated_data):
        password = validated_data.pop("password", None)
        for key, value in validated_data.items():
            setattr(instance, key, value)
        instance.is_staff = instance.role in {"staff", "admin"}
        instance.is_superuser = instance.role == "admin"
        if password:
            instance.set_password(password)
        instance.save()
        return instance

    def validate(self, attrs):
        role = attrs.get("role", getattr(self.instance, "role", None))
        if role == "student" and not attrs.get(
            "register_number", getattr(self.instance, "register_number", None)
        ):
            raise serializers.ValidationError(
                {"register_number": "Register number is required for students."}
            )
        if role in {"staff", "admin"} and not attrs.get(
            "employee_id", getattr(self.instance, "employee_id", None)
        ):
            raise serializers.ValidationError(
                {"employee_id": "Employee ID is required for staff/admin users."}
            )
        return attrs


class NoticeSerializer(serializers.ModelSerializer):
    created_by_name = serializers.CharField(source="created_by.full_name", read_only=True)
    attachment_name = serializers.SerializerMethodField()
    attachment_url = serializers.SerializerMethodField()

    class Meta:
        model = Notice
        fields = (
            "id",
            "title",
            "description",
            "attachment",
            "attachment_name",
            "attachment_url",
            "created_by_name",
            "created_at",
            "updated_at",
        )
        read_only_fields = (
            "id",
            "attachment_name",
            "attachment_url",
            "created_by_name",
            "created_at",
            "updated_at",
        )

    def get_attachment_name(self, obj):
        if not obj.attachment:
            return ""
        return obj.attachment.name.split("/")[-1]

    def get_attachment_url(self, obj):
        request = self.context.get("request")
        if not obj.attachment:
            return ""
        url = obj.attachment.url
        return request.build_absolute_uri(url) if request else url

    def validate_attachment(self, value):
        if value is None:
            return value
        name = value.name.lower()
        if not name.endswith(".pdf"):
            raise serializers.ValidationError("Only PDF notice attachments are allowed.")
        max_size = 5 * 1024 * 1024
        if value.size > max_size:
            raise serializers.ValidationError("Notice attachments must be 5 MB or smaller.")
        return value


class ResultSerializer(serializers.ModelSerializer):
    student_id = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.filter(role="student"),
        source="student",
        write_only=True,
        required=False,
    )
    student_name = serializers.CharField(source="student.full_name", read_only=True)
    register_number = serializers.CharField(source="student.register_number", read_only=True)

    class Meta:
        model = Result
        fields = (
            "id",
            "student_id",
            "student_name",
            "register_number",
            "semester",
            "subject_code",
            "subject_name",
            "marks",
            "grade",
            "credits",
            "created_at",
            "updated_at",
        )
        read_only_fields = ("id", "student_name", "register_number", "created_at", "updated_at")


class ResultUploadItemSerializer(serializers.Serializer):
    student_identifier = serializers.CharField()
    semester = serializers.IntegerField(min_value=1, max_value=12)
    subject_code = serializers.CharField(max_length=20)
    subject_name = serializers.CharField(max_length=200)
    marks = serializers.IntegerField(min_value=0, max_value=100)
    grade = serializers.CharField(max_length=5)
    credits = serializers.DecimalField(max_digits=4, decimal_places=1, min_value=Decimal("0.1"))


class ResultUploadSerializer(serializers.Serializer):
    entries = ResultUploadItemSerializer(many=True)

    def validate(self, attrs):
        seen = set()
        for entry in attrs["entries"]:
            entry["student_identifier"] = entry["student_identifier"].strip()
            entry["subject_code"] = entry["subject_code"].strip().upper()
            entry["subject_name"] = entry["subject_name"].strip()
            entry["grade"] = entry["grade"].strip().upper()
            key = (
                entry["student_identifier"].lower(),
                entry["semester"],
                entry["subject_code"],
            )
            if key in seen:
                raise serializers.ValidationError(
                    "Duplicate result rows for the same student, semester, and subject code were submitted."
                )
            seen.add(key)
        return attrs


class DashboardSummarySerializer(serializers.Serializer):
    role = serializers.CharField()
    welcome_name = serializers.CharField()
    stats = serializers.DictField()
