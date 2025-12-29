import '../models/user_preference.dart';
import '../models/api_error.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Service for user-related API calls
class UserService {
  final ApiService _api = ApiService();

  /// Constants for preference endpoint
  static const String _preferencePath = '/api/user/preference';

  /// Update user preferences
  /// POST /api/user/preference
  Future<UserPreference> updatePreference(UserPreference preference) async {
    try {
      final response = await _api.post(
        _preferencePath,
        data: preference.toJson(),
      );

      final data = response.data;
      if (ApiConstants.isDevelopment) {
        print('BACKEND RESPONSE: $data');
      }

      // Check for success status or if data looks like a preference object
      if (data != null && (data['status'] == 'success' || data['success'] == true)) {
        return UserPreference.fromJson(data['data'] as Map<String, dynamic>);
      } else if (data != null && (data.containsKey('role') || data['data'] != null)) {
        // Handle direct response (no status wrapper) or traditional data wrapper
        final preferenceData = data['data'] ?? data;
        return UserPreference.fromJson(preferenceData as Map<String, dynamic>);
      } else {
        throw ApiError(
          code: 'UPDATE_FAILED',
          message: data?['message'] ?? 'Gagal memperbarui preferensi',
        );
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError.fromException(Exception(e));
    }
  }

  /// Get current user preferences
  /// GET /api/user/preference
  Future<UserPreference?> getPreference() async {
    try {
      final response = await _api.get(_preferencePath);
      
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        return UserPreference.fromJson(data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      // If no preference set yet, return null instead of throwing
      return null;
    }
  }
}
