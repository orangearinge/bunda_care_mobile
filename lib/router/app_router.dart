import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/main_navigation.dart';
import '../pages/registration_form_page.dart';
import '../pages/multi_step_form_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/chatbot_page.dart';
import '../pages/scan_page.dart';
import '../pages/edukasi_page.dart';
import '../pages/profile_page.dart';
import '../pages/feedback_page.dart';
import '../utils/navigator_observers.dart';

/// Application router configuration with authentication guards
class AppRouter {
  final AuthProvider authProvider;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    observers: [ExitDialogNavigatorObserver()],
    refreshListenable: authProvider,
    debugLogDiagnostics: true,

    // Redirect logic based on authentication state
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final isUserComplete = authProvider.isUserComplete;
      final isAuthenticating =
          authProvider.state == AuthState.initial ||
          authProvider.state == AuthState.loading;
      final isGoogleSignInInProgress = authProvider.isGoogleSignInInProgress;

      final isGoingToAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isGoingToRoleSelection = state.matchedLocation == '/role-selection';

      // Still checking auth status, Google sign-in in progress, or loading on login page - stay on current route
      if (isAuthenticating ||
          isGoogleSignInInProgress ||
          (authProvider.state == AuthState.loading &&
              state.matchedLocation == '/login'))
        return null;

      // User is authenticated but trying to access auth pages
      if (isAuthenticated && isGoingToAuth) {
        // If user is not complete, redirect to role selection
        if (!isUserComplete) {
          return '/role-selection';
        }
        return '/';
      }

      // User is authenticated but not complete, trying to access home/dashboard
      if (isAuthenticated && !isUserComplete && state.matchedLocation == '/') {
        return '/role-selection';
      }

      // User is authenticated and complete, but trying to access role selection
      if (isAuthenticated && isUserComplete && isGoingToRoleSelection) {
        return '/';
      }

      // User is not authenticated but trying to access protected pages
      if (!isAuthenticated && !isGoingToAuth && !isGoingToRoleSelection) {
        return '/login';
      }

      // No redirect needed
      return null;
    },

    routes: [
      // Auth Routes (Public)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const SignUpPage(),
      ),

      // Main Navigation Shell (Stateful)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigation(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chatbot',
                name: 'chatbot',
                builder: (context, state) => const ChatbotPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scan',
                name: 'scan',
                builder: (context, state) => const ScanPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/edukasi',
                name: 'edukasi',
                builder: (context, state) => const EdukasiPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // Other Protected Routes
      GoRoute(
        path: '/role-selection',
        name: 'role-selection',
        builder: (context, state) => RegistrationFormPage(),
      ),
      GoRoute(
        path: '/multi-step-form/:role',
        name: 'multi-step-form',
        builder: (context, state) {
          final role = state.pathParameters['role']!;
          return MultiStepFormPage(userRole: role);
        },
      ),
      GoRoute(
        path: '/feedback',
        name: 'feedback',
        builder: (context, state) => const FeedbackPage(),
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
