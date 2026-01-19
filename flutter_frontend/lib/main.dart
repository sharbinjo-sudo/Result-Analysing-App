// 📁 lib/main.dart
import 'package:flutter/material.dart';

// 🔹 Import Screens
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

      // ✅ Global Theme
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

      // ✅ Initial route
      home: const AppStart(),


      // ✅ All Named Routes
      routes: {
        // --- Authentication ---
        '/login': (context) => const LoginPage(),

        // --- Student routes ---
        '/studentDashboard': (context) => const StudentDashboard(),
        '/studentResults': (context) => const ResultScreen(),
        '/studentAnalysis': (context) => const AnalysisScreen(),
        '/studentProfile': (context) => const ProfileScreen(),

        // --- Staff routes ---
        '/staffDashboard': (context) => const StaffDashboard(),
        '/staffUploadResults': (context) => const UploadResultsScreen(),
        '/staffClassAnalysis': (context) => const ClassAnalysisScreen(),
        '/staffStudentInsights': (context) => const StudentInsightsScreen(),

        // --- Admin routes ---
        '/adminDashboard': (context) => const AdminDashboard(),
        '/staffProfile': (context) => const StaffProfileScreen(),
        '/adminProfile': (context) => const AdminProfileScreen(),

        // --- Shared route: College Notices ---
        '/collegeNoticesStudent': (context) => const NoticesScreen(role: "student"),
          '/collegeNoticesStaff': (context) => const NoticesScreen(role: "staff"),
          '/collegeNoticesAdmin': (context) => const NoticesScreen(role: "admin"),
        '/adminUserManagement': (context) => const UserManagementScreen(),
        // --- Shared route: College Notices ---
        '/collegeNotices': (context) {
          // You can dynamically set the role later using arguments
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final role = args?['role'] ?? 'student';
          return NoticesScreen(role: role);
        },
      },
    );
  }
}
