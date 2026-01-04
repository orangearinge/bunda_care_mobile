/// Model for user preferences
class UserPreference {
  final String role;
  final String? name; // For syncing user name
  final String? hpht; // YYYY-MM-DD
  final int heightCm;
  final double weightKg;
  final int ageYear;
  final double? bellyCircumferenceCm;
  final double? lilaCm;
  final double? lactationMl;
  final List<String> foodProhibitions;
  final List<String> allergens;
  final int? gestationalAgeWeeks; // Read-only from response
  final NutritionalTargets? nutritionalTargets; // From response

  UserPreference({
    required this.role,
    this.name,
    this.hpht,
    required this.heightCm,
    required this.weightKg,
    required this.ageYear,
    this.bellyCircumferenceCm,
    this.lilaCm,
    this.lactationMl,
    this.foodProhibitions = const [],
    this.allergens = const [],
    this.gestationalAgeWeeks,
    this.nutritionalTargets,
  });

  /// Create UserPreference from JSON
  factory UserPreference.fromJson(Map<String, dynamic> json) {
    return UserPreference(
      role: json['role'] as String,
      name: json['name'] as String? ?? json['nama'] as String?,
      hpht: json['hpht'] as String?,
      heightCm: (json['height_cm'] as num).toInt(),
      weightKg: (json['weight_kg'] as num).toDouble(),
      ageYear: (json['age_year'] as num).toInt(),
      bellyCircumferenceCm: (json['belly_circumference_cm'] as num?)?.toDouble(),
      lilaCm: (json['lila_cm'] as num?)?.toDouble(),
      lactationMl: (json['lactation_ml'] as num?)?.toDouble(),
      foodProhibitions: List<String>.from(json['food_prohibitions'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      gestationalAgeWeeks: (json['gestational_age_weeks'] as num?)?.toInt(),
      nutritionalTargets: json['nutritional_targets'] != null
          ? NutritionalTargets.fromJson(json['nutritional_targets'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert UserPreference to JSON for API request
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'role': role,
      'name': name,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'age_year': ageYear,
      'food_prohibitions': foodProhibitions,
      'allergens': allergens,
    };

    if (role == 'IBU_HAMIL') {
      data['hpht'] = hpht;
      data['belly_circumference_cm'] = bellyCircumferenceCm;
      data['lila_cm'] = lilaCm;
    } else if (role == 'IBU_MENYUSUI') {
      data['lactation_ml'] = lactationMl;
    }

    return data;
  }
}

/// Model for nutritional targets returned by the API
class NutritionalTargets {
  final double calories;
  final double proteinG;
  final double bmi;

  NutritionalTargets({
    required this.calories,
    required this.proteinG,
    required this.bmi,
  });

  factory NutritionalTargets.fromJson(Map<String, dynamic> json) {
    return NutritionalTargets(
      calories: (json['calories'] as num).toDouble(),
      proteinG: (json['protein_g'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein_g': proteinG,
      'bmi': bmi,
    };
  }
}
