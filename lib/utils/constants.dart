import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

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
    // For web, always use localhost regardless of .env
    if (kIsWeb) {
      return "http://127.0.0.1:5000"; // Web localhost
    }

    // For mobile platforms, check .env first
    final url = dotenv.env['API_BASE_URL'];
    if (url != null && url.isNotEmpty) return url;

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
    if (!Platform.isAndroid) return false;
    // Additional emulator detection can be added here if needed
    return true; // For now, assume all Android is emulator unless .env is set
  }

  /// Check if running on Physical Android Device
  static bool get isPhysicalAndroid {
    return Platform.isAndroid && !isAndroidEmulator;
  }

  /// Check if running on iOS Simulator
  static bool get isIOSSimulator {
    if (!Platform.isIOS) return false;
    // Additional simulator detection can be added here if needed
    return true; // For now, assume all iOS is simulator unless .env is set
  }

  /// Get platform information for debugging
  static String get platformInfo {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid)
      return 'Android (${isAndroidEmulator ? 'Emulator' : 'Physical'})';
    if (Platform.isIOS)
      return 'iOS (${isIOSSimulator ? 'Simulator' : 'Physical'})';
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
    'VALIDATION_ERROR': 'Harap isi semua kolom dengan benar',
    'INVALID_CREDENTIALS': 'Email atau password salah',
    'EMAIL_IN_USE': 'Email ini sudah terdaftar',
    'INVALID_TOKEN': 'Sesi tidak valid, silakan login kembali',
    'SESSION_EXPIRED': 'Sesi Anda telah berakhir, silakan login kembali',
    'UNAUTHORIZED': 'Anda tidak memiliki akses ke fitur ini',
    'ACCOUNT_NOT_VERIFIED': 'Harap verifikasi email Anda sebelum login',
    'PASSWORD_TOO_WEAK': 'Password minimal harus 8 karakter',
    'LOGOUT_FAILED': 'Gagal keluar, silakan coba lagi',
    'GOOGLE_AUTH_CANCELLED': 'Pendaftaran Google dibatalkan',
    'GOOGLE_SIGNIN_CANCELLED': 'Login Google dibatalkan',

    // Network / Server Errors
    'NETWORK_ERROR': 'Tidak ada koneksi internet. Periksa jaringan Anda',
    'TIMEOUT_ERROR': 'Koneksi terputus. Silakan coba lagi',
    'SERVER_ERROR': 'Terjadi gangguan pada server. Coba lagi nanti',
    'UNKNOWN_ERROR': 'Terjadi kesalahan yang tidak terduga',
    'REQUEST_CANCELLED': 'Permintaan dibatalkan',

    // Food scanning & Recommendation
    'SCAN_FAILED': 'Gagal memindai makanan. Coba lagi dengan gambar yang lebih jelas',
    'FOOD_NOT_RECOGNIZED': 'Makanan tidak dikenali. Coba foto yang lain',
    'SCAN_LIMIT_EXCEEDED': 'Batas pindaian harian tercapai. Coba lagi besok',
    'RECOMMENDATION_FAILED': 'Gagal memuat rekomendasi. Coba lagi nanti',
    'NO_RECOMMENDATIONS': 'Belum ada rekomendasi yang tersedia',
    'INVALID_FOOD_DATA': 'Data makanan tidak lengkap',

    // Meal logging
    'LOG_FAILED': 'Gagal menyimpan catatan makan. Coba lagi',
    'LOG_LIMIT_EXCEEDED': 'Anda sudah mencatat terlalu banyak hari ini',
    'DUPLICATE_LOG': 'Makanan ini sudah dicatat sebelumnya',

    // Cloudinary & Files
    'UPLOAD_FAILED': 'Gagal mengunggah gambar. Periksa koneksi Anda',
    'INVALID_FILE_TYPE': 'Hanya file gambar yang diizinkan',
    'FILE_TOO_LARGE': 'Ukuran gambar terlalu besar',

    // Data Errors
    'INVALID_USER_DATA': 'Data pengguna tidak valid',
    'DATA_NOT_FOUND': 'Data tidak ditemukan',
  };

  /// Get user-friendly error message from error code
  static String getErrorMessage(String? errorCode) {
    if (errorCode == null) return errorMessages['UNKNOWN_ERROR']!;
    return errorMessages[errorCode] ?? errorMessages['UNKNOWN_ERROR']!;
  }

  // ==================== Debug Information ====================

  /// Print current API configuration for debugging
  static void debugPrintConfig() {
    if (isDevelopment) {
      print('🔧 API Configuration Debug:');
      print('   Platform: $platformInfo');
      print('   Base URL: $baseUrl');
      print('   Environment: ${dotenv.env['APP_ENV'] ?? 'not set'}');
      print(
        '   API_BASE_URL from .env: ${dotenv.env['API_BASE_URL'] ?? 'not set'}',
      );
      print('   kIsWeb: $kIsWeb');
    }
  }
}
