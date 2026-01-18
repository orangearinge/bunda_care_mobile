import 'package:dio/dio.dart';
import '../models/api_error.dart';
import '../models/food_detail.dart';
import '../utils/constants.dart';
import '../utils/cache_config.dart';
import '../utils/error_handler.dart';
import 'api_service.dart';


/// Service for food-related API calls
class FoodService {
  final ApiService _api = ApiService();

  /// Scan food image
  /// POST /api/scan-food
  Future<Map<String, dynamic>> scanFood(
    List<int> imageBytes,
    String fileName,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        "image": MultipartFile.fromBytes(imageBytes, filename: fileName),
      });

      // Food scanning might take longer, use 60s timeout
      final response = await _api.post(
        ApiConstants.scanFood,
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final data = _api.unwrap(response);
      if (data != null && data is Map<String, dynamic>) {
        return data;
      }

      throw ApiError(
        code: 'SCAN_FAILED',
        message: ApiConstants.getErrorMessage('SCAN_FAILED'),
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Get food recommendations
  /// GET /api/recommendation
  Future<Map<String, dynamic>> getRecommendations({
    String? mealType,
    List<int>? detectedIds,
    bool forceRefresh = false,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (mealType != null) queryParams['meal_type'] = mealType;

      if (detectedIds != null && detectedIds.isNotEmpty) {
        queryParams['detected_ids'] = detectedIds.join(',');
      }

      final cacheOptions = forceRefresh
          ? _api.getCacheOptions(CacheConfig.forceRefresh)
          : _api.getCacheOptions(CacheConfig.recommendations);

      final response = await _api.get(
        ApiConstants.recommendation,
        queryParameters: queryParams,
        options: _api.applyCacheOptions(cacheOptions),
      );

      final data = _api.unwrap(response);
      if (data != null && data is Map<String, dynamic>) {
        return data;
      }

      throw ApiError(
        code: 'RECOMMENDATION_FAILED',
        message: ApiConstants.getErrorMessage('RECOMMENDATION_FAILED'),
      );
    } catch (e) {
       // If it fails due to network/timeout, return empty data or let cache handle it
      if (e is ApiError && (e.code == 'NETWORK_ERROR' || e.code == 'TIMEOUT_ERROR')) {
        return {};
      }
      throw ErrorHandler.handle(e);
    }
  }

  /// Get food/menu detail by ID
  /// GET /api/menus/:id
  Future<FoodDetail> getFoodDetail(int menuId, {bool forceRefresh = false}) async {
    try {
      final cacheOptions = forceRefresh
          ? _api.getCacheOptions(CacheConfig.forceRefresh)
          : _api.getCacheOptions(CacheConfig.foodDetails);

      final response = await _api.get(
        '${ApiConstants.menuDetail}/$menuId',
        options: _api.applyCacheOptions(cacheOptions),
      );
      final data = _api.unwrap(response);

      if (data != null && data is Map<String, dynamic>) {
        return FoodDetail.fromJson(data);
      }

      throw ApiError(
        code: 'MENU_NOT_FOUND',
        message: 'Detail makanan tidak ada',
      );
    } catch (e) {
      // Allow detail to be null if network error (might be in cache)
      if (e is ApiError && (e.code == 'NETWORK_ERROR' || e.code == 'TIMEOUT_ERROR')) {
        // We throw so the provider knows it's an error, 
        // but it could potentially be caught and handled if we want to show stale data.
        // Actually, let's throw but make sure the provider handles it nicely.
      }
      throw ErrorHandler.handle(e);
    }
  }

  /// Log a meal (Wishlist or consumed)
  /// POST /api/meal-log
  Future<Map<String, dynamic>> logMeal({
    required int menuId,
    double servings = 1.0,
    bool isConsumed = false,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.mealLog,
        data: {
          "menu_id": menuId,
          "servings": servings,
          "is_consumed": isConsumed,
        },
      );
      return _api.unwrap(response);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Get meal logs
  /// GET /api/meal-log
  Future<List<dynamic>> getMealLogs({int limit = 50}) async {
    try {
      final response = await _api.get(
        ApiConstants.mealLog,
        queryParameters: {"limit": limit},
      );
      final data = _api.unwrap(response);
      
      if (data != null && data is Map<String, dynamic>) {
        return data['items'] ?? [];
      } else if (data is List) {
        return data;
      }
      return [];
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Confirm a meal log as consumed
  /// POST /api/meal-log/:id/confirm
  Future<bool> confirmMeal(int mealLogId) async {
    try {
      final response = await _api.post('${ApiConstants.mealLog}/$mealLogId/confirm');
      return response.statusCode == 200;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
