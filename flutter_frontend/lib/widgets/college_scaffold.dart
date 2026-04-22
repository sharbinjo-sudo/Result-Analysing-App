import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/storage.dart';

class CollegeScaffold extends StatelessWidget {
  const CollegeScaffold({
    super.key,
    required this.title,
    required this.role,
    required this.body,
    this.floatingActionButton,
  });

  final String title;
  final String role;
  final Widget body;
  final Widget? floatingActionButton;

  List<Map<String, dynamic>> _itemsForRole() {
    switch (role) {
      case 'student':
        return const [
          {'label': 'Dashboard', 'route': '/studentDashboard', 'icon': Icons.dashboard_outlined},
          {'label': 'My Results', 'route': '/studentResults', 'icon': Icons.grade_outlined},
          {'label': 'Analysis', 'route': '/studentAnalysis', 'icon': Icons.analytics_outlined},
          {'label': 'Profile', 'route': '/studentProfile', 'icon': Icons.person_outline},
          {'label': 'College Notices', 'route': '/collegeNoticesStudent', 'icon': Icons.notifications_outlined},
        ];
      case 'staff':
        return const [
          {'label': 'Dashboard', 'route': '/staffDashboard', 'icon': Icons.dashboard_outlined},
          {'label': 'Upload Results', 'route': '/staffUploadResults', 'icon': Icons.upload_file_outlined},
          {'label': 'Class Analysis', 'route': '/staffClassAnalysis', 'icon': Icons.bar_chart_outlined},
          {'label': 'Student Insights', 'route': '/staffStudentInsights', 'icon': Icons.people_outline},
          {'label': 'Profile', 'route': '/staffProfile', 'icon': Icons.person_outline},
          {'label': 'College Notices', 'route': '/collegeNoticesStaff', 'icon': Icons.notifications_outlined},
        ];
      default:
        return const [
          {'label': 'Dashboard', 'route': '/adminDashboard', 'icon': Icons.dashboard_customize_outlined},
          {'label': 'User Management', 'route': '/adminUserManagement', 'icon': Icons.people_alt_outlined},
          {'label': 'Profile', 'route': '/adminProfile', 'icon': Icons.person_outline},
          {'label': 'Manage Notices', 'route': '/collegeNoticesAdmin', 'icon': Icons.campaign_outlined},
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final menuItems = _itemsForRole();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/vvcoe_logo.jpg',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8F0D12), Color(0xFFB11116), Color(0xFFCE5961)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8F0D12), Color(0xFFB11116)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/vvcoe_logo.jpg',
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'V V College of Engineering',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${role[0].toUpperCase()}${role.substring(1)} Portal',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (final item in menuItems)
                      ListTile(
                        leading: Icon(item['icon'] as IconData, color: kPrimaryColor),
                        title: Text(item['label'] as String),
                        selected: currentRoute == item['route'],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onTap: () {
                          Navigator.pop(context);
                          if (currentRoute != item['route']) {
                            Navigator.pushReplacementNamed(context, item['route'] as String);
                          }
                        },
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await SecureStorage.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7FBFF), Color(0xFFFFF5F1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(child: body),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
