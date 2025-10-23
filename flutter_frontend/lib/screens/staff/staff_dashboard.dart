import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 🔹 Sidebar for navigation
          const Sidebar(role: "staff"),

          // 🔹 Main content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Welcome, Staff 👋",
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
                    "Manage class performance, upload results, and monitor student progress.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),

                  // Dashboard Cards Section
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      DashboardCard(
                        title: "Upload Results",
                        icon: Icons.upload_file,
                        color: Colors.green,
                        description:
                            "Upload marks or PDFs, or manually enter results.",
                        onTap: () {
                          Navigator.pushNamed(context, '/staffUploadResults');
                        },
                      ),
                      DashboardCard(
                        title: "Class Analysis",
                        icon: Icons.bar_chart_outlined,
                        color: Colors.orange,
                        description:
                            "View class pass percentage, averages, and toppers.",
                        onTap: () {
                          Navigator.pushNamed(context, '/staffClassAnalysis');
                        },
                      ),
                      DashboardCard(
                        title: "Student Insights",
                        icon: Icons.people_outline,
                        color: Colors.blue,
                        description:
                            "Search individual students and analyze their performance.",
                        onTap: () {
                          Navigator.pushNamed(context, '/staffStudentInsights');
                        },
                      ),
                      DashboardCard(
                        title: "Reports & PDFs",
                        icon: Icons.picture_as_pdf_outlined,
                        color: Colors.purple,
                        description:
                            "Download generated reports and department summaries.",
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Reports feature coming soon")),
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

// 🔸 Dashboard Card Widget
class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? description;
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
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title coming soon")),
            );
          },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 260,
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(1, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            const SizedBox(height: 6),
            if (description != null)
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
        ),
      ),
    );
  }
}
