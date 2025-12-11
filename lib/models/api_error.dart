/// API Error model for consistent error handling
class ApiError {
  final String code;
  final String message;

  ApiError({
    required this.code,
    required this.message,
  });

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
    final error = json['error'] as Map<String, dynamic>;
    return ApiError(
      code: error['code'] as String,
      message: error['message'] as String,
    );
  }

  /// Create ApiError from exception
  factory ApiError.fromException(Exception e) {
    return ApiError(
      code: 'UNKNOWN_ERROR',
      message: e.toString(),
    );
  }

  /// Create network error
  factory ApiError.networkError() {
    return ApiError(
      code: 'NETWORK_ERROR',
      message: 'No internet connection. Please check your network',
    );
  }

  /// Create timeout error
  factory ApiError.timeoutError() {
    return ApiError(
      code: 'TIMEOUT_ERROR',
      message: 'Connection timeout. Please try again',
    );
  }

  /// Create server error
  factory ApiError.serverError([String? message]) {
    return ApiError(
      code: 'SERVER_ERROR',
      message: message ?? 'Something went wrong. Please try again later',
    );
  }

  @override
  String toString() {
    return 'ApiError(code: $code, message: $message)';
  }
}
