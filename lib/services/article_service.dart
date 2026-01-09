
import '../services/api_service.dart';
import '../models/article.dart';
import '../utils/constants.dart';

class ArticleService {
  final ApiService _api = ApiService();

  Future<ArticleListResponse> getPublicArticles({int page = 1, int limit = 10}) async {
    try {
      final response = await _api.get(
        ApiConstants.publicArticles,
        queryParameters: {
          'page': page,
          'limit': limit,
          'sort_by': 'published_at',
          'sort_order': 'desc',
        },
      );

      final data = response.data;
      // Standard backend response is flat: { items: [], pagination: {} }
      // But ApiService.get converts bad responses to ApiError.
      // So if we are here, it's a 2xx response.
      
      return ArticleListResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Article> getArticleDetail(String slug) async {
    try {
      final response = await _api.get('${ApiConstants.publicArticles}/$slug');
      
      return Article.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
