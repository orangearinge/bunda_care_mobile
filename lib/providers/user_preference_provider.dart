import 'package:flutter/material.dart';
import '../models/user_preference.dart';
import '../models/api_error.dart';
import '../services/user_service.dart';

enum PreferenceStatus { initial, loading, success, error }

class UserPreferenceProvider with ChangeNotifier {
  final UserService _userService = UserService();

  PreferenceStatus _status = PreferenceStatus.initial;
  UserPreference? _currentPreference;
  String? _errorMessage;

  PreferenceStatus get status => _status;
  UserPreference? get currentPreference => _currentPreference;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == PreferenceStatus.loading;

  /// Update user preference through API
  Future<bool> updatePreference({
    required String role,
    String? name,
    String? hpht,
    required double heightCm,
    required double weightKg,
    required int ageYear,
    double? bellyCircumferenceCm,
    double? lilaCm,
    double? lactationMl,
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
        bellyCircumferenceCm: bellyCircumferenceCm,
        lilaCm: lilaCm,
        lactationMl: lactationMl,
        foodProhibitions: foodProhibitions,
        allergens: allergens,
      );

      final updatedPreference = await _userService.updatePreference(preference);
      _currentPreference = updatedPreference;
      _status = PreferenceStatus.success;

      // Update name in AuthProvider if it was provided
      if (name != null && name.isNotEmpty) {
        _updateAuthProviderName(name);
      }

      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _status = PreferenceStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage =
          'Terjadi kesalahan saat menyimpan data. Silakan coba lagi.';
      _status = PreferenceStatus.error;
      notifyListeners();
      return false;
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
      print('Could not update AuthProvider name: $e');
    }
  }

  /// Fetch user preference from API
  Future<void> fetchPreference() async {
    _status = PreferenceStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final preference = await _userService.getPreference();
      _currentPreference = preference;
      _status = PreferenceStatus.success;
      notifyListeners();
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _status = PreferenceStatus.error;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat data profil.';
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
    } catch (e) {
      _errorMessage = e.toString();
      _status = PreferenceStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Reset status
  void resetStatus() {
    _status = PreferenceStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
