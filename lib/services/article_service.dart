import '../services/api_service.dart';
import '../models/article.dart';
import '../utils/constants.dart';
import '../utils/cache_config.dart';
import '../utils/error_handler.dart';

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
      throw ErrorHandler.handle(e);
    }
  }

  Future<Article> getArticleDetail(String slug, {bool forceRefresh = false}) async {
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
      throw ErrorHandler.handle(e);
    }
  }
}
