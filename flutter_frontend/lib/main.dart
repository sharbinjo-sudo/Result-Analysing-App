import 'package:flutter/material.dart';

// 🔹 Core
import 'utils/route_guard.dart';
import 'screens/login_page.dart';
import 'app_start.dart';

// --- Student Screens ---
import 'screens/student/student_dashboard.dart';
import 'screens/student/result_screen.dart';
import 'screens/student/analysis_screen.dart';
import 'screens/student/profile_screen.dart';

// --- Staff Screens ---
import 'screens/staff/staff_dashboard.dart';
import 'screens/staff/upload_results_screen.dart';
import 'screens/staff/class_analysis_screen.dart';
import 'screens/staff/student_insights_screen.dart';
import 'screens/staff/staff_profile_screen.dart';

// --- Admin Screens ---
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/user_management_screen.dart';
import 'screens/admin/admin_profile_screen.dart';

// --- Shared Screens ---
import 'screens/shared/notices_screen.dart';

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

      // 🎨 Theme
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFB11116),
        scaffoldBackgroundColor: const Color(0xFFFFF8F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB11116),
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB11116),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),

      // 🚀 App start
      home: const AppStart(),

      // 🔐 ROUTE GUARD (GLOBAL)
      onGenerateRoute: (settings) {
        switch (settings.name) {

          // 🔓 Public
          case '/login':
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
              settings: settings,
            );

          // 🎓 Student
          case '/studentDashboard':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'student',
              builder: (_) => const StudentDashboard(),
            );
          case '/studentResults':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'student',
              builder: (_) => const ResultScreen(),
            );
          case '/studentAnalysis':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'student',
              builder: (_) => const AnalysisScreen(),
            );
          case '/studentProfile':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'student',
              builder: (_) => const ProfileScreen(),
            );

          // 👨‍🏫 Staff
          case '/staffDashboard':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'staff',
              builder: (_) => const StaffDashboard(),
            );
          case '/staffUploadResults':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'staff',
              builder: (_) => const UploadResultsScreen(),
            );
          case '/staffClassAnalysis':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'staff',
              builder: (_) => const ClassAnalysisScreen(),
            );
          case '/staffStudentInsights':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'staff',
              builder: (_) => const StudentInsightsScreen(),
            );
          case '/staffProfile':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'staff',
              builder: (_) => const StaffProfileScreen(),
            );

          // 👑 Admin
          case '/adminDashboard':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'admin',
              builder: (_) => const AdminDashboard(),
            );
          case '/adminProfile':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'admin',
              builder: (_) => const AdminProfileScreen(),
            );
          case '/adminUserManagement':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'admin',
              builder: (_) => const UserManagementScreen(),
            );

          // 📢 Notices
          case '/collegeNoticesStudent':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'student',
              builder: (_) => const NoticesScreen(role: 'student'),
            );
          case '/collegeNoticesStaff':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'staff',
              builder: (_) => const NoticesScreen(role: 'staff'),
            );
          case '/collegeNoticesAdmin':
            return RouteGuard.guard(
              settings: settings,
              requiredRole: 'admin',
              builder: (_) => const NoticesScreen(role: 'admin'),
            );

          // ❓ Fallback
          default:
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
            );
        }
      },
    );
  }
}
