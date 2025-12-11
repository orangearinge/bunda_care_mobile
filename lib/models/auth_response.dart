import 'user.dart';
import 'api_error.dart';

/// Authentication response model
/// Wraps the backend response containing token and user data
class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  /// Create AuthResponse from backend JSON success response
  /// Supports multiple formats:
  /// Format 1: { "success": true, "data": { "token": "...", "user": {...} } }
  /// Format 2: { "token": "...", "user": {...} } (direct data)
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data;

    // Check if response has "data" wrapper
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    } else {
      // Assume direct format without wrapper
      data = json;
    }

    final token = data['token'];
    if (token == null || token is! String) {
      throw ApiError(
        code: 'INVALID_TOKEN',
        message: 'Invalid token in response',
      );
    }

    final userData = data['user'];
    if (userData == null || userData is! Map<String, dynamic>) {
      throw ApiError(
        code: 'INVALID_USER_DATA',
        message: 'Invalid user data in response',
      );
    }

    return AuthResponse(
      token: token,
      user: User.fromJson(userData),
    );
  }

  /// Alternative factory for direct data (without "data" wrapper)
  factory AuthResponse.fromData(Map<String, dynamic> data) {
    return AuthResponse(
      token: data['token'] as String,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() {
    return 'AuthResponse(token: ${token.substring(0, 10)}..., user: $user)';
  }
}
