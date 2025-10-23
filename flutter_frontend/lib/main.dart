import 'package:flutter/material.dart';

// 🔹 Import Screens
import 'screens/login_page.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/staff/staff_dashboard.dart';
import 'screens/student/result_screen.dart';
import 'screens/student/analysis_screen.dart';
import 'screens/student/profile_screen.dart';
import 'screens/staff/upload_results_screen.dart';
import 'screens/staff/class_analysis_screen.dart';
import 'screens/staff/student_insights_screen.dart';
import 'screens/admin/admin_dashboard.dart';

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

      // ✅ Theme setup
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

      // ✅ Default route
      initialRoute: '/login',

      // ✅ Named routes
      routes: {
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

        // --- Admin route ---
        '/adminDashboard': (context) => const AdminDashboard(),
      },
    );
  }
}
