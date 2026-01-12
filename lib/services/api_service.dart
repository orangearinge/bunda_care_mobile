import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/api_error.dart';
import 'storage_service.dart';

/// Base API service with Dio HTTP client
/// Provides interceptors for authentication and error handling
class ApiService {
  late final Dio _dio;
  final StorageService _storage = StorageService();

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add request interceptor to attach JWT token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to headers if it exists
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log successful responses in debug mode
          if (ApiConstants.isDevelopment) {
            print('✅ [${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          // Log errors in debug mode
          if (ApiConstants.isDevelopment) {
            print('❌ [${error.response?.statusCode ?? "ERR"}] ${error.requestOptions.method} ${error.requestOptions.path}');
            print('   Message: ${error.message}');
            if (error.response?.data != null) {
              print('   Data: ${error.response?.data}');
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Get the Dio instance
  Dio get client => _dio;

  // ==================== HTTP Methods ====================

  /// Generic GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Error Handling ====================

  /// Handle Dio errors and convert to ApiError
  ApiError _handleError(DioException error) {
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
          // 1. Try to parse backend error format first
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data['error'] != null) {
              return ApiError.fromJson(data);
            }
          }

          // 2. Handle specific HTTP status codes if no backend error format
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
}
