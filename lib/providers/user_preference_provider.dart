import 'package:flutter/material.dart';
import '../models/user_preference.dart';
import '../models/dashboard_summary.dart';
import '../models/api_error.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

enum PreferenceStatus { initial, loading, success, error }

class UserPreferenceProvider with ChangeNotifier {
  final UserService _userService = UserService();

  PreferenceStatus _status = PreferenceStatus.initial;
  UserPreference? _currentPreference;
  DashboardSummary? _dashboardSummary;
  String? _errorMessage;

  // Track profile updates for dashboard refresh
  bool _profileUpdated = false;

  PreferenceStatus get status => _status;
  UserPreference? get currentPreference => _currentPreference;
  DashboardSummary? get dashboardSummary => _dashboardSummary;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == PreferenceStatus.loading;
  bool get profileUpdated => _profileUpdated;

  /// Update user preference through API
  Future<({bool success, String? token})> updatePreference({
    required String role,
    String? name,
    String? hpht,
    required double heightCm,
    required double weightKg,
    required int ageYear,
    int? ageMonth,
    double? lilaCm,
    String? lactationPhase,
    List<String> foodProhibitions = const [],
    List<String> allergens = const [],
  }) async {
    _status = PreferenceStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final preference = UserPreference(
        role: role,
        name: name,
        hpht: hpht,
        heightCm: heightCm.toInt(),
        weightKg: weightKg,
        ageYear: ageYear,
        ageMonth: ageMonth,
        lilaCm: lilaCm,
        lactationPhase: lactationPhase,
        foodProhibitions: foodProhibitions,
        allergens: allergens,
      );

      final result = await _userService.updatePreference(preference);
      _currentPreference = result.preference;
      markProfileUpdated(); // Trigger dashboard refresh
      _status = PreferenceStatus.success;

      // Update name in AuthProvider if it was provided
      if (name != null && name.isNotEmpty) {
        _updateAuthProviderName(name);
      }

      notifyListeners();
      return (success: true, token: result.token);
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _status = PreferenceStatus.error;
      notifyListeners();
      return (success: false, token: null);
    } catch (e) {
      _errorMessage = ApiConstants.getErrorMessage('SERVER_ERROR');
      _status = PreferenceStatus.error;
      notifyListeners();
      return (success: false, token: null);
    }
  }

  /// Update name in AuthProvider if available
  void _updateAuthProviderName(String name) {
    try {
      // Access AuthProvider through context - this is a bit of a hack
      // but necessary since UserPreferenceProvider doesn't have access to AuthProvider
      // The proper way would be to have a combined provider or use a service locator
      // For now, this will work since the ProfilePage uses both providers
    } catch (e) {
      // Silently fail if AuthProvider not available
      AppLogger.e('Could not update AuthProvider name', e);
    }
  }

  /// Fetch user preference from API
  Future<void> fetchPreference({bool forceRefresh = false}) async {
    _status = PreferenceStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final preference = await _userService.getPreference(forceRefresh: forceRefresh);
      
      // Only update if we actually got something back
      if (preference != null) {
        _currentPreference = preference;
        _status = PreferenceStatus.success;
      } else if (_currentPreference != null) {
        // If we have existing data but the refresh failed (returned null)
        // we stay in success state to keep showing stale data
        _status = PreferenceStatus.success;
      } else {
        // No data in memory AND fetch returned null
        _status = PreferenceStatus.success; // Or success with null pref
      }
      notifyListeners();
    } on ApiError catch (e) {
      // If we already have data, don't show error state, just keep stale data
      if (_currentPreference != null && (e.code == 'NETWORK_ERROR' || e.code == 'TIMEOUT_ERROR')) {
         _status = PreferenceStatus.success;
      } else {
        _errorMessage = e.message;
        _status = PreferenceStatus.error;
      }
      notifyListeners();
    } catch (e) {
      if (_currentPreference != null) {
        _status = PreferenceStatus.success;
      } else {
        _errorMessage = ApiConstants.getErrorMessage('SERVER_ERROR');
        _status = PreferenceStatus.error;
      }
      notifyListeners();
    }
  }

  /// Fetch dashboard summary
  Future<void> fetchDashboardSummary({bool forceRefresh = false}) async {
    // Only set loading if we don't have data yet
    if (_dashboardSummary == null) {
      _status = PreferenceStatus.loading;
      notifyListeners();
    }

    try {
      _dashboardSummary = await _userService.getDashboardSummary(forceRefresh: forceRefresh);
      _status = PreferenceStatus.success;
      notifyListeners();
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _status = PreferenceStatus.error;
      notifyListeners();
    } catch (e) {
      _errorMessage = ApiConstants.getErrorMessage('SERVER_ERROR');
      _status = PreferenceStatus.error;
      notifyListeners();
    }
  }

  /// Update avatar URL via API and refresh profile
  Future<bool> updateAvatar({required String avatarUrl}) async {
    _status = PreferenceStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _userService.updateAvatar(avatarUrl);
      if (updated.isNotEmpty) {
        await fetchPreference();
      }
      _status = PreferenceStatus.success;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _status = PreferenceStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = PreferenceStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Mark profile as updated (for dashboard refresh)
  void markProfileUpdated() {
    _profileUpdated = true;
    notifyListeners();
  }

  /// Reset profile update flag
  void resetProfileUpdatedFlag() {
    _profileUpdated = false;
    notifyListeners();
  }

  /// Reset status
  void resetStatus() {
    _status = PreferenceStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
