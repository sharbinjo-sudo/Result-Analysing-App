import 'package:flutter/material.dart';
import '../utils/storage.dart';

class RouteGuard {
  static Route<dynamic> guard({
    required RouteSettings settings,
    required WidgetBuilder builder,
    String? requiredRole,
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        return FutureBuilder<bool>(
          future: SecureStorage.isLoggedIn(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final loggedIn = snapshot.data!;
            final hasAccess = requiredRole == null
                ? loggedIn
                : loggedIn && SecureStorage.hasRole(requiredRole);

            if (!hasAccess) {
              // 🔥 HARD RESET NAVIGATION STACK
              WidgetsBinding.instance.addPostFrameCallback((_) {
                SecureStorage.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                );
              });

              // Return empty widget while redirecting
              return const SizedBox.shrink();
            }

            // ✅ Access allowed
            return builder(context);
          },
        );
      },
    );
  }
}
