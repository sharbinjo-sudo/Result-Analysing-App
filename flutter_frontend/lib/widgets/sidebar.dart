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

    return Material(
      color: const Color(0xFFB11116),
      child: SafeArea(
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

            // 🔹 Menu Items (using ListView.separated for smoother rendering)
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: menuItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final route = item["route"] as String;
                  final isSelected = currentRoute == route;

                  return _SidebarItem(
                    icon: item["icon"] as IconData,
                    title: item["title"] as String,
                    isSelected: isSelected,
                    onTap: () {
                      if (currentRoute == route) return;
                      if (onNavigate != null) {
                        onNavigate!(route);
                      } else {
                        Navigator.pushReplacementNamed(context, route);
                      }
                    },
                  );
                },
              ),
            ),

            const Divider(color: Colors.white38, indent: 16, endIndent: 16),

            // 🔹 Logout Button (exact confirmation dialog as in StaffProfileScreen)
            _SidebarItem(
              icon: Icons.logout,
              title: "Logout",
              isSelected: currentRoute == '/login',
              onTap: () async {
                final confirmLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm Logout"),
                    content: const Text("Are you sure you want to logout from your account?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB11116),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                );

                if (confirmLogout == true) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ Extracted Sidebar Item Widget (reduces rebuild cost & vibration)
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white10,
      hoverColor: Colors.white12,
      child: Container(
        color: isSelected ? Colors.white.withOpacity(0.15) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
            dense: true,
            leading: Icon(icon, color: Colors.white),
            title: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ),
    );
  }
}
