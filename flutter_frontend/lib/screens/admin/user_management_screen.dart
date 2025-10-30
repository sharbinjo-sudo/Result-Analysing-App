import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  static const double sidebarWidth = 240;
  late final AnimationController _controller;
  late final Animation<double> _sidebarTranslate;
  late final Animation<double> _contentTranslate;
  late final Animation<double> _overlayOpacity;
  bool _isOpen = false;
  bool _navigating = false;

  final TextEditingController _searchController = TextEditingController();
  String selectedRole = "All";
  String selectedDept = "All";
  String selectedClass = "All";
  String selectedYear = "All";

  // Demo users (replace with backend integration)
  List<Map<String, dynamic>> users = [
    {
      "name": "N. R. Forename",
      "role": "Student",
      "dept": "CSE",
      "year": "SE",
      "class": "SE-A",
      "email": "forename@student.vvcoe.com",
      "approved": true,
    },
    {
      "name": "S. Meena",
      "role": "Staff",
      "dept": "ECE",
      "year": null,
      "class": null,
      "email": "meena@vvcoe.com",
      "approved": false,
    },
    {
      "name": "Dr. R. Aravind",
      "role": "HOD",
      "dept": "EEE",
      "year": null,
      "class": null,
      "email": "aravind@vvcoe.com",
      "approved": true,
    },
  ];
  final List<String> departments = ["All", "CSE", "ECE", "EEE", "MECH", "IT"];
  // Updated year options as requested: I, II, III, IV (plus All)
  final List<String> years = ["All", "I", "II", "III", "IV"];
  // Updated class options as requested: A, B, C, D (plus All)
  final Map<String, List<String>> classesByDept = {
    "All": ["All", "A", "B", "C", "D"],
    "CSE": ["All", "A", "B", "C", "D"],
    "ECE": ["All", "A", "B", "C", "D"],
    "EEE": ["All", "A", "B", "C", "D"],
    "MECH": ["All", "A", "B", "C", "D"],
    "IT": ["All", "A", "B", "C", "D"],
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
   final animationCurve = Curves.easeInOutQuart; // ✅ add this before them

_sidebarTranslate = Tween<double>(begin: -sidebarWidth, end: 0).animate(
  CurvedAnimation(parent: _controller, curve: animationCurve),
);
_contentTranslate = Tween<double>(begin: 0, end: sidebarWidth).animate(
  CurvedAnimation(parent: _controller, curve: animationCurve),
);
_overlayOpacity = Tween<double>(begin: 0, end: 0.35).animate(
  CurvedAnimation(parent: _controller, curve: animationCurve),
);


  }

  void _toggleSidebar() {
    if (_navigating) return;
    setState(() {
      _isOpen = !_isOpen;
      _isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  Future<void> _handleSidebarNavigation(String route) async {
    if (_navigating) return;
    _navigating = true;

    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) {
      await _controller.reverse();
      setState(() => _isOpen = false);
      _navigating = false;
      return;
    }

    if (route == '/login') {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    } else {
      Navigator.pushReplacementNamed(context, route);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        await _controller.reverse();
        setState(() => _isOpen = false);
      }
      _navigating = false;
    });
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacementNamed(context, '/adminDashboard');
    return false;
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Header identical to other pages
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFF2F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon:
                  const Icon(Icons.menu_rounded, color: Color(0xFFB11116), size: 30),
              onPressed: _toggleSidebar,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "User Management",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11116),
                ),
              ),
            ),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/adminDashboard');
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFB11116),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x33B11116),
                        blurRadius: 8,
                        offset: Offset(0, 3))
                  ],
                ),
                child: const Icon(Icons.dashboard, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add/Edit user form dialog (supports Year & Class)
  Future<void> _showUserForm({Map<String, dynamic>? user, int? index}) async {
    final bool isEdit = user != null && index != null;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user?['name'] ?? '');
    final emailCtrl = TextEditingController(text: user?['email'] ?? '');
    String role = user?['role'] ?? 'Student';
    String dept = user?['dept'] ?? 'CSE';
    String klass = user?['class'] ??
        (classesByDept[dept]?.firstWhere((e) => e != 'All', orElse: () => '') ?? '');
    String yearVar = user?['year'] ?? 'I';
    bool approved = user?['approved'] ?? false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit User' : 'Register New User'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: StatefulBuilder(builder: (context, st) {
            final classOptions = classesByDept[dept] ?? ['All'];
            if (!classOptions.contains(klass)) {
              klass = classOptions.firstWhere((c) => c != 'All', orElse: () => '');
            }

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Full name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: role,
                        items: ['Student', 'Staff', 'HOD', 'Principal', 'Admin']
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) => st(() => role = v!),
                        decoration: const InputDecoration(labelText: 'Role'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: dept,
                        items: departments
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (v) => st(() {
                          dept = v!;
                          klass = (classesByDept[dept] ?? ['All']).firstWhere((c) => c != 'All', orElse: () => '');
                        }),
                        decoration: const InputDecoration(labelText: 'Department'),
                      ),
                      const SizedBox(height: 12),
