import 'package:flutter/material.dart';
import '../models/api_error.dart';
import '../models/history_entry.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';

enum HistoryStatus { initial, loading, success, error }

class HistoryProvider with ChangeNotifier {
  final UserService _userService = UserService();

  HistoryStatus _status = HistoryStatus.initial;
  List<HistoryEntry> _history = [];
  List<HistoryDetailItem> _historyDetails = [];
  String? _errorMessage;

  HistoryStatus get status => _status;
  List<HistoryEntry> get history => _history;
  List<HistoryDetailItem> get historyDetails => _historyDetails;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == HistoryStatus.loading;

  /// Fetch nutrition history
  Future<void> fetchHistory() async {
    _status = HistoryStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _userService.getHistory();
      _history = results;
      _status = HistoryStatus.success;
      notifyListeners();
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _status = HistoryStatus.error;
      notifyListeners();
    } catch (e) {
      _errorMessage = ApiConstants.getErrorMessage('SERVER_ERROR');
      _status = HistoryStatus.error;
      notifyListeners();
    }
  }

  /// Fetch history details for a specific date
  Future<void> fetchHistoryDetail(String date) async {
    _status = HistoryStatus.loading;
    _errorMessage = null;
    _historyDetails = [];
    notifyListeners();

    try {
      final results = await _userService.getHistoryDetail(date);
      _historyDetails = results;
      _status = HistoryStatus.success;
      notifyListeners();
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _status = HistoryStatus.error;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat detail histori';
      _status = HistoryStatus.error;
      notifyListeners();
    }
  }

  /// Reset provider state
  void reset() {
    _status = HistoryStatus.initial;
    _history = [];
    _historyDetails = [];
    _errorMessage = null;
    notifyListeners();
  }
}
