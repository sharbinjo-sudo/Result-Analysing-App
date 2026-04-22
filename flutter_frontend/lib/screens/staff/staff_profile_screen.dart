import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/profile_view.dart';

class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')),
            ),
          );
        }

        final data = snapshot.data ?? <String, dynamic>{};
        final name = (data['name'] as String?)?.trim().isNotEmpty == true
            ? data['name'] as String
            : (data['username'] as String? ?? 'Staff');

        final fields = <MapEntry<String, String>>[
          MapEntry('Username', data['username'] as String? ?? '-'),
          MapEntry('Employee ID', data['employee_id'] as String? ?? '-'),
          MapEntry('Email', data['email'] as String? ?? '-'),
          MapEntry('Department', data['department_name'] as String? ?? '-'),
          MapEntry('Phone Number', data['phone_number'] as String? ?? '-'),
          MapEntry('Role', data['role_name'] as String? ?? '-'),
          MapEntry('Approval Status', (data['is_approved'] as bool? ?? true) ? 'Approved' : 'Pending'),
        ];

        return ProfileView(
          title: 'Staff Profile',
          role: 'staff',
          heroIcon: Icons.school_outlined,
          name: name,
          subtitle: 'Faculty account information is synced from the backend and updates without hardcoded values.',
          fields: fields,
        );
      },
    );
  }
}
