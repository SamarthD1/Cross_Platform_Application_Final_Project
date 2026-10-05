import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/user_role.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/common_widgets/role_switch_header.dart';
import '../../features/customer/presentation/customer_dashboard.dart';
import '../../features/vendor/presentation/kitchen_dashboard.dart';
import '../../features/delivery/presentation/delivery_dashboard.dart';
import '../../features/admin/presentation/admin_dashboard.dart';

/// Listenable bridge connecting Riverpod's AuthState with GoRouter's refresh mechanism
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) {
        if (previous?.isAuthenticated != next.isAuthenticated ||
            previous?.user?.role != next.user?.role) {
          notifyListeners();
        }
      },
    );
  }
}

final routerRefreshNotifierProvider = Provider<GoRouterRefreshNotifier>((ref) {
  return GoRouterRefreshNotifier(ref);
});

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    debugLogDiagnostics: true,
    routes: [
      // 1. Authentication Route (Public)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 2. Protected Role Shell (Houses Customer, Vendor, Delivery, Admin)
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: Column(
              children: [
                const RoleSwitchHeader(),
                Expanded(child: child),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/customer',
            name: 'customer',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CustomerDashboard(),
            ),
          ),
          GoRoute(
            path: '/vendor',
            name: 'vendor',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: KitchenDashboard(),
            ),
          ),
          GoRoute(
            path: '/delivery',
            name: 'delivery',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DeliveryDashboard(),
            ),
          ),
          GoRoute(
            path: '/admin',
            name: 'admin',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminDashboard(),
            ),
          ),
        ],
      ),

      // 3. Fallback Route
      GoRoute(
        path: '/unauthorized',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_person, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  '403 Forbidden',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You do not have authorization to view this role dashboard.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],

    // CORE MIDDLEWARE / ROUTE PROTECTION GUARD
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authControllerProvider);
      final isLoggedIn = authState.isAuthenticated;
      final currentPath = state.uri.path;
      final isGoingToLogin = currentPath == '/login';

      // Rule 1: If unauthenticated, deny access to protected routes and redirect to /login
      if (!isLoggedIn) {
        return isGoingToLogin ? null : '/login';
      }

      final userRole = authState.user!.role;

      // Rule 2: If authenticated and trying to access /login or root /, route to role's dashboard
      if (isGoingToLogin || currentPath == '/') {
        return getDashboardPathForRole(userRole);
      }

      // Rule 3: Role-Based Access Control (RBAC) Guard
      // Prevents a Delivery partner or Customer from manually entering /admin or /vendor in URL
      if (currentPath.startsWith('/admin') && userRole != UserRole.admin) {
        return getDashboardPathForRole(userRole);
      }
      if (currentPath.startsWith('/vendor') && userRole != UserRole.vendor) {
        return getDashboardPathForRole(userRole);
      }
      if (currentPath.startsWith('/delivery') && userRole != UserRole.delivery) {
        return getDashboardPathForRole(userRole);
      }
      if (currentPath.startsWith('/customer') && userRole != UserRole.customer) {
        return getDashboardPathForRole(userRole);
      }

      return null; // Route is authorized
    },
  );
});

String getDashboardPathForRole(UserRole role) {
  switch (role) {
    case UserRole.customer:
      return '/customer';
    case UserRole.vendor:
      return '/vendor';
    case UserRole.delivery:
      return '/delivery';
    case UserRole.admin:
      return '/admin';
  }
}
