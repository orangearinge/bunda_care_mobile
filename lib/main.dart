import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'router/app_router.dart';
import 'pages/dashboard_page.dart';
import 'pages/rekomendasi_page.dart';
import 'pages/scan_page.dart';
import 'pages/chatbot_page.dart';
import 'pages/edukasi_page.dart';

void main() {
  runApp(const BundaCareApp());
}

class BundaCareApp extends StatelessWidget {
  const BundaCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const AppContent(),
    );
  }
}

class AppContent extends StatefulWidget {
  const AppContent({super.key});

  @override
  State<AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<AppContent> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _appRouter = AppRouter(authProvider);

    // Check authentication status when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider.checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Bunda Care',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6CC4A1),
      ),
      routerConfig: _appRouter.router,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DashboardPage(),
    );
  }
}
