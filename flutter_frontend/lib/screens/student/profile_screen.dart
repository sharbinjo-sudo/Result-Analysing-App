import 'package:flutter/material.dart';
import '../../utils/storage.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // 🧠 Temporary mock student data (we'll later fetch from FastAPI)
  final Map<String, String> studentData = const {
    "name": "N. R. Forename",
    "registerNo": "VV2025CSE001",
    "department": "Computer Science and Engineering",
    "email": "student@vvcoe.com",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      backgroundColor: const Color(0xFFFFF8F8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 420,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // VVCOE Logo
                Image.asset(
                  'assets/images/vvcoe_logo.jpg',
                  height: 90,
                ),
                const SizedBox(height: 20),

                const Text(
                  "Student Profile",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB11116),
                  ),
                ),
                const SizedBox(height: 24),

                // Profile Info Fields
                ProfileItem(
                  label: "Name",
                  value: studentData["name"]!,
                  icon: Icons.person_outline,
                ),
                ProfileItem(
                  label: "Register Number",
                  value: studentData["registerNo"]!,
                  icon: Icons.badge_outlined,
                ),
                ProfileItem(
                  label: "Department",
                  value: studentData["department"]!,
                  icon: Icons.school_outlined,
                ),
                ProfileItem(
                  label: "Email",
                  value: studentData["email"]!,
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 32),

                // Logout Button
                ElevatedButton.icon(
                  onPressed: () async {
                    await SecureStorage.deleteToken(); // clear token
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB11116),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🧱 Profile Info Widget (Reusable)
class ProfileItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ProfileItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB11116)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}