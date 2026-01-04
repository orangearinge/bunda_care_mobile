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
  Future<Map<String, dynamic>> scanFood(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          imageFile.path,
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
}
