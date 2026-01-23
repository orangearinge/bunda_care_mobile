class Article {
  final int id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? content;
  final String? coverImage;
  final String? status;
  final DateTime? publishedAt;

  Article({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.content,
    this.coverImage,
    this.status,
    this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      excerpt: json['excerpt'] as String?,
      content: json['content'] as String?,
      coverImage: json['cover_image'] as String?,
      status: json['status'] as String?,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
    );
  }
}

class ArticleListResponse {
  final List<Article> items;
  final Pagination pagination;

  ArticleListResponse({required this.items, required this.pagination});

  factory ArticleListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<Article> itemsList = list.map((i) => Article.fromJson(i)).toList();

    return ArticleListResponse(
      items: itemsList,
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      hasNext: json['has_next'] as bool,
      hasPrev: json['has_prev'] as bool,
    );
  }
}
