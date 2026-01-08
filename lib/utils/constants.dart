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
    'VALIDATION_ERROR': 'Please fill all required fields',
    'INVALID_CREDENTIALS': 'Email or password incorrect',
    'EMAIL_IN_USE': 'This email is already registered',
    'INVALID_TOKEN': 'Google sign-in failed. Please try again',
    'NETWORK_ERROR': 'No internet connection. Please check your network',
    'TIMEOUT_ERROR': 'Connection timeout. Please try again',
    'SERVER_ERROR': 'Something went wrong. Please try again later',
    'UNKNOWN_ERROR': 'An unexpected error occurred',

    // Auth-specific additions
    'ACCOUNT_NOT_VERIFIED': 'Please verify your email before logging in',
    'PASSWORD_TOO_WEAK': 'Password must be at least 8 characters long',
    'LOGOUT_FAILED': 'Logout failed. Please try again',
    'GOOGLE_AUTH_CANCELLED': 'Google sign-in was cancelled. Please try again',

    // Food scanning feature
    'SCAN_FAILED':
        'Food scanning failed. Please try again with a clearer image',
    'FOOD_NOT_RECOGNIZED':
        'We couldn\'t identify the food. Please try a different photo',
    'SCAN_LIMIT_EXCEEDED': 'Too many scans today. Please try again tomorrow',

    // Recommendation feature
    'RECOMMENDATION_FAILED':
        'Unable to generate recommendations. Please try again later',
    'NO_RECOMMENDATIONS':
        'No recommendations available right now. Check back soon',
    'INVALID_FOOD_DATA': 'Food data is incomplete. Please scan again',

    // Meal logging feature
    'LOG_FAILED': 'Failed to save your meal. Please try again',
    'LOG_LIMIT_EXCEEDED': 'You\'ve logged too many meals today. Take a break!',
    'DUPLICATE_LOG': 'This meal was already logged. Try editing instead',

    // Cloudinary upload feature
    'UPLOAD_FAILED':
        'Image upload failed. Please check your connection and try again',
    'INVALID_FILE_TYPE': 'Only image files are allowed. Please choose a photo',
    'FILE_TOO_LARGE': 'Image is too large. Please use a smaller file',
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