if (role == 'Student') ...[
  // Build deduped lists to avoid duplicate value assertion
  DropdownButtonFormField<String>(
    value: ['I', 'II', 'III', 'IV'].contains(yearVar) ? yearVar : null,
    items: ['I', 'II', 'III', 'IV']
        .map((y) => DropdownMenuItem(value: y, child: Text(y)))
        .toList(),
    onChanged: (v) => st(() => yearVar = v ?? 'I'),
    decoration: const InputDecoration(labelText: 'Year'),
  ),
  const SizedBox(height: 12),
  DropdownButtonFormField<String>(
    value: ((classesByDept[dept] ?? ['All'])
                .where((c) => c != 'All')
                .contains(klass))
        ? klass
        : null,
    items: (classesByDept[dept] ?? ['All'])
        .where((c) => c != 'All')
        .toSet() // remove duplicates
        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
        .toList(),
    onChanged: (v) => st(() =>
        klass = v ?? (classesByDept[dept] ?? ['A']).firstWhere((c) => c != 'All')),
    decoration: const InputDecoration(labelText: 'Class / Section'),
  ),
  const SizedBox(height: 12),
],

                      Row(
                        children: [
                          Checkbox(
                            value: approved,
                            onChanged: (val) => st(() => approved = val ?? false),
                          ),
                          const SizedBox(width: 8),
                          const Text('Approved'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB11116)),
              onPressed: () {
                if (formKey.currentState != null && formKey.currentState!.validate()) {
                  final newUser = {
                    "name": nameCtrl.text.trim(),
                    "email": emailCtrl.text.trim(),
                    "role": role,
                    "dept": dept,
                    "year": role == 'Student' ? yearVar : null,
                    "class": role == 'Student' ? klass : null,
                    "approved": approved,
                  };

setState(() {
  if (index != null) {
    final i = index;
    users[i] = {...users[i], ...newUser}; // analyzer knows i is non-nullable
  } else {
    users.insert(0, newUser);
  }
});

                  Navigator.pop(context);
                }
              },
              child: Text(isEdit ? 'Save' : 'Register'),
            ),
          ],
        );
      },
    );
  }

  // Confirm delete
  Future<bool?> _confirmDelete(String name) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete user'),
        content: Text('Are you sure you want to delete $name? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB11116)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Main UI
  @override
  Widget build(BuildContext context) {
    final availableClassFilters = classesByDept[selectedDept] ?? ['All'];
    if (!availableClassFilters.contains(selectedClass)) selectedClass = 'All';

    final filteredUsers = users.where((user) {
      final matchesRole = selectedRole == 'All' || user['role'] == selectedRole;
      final matchesDept = selectedDept == 'All' || user['dept'] == selectedDept;
      final matchesYear = selectedYear == 'All' || (user['year'] ?? 'All') == selectedYear;
      final matchesClass = selectedClass == 'All' || (user['class'] ?? 'All') == selectedClass;
      final search = _searchController.text.trim().toLowerCase();
      final matchesSearch = search.isEmpty ||
          user['name'].toString().toLowerCase().contains(search) ||
          user['email'].toString().toLowerCase().contains(search);
      return matchesRole && matchesDept && matchesYear && matchesClass && matchesSearch;
    }).toList();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFE9F2FF),
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_contentTranslate.value, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search bar (full width-ish on larger screens)
                              LayoutBuilder(builder: (context, constraints) {
                                final maxWidth = constraints.maxWidth;
                                final searchWidth = maxWidth > 700 ? 480.0 : maxWidth;
                                return SizedBox(
                                  width: searchWidth,
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      labelText: "Search by name or email",
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                    onChanged: (v) => setState(() {}),
                                  ),
                                );
                              }),

                              const SizedBox(height: 10),

                              // Filters under the search bar (responsive)
                              Wrap(
                                spacing: 12,
                                runSpacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 140),
                                    child: DropdownButtonFormField<String>(
                                      value: selectedRole,
                                      decoration: const InputDecoration(labelText: 'Role'),
                                      items: ['All', 'Student', 'Staff', 'HOD', 'Principal', 'Admin']
                                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                          .toList(),
                                      onChanged: (v) => setState(() => selectedRole = v!),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 140),
                                    child: DropdownButtonFormField<String>(
                                      value: selectedDept,
                                      decoration: const InputDecoration(labelText: 'Department'),
                                      items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                                      onChanged: (v) => setState(() {
                                        selectedDept = v!;
                                        selectedClass = (classesByDept[selectedDept] ?? ['All']).first;
                                      }),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 140),
                                    child: DropdownButtonFormField<String>(
                                      value: selectedYear,
                                      decoration: const InputDecoration(labelText: 'Year'),
                                      items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                                      onChanged: (v) => setState(() {
                                        selectedYear = v!;
                                        // if a specific year is chosen set role to Student
                                        if (selectedYear != 'All') selectedRole = 'Student';
                                      }),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 140),
                                    child: DropdownButtonFormField<String>(
                                      value: selectedClass,
                                      decoration: const InputDecoration(labelText: 'Class'),
                                      items: (classesByDept[selectedDept] ?? ['All']).map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                      onChanged: (v) => setState(() {
                                        selectedClass = v!;
                                        // if a specific class is chosen set role to Student
                                        if (selectedClass != 'All') selectedRole = 'Student';
                                      }),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _showUserForm(),
                                    icon: const Icon(Icons.person_add, size: 18),
                                    label: const Text('Add User'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFB11116),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // Info counts
                              Text(
                                'Results: ${filteredUsers.length} • Total users: ${users.length}',
                                style: const TextStyle(color: Colors.black54),
                              ),

                              const SizedBox(height: 12),

                              // Users list container
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: filteredUsers.isEmpty
                                      ? const Center(child: Text('No users found'))
                                      : ListView.separated(
                                          padding: EdgeInsets.zero,
                                          itemCount: filteredUsers.length,
                                          separatorBuilder: (_, __) => const Divider(height: 1),
                                          itemBuilder: (context, idx) {
                                            final user = filteredUsers[idx];
                                            final realIndex = users.indexWhere((u) => u['email'] == user['email'] && u['name'] == user['name']);
                                            return ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: const Color(0xFFB11116).withOpacity(0.12),
                                                child: Text(user['name'].toString()[0], style: const TextStyle(color: Color(0xFFB11116))),
                                              ),
                                              title: Text(user['name']),
                                              subtitle: Text(
                                                '${user['role']} • ${user['dept']}${user['class'] != null && user['class'] != '' ? ' • ${user['class']}' : ''}${user['year'] != null && user['year'] != '' ? ' • ${user['year']}' : ''}\n${user['email']}',
                                              ),
                                              isThreeLine: true,
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    tooltip: user['approved'] ? 'Revoke approval' : 'Approve user',
                                                    icon: Icon(user['approved'] ? Icons.check_circle : Icons.hourglass_empty,
                                                        color: user['approved'] ? Colors.green : Colors.orange),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (realIndex >= 0) {
                                                          users[realIndex]['approved'] = !(users[realIndex]['approved'] ?? false);
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  IconButton(
                                                    tooltip: 'Edit user',
                                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                                    onPressed: () {
                                                      if (realIndex >= 0) {
                                                        _showUserForm(user: Map<String, dynamic>.from(users[realIndex]), index: realIndex);
                                                      }
                                                    },
                                                  ),
                                                  IconButton(
                                                    tooltip: 'Delete user',
                                                    icon: const Icon(Icons.delete, color: Colors.red),
                                                    onPressed: () async {
                                                      final confirm = await _confirmDelete(user['name'] ?? 'this user');
                                                      if (confirm == true && realIndex >= 0) {
                                                        setState(() {
                                                          users.removeAt(realIndex);
                                                        });
                                                      }
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
                      ),
                    ],
                  ),
                );
              },
            ),
AnimatedBuilder(
  animation: _overlayOpacity,
  builder: (context, _) {
    return IgnorePointer(
      ignoring: !_isOpen,
      child: Opacity(
        opacity: _overlayOpacity.value,
        child: GestureDetector(
          onTap: _toggleSidebar,
          child: Container(
            color: Colors.black.withOpacity(0.3),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  },
),

            // Sidebar
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_sidebarTranslate.value, 0),
                  child: SizedBox(
                    width: sidebarWidth,
                    height: MediaQuery.of(context).size.height,
                    child: Sidebar(
                      role: "admin",
                      onNavigate: _handleSidebarNavigation,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
