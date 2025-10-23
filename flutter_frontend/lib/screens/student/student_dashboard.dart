import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(role: "student"),

          // 🔹 Main content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Header section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Welcome, Student 👋",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB11116),
                        ),
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFB11116),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Here’s your academic summary and quick actions:",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),

                  // ---------- Dashboard Cards ----------
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      DashboardCard(
                        title: "My Results",
                        description:
                            "View your semester-wise marks and grades.",
                        icon: Icons.grade_outlined,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pushNamed(context, '/studentResults');
                        },
                      ),
                      DashboardCard(
                        title: "Analysis",
                        description:
                            "Check your performance trend and subject averages.",
                        icon: Icons.analytics_outlined,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.pushNamed(context, '/studentAnalysis');
                        },
                      ),
                      DashboardCard(
                        title: "Profile",
                        description:
                            "View your personal details and logout safely.",
                        icon: Icons.person_outline,
                        color: Colors.green,
                        onTap: () {
                          Navigator.pushNamed(context, '/studentProfile');
                        },
                      ),
                      DashboardCard(
                        title: "College Notices",
                        description:
                            "Access official circulars and announcements.",
                        icon: Icons.notifications_outlined,
                        color: Colors.purple,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Notices feature coming soon!"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- DashboardCard Widget ----------
class DashboardCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title coming soon")),
            );
          },
      child: Container(
        width: 260,
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 6),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
