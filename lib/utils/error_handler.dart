import 'package:dio/dio.dart';
import '../models/api_error.dart';
import 'logger.dart';

class ErrorHandler {
  static ApiError handle(dynamic error) {
    if (error is ApiError) return error;

    if (error is DioException) {
      AppLogger.e('DIO_ERROR: [${error.type}] ${error.message}', error, error.stackTrace);
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiError.timeoutError();
        case DioExceptionType.connectionError:
          return ApiError.networkError();
        case DioExceptionType.badResponse:
          final response = error.response;
          if (response != null) {
            if (response.data is Map<String, dynamic>) {
              final data = response.data as Map<String, dynamic>;
              if (data['error'] != null) {
                return ApiError.fromJson(data);
              }
            }
            switch (response.statusCode) {
              case 400:
                return ApiError(code: 'VALIDATION_ERROR');
              case 401:
                return ApiError(code: 'SESSION_EXPIRED');
              case 403:
                return ApiError(code: 'UNAUTHORIZED');
              case 404:
                return ApiError(code: 'DATA_NOT_FOUND');
              case 500:
                return ApiError(code: 'SERVER_ERROR');
            }
          }
          return ApiError.serverError(
            'Error ${response?.statusCode}: ${error.message}',
          );
        case DioExceptionType.cancel:
          return ApiError(code: 'REQUEST_CANCELLED');
        default:
          return ApiError.fromException(error);
      }
    }

    AppLogger.e('UNKNOWN_ERROR: $error', error);
    return ApiError.fromException(error);
  }
}
