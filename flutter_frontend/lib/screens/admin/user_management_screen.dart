import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme.dart';
import '../../widgets/college_scaffold.dart';
import '../../widgets/dashboard_parts.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late Future<List<dynamic>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _roleFilter = 'all';
  String _approvalFilter = 'all';

  @override
  void initState() {
    super.initState();
    _future = ApiService.getUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => _future = ApiService.getUsers());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showUserDialog([Map<String, dynamic>? user]) async {
    final isEdit = user != null;
    final usernameController = TextEditingController(text: user?['username']?.toString() ?? '');
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController(text: user?['first_name']?.toString() ?? '');
    final lastNameController = TextEditingController(text: user?['last_name']?.toString() ?? '');
    final emailController = TextEditingController(text: user?['email']?.toString() ?? '');
    final departmentController = TextEditingController(text: user?['department']?.toString() ?? '');
    final registerController = TextEditingController(text: user?['register_number']?.toString() ?? '');
    final employeeController = TextEditingController(text: user?['employee_id']?.toString() ?? '');
    final yearController = TextEditingController(text: user?['year_of_study']?.toString() ?? '');
    final sectionController = TextEditingController(text: user?['section']?.toString() ?? '');
    final phoneController = TextEditingController(text: user?['phone_number']?.toString() ?? '');
    var role = user?['role']?.toString() ?? 'student';
    var approved = user?['is_approved'] as bool? ?? true;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit User Profile' : 'Create User Profile'),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create or update users directly in the portal database.',
                        style: TextStyle(color: kTextLight, height: 1.5),
                      ),
                      const SizedBox(height: 18),
                      const Text('Basic Details', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(labelText: 'Username'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: isEdit ? 'Password (optional)' : 'Password',
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(labelText: 'First Name'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(labelText: 'Last Name'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email Address'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      const Text('Role and Academic Info', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(value: 'student', child: Text('Student')),
                          DropdownMenuItem(value: 'staff', child: Text('Staff')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (value) => setLocalState(() => role = value ?? 'student'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: departmentController,
                        decoration: const InputDecoration(labelText: 'Department Code'),
                      ),
                      const SizedBox(height: 10),
                      if (role == 'student') ...[
                        TextField(
                          controller: registerController,
                          decoration: const InputDecoration(labelText: 'Register Number'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: yearController,
                          decoration: const InputDecoration(labelText: 'Year of Study'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: sectionController,
                          decoration: const InputDecoration(labelText: 'Section'),
                        ),
                      ] else ...[
                        TextField(
                          controller: employeeController,
                          decoration: const InputDecoration(labelText: 'Employee ID'),
                        ),
                      ],
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        value: approved,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Approved for login'),
                        subtitle: const Text('Only approved users can sign in to the portal.'),
                        onChanged: (value) => setLocalState(() => approved = value ?? true),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    final payload = <String, dynamic>{
                      'username': usernameController.text.trim(),
                      if (passwordController.text.trim().isNotEmpty)
                        'password': passwordController.text.trim(),
                      'first_name': firstNameController.text.trim(),
                      'last_name': lastNameController.text.trim(),
                      'email': emailController.text.trim(),
                      'role': role,
                      'department': departmentController.text.trim(),
                      'register_number': registerController.text.trim().isEmpty
                          ? null
                          : registerController.text.trim(),
                      'employee_id': employeeController.text.trim().isEmpty
                          ? null
                          : employeeController.text.trim(),
                      'year_of_study': int.tryParse(yearController.text.trim()),
                      'section': sectionController.text.trim(),
                      'phone_number': phoneController.text.trim(),
                      'is_approved': approved,
                    };

                    try {
                      if (isEdit) {
                        await ApiService.updateUser(user['id'] as int, payload);
                        _showMessage('User updated successfully.');
                      } else {
                        await ApiService.createUser(payload);
                        _showMessage('User created successfully.');
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      _reload();
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                      );
                    }
                  },
                  icon: Icon(isEdit ? Icons.save_outlined : Icons.person_add_alt_1_outlined),
                  label: Text(isEdit ? 'Save Changes' : 'Create User'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _toggleApproval(Map<String, dynamic> user) async {
    try {
      await ApiService.updateUser(
        user['id'] as int,
        {'is_approved': !(user['is_approved'] as bool? ?? true)},
      );
      _reload();
      _showMessage(
        (user['is_approved'] as bool? ?? true)
            ? 'User moved to pending approval.'
            : 'User approved successfully.',
      );
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'This will deactivate ${user['name']?.toString().isNotEmpty == true ? user['name'] : user['username']}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ApiService.deleteUser(user['id'] as int);
      _reload();
      _showMessage('User deleted successfully.');
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CollegeScaffold(
      title: 'User Management',
      role: 'admin',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserDialog(),
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Add User'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
          }

          final users = List<Map<String, dynamic>>.from(snapshot.data ?? const []);
          final searchTerm = _searchController.text.trim().toLowerCase();
          final filteredUsers = users.where((user) {
            final matchesSearch = searchTerm.isEmpty ||
                (user['username']?.toString().toLowerCase().contains(searchTerm) ?? false) ||
                (user['email']?.toString().toLowerCase().contains(searchTerm) ?? false) ||
                (user['name']?.toString().toLowerCase().contains(searchTerm) ?? false) ||
                (user['register_number']?.toString().toLowerCase().contains(searchTerm) ?? false) ||
                (user['employee_id']?.toString().toLowerCase().contains(searchTerm) ?? false);
            final matchesRole = _roleFilter == 'all' || user['role']?.toString() == _roleFilter;
            final approved = user['is_approved'] as bool? ?? false;
            final matchesApproval = _approvalFilter == 'all' ||
                (_approvalFilter == 'approved' && approved) ||
                (_approvalFilter == 'pending' && !approved);
            return matchesSearch && matchesRole && matchesApproval;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              DashboardHero(
                title: 'User Administration',
                subtitle:
                    'Create, update, approve, and deactivate portal users while keeping student, staff, and admin records in sync with the backend.',
                badges: [
                  '${users.length} Active Users',
                  '${users.where((user) => user['role'] == 'student').length} Students',
                  '${users.where((user) => !(user['is_approved'] as bool? ?? false)).length} Pending Approval',
                ],
              ),
              const SizedBox(height: 24),
              SummaryGrid(
                stats: {
                  'students': users.where((user) => user['role'] == 'student').length,
                  'staff': users.where((user) => user['role'] == 'staff').length,
                  'admins': users.where((user) => user['role'] == 'admin').length,
                  'pending': users.where((user) => !(user['is_approved'] as bool? ?? false)).length,
                },
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        title: 'Search and Filter',
                        subtitle:
                            'Filter by role and approval state to manage users faster without leaving the page.',
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search by name, username, email, register number, or employee ID',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final role in const ['all', 'student', 'staff', 'admin'])
                            ChoiceChip(
                              label: Text(
                                role == 'all'
                                    ? 'All Roles'
                                    : '${role[0].toUpperCase()}${role.substring(1)}',
                              ),
                              selected: _roleFilter == role,
                              onSelected: (_) => setState(() => _roleFilter = role),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final status in const ['all', 'approved', 'pending'])
                            ChoiceChip(
                              label: Text(
                                status == 'all'
                                    ? 'All Status'
                                    : '${status[0].toUpperCase()}${status.substring(1)}',
                              ),
                              selected: _approvalFilter == status,
                              onSelected: (_) => setState(() => _approvalFilter = status),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SectionTitle(
                title: 'Users',
                subtitle: 'Showing ${filteredUsers.length} matching users from the backend.',
              ),
              const SizedBox(height: 16),
              if (filteredUsers.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No users matched the current filters.'),
                  ),
                )
              else
                ...filteredUsers.map(
                  (user) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _UserCard(
                      user: user,
                      onEdit: () => _showUserDialog(user),
                      onToggleApproval: () => _toggleApproval(user),
                      onDelete: () => _confirmDelete(user),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onToggleApproval,
    required this.onDelete,
  });

  final Map<String, dynamic> user;
  final VoidCallback onEdit;
  final VoidCallback onToggleApproval;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final approved = user['is_approved'] as bool? ?? false;
    final displayName = user['name']?.toString().trim().isNotEmpty == true
        ? user['name'].toString()
        : user['username']?.toString() ?? 'User';
    final identity = user['role'] == 'student'
        ? (user['register_number']?.toString().isNotEmpty == true
            ? user['register_number'].toString()
            : 'No register number')
        : (user['employee_id']?.toString().isNotEmpty == true
            ? user['employee_id'].toString()
            : 'No employee ID');
    final department = user['department_name']?.toString().isNotEmpty == true
        ? user['department_name'].toString()
        : (user['department']?.toString().isNotEmpty == true ? user['department'].toString() : '-');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: kPrimaryColor.withValues(alpha: 0.12),
                  child: Text(
                    displayName.isEmpty ? 'U' : displayName[0].toUpperCase(),
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '@${user['username'] ?? ''} | ${user['email'] ?? 'No email'}',
                        style: const TextStyle(color: kTextLight, height: 1.4),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusBadge(
                      label: user['role_name']?.toString() ?? user['role']?.toString() ?? '-',
                      color: kPrimaryColor,
                    ),
                    _StatusBadge(
                      label: approved ? 'Approved' : 'Pending',
                      color: approved ? const Color(0xFF178347) : const Color(0xFFD17D00),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _InfoPill(icon: Icons.badge_outlined, label: identity),
                _InfoPill(icon: Icons.apartment_outlined, label: department),
                if (user['role'] == 'student')
                  _InfoPill(
                    icon: Icons.school_outlined,
                    label: 'Year ${user['year_of_study'] ?? '-'} | Sec ${user['section'] ?? '-'}',
                  ),
                if ((user['phone_number']?.toString().isNotEmpty ?? false))
                  _InfoPill(
                    icon: Icons.phone_outlined,
                    label: user['phone_number']?.toString() ?? '',
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: onToggleApproval,
                  icon: Icon(approved ? Icons.hourglass_top_outlined : Icons.verified_outlined),
                  label: Text(approved ? 'Mark Pending' : 'Approve'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: kPrimaryColor),
                  label: const Text('Delete', style: TextStyle(color: kPrimaryColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kPrimaryColor),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: kTextDark, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
