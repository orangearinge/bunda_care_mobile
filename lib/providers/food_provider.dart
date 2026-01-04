import 'dart:io';
import 'package:flutter/material.dart';
import '../models/api_error.dart';
import '../services/food_service.dart';

enum FoodStatus { initial, loading, success, error }

class FoodProvider with ChangeNotifier {
  final FoodService _foodService = FoodService();

  FoodStatus _status = FoodStatus.initial;
  Map<String, dynamic>? _scanResults;
  Map<String, dynamic>? _recommendations;
  String? _errorMessage;

  FoodStatus get status => _status;
  Map<String, dynamic>? get scanResults => _scanResults;
  Map<String, dynamic>? get recommendations => _recommendations;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == FoodStatus.loading;

  /// Scan food image
  Future<bool> scanFood(File imageFile) async {
    _status = FoodStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _foodService.scanFood(imageFile);
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
      _errorMessage = 'Gagal memindai makanan. Silakan coba lagi.';
      _status = FoodStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Get recommendations
  Future<void> fetchRecommendations({String? mealType, List<int>? detectedIds}) async {
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
      _errorMessage = 'Gagal memuat rekomendasi makanan.';
      _status = FoodStatus.error;
      notifyListeners();
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
