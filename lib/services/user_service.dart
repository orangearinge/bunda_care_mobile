import '../models/user_preference.dart';
import '../models/dashboard_summary.dart';
import '../models/history_entry.dart';
import '../models/api_error.dart';
import '../utils/constants.dart';
import '../utils/cache_config.dart';
import '../utils/error_handler.dart';
import '../utils/logger.dart';
import 'api_service.dart';

/// Service for user-related API calls
class UserService {
  final ApiService _api = ApiService();

  /// Update user preferences
  /// POST /api/user/preference
  Future<({UserPreference preference, String? token})> updatePreference(
    UserPreference preference,
  ) async {
    try {
      final response = await _api.post(
        ApiConstants.userPreference,
        data: preference.toJson(),
      );

      final data = response.data;
      AppLogger.d('BACKEND RESPONSE: $data');

      final unwrapped = _api.unwrap(response);
      if (unwrapped is Map<String, dynamic>) {
        final pref = UserPreference.fromJson(unwrapped);
        final token = data['token'] as String?;
        
        // Invalidate user preference cache after update
        await _api.clearCacheForUrl(ApiConstants.userPreference);
        await _api.clearCacheForUrl(ApiConstants.userProfile);
        
        return (preference: pref, token: token);
      } else {
        throw ApiError(
          code: 'UPDATE_FAILED',
          message: 'Format respons tidak valid',
        );
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Get current user preferences
  /// GET /api/user/preference
  Future<UserPreference?> getPreference({bool forceRefresh = false}) async {
    try {
      final cacheOptions = forceRefresh
          ? _api.getCacheOptions(CacheConfig.forceRefresh)
          : _api.getCacheOptions(CacheConfig.userProfile);

      final response = await _api.get(
        ApiConstants.userPreference,
        options: _api.applyCacheOptions(cacheOptions),
      );
      final data = _api.unwrap(response);
      
      if (data != null && data is Map<String, dynamic> && data.containsKey('role')) {
        return UserPreference.fromJson(data);
      }
      return null;
    } catch (e) {
      AppLogger.e('GET PREFERENCE ERROR', e);
      return null;
    }
  }

  /// Get dashboard summary
  /// GET /api/user/dashboard
  Future<DashboardSummary> getDashboardSummary({bool forceRefresh = false}) async {
    try {
      final cacheOptions = forceRefresh
          ? _api.getCacheOptions(CacheConfig.forceRefresh)
          : _api.getCacheOptions(CacheConfig.dashboard);

      final response = await _api.get(
        ApiConstants.userDashboard,
        options: _api.applyCacheOptions(cacheOptions),
      );
      final data = _api.unwrap(response);

      if (data == null) {
        throw ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'Respon kosong dari server',
        );
      }

      if (data is Map<String, dynamic>) {
        return DashboardSummary.fromJson(data);
      }
      
      throw ApiError(
        code: 'FETCH_FAILED',
        message: 'Format data dashboard tidak valid',
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Get user profile
  /// GET /api/user/profile
  Future<Map<String, dynamic>> getUserProfile({bool forceRefresh = false}) async {
    try {
      final cacheOptions = forceRefresh
          ? _api.getCacheOptions(CacheConfig.forceRefresh)
          : _api.getCacheOptions(CacheConfig.userProfile);

      final response = await _api.get(
        ApiConstants.userProfile,
        options: _api.applyCacheOptions(cacheOptions),
      );
      final data = _api.unwrap(response);

      if (data != null && data is Map<String, dynamic>) {
        return data;
      }
      
      throw ApiError(
        code: 'PROFILE_FETCH_FAILED',
        message: 'Gagal mengambil data profil pengguna',
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Update user avatar
  /// PUT /api/user/avatar
  Future<String> updateAvatar(String avatarUrl) async {
    try {
      final response = await _api.put(
        ApiConstants.userAvatar,
        data: {'avatar': avatarUrl},
      );
      final data = _api.unwrap(response);
      
      if (data != null && data is Map<String, dynamic> && data['avatar'] != null) {
        // Invalidate profile cache after avatar update
        await _api.clearCacheForUrl(ApiConstants.userProfile);
        return data['avatar'] as String;
      }
      throw ApiError(
        code: 'AVATAR_UPDATE_FAILED',
        message: 'Gagal memperbarui avatar',
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Get nutritional history
  /// GET /api/user/history
  Future<List<HistoryEntry>> getHistory() async {
    try {
      final response = await _api.get(ApiConstants.userHistory);
      final data = _api.unwrap(response);

      if (data == null) return [];

      final List<dynamic> listData = data is List ? data : [];

      return listData
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Get nutritional history detail
  /// GET /api/user/history/<date_str>
  Future<List<HistoryDetailItem>> getHistoryDetail(String dateStr) async {
    try {
      final response = await _api.get('${ApiConstants.userHistory}/$dateStr');
      final data = _api.unwrap(response);

      if (data == null) return [];

      final List<dynamic> listData = data is List ? data : [];

      return listData
          .map((e) => HistoryDetailItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
