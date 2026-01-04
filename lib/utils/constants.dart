import 'package:flutter/foundation.dart';

/// API Configuration Constants
/// Contains all API endpoints, URLs, and configuration values
class ApiConstants {
  // Prevent instantiation
  ApiConstants._();

  // ==================== Base URLs ====================

  /// Base URL for development (local network)
  /// IMPORTANT: Replace with your actual local network IP or ngrok URL
  /// Examples:
  /// - Android Emulator: "http://10.0.2.2:5000"
  /// - Physical Device (USB via 'adb reverse tcp:5000 tcp:5000'): "http://127.0.0.1:5000"
  /// - Physical Device (WiFi): "http://<YOUR_LAN_IP>:5000" (e.g. 192.168.1.5)
  static const String devBaseUrl = "http://192.168.8.228:5000"; // GANTI dengan IP laptop Anda jika pakai WiFi

  /// Base URL for production
  static const String prodBaseUrl = "https://api.bundacare.com";

  /// Current environment - change to false for production
  static const bool isDevelopment = true;

  /// Base URL for Web Development
  /// Note: Web browsers enforce CORS. Your backend must allow requests from the Flutter Web port.
  static const String webDevBaseUrl = "http://127.0.0.1:5000";

  /// Get the active base URL based on environment and platform
  static String get baseUrl {
    if (kIsWeb && isDevelopment) {
      return webDevBaseUrl;
    }
    return isDevelopment ? devBaseUrl : prodBaseUrl;
  }

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
