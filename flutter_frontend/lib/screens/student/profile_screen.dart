import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/profile_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        final fullName = (data['name'] as String?)?.trim().isNotEmpty == true
            ? data['name'] as String
            : (data['username'] as String? ?? 'Student');

        final fields = <MapEntry<String, String>>[
          MapEntry('Username', data['username'] as String? ?? '-'),
          MapEntry('Email', data['email'] as String? ?? '-'),
          MapEntry('Department', data['department_name'] as String? ?? '-'),
          MapEntry('Register Number', data['register_number'] as String? ?? '-'),
          MapEntry('Year of Study', '${data['year_of_study'] ?? '-'}'),
          MapEntry('Section', data['section'] as String? ?? '-'),
          MapEntry('Phone Number', data['phone_number'] as String? ?? '-'),
          MapEntry('Role', data['role_name'] as String? ?? '-'),
        ];

        return ProfileView(
          title: 'Student Profile',
          role: 'student',
          heroIcon: Icons.person_outline,
          name: fullName,
          subtitle: 'Your profile details are loaded directly from the college database.',
          fields: fields,
        );
      },
    );
  }
}
