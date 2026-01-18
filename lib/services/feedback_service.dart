import '../models/feedback.dart';
import '../models/api_error.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../utils/logger.dart';
import 'api_service.dart';

/// Service for user feedback API calls
class FeedbackService {
  final ApiService _api = ApiService();

  /// Send new feedback
  /// POST /api/feedback
  Future<FeedbackModel> sendFeedback(int rating, String comment) async {
    try {
      final response = await _api.post(
        ApiConstants.feedback,
        data: {
          'rating': rating,
          'comment': comment,
        },
      );

      final unwrapped = _api.unwrap(response);
      if (unwrapped is Map<String, dynamic>) {
        return FeedbackModel.fromJson(unwrapped);
      } else {
        throw ApiError(
          code: 'FEEDBACK_FAILED',
          message: 'Format respons salah',
        );
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Get my feedback history with pagination and search
  /// GET /api/feedback/me
  Future<FeedbackListResponse> getMyFeedback({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.myFeedback,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      final unwrapped = _api.unwrap(response);
      return FeedbackListResponse.fromJson(unwrapped);
    } catch (e) {
      AppLogger.e('GET FEEDBACK ERROR', e);
      throw ErrorHandler.handle(e);
    }
  }
}
