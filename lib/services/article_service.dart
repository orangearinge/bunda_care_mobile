import '../models/article.dart';
import '../models/api_error.dart';
import '../utils/constants.dart';
import '../utils/cache_config.dart';
import '../utils/error_handler.dart';
import 'api_service.dart';

class ArticleService {
  final ApiService _api = ApiService();

  Future<ArticleListResponse> getPublicArticles({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    try {
      // Use cache for articles, unless force refresh
      final cacheOptions = forceRefresh
          ? _api.getCacheOptions(CacheConfig.forceRefresh)
          : _api.getCacheOptions(CacheConfig.articles);

      final response = await _api.get(
        ApiConstants.publicArticles,
        queryParameters: {
          'page': page,
          'limit': limit,
          'sort_by': 'published_at',
          'sort_order': 'desc',
        },
        options: _api.applyCacheOptions(cacheOptions),
      );

      final data = _api.unwrap(response);
      return ArticleListResponse.fromJson(data);
    } catch (e) {
      // For network errors, throw to show offline placeholder
      if (e is ApiError &&
          (e.code == 'NETWORK_ERROR' || e.code == 'TIMEOUT_ERROR')) {
        rethrow; // Re-throw network errors to show offline state
      }
      // For other errors, return empty list (server errors)
      return ArticleListResponse(
        items: [],
        pagination: Pagination(
          page: page,
          limit: limit,
          total: 0,
          totalPages: 0,
          hasNext: false,
          hasPrev: false,
        ),
      );
    }
  }

  Future<Article> getArticleDetail(
    String slug, {
    bool forceRefresh = false,
  }) async {
    try {
      final cacheOptions = forceRefresh
          ? _api.getCacheOptions(CacheConfig.forceRefresh)
          : _api.getCacheOptions(CacheConfig.articles);

      final response = await _api.get(
        '${ApiConstants.publicArticles}/$slug',
        options: _api.applyCacheOptions(cacheOptions),
      );
      final data = _api.unwrap(response);

      return Article.fromJson(data);
    } catch (e) {
      if (e is ApiError &&
          (e.code == 'NETWORK_ERROR' || e.code == 'TIMEOUT_ERROR')) {
        // Handle network error
      }
      throw ErrorHandler.handle(e);
    }
  }
}
