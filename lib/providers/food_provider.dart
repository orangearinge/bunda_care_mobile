import 'dart:io';
import 'package:flutter/material.dart';
import '../models/api_error.dart';
import '../services/food_service.dart';
import '../utils/constants.dart';

enum FoodStatus { initial, loading, success, error }

class FoodProvider with ChangeNotifier {
  final FoodService _foodService = FoodService();

  FoodStatus _status = FoodStatus.initial;
  Map<String, dynamic>? _scanResults;
  Map<String, dynamic>? _recommendations;
  List<dynamic> _mealLogs = [];
  dynamic _selectedFoodDetail;
  String? _errorMessage;

  FoodStatus get status => _status;
  Map<String, dynamic>? get scanResults => _scanResults;
  Map<String, dynamic>? get recommendations => _recommendations;
  List<dynamic> get mealLogs => _mealLogs;
  dynamic get selectedFoodDetail => _selectedFoodDetail;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == FoodStatus.loading;

  /// Scan food image
  Future<bool> scanFood(List<int> imageBytes, String fileName) async {
    _status = FoodStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _foodService.scanFood(imageBytes, fileName);
      _scanResults = results;
      _status = FoodStatus.success;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _status = FoodStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = ApiConstants.getErrorMessage('SCAN_FAILED');
      _status = FoodStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Get recommendations
  Future<void> fetchRecommendations({
    String? mealType,
    List<int>? detectedIds,
  }) async {
    _status = FoodStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _foodService.getRecommendations(
        mealType: mealType,
        detectedIds: detectedIds,
      );
      _recommendations = results;
      _status = FoodStatus.success;
      notifyListeners();
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _status = FoodStatus.error;
      notifyListeners();
    } catch (e) {
      _errorMessage = ApiConstants.getErrorMessage('RECOMMENDATION_FAILED');
      _status = FoodStatus.error;
      notifyListeners();
    }
  }

  /// Log a meal (Wishlist or consumed)
  Future<bool> logMeal({required int menuId, bool isConsumed = false}) async {
    _status = FoodStatus.loading;
    notifyListeners();
    try {
      await _foodService.logMeal(menuId: menuId, isConsumed: isConsumed);
      _status = FoodStatus.success;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _status = FoodStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = ApiConstants.getErrorMessage('LOG_FAILED');
      _status = FoodStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Fetch meal logs
  Future<void> fetchMealLogs() async {
    _status = FoodStatus.loading;
    notifyListeners();
    try {
      final logs = await _foodService.getMealLogs();
      _mealLogs = logs;
      _status = FoodStatus.success;
      notifyListeners();
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _status = FoodStatus.error;
      notifyListeners();
    } catch (e) {
      _errorMessage = ApiConstants.getErrorMessage('SERVER_ERROR');
      _status = FoodStatus.error;
      notifyListeners();
    }
  }

  /// Fetch food detail
  Future<void> fetchFoodDetail(int menuId) async {
    _status = FoodStatus.loading;
    _errorMessage = null;
    _selectedFoodDetail = null;
    notifyListeners();

    try {
      final detail = await _foodService.getFoodDetail(menuId);
      _selectedFoodDetail = detail;
      _status = FoodStatus.success;
      notifyListeners();
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _status = FoodStatus.error;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat detail makanan';
      _status = FoodStatus.error;
      notifyListeners();
    }
  }

  /// Confirm a meal as eaten
  Future<bool> confirmMeal(int mealLogId) async {
    try {
      final success = await _foodService.confirmMeal(mealLogId);
      if (success) {
        // Update local list
        final index = _mealLogs.indexWhere(
          (l) => l['meal_log_id'] == mealLogId,
        );
        if (index != -1) {
          _mealLogs[index]['is_consumed'] = true;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Clear scan results
  void clearScanResults() {
    _scanResults = null;
    notifyListeners();
  }

  /// Reset status
  void resetStatus() {
    _status = FoodStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
