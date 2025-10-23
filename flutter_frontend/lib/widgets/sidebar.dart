import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String role;
  const Sidebar({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final menuItems = role == "student"
        ? ["Dashboard", "My Results", "Analysis", "Profile"]
        : ["Dashboard", "Upload Results", "Class Analysis", "Profile"];

    return Container(
      width: 230,
      color: const Color(0xFFB11116),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            height: 100,
            color: const Color(0xFF8E0F13),
            child: Row(
              children: [
                Image.asset('assets/images/vvcoe_logo.jpg', height: 50),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "V V College",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
          ...menuItems.map(
            (item) => ListTile(
              title: Text(
                item,
                style: const TextStyle(color: Colors.white),
              ),
              leading: const Icon(Icons.arrow_right, color: Colors.white),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$item page coming soon")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
