import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'providers/auth_provider.dart';
import 'providers/user_preference_provider.dart';
import 'providers/food_provider.dart';
import 'providers/article_provider.dart';
import 'providers/history_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/feedback_provider.dart';
import 'providers/meal_schedule_provider.dart';
import 'services/notification_service.dart';
import 'router/app_router.dart';
import 'utils/constants.dart';
import 'utils/logger.dart';
import 'utils/styles.dart';

void main() async {
  // Menangkap error flutter di luar zone (misalnya saat inisialisasi)
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal (untuk Bahasa Indonesia)
  await initializeDateFormatting('id_ID', null);

  // Initialize timezone data
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // Set to Indonesian timezone

  try {
    await dotenv.load(fileName: ".env");
    AppLogger.i("Environment loaded successfully");
    // Debug API configuration
    ApiConstants.debugPrintConfig();
  } catch (e) {
    AppLogger.w("Warning: Could not load .env file: $e");
  }

  // Initialize notification service
  await NotificationService().init();
  AppLogger.i("Notification service initialized");

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
        ChangeNotifierProvider(create: (_) => MealScheduleProvider()),
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
      // Initialize meal schedule provider
      context.read<MealScheduleProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch AuthProvider untuk mendeteksi perubahan state
    final authProvider = context.watch<AuthProvider>();

    // Inisialisasi AppRouter hanya sekali
    _appRouter ??= AppRouter(authProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Bunda Care',
      theme: AppStyles.themeData,
      routerConfig: _appRouter!.router,
    );
  }
}
