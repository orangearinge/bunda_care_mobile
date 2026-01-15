
import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/article_service.dart';

class ArticleProvider with ChangeNotifier {
  final ArticleService _articleService = ArticleService();

  List<Article> _articles = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  Article? _selectedArticle;
  Pagination? _pagination;
  String? _error;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  Article? get selectedArticle => _selectedArticle;
  String? get error => _error;
  bool get hasMore => _pagination?.hasNext ?? false;

  Future<void> fetchArticles({bool refresh = false}) async {
    if (refresh) {
      _isLoading = true;
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
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchArticleDetail(String slug) async {
    _isLoading = true;
    _selectedArticle = null;
    _error = null;
    notifyListeners();

    try {
      final article = await _articleService.getArticleDetail(slug);
      _selectedArticle = article;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
