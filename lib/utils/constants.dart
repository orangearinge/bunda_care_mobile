/// API Configuration Constants
/// Contains all API endpoints, URLs, and configuration values
class ApiConstants {
  // Prevent instantiation
  ApiConstants._();

  // ==================== Base URLs ====================
  
  /// Base URL for development (local network)
  /// IMPORTANT: Replace with your actual local network IP or ngrok URL
  /// Examples:
  /// - Local network: "http://192.168.1.10:5000"
  /// - Ngrok: "https://abc123.ngrok.io"
  /// - For Android emulator (if you use it later): "http://10.0.2.2:5000"
  static const String devBaseUrl = "http://192.168.8.228:5000";// TODO: Update this!
  
  /// Base URL for production
  static const String prodBaseUrl = "https://api.bundacare.com";
  
  /// Current environment - change to false for production
  static const bool isDevelopment = true;
  
  /// Get the active base URL based on environment
  static String get baseUrl => isDevelopment ? devBaseUrl : prodBaseUrl;

  // ==================== Auth Endpoints ====================
  
  static const String register = "/api/auth/register";
  static const String login = "/api/auth/login";
  static const String googleAuth = "/api/auth/google";
  static const String logout = "/api/auth/logout";

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
