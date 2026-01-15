import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/constants.dart';
import '../models/api_error.dart';
import 'storage_service.dart';

/// Base API service with Dio HTTP client
/// Provides interceptors for authentication, caching, and error handling
class ApiService {
  late final Dio _dio;
  CacheStore? _cacheStore;
  final StorageService _storage = StorageService();

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    // Sync initialization of _dio to prevent LateInitializationError
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    // Add logging and auth interceptor immediately
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (ApiConstants.isDevelopment) {
            final fromCache = response.extra['dio_cache_interceptor_response'] == true;
            final cacheIndicator = fromCache ? '💾' : '🌐';
            print('✅ $cacheIndicator [${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (ApiConstants.isDevelopment) {
            print('❌ [${error.response?.statusCode ?? "ERR"}] ${error.requestOptions.method} ${error.requestOptions.path}');
          }
          return handler.next(error);
        },
      ),
    );

    // Deferred async initialization for cache
    _setupCache();
  }

  /// Setup cache store and add interceptor when ready
  Future<void> _setupCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      _cacheStore = HiveCacheStore(
        cacheDir.path,
        hiveBoxName: 'bunda_care_cache',
      );

      // Add cache interceptor to the existing Dio instance
      // We insert at index 0 to ensure it catches requests early
      _dio.interceptors.insert(
        0,
        DioCacheInterceptor(
          options: CacheOptions(
            store: _cacheStore,
            policy: CachePolicy.request,
            hitCacheOnErrorExcept: [401, 403],
            maxStale: const Duration(days: 7),
            priority: CachePriority.normal,
            keyBuilder: CacheOptions.defaultCacheKeyBuilder,
          ),
        ),
      );
    } catch (e) {
      if (ApiConstants.isDevelopment) {
        print('⚠️ Failed to initialize cache: $e');
      }
    }
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

  // ==================== Data Parsing ====================

  /// Standardize data extraction from potential wrapped responses
  /// Backend often returns: { "status": "success", "data": ... }
  /// This helper extracts the 'data' part if it exists, or returns the raw data
  dynamic unwrap(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['status'] == 'success' || data['success'] == true) {
        return data['data'] ?? data;
      }
    }
    return data;
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

  // ==================== Cache Management ====================

  /// Clear all cached data
  Future<void> clearAllCache() async {
    if (_cacheStore == null) return;
    try {
      await _cacheStore!.clean();
      if (ApiConstants.isDevelopment) {
        print('🗑️ Cache cleared successfully');
      }
    } catch (e) {
      if (ApiConstants.isDevelopment) {
        print('❌ Failed to clear cache: $e');
      }
    }
  }

  /// Clear cache for specific URL
  Future<void> clearCacheForUrl(String url) async {
    if (_cacheStore == null) return;
    try {
      await _cacheStore!.delete(url);
      if (ApiConstants.isDevelopment) {
        print('🗑️ Cache cleared for: $url');
      }
    } catch (e) {
      if (ApiConstants.isDevelopment) {
        print('❌ Failed to clear cache for URL: $e');
      }
    }
  }

  /// Apply custom cache options to existing options
  Options applyCacheOptions(CacheOptions cacheOptions, {Options? options}) {
    final opts = options ?? Options();
    return opts.copyWith(
      extra: {
        ...?opts.extra,
        ...cacheOptions.toExtra(),
      },
    );
  }

  /// Get cache options with store configured
  CacheOptions getCacheOptions(CacheOptions template) {
    if (_cacheStore == null) {
      // Return template with noCache policy if store isn't ready
      return template.copyWith(policy: CachePolicy.noCache);
    }
    return template.copyWith(store: _cacheStore);
  }
}
