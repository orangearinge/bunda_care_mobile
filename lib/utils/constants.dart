import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'logger.dart';

/// API Configuration Constants
/// Contains all API endpoints, URLs, and configuration values
/// Values are loaded from .env file via flutter_dotenv
class ApiConstants {
  // Prevent instantiation
  ApiConstants._();

  // ==================== Environment ====================

  /// Base URL for the API
  /// Loaded from .env (API_BASE_URL)
  /// Automatically detects platform and uses appropriate URL
  static String get baseUrl {
    // Check .env first for all platforms
    final url = dotenv.env['API_BASE_URL'];
    if (url != null && url.isNotEmpty) {
      return url;
    }

    // Fallback for web
    if (kIsWeb) {
      return "http://127.0.0.1:5000";
    }

    // Platform-specific fallback logic for mobile
    if (Platform.isAndroid) {
      return "http://10.0.2.2:5000"; // Android Emulator default
    }

    if (Platform.isIOS) {
      return "http://127.0.0.1:5000"; // iOS Simulator default
    }

    // Default fallback
    return "http://127.0.0.1:5000";
  }

  /// Current environment status
  static bool get isDevelopment => dotenv.env['APP_ENV'] != 'production';

  // ==================== Platform Detection ====================

  /// Check if running on Android Emulator
  static bool get isAndroidEmulator {
    if (!Platform.isAndroid) {
      return false;
    }
    // Additional emulator detection can be added here if needed
    return true; // For now, assume all Android is emulator unless .env is set
  }

  /// Check if running on Physical Android Device
  static bool get isPhysicalAndroid {
    return Platform.isAndroid && !isAndroidEmulator;
  }

  /// Check if running on iOS Simulator
  static bool get isIOSSimulator {
    if (!Platform.isIOS) {
      return false;
    }
    // Additional simulator detection can be added here if needed
    return true; // For now, assume all iOS is simulator unless .env is set
  }

  /// Get platform information for debugging
  static String get platformInfo {
    if (kIsWeb) {
      return 'Web';
    }
    if (Platform.isAndroid) {
      return 'Android (${isAndroidEmulator ? 'Emulator' : 'Physical'})';
    }
    if (Platform.isIOS) {
      return 'iOS (${isIOSSimulator ? 'Simulator' : 'Physical'})';
    }
    return 'Unknown';
  }

  // ==================== Cloudinary ====================

  static String get cloudinaryCloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'demo';
  static String get cloudinaryUploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'ml_default';
  static String get cloudinaryFolder =>
      dotenv.env['CLOUDINARY_FOLDER'] ?? 'bunda_care/avatars';

  // ==================== Auth Endpoints ====================

  static const String register = "/api/auth/register";
  static const String login = "/api/auth/login";
  static const String googleAuth = "/api/auth/google";
  static const String logout = "/api/auth/logout";

  // ==================== Food Endpoints ====================
  static const String scanFood = "/api/scan-food";
  static const String recommendation = "/api/recommendation";
  static const String mealLog = "/api/meal-log";
  static const String menuDetail = "/api/menus";

  // ==================== User Endpoints ====================
  static const String userPreference = "/api/user/preference";
  static const String userDashboard = "/api/user/dashboard";
  static const String userProfile = "/api/user/profile";
  static const String userAvatar = "/api/user/avatar";
  static const String userHistory = "/api/user/history";
  static const String feedback = "/api/feedback";
  static const String myFeedback = "/api/feedback/me";

  // ==================== Chat Endpoints ====================
  static const String chat = "/api/chat";
  static const String chatRebuild = "/api/chat/rebuild";

  // ==================== Article Endpoints ====================
  static const String publicArticles = "/api/public/articles";

  // ==================== Timeouts ====================

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ==================== Storage Keys ====================

  static const String tokenKey = "auth_token";
  static const String userKey = "user_data";

  // ==================== Error Messages ====================

  /// Map backend error codes to user-friendly messages
  static const Map<String, String> errorMessages = {
    // Auth Errors
    'VALIDATION_ERROR': 'Isi semua kolom dulu ya!',
    'INVALID_CREDENTIALS': 'Email atau password salah nih',
    'EMAIL_IN_USE': 'Email ini sudah dipakai orang lain',
    'INVALID_TOKEN': 'Sesi habis. Login lagi yuk!',
    'SESSION_EXPIRED': 'Waktunya login lagi nih!',
    'UNAUTHORIZED': 'Kamu belum punya akses fitur ini',
    'ACCOUNT_NOT_VERIFIED': 'Verifikasi email dulu ya!',
    'PASSWORD_TOO_WEAK': 'Password harus 8 karakter!',
    'LOGOUT_FAILED': 'Gagal logout. Coba lagi deh',
    'GOOGLE_AUTH_CANCELLED': 'Daftar Google dibatalkan',
    'GOOGLE_SIGNIN_CANCELLED': 'Login Google dibatalkan',

    // Network / Server Errors
    'NETWORK_ERROR': 'Yah, internetnya mati. Cek koneksi kamu ya!',
    'TIMEOUT_ERROR': 'Lama banget responsnya. Coba lagi yuk!',
    'SERVER_ERROR': 'Server lagi maintenance. Tunggu ya!',
    'UNKNOWN_ERROR': 'Ada masalah. Coba lagi nanti',
    'REQUEST_CANCELLED': 'Permintaan dibatalkan',

    // Food scanning & Recommendation
    'SCAN_FAILED': 'Foto kurang jelas. Foto ulang yang lebih terang ya!',
    'FOOD_NOT_RECOGNIZED': 'Makanan ini belum kenal. Coba foto yang berbeda',
    'SCAN_LIMIT_EXCEEDED': 'Batas scan harian habis. Besok lagi yuk!',
    'RECOMMENDATION_FAILED': 'Rekomendasi lagi error. Tunggu sebentar',
    'NO_RECOMMENDATIONS': 'Belum ada saran untuk saat ini',
    'INVALID_FOOD_DATA': 'Data makanan kurang lengkap',

    // Meal logging
    'LOG_FAILED': 'Gagal simpan catatan. Coba lagi ya!',
    'LOG_LIMIT_EXCEEDED': 'Catatan hari ini sudah cukup banyak',
    'DUPLICATE_LOG': 'Makanan ini sudah dicatat sebelumnya',

    // Cloudinary & Files
    'UPLOAD_FAILED': 'Upload gagal. Cek internet!',
    'INVALID_FILE_TYPE': 'Harus file gambar!',
    'FILE_TOO_LARGE': 'Gambar terlalu besar',

    // Data Errors
    'INVALID_USER_DATA': 'Data user salah',
    'DATA_NOT_FOUND': 'Data tidak ada',
  };

  /// Get user-friendly error message from error code
  static String getErrorMessage(String? errorCode) {
    if (errorCode == null) {
      return errorMessages['UNKNOWN_ERROR']!;
    }
    return errorMessages[errorCode] ?? errorMessages['UNKNOWN_ERROR']!;
  }

  // ==================== Debug Information ====================

  /// Print current API configuration for debugging
  static void debugPrintConfig() {
    if (isDevelopment) {
      AppLogger.d('🔧 API Configuration Debug:');
      AppLogger.d('   Platform: $platformInfo');
      AppLogger.d('   Base URL: $baseUrl');
      AppLogger.d('   Environment: ${dotenv.env['APP_ENV'] ?? 'not set'}');
      AppLogger.d(
        '   API_BASE_URL from .env: ${dotenv.env['API_BASE_URL'] ?? 'not set'}',
      );
      AppLogger.d('   kIsWeb: $kIsWeb');
    }
  }
}
