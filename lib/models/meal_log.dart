class MealLog {
  final int id;
  final String menuName;
  final bool isConsumed;
  final String? imageUrl;
  final MealLogNutrition nutrition;
  final DateTime? createdAt;

  MealLog({
    required this.id,
    required this.menuName,
    required this.isConsumed,
    this.imageUrl,
    required this.nutrition,
    this.createdAt,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['meal_log_id'] ?? 0,
      menuName: json['menu_name'] ?? 'Menu',
      isConsumed: json['is_consumed'] ?? false,
      imageUrl: json['image_url'],
      nutrition: MealLogNutrition.fromJson(json['total'] ?? {}),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
    );
  }

  String get caloriesText => "${nutrition.calories} kkal";

  MealLog copyWith({
    int? id,
    String? menuName,
    bool? isConsumed,
    String? imageUrl,
    MealLogNutrition? nutrition,
    DateTime? createdAt,
  }) {
    return MealLog(
      id: id ?? this.id,
      menuName: menuName ?? this.menuName,
      isConsumed: isConsumed ?? this.isConsumed,
      imageUrl: imageUrl ?? this.imageUrl,
      nutrition: nutrition ?? this.nutrition,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MealLogNutrition {
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  MealLogNutrition({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory MealLogNutrition.fromJson(Map<String, dynamic> json) {
    return MealLogNutrition(
      calories: json['calories'] ?? 0,
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
    );
  }
}
