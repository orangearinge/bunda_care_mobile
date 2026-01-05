import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration Constants
/// Contains all API endpoints, URLs, and configuration values
/// Values are loaded from .env file via flutter_dotenv
class ApiConstants {
  // Prevent instantiation
  ApiConstants._();

  // ==================== Environment = :===================
  
  /// Base URL for the API
  /// Loaded from .env (API_BASE_URL)
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url != null) return url;
    
    // Fallback logic
    if (kIsWeb) return "http://127.0.0.1:5000";
    return "http://10.0.2.2:5000"; // Android Emulator default
  }

  /// Current environment status
  static bool get isDevelopment => dotenv.env['APP_ENV'] != 'production';

  // ==================== Cloudinary ====================
  
  static String get cloudinaryCloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'demo';
  static String get cloudinaryUploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'ml_default';
  static String get cloudinaryFolder => dotenv.env['CLOUDINARY_FOLDER'] ?? 'bunda_care/avatars';

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
  };

  /// Get user-friendly error message from error code
  static String getErrorMessage(String? errorCode) {
    if (errorCode == null) return errorMessages['UNKNOWN_ERROR']!;
    return errorMessages[errorCode] ?? errorMessages['UNKNOWN_ERROR']!;
  }
}
