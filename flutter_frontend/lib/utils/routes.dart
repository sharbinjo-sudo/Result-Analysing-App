class AppRoutes {
  static const login = '/login';

  static const studentDashboard = '/studentDashboard';
  static const studentResults = '/studentResults';
  static const studentAnalysis = '/studentAnalysis';
  static const studentProfile = '/studentProfile';

  static const staffDashboard = '/staffDashboard';
  static const staffUploadResults = '/staffUploadResults';
  static const staffClassAnalysis = '/staffClassAnalysis';
  static const staffStudentInsights = '/staffStudentInsights';
  static const staffProfile = '/staffProfile';

  static const adminDashboard = '/adminDashboard';
  static const adminProfile = '/adminProfile';
  static const adminUserManagement = '/adminUserManagement';

  static const collegeNoticesStudent = '/collegeNoticesStudent';
  static const collegeNoticesStaff = '/collegeNoticesStaff';
  static const collegeNoticesAdmin = '/collegeNoticesAdmin';

  static String homeForRole(String? role) {
    switch (role) {
      case 'admin':
        return adminDashboard;
      case 'staff':
        return staffDashboard;
      case 'student':
        return studentDashboard;
      default:
        return login;
    }
  }
}
