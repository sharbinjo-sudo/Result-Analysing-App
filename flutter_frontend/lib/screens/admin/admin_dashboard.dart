import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _searchController = TextEditingController();
  String selectedRole = "All";

  // 🧩 Mock user data — replace with FastAPI API call later
  List<Map<String, dynamic>> users = [
    {
      "name": "N. R. Forename",
      "role": "Student",
      "dept": "CSE",
      "email": "forename@student.vvcoe.com",
      "approved": true,
    },
    {
      "name": "S. Meena",
      "role": "Staff",
      "dept": "ECE",
      "email": "meena@vvcoe.com",
      "approved": false,
    },
    {
      "name": "Dr. R. Aravind",
      "role": "HOD",
      "dept": "EEE",
      "email": "aravind@vvcoe.com",
      "approved": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((user) {
      final matchesRole =
          selectedRole == "All" || user["role"] == selectedRole;
      final matchesSearch = user["name"]
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          user["email"]
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      return matchesRole && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),
      backgroundColor: const Color(0xFFFFF8F8),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "User Management",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB11116),
              ),
            ),
            const SizedBox(height: 16),

            // 🔍 Search & Filter Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: "Search by name or email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: selectedRole,
                  items: ["All", "Student", "Staff", "HOD", "Principal"]
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => selectedRole = v!),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 📋 User Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6),
                  ],
                ),
                child: ListView.separated(
                  itemCount: filteredUsers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFB11116).withOpacity(0.2),
                        child: Text(
                          user["name"].toString()[0],
                          style: const TextStyle(color: Color(0xFFB11116)),
                        ),
                      ),
                      title: Text(user["name"]),
                      subtitle: Text(
                        "${user["role"]} • ${user["dept"]} • ${user["email"]}",
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Approve / Revoke Button
                          IconButton(
                            icon: Icon(
                              user["approved"]
                                  ? Icons.check_circle
                                  : Icons.hourglass_empty,
                              color: user["approved"]
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            tooltip: user["approved"]
                                ? "Approved"
                                : "Pending Approval",
                            onPressed: () {
                              setState(() {
                                user["approved"] = !user["approved"];
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    user["approved"]
                                        ? "${user["name"]} approved"
                                        : "${user["name"]} approval revoked",
                                  ),
                                ),
                              );
                            },
                          ),
                          // Delete Button
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: "Remove user",
                            onPressed: () {
                              setState(() {
                                users.remove(user);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("${user["name"]} removed successfully"),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
