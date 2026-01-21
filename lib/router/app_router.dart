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
import '../pages/splash_page.dart';

/// Application router configuration with authentication guards
class AppRouter {
  final AuthProvider authProvider;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    refreshListenable: authProvider,
    debugLogDiagnostics: true,
    initialLocation: '/splash', // Start at splash

    // Redirect logic based on authentication state
    redirect: (context, state) {
      final authState = authProvider.state;
      final isAuthenticated = authProvider.isAuthenticated;
      final isUserComplete = authProvider.isUserComplete;
      
      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isRoleSelection = state.matchedLocation == '/role-selection';

      // 1. If initializing or loading, stay on Splash (if starting) or stay put
      if (authState == AuthState.initial || authState == AuthState.loading) {
        // Only return splash if we are at root or splash, otherwise stay where we are
        if (isSplash || state.matchedLocation == '/') {
          return '/splash';
        }
        return null;
      }

      // 2. If authenticated...
      if (isAuthenticated) {
        // If on splash, login, or register -> go to appropriate home
        if (isSplash || isLoggingIn || isRegistering) {
          return isUserComplete ? '/' : '/role-selection';
        }

        // Forced stay on role-selection if user not complete
        if (!isUserComplete &&
            !isRoleSelection &&
            !state.matchedLocation.startsWith('/multi-step-form')) {
          return '/role-selection';
        }

        return null;
      }

      // 3. If NOT authenticated...
      if (!isAuthenticated) {
        // Allow access to splash, login, and register
        if (isSplash || isLoggingIn || isRegistering) {
          return isSplash ? '/login' : null;
        }

        // Block everything else
        return '/login';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
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
