  import '../utils/constants.dart';

/// API Error model for consistent error handling
class ApiError {
  final String code;
  final String message;

  ApiError({
    required this.code,
    String? message,
  }) : message = message ?? ApiConstants.getErrorMessage(code);

  /// Create ApiError from backend error response
  /// Expected format:
  /// {
  ///   "success": false,
  ///   "error": {
  ///     "code": "ERROR_CODE",
  ///     "message": "Error message"
  ///   }
  /// }
  factory ApiError.fromJson(Map<String, dynamic> json) {
    if (json['error'] is Map<String, dynamic>) {
      final error = json['error'] as Map<String, dynamic>;
      return ApiError(
        code: error['code'] as String? ?? 'UNKNOWN_ERROR',
        message: error['message'] as String?,
      );
    }

    // Default if structure is different
    return ApiError(code: 'UNKNOWN_ERROR');
  }

  /// Create ApiError from exception
  factory ApiError.fromException(Object e) {
    return ApiError(
      code: 'UNKNOWN_ERROR',
      message: e.toString(),
    );
  }

  /// Create network error
  factory ApiError.networkError() {
    return ApiError(code: 'NETWORK_ERROR');
  }

  /// Create timeout error
  factory ApiError.timeoutError() {
    return ApiError(code: 'TIMEOUT_ERROR');
  }

  /// Create server error
  factory ApiError.serverError([String? message]) {
    return ApiError(
      code: 'SERVER_ERROR',
      message: message,
    );
  }

  @override
  String toString() {
    return 'ApiError(code: $code, message: $message)';
  }

  /// Check if the error is related to authentication (session expired, unauthorized)
  bool get isAuthError =>
      code == 'SESSION_EXPIRED' ||
      code == 'UNAUTHORIZED' ||
      code == 'TOKEN_EXPIRED' ||
      code == 'INVALID_TOKEN';

  /// Check if the error is related to network or server connectivity
  bool get isConnectionError =>
      code == 'NETWORK_ERROR' ||
      code == 'TIMEOUT_ERROR' ||
      code == 'SERVER_ERROR';
}
