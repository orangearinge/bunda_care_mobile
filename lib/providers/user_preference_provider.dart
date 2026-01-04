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
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _status = PreferenceStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat menyimpan data. Silakan coba lagi.';
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
