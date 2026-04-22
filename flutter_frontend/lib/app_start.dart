import 'package:flutter/material.dart';

import 'utils/routes.dart';
import 'utils/storage.dart';

class AppStart extends StatelessWidget {
  const AppStart({super.key});

  Future<String> _decideStartRoute() async {
    final loggedIn = await SecureStorage.isLoggedIn();
    if (!loggedIn) {
      await SecureStorage.clearSession();
      return AppRoutes.login;
    }

    final role = await SecureStorage.getRole();
    final route = AppRoutes.homeForRole(role);
    if (route == AppRoutes.login) {
      await SecureStorage.clearSession();
    }
    return route;
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
