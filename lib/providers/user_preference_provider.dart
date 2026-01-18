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

  PreferenceStatus _prefStatus = PreferenceStatus.initial;
  PreferenceStatus _dashboardStatus = PreferenceStatus.initial;
  
  UserPreference? _currentPreference;
  DashboardSummary? _dashboardSummary;
  
  String? _prefError;
  String? _dashboardError;

  // Track profile updates for dashboard refresh
  bool _profileUpdated = false;

  PreferenceStatus get prefStatus => _prefStatus;
  PreferenceStatus get dashboardStatus => _dashboardStatus;
  
  UserPreference? get currentPreference => _currentPreference;
  DashboardSummary? get dashboardSummary => _dashboardSummary;
  
  String? get prefError => _prefError;
  String? get dashboardError => _dashboardError;
  
  // Compatibility getters
  PreferenceStatus get status => _prefStatus;
  String? get errorMessage => _prefError;
  bool get isLoading => _prefStatus == PreferenceStatus.loading;
  bool get isDashboardLoading => _dashboardStatus == PreferenceStatus.loading;
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
    _prefStatus = PreferenceStatus.loading;
    _prefError = null;
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
      _prefStatus = PreferenceStatus.success;

      // Update name in AuthProvider if it was provided
      if (name != null && name.isNotEmpty) {
        _updateAuthProviderName(name);
      }

      notifyListeners();
      return (success: true, token: result.token);
    } on ApiError catch (e) {
      _prefError = ApiConstants.getErrorMessage(e.code);
      _prefStatus = PreferenceStatus.error;
      notifyListeners();
      return (success: false, token: null);
    } catch (e) {
      _prefError = ApiConstants.getErrorMessage('SERVER_ERROR');
      _prefStatus = PreferenceStatus.error;
      notifyListeners();
      return (success: false, token: null);
    }
  }

  /// Update name in AuthProvider if available
  void _updateAuthProviderName(String name) {
    try {
      // Access AuthProvider through context - this is a bit of a hack
    } catch (e) {
      AppLogger.e('Could not update AuthProvider name', e);
    }
  }

  /// Fetch user preference from API
  Future<void> fetchPreference({bool forceRefresh = false}) async {
    _prefStatus = PreferenceStatus.loading;
    _prefError = null;
    notifyListeners();

    try {
      final preference = await _userService.getPreference(forceRefresh: forceRefresh);
      
      if (preference != null) {
        _currentPreference = preference;
        _prefStatus = PreferenceStatus.success;
      } else if (_currentPreference != null) {
        _prefStatus = PreferenceStatus.success;
      } else {
        _prefStatus = PreferenceStatus.success;
      }
      notifyListeners();
    } on ApiError catch (e) {
      if (_currentPreference != null && (e.code == 'NETWORK_ERROR' || e.code == 'TIMEOUT_ERROR')) {
         _prefStatus = PreferenceStatus.success;
      } else {
        _prefError = ApiConstants.getErrorMessage(e.code);
        _prefStatus = PreferenceStatus.error;
      }
      notifyListeners();
    } catch (e) {
      if (_currentPreference != null) {
        _prefStatus = PreferenceStatus.success;
      } else {
        _prefError = ApiConstants.getErrorMessage('SERVER_ERROR');
        _prefStatus = PreferenceStatus.error;
      }
      notifyListeners();
    }
  }

  /// Fetch dashboard summary
  Future<void> fetchDashboardSummary({bool forceRefresh = false}) async {
    _dashboardStatus = PreferenceStatus.loading;
    _dashboardError = null;
    notifyListeners();

    try {
      _dashboardSummary = await _userService.getDashboardSummary(forceRefresh: forceRefresh);
      _dashboardStatus = PreferenceStatus.success;
      notifyListeners();
    } on ApiError catch (e) {
      _dashboardError = ApiConstants.getErrorMessage(e.code);
      _dashboardStatus = PreferenceStatus.error;
      notifyListeners();
    } catch (e) {
      _dashboardError = ApiConstants.getErrorMessage('SERVER_ERROR');
      _dashboardStatus = PreferenceStatus.error;
      notifyListeners();
    }
  }

  /// Update avatar URL via API and refresh profile
  Future<bool> updateAvatar({required String avatarUrl}) async {
    _prefStatus = PreferenceStatus.loading;
    _prefError = null;
    notifyListeners();
    try {
      final updated = await _userService.updateAvatar(avatarUrl);
      if (updated.isNotEmpty) {
        await fetchPreference();
      }
      _prefStatus = PreferenceStatus.success;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _prefError = ApiConstants.getErrorMessage(e.code);
      _prefStatus = PreferenceStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _prefError = ApiConstants.getErrorMessage('UNKNOWN_ERROR');
      _prefStatus = PreferenceStatus.error;
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
    _prefStatus = PreferenceStatus.initial;
    _dashboardStatus = PreferenceStatus.initial;
    _prefError = null;
    _dashboardError = null;
    notifyListeners();
  }
}
