class FoodDetail {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String category;
  final FoodNutrition nutrition;
  final List<FoodIngredient> ingredients;
  final String? cookingInstructions;
  final int? cookingTimeMinutes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FoodDetail({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.category,
    required this.nutrition,
    required this.ingredients,
    this.cookingInstructions,
    this.cookingTimeMinutes,
    this.createdAt,
    this.updatedAt,
  });

  factory FoodDetail.fromJson(Map<String, dynamic> json) {
    return FoodDetail(
      id: json['id'] ?? json['menu_id'] ?? 0,
      name: json['name'] ?? json['menu_name'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      category: json['category'] ?? 'LUNCH',
      nutrition: FoodNutrition.fromJson(json['nutrition'] ?? {}),
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((i) => FoodIngredient.fromJson(i))
              .toList() ??
          [],
      cookingInstructions: json['cooking_instructions'],
      cookingTimeMinutes: json['cooking_time_minutes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'nutrition': nutrition.toJson(),
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'cooking_instructions': cookingInstructions,
      'cooking_time_minutes': cookingTimeMinutes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class FoodNutrition {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  FoodNutrition({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory FoodNutrition.fromJson(Map<String, dynamic> json) {
    return FoodNutrition(
      calories: (json['calories'] ?? 0).toDouble(),
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
    };
  }
}

class FoodIngredient {
  final int id;
  final String name;
  final double quantity;
  final String unit;

  FoodIngredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory FoodIngredient.fromJson(Map<String, dynamic> json) {
    return FoodIngredient(
      id: json['id'] ?? json['ingredient_id'] ?? 0,
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'gram',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}
