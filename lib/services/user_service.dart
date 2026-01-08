import '../models/user_preference.dart';
import '../models/dashboard_summary.dart';
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
  Future<({UserPreference preference, String? token})> updatePreference(
    UserPreference preference,
  ) async {
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
      if (data != null &&
          (data['status'] == 'success' ||
              data['success'] == true ||
              data.containsKey('role') ||
              data['data'] != null)) {
        final preferenceData = data['data'] ?? data;
        final pref = UserPreference.fromJson(
          preferenceData as Map<String, dynamic>,
        );
        final token = data['token'] as String?;
        return (preference: pref, token: token);
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
      if (data != null) {
        if (data['status'] == 'success' && data['data'] != null) {
          return UserPreference.fromJson(data['data'] as Map<String, dynamic>);
        } else if (data.containsKey('role')) {
          // Direct response
          return UserPreference.fromJson(data as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      // If no preference set yet, return null instead of throwing
      if (ApiConstants.isDevelopment) {
        print('GET PREFERENCE ERROR: $e');
      }
      return null;
    }
  }

  /// Get dashboard summary
  /// GET /api/user/dashboard
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      final response = await _api.get('/api/user/dashboard');
      final data = response.data;

      if (data == null) {
        throw ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'Respon kosong dari server',
        );
      }

      // Handle both wrapped and direct responses
      if (data['status'] == 'success' && data['data'] != null) {
        return DashboardSummary.fromJson(data['data'] as Map<String, dynamic>);
      } else if (data.containsKey('user') || data.containsKey('targets')) {
        // Direct response
        return DashboardSummary.fromJson(data as Map<String, dynamic>);
      } else {
        throw ApiError(
          code: 'FETCH_FAILED',
          message: data['message'] ?? 'Gagal mengambil data dashboard',
        );
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError.fromException(Exception(e));
    }
  }

  /// Get user profile
  /// GET /api/user/profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _api.get('/api/user/profile');
      final data = response.data;
      if (data != null) {
        if (data['status'] == 'success' && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        } else if (data.containsKey('id')) {
          // Direct response
          return data as Map<String, dynamic>;
        }
      }
      throw ApiError(
        code: 'PROFILE_FETCH_FAILED',
        message: 'Gagal mengambil data profil pengguna',
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError.fromException(Exception(e));
    }
  }

  /// Update user avatar
  /// PUT /api/user/avatar
  Future<String> updateAvatar(String avatarUrl) async {
    try {
      final response = await _api.put(
        '/api/user/avatar',
        data: {'avatar': avatarUrl},
      );
      final data = response.data;
      if (data != null && data['avatar'] != null) {
        return data['avatar'] as String;
      }
      throw ApiError(
        code: 'AVATAR_UPDATE_FAILED',
        message: data?['message'] ?? 'Gagal memperbarui avatar',
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError.fromException(Exception(e));
    }
  }
}
