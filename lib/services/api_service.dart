import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../utils/logger.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;
  CacheStore? _cacheStore;
  final StorageService _storage = StorageService();
  bool _cacheInitialized = false;
  bool _isCacheInitializing = false;
  final Completer<void> _cacheCompleter = Completer<void>();

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
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

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
          final fromCache =
              response.extra['dio_cache_interceptor_response'] == true;
          final cacheIndicator = fromCache ? '💾' : '🌐';
          AppLogger.d(
            '✅ $cacheIndicator [${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.e(
            '❌ [${error.response?.statusCode ?? "ERR"}] ${error.requestOptions.method} ${error.requestOptions.path}',
            error,
          );
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _ensureCacheInitialized() async {
    if (_cacheInitialized) return;
    if (!_cacheCompleter.isCompleted) {
      await _cacheCompleter.future;
    }
  }

  Future<void> _setupCache() async {
    if (_cacheInitialized || _isCacheInitializing) return;
    _isCacheInitializing = true;

    try {
      String? cachePath;
      if (!kIsWeb) {
        final cacheDir = await getTemporaryDirectory();
        cachePath = cacheDir.path;
      }
      
      _cacheStore = HiveCacheStore(
        cachePath,
        hiveBoxName: 'bunda_care_cache',
      );

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
            allowPostMethod: false,
          ),
        ),
      );
      _cacheInitialized = true;
    } catch (e) {
      AppLogger.w('⚠️ Failed to initialize cache: $e');
    } finally {
      if (!_cacheCompleter.isCompleted) {
        _cacheCompleter.complete();
      }
    }
  }

  Dio get client => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!_cacheInitialized) {
      unawaited(_setupCache());
    }
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!_cacheInitialized) {
      unawaited(_setupCache());
    }
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!_cacheInitialized) {
      unawaited(_setupCache());
    }
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!_cacheInitialized) {
      unawaited(_setupCache());
    }
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  dynamic unwrap(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['status'] == 'success' || data['success'] == true) {
        return data['data'] ?? data;
      }
    }
    return data;
  }



  Future<void> clearAllCache() async {
    await _ensureCacheInitialized();
    if (_cacheStore == null) return;
    try {
      await _cacheStore!.clean();
      AppLogger.i('🗑️ Cache cleared successfully');
    } catch (e) {
      AppLogger.e('❌ Failed to clear cache', e);
    }
  }

  Future<void> clearCacheForUrl(String url) async {
    await _ensureCacheInitialized();
    if (_cacheStore == null) return;
    try {
      // Key is the full URL or a partial key depending on how keyBuilder works
      // The default use the URI itself as key base
      final baseUrl = _dio.options.baseUrl;
      final fullUrl = url.startsWith('http') ? url : '$baseUrl$url';
      
      final key = CacheOptions.defaultCacheKeyBuilder(
        RequestOptions(path: fullUrl, baseUrl: baseUrl),
      );
      
      await _cacheStore!.delete(key);
      AppLogger.i('🗑️ Cache cleared for: $fullUrl (key: $key)');
    } catch (e) {
      AppLogger.e('❌ Failed to clear cache for URL', e);
    }
  }

  Options applyCacheOptions(CacheOptions cacheOptions, {Options? options}) {
    final opts = options ?? Options();
    return opts.copyWith(extra: {...?opts.extra, ...cacheOptions.toExtra()});
  }

  CacheOptions getCacheOptions(CacheOptions template) {
    if (_cacheStore == null) {
      return template.copyWith(policy: CachePolicy.noCache);
    }
    return template.copyWith(store: _cacheStore);
  }
}
