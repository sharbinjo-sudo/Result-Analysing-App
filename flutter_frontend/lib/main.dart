import 'package:flutter/material.dart';

import 'app_start.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_profile_screen.dart';
import 'screens/admin/user_management_screen.dart';
import 'screens/login_page.dart';
import 'screens/shared/notices_screen.dart';
import 'screens/staff/class_analysis_screen.dart';
import 'screens/staff/staff_dashboard.dart';
import 'screens/staff/staff_profile_screen.dart';
import 'screens/staff/student_insights_screen.dart';
import 'screens/staff/upload_results_screen.dart';
import 'screens/student/analysis_screen.dart';
import 'screens/student/profile_screen.dart';
import 'screens/student/result_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'theme.dart';
import 'utils/route_guard.dart';
import 'utils/routes.dart';

void main() {
  runApp(const VVCollegeApp());
}

class VVCollegeApp extends StatelessWidget {
  const VVCollegeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V V College of Engineering',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const AppStart(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return RouteGuard.public(
              settings: settings,
              builder: (_) => const LoginPage(),
            );
          case AppRoutes.studentDashboard:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'student',
              builder: (_) => const StudentDashboard(),
            );
          case AppRoutes.studentResults:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'student',
              builder: (_) => const ResultScreen(),
            );
          case AppRoutes.studentAnalysis:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'student',
              builder: (_) => const AnalysisScreen(),
            );
          case AppRoutes.studentProfile:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'student',
              builder: (_) => const ProfileScreen(),
            );
          case AppRoutes.staffDashboard:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'staff',
              builder: (_) => const StaffDashboard(),
            );
          case AppRoutes.staffUploadResults:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'staff',
              builder: (_) => const UploadResultsScreen(),
            );
          case AppRoutes.staffClassAnalysis:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'staff',
              builder: (_) => const ClassAnalysisScreen(),
            );
          case AppRoutes.staffStudentInsights:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'staff',
              builder: (_) => const StudentInsightsScreen(),
            );
          case AppRoutes.staffProfile:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'staff',
              builder: (_) => const StaffProfileScreen(),
            );
          case AppRoutes.adminDashboard:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'admin',
              builder: (_) => const AdminDashboard(),
            );
          case AppRoutes.adminProfile:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'admin',
              builder: (_) => const AdminProfileScreen(),
            );
          case AppRoutes.adminUserManagement:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'admin',
              builder: (_) => const UserManagementScreen(),
            );
          case AppRoutes.collegeNoticesStudent:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'student',
              builder: (_) => const NoticesScreen(role: 'student'),
            );
          case AppRoutes.collegeNoticesStaff:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'staff',
              builder: (_) => const NoticesScreen(role: 'staff'),
            );
          case AppRoutes.collegeNoticesAdmin:
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'admin',
              builder: (_) => const NoticesScreen(role: 'admin'),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
            );
        }
      },
    );
  }
}
