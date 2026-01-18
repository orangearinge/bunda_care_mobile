import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'providers/user_preference_provider.dart';
import 'providers/food_provider.dart';
import 'providers/article_provider.dart';
import 'providers/history_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/feedback_provider.dart';
import 'router/app_router.dart';
import 'pages/main_navigation.dart';
import 'package:shimmer/shimmer.dart';
import 'utils/constants.dart';
import 'utils/logger.dart';
import 'utils/styles.dart';
// import 'utils/navigator_observers.dart';

void main() async {
  // Menangkap error flutter di luar zone (misalnya saat inisialisasi)
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal (untuk Bahasa Indonesia)
  await initializeDateFormatting('id_ID', null);

  try {
    await dotenv.load(fileName: ".env");
    AppLogger.i("Environment loaded successfully");
    // Debug API configuration
    ApiConstants.debugPrintConfig();
  } catch (e) {
    AppLogger.w("Warning: Could not load .env file: $e");
  }

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
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
      ],
      // Menggunakan Builder agar context bisa mengakses provider di level yang sama
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
  AppRouter? _appRouter;

  @override
  void initState() {
    super.initState();
    // Memulai pengecekan status auth segera setelah inisialisasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch AuthProvider untuk mendeteksi perubahan state
    final authProvider = context.watch<AuthProvider>();

    // Jika masih dalam status inisialisasi awal, tampilkan loading screen sederhana
    // Ini membantu mencegah blank screen saat GoRouter sedang bersiap
    if (authProvider.state == AuthState.initial) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.pink[300]),
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.pink[50]!],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or App Icon
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween(begin: 0.8, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'lib/assets/images/logo_bundacare.png',
                      width: 100,
                      height: 100,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.favorite,
                        size: 80,
                        color: Colors.pink[300],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Loading Text with subtle shimmer
                Shimmer.fromColors(
                  baseColor: Colors.pink[400]!,
                  highlightColor: Colors.pink[200]!,
                  child: const Text(
                    "Bunda Care",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Partner Gizi Bunda & Buah Hati",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 60),
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Inisialisasi AppRouter hanya sekali setelah AuthProvider siap
    _appRouter ??= AppRouter(authProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Bunda Care',
      theme: AppStyles.themeData,
      routerConfig: _appRouter!.router,
    );
  }
}
