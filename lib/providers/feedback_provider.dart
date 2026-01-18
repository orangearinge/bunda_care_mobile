import 'package:flutter/foundation.dart';
import '../models/feedback.dart';
import '../services/feedback_service.dart';
import '../utils/constants.dart';

class FeedbackProvider with ChangeNotifier {
  final FeedbackService _feedbackService = FeedbackService();

  List<FeedbackModel> _feedbacks = [];
  Pagination? _pagination;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  List<FeedbackModel> get feedbacks => _feedbacks;
  Pagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  Future<void> fetchMyFeedbacks({
    int page = 1,
    String? search,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final response = await _feedbackService.getMyFeedback(
        page: page,
        search: search,
      );

      if (page == 1) {
        _feedbacks = response.items;
      } else {
        _feedbacks.addAll(response.items);
      }
      _pagination = response.pagination;
    } catch (e) {
      _error = ApiConstants.getErrorMessage('SERVER_ERROR');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitFeedback(int rating, String comment) async {
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final newFeedback = await _feedbackService.sendFeedback(rating, comment);
      _feedbacks.insert(0, newFeedback);
      return true;
    } catch (e) {
      _error = ApiConstants.getErrorMessage('SERVER_ERROR');
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
