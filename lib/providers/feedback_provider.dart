import 'package:flutter/foundation.dart';
import '../models/feedback.dart';
import '../services/feedback_service.dart';

class FeedbackProvider with ChangeNotifier {
  final FeedbackService _feedbackService = FeedbackService();

  List<FeedbackModel> _feedbacks = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  List<FeedbackModel> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  Future<void> fetchMyFeedbacks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _feedbacks = await _feedbackService.getMyFeedback();
    } catch (e) {
      _error = e.toString();
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
      _error = e.toString();
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
