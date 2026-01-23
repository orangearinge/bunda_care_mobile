import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../models/api_error.dart';
import '../services/article_service.dart';
import '../utils/constants.dart';

enum ArticleStatus { initial, loading, success, error }

class ArticleProvider with ChangeNotifier {
  final ArticleService _articleService = ArticleService();

  ArticleStatus _status = ArticleStatus.initial;
  List<Article> _articles = [];
  bool _isLoadingMore = false;
  Article? _selectedArticle;
  Pagination? _pagination;
  String? _error;

  ArticleStatus get status => _status;
  List<Article> get articles => _articles;
  bool get isLoading => _status == ArticleStatus.loading;
  bool get isLoadingMore => _isLoadingMore;
  Article? get selectedArticle => _selectedArticle;
  String? get error => _error;
  bool get hasMore => _pagination?.hasNext ?? false;

  Future<void> fetchArticles({bool refresh = false}) async {
    if (refresh) {
      _status = ArticleStatus.loading;
      _articles = [];
      _pagination = null;
      _error = null;
    } else {
      if (!hasMore && _articles.isNotEmpty) return;
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final page = refresh ? 1 : (_pagination?.page ?? 0) + 1;
      final response = await _articleService.getPublicArticles(
        page: page,
        forceRefresh: refresh,
      );

      if (refresh) {
        _articles = response.items;
      } else {
        _articles.addAll(response.items);
      }
      _pagination = response.pagination;
      _status = ArticleStatus.success;
      _error = null;
    } on ApiError catch (e) {
      _error = ApiConstants.getErrorMessage(e.code);
      _status = ArticleStatus.error;
    } catch (e) {
      _error = ApiConstants.getErrorMessage('SERVER_ERROR');
      _status = ArticleStatus.error;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchArticleDetail(String slug) async {
    _status = ArticleStatus.loading;
    _selectedArticle = null;
    _error = null;
    notifyListeners();

    try {
      final article = await _articleService.getArticleDetail(slug);
      _selectedArticle = article;
      _status = ArticleStatus.success;
    } on ApiError catch (e) {
      _error = ApiConstants.getErrorMessage(e.code);
      _status = ArticleStatus.error;
    } catch (e) {
      _error = ApiConstants.getErrorMessage('SERVER_ERROR');
      _status = ArticleStatus.error;
    } finally {
      notifyListeners();
    }
  }
}
