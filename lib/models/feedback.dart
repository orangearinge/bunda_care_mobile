class FeedbackModel {
  final int id;
  final int rating;
  final String comment;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class FeedbackListResponse {
  final List<FeedbackModel> items;
  final Pagination pagination;

  FeedbackListResponse({required this.items, required this.pagination});

  factory FeedbackListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<FeedbackModel> itemsList = list
        .map((i) => FeedbackModel.fromJson(i))
        .toList();

    return FeedbackListResponse(
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
