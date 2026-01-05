import 'dart:io';
import 'package:dio/dio.dart';
import '../models/api_error.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Service for food-related API calls
class FoodService {
  final ApiService _api = ApiService();

  /// Scan food image
  /// POST /api/scan-food
  Future<Map<String, dynamic>> scanFood(List<int> imageBytes, String fileName) async {
    try {
      FormData formData = FormData.fromMap({
        "image": MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
        ),
      });

      final response = await _api.post(
        ApiConstants.scanFood,
        data: formData,
      );

      final data = response.data;
      if (data != null) {
        // Handle both wrapped and unwrapped data
        if (data['status'] == 'success' || data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else if (data.containsKey('candidates')) {
          return data as Map<String, dynamic>;
        }
      }
      
      throw ApiError(
        code: 'SCAN_FAILED',
        message: (data is Map) ? (data['message'] ?? 'Gagal memindai makanan') : 'Format respons tidak valid',
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError.fromException(Exception(e));
    }
  }

  /// Get food recommendations
  /// GET /api/recommendation
  Future<Map<String, dynamic>> getRecommendations({
    String? mealType,
    List<int>? detectedIds,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (mealType != null) queryParams['meal_type'] = mealType;
      
      // If we have detected IDs, we can pass them in the query or body.
      // The backend handles both. Let's use query for simplicity if not too many.
      if (detectedIds != null && detectedIds.isNotEmpty) {
        queryParams['detected_ids'] = detectedIds.join(',');
      }

      final response = await _api.get(
        ApiConstants.recommendation,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data != null) {
        // Handle both wrapped and unwrapped data
        if (data['status'] == 'success' || data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else if (data.containsKey('recommendations')) {
          return data as Map<String, dynamic>;
        }
      }

      throw ApiError(
        code: 'RECOMMENDATION_FAILED',
        message: (data is Map) ? (data['message'] ?? 'Gagal mendapatkan rekomendasi') : 'Format respons tidak valid',
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError.fromException(Exception(e));
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
        '/api/meal-log',
        data: {
          "menu_id": menuId,
          "servings": servings,
          "is_consumed": isConsumed,
        },
      );
      return response.data;
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError.fromException(Exception(e));
    }
  }

  /// Get meal logs
  /// GET /api/meal-log
  Future<List<dynamic>> getMealLogs({int limit = 50}) async {
    try {
      final response = await _api.get(
        '/api/meal-log',
        queryParameters: {"limit": limit},
      );
      final data = response.data;
      if (data != null && data['status'] == 'success' && data['data'] != null) {
        return (data['data'] as Map<String, dynamic>)['items'] ?? [];
      } else if (data != null && data['items'] != null) {
        return data['items'];
      }
      return [];
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError.fromException(Exception(e));
    }
  }

  /// Confirm a meal log as consumed
  /// POST /api/meal-log/:id/confirm
  Future<bool> confirmMeal(int mealLogId) async {
    try {
      final response = await _api.post('/api/meal-log/$mealLogId/confirm');
      return response.data?['status'] == 'success' || response.statusCode == 200;
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError.fromException(Exception(e));
    }
  }
}
