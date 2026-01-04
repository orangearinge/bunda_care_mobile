import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_preference_provider.dart';
import 'providers/food_provider.dart';
import 'router/app_router.dart';
import 'pages/dashboard_page.dart';
import 'pages/rekomendasi_page.dart';
import 'pages/scan_page.dart';
import 'pages/chatbot_page.dart';
import 'pages/edukasi_page.dart';
import 'pages/profile_page.dart';

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
        ChangeNotifierProvider(create: (_) => UserPreferenceProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
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
        colorSchemeSeed: Colors.pink[300],
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
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardPage(),
      const ChatbotPage(),
      const ScanPage(),
      const EdukasiPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, Icons.home, 0),
                _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 1),
                _buildNavItem(Icons.qr_code_scanner, Icons.qr_code_scanner, 2),
                _buildNavItem(
                  Icons.menu_book_outlined,
                  Icons.menu_book,
                  3,
                ),
                _buildNavItem(Icons.person_outline, Icons.person, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData iconOutlined, IconData iconFilled, int index) {
    bool isSelected = _selectedIndex == index;

    List<Color> gradientColors;
    switch (index) {
      case 0:
        gradientColors = [Colors.pink[300]!, Colors.pink[400]!];
        break;
      case 1:
        gradientColors = [Colors.purple[300]!, Colors.purple[400]!];
        break;
      case 2:
        gradientColors = [Colors.blue[300]!, Colors.blue[400]!];
        break;
      case 3:
        gradientColors = [Colors.orange[300]!, Colors.orange[400]!];
        break;
      case 4:
        gradientColors = [Colors.pink[300]!, Colors.pink[400]!]; // Matched with ProfilePage
        break;
      default:
        gradientColors = [Colors.grey[300]!, Colors.grey[400]!];
    }

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isSelected ? iconFilled : iconOutlined,
          color: isSelected ? Colors.white : Colors.grey[400],
          size: 28,
        ),
      ),
    );
  }
}
