import 'package:dio/dio.dart';
import 'dart:io';
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
            print('✅ Response [${response.statusCode}]: ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          // Log errors in debug mode
          if (ApiConstants.isDevelopment) {
            print('❌ Error: ${error.message}');
            print('   URI: ${error.requestOptions.uri}');
            print('   Response: ${error.response?.data}');
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
        // Parse backend error response
        final response = error.response;
        if (response != null && response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          
          // Check if it's our backend error format
          if (data['success'] == false && data['error'] != null) {
            return ApiError.fromJson(data);
          }
        }
        
        // Generic server error
        return ApiError.serverError(
          'Server error: ${response?.statusCode ?? "Unknown"}',
        );

      case DioExceptionType.cancel:
        return ApiError(
          code: 'REQUEST_CANCELLED',
          message: 'Request was cancelled',
        );

      default:
        return ApiError.fromException(Exception(error.message));
    }
  }
}
