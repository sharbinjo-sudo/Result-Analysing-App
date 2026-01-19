import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'utils/storage.dart';

class AppStart extends StatelessWidget {
  const AppStart({super.key});

  Future<String> _decideStartRoute() async {
    final token = await SecureStorage.getToken();

    if (token == null) {
      return '/login';
    }

    // Token exists → check expiry
    if (Jwt.isExpired(token)) {
      await SecureStorage.deleteToken();
      return '/login';
    }

    final decoded = Jwt.parseJwt(token);
    final role = decoded['role'];

    if (role == 'admin') return '/adminDashboard';
    if (role == 'staff') return '/staffDashboard';
    if (role == 'student') return '/studentDashboard';

    // Fallback
    await SecureStorage.deleteToken();
    return '/login';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _decideStartRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, snapshot.data!);
        });

        return const SizedBox.shrink();
      },
    );
  }
}
