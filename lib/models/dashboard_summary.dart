class DashboardSummary {
  final DashboardUser user;
  final DashboardTargets targets;
  final DashboardNutrition todayNutrition;
  final DashboardNutrition remaining;
  final List<DashboardRecommendation> recommendations;

  DashboardSummary({
    required this.user,
    required this.targets,
    required this.todayNutrition,
    required this.remaining,
    required this.recommendations,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      user: DashboardUser.fromJson(json['user']),
      targets: DashboardTargets.fromJson(json['targets']),
      todayNutrition: DashboardNutrition.fromJson(json['today_nutrition']),
      remaining: DashboardNutrition.fromJson(json['remaining']),
      recommendations: (json['recommendations'] as List)
          .map((i) => DashboardRecommendation.fromJson(i))
          .toList(),
    );
  }
}

class DashboardUser {
  final String name;
  final String role;
  final Map<String, dynamic> preferences;

  DashboardUser({
    required this.name,
    required this.role,
    required this.preferences,
  });

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      preferences: json['preferences'] ?? {},
    );
  }
}

class DashboardTargets {
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double? bmi;

  DashboardTargets({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.bmi,
  });

  factory DashboardTargets.fromJson(Map<String, dynamic> json) {
    return DashboardTargets(
      calories: json['calories'] ?? 0,
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
      bmi: json['bmi']?.toDouble(),
    );
  }
}

class DashboardNutrition {
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  DashboardNutrition({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory DashboardNutrition.fromJson(Map<String, dynamic> json) {
    return DashboardNutrition(
      calories: json['calories'] ?? 0,
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
    );
  }
}

class DashboardRecommendation {
  final int id;
  final String name;
  final int calories;
  final String imageUrl;
  final String description;

  DashboardRecommendation({
    required this.id,
    required this.name,
    required this.calories,
    required this.imageUrl,
    required this.description,
  });

  factory DashboardRecommendation.fromJson(Map<String, dynamic> json) {
    return DashboardRecommendation(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      calories: json['calories'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
