import 'package:flutter/material.dart';

import 'routes.dart';
import 'storage.dart';

class RouteGuard {
  static Route<dynamic> guard({
    required RouteSettings settings,
    required WidgetBuilder builder,
    String? requiredRole,
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        return FutureBuilder<_RouteAccess>(
          future: _hasAccess(requiredRole),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final access = snapshot.data!;
            if (!access.hasAccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  access.redirectRoute,
                  (_) => false,
                );
              });
              return const SizedBox.shrink();
            }

            return builder(context);
          },
        );
      },
    );
  }

  static Route<dynamic> public({
    required RouteSettings settings,
    required WidgetBuilder builder,
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        return FutureBuilder<_RouteAccess>(
          future: _publicAccess(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final access = snapshot.data!;
            if (!access.hasAccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  access.redirectRoute,
                  (_) => false,
                );
              });
              return const SizedBox.shrink();
            }

            return builder(context);
          },
        );
      },
    );
  }

  static Future<_RouteAccess> _hasAccess(String? requiredRole) async {
    final loggedIn = await SecureStorage.isLoggedIn();
    if (!loggedIn) {
      await SecureStorage.clearSession();
      return const _RouteAccess(false, AppRoutes.login);
    }

    final role = await SecureStorage.getRole();
    if (requiredRole == null || role == requiredRole) {
      return const _RouteAccess(true, '');
    }

    return _RouteAccess(false, AppRoutes.homeForRole(role));
  }

  static Future<_RouteAccess> _publicAccess() async {
    final loggedIn = await SecureStorage.isLoggedIn();
    if (!loggedIn) {
      return const _RouteAccess(true, '');
    }

    final role = await SecureStorage.getRole();
    return _RouteAccess(false, AppRoutes.homeForRole(role));
  }
}

class _RouteAccess {
  const _RouteAccess(this.hasAccess, this.redirectRoute);

  final bool hasAccess;
  final String redirectRoute;
}
