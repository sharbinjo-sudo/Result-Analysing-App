// lib/widgets/sidebar.dart
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String role;
  final void Function(String)? onNavigate;

  const Sidebar({
    super.key,
    required this.role,
    this.onNavigate,
  });

  // 🔹 Get menu items based on role
  List<Map<String, dynamic>> _getMenuItems() {
    switch (role.toLowerCase()) {
      case "student":
        return [
          {"title": "Dashboard", "icon": Icons.dashboard_outlined, "route": "/studentDashboard"},
          {"title": "My Results", "icon": Icons.grade_outlined, "route": "/studentResults"},
          {"title": "Analysis", "icon": Icons.analytics_outlined, "route": "/studentAnalysis"},
          {"title": "Profile", "icon": Icons.person_outline, "route": "/studentProfile"},
          {"title": "College Notices", "icon": Icons.notifications_outlined, "route": "/collegeNoticesStudent"},
        ];
      case "staff":
        return [
          {"title": "Dashboard", "icon": Icons.dashboard_outlined, "route": "/staffDashboard"},
          {"title": "Upload Results", "icon": Icons.upload_file_outlined, "route": "/staffUploadResults"},
          {"title": "Class Analysis", "icon": Icons.bar_chart_outlined, "route": "/staffClassAnalysis"},
          {"title": "Student Insights", "icon": Icons.people_outline, "route": "/staffStudentInsights"},
          {"title": "Profile", "icon": Icons.person_outline, "route": "/staffProfile"},
          {"title": "College Notices", "icon": Icons.notifications_outlined, "route": "/collegeNoticesStaff"},
        ];
      case "admin":
        return [
          {"title": "Dashboard", "icon": Icons.dashboard_customize_outlined, "route": "/adminDashboard"},
          {"title": "User Management", "icon": Icons.people_alt_outlined, "route": "/adminUserManagement"},
          {"title": "Profile", "icon": Icons.person_outline, "route": "/adminProfile"},
          {"title": "Notice Management", "icon": Icons.campaign_outlined, "route": "/collegeNoticesAdmin"},
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return Container(
      width: 240,
      color: const Color(0xFFB11116),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Sidebar Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Icon(Icons.school_rounded, color: Colors.white, size: 26),
                SizedBox(width: 10),
                Text(
                  "V V College",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white38, indent: 16, endIndent: 16),

          // 🔹 Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final route = item["route"] as String;
                final isSelected = currentRoute == route;

                return InkWell(
                  onTap: () {
                    // avoid reloading same route
                    if (currentRoute == route) {
                      return;
                    }

                    // Prefer parent handler so parent can manage animation/navigation.
                    if (onNavigate != null) {
                      onNavigate!(route);
                    } else {
                      // fallback: replace to avoid stacking
                      Navigator.pushReplacementNamed(context, route);
                    }
                  },
                  splashColor: Colors.white10,
                  hoverColor: Colors.white12,
                  child: Container(
                    color: isSelected ? Colors.white.withOpacity(0.15) : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ListTile(
                        leading: Icon(item["icon"] as IconData, color: Colors.white),
                        title: Text(
                          item["title"] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(color: Colors.white38, indent: 16, endIndent: 16),

          // 🔹 Logout
          InkWell(
            onTap: () {
              if (onNavigate != null) {
                onNavigate!('/login');
              } else {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            splashColor: Colors.white10,
            child: Container(
              color: currentRoute == '/login' ? Colors.white.withOpacity(0.15) : null,
              child: const ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text("Logout", style: TextStyle(color: Colors.white, fontSize: 15)),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
