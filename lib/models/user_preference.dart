/// Model for user preferences
class UserPreference {
  final String role;
  final String? name; // For syncing user name
  final String? hpht; // YYYY-MM-DD
  final int heightCm;
  final double weightKg;
  final int ageYear;
  final double? lilaCm;
  final String? lactationPhase; // "0-6" or "6-12"
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
    this.lilaCm,
    this.lactationPhase,
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
      heightCm: (json['height_cm'] as num?)?.toInt() ?? 0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      ageYear: (json['age_year'] as num?)?.toInt() ?? 0,
      lilaCm: (json['lila_cm'] as num?)?.toDouble(),
      lactationPhase: json['lactation_phase'] as String?,
      foodProhibitions: List<String>.from(json['food_prohibitions'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      gestationalAgeWeeks: (json['gestational_age_weeks'] as num?)?.toInt(),
      nutritionalTargets: json['nutritional_targets'] != null
          ? NutritionalTargets.fromJson(
              json['nutritional_targets'] as Map<String, dynamic>,
            )
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
      data['lila_cm'] = lilaCm;
    } else if (role == 'IBU_MENYUSUI') {
      data['lactation_phase'] = lactationPhase;
    }

    return data;
  }
}

/// Model for nutritional targets returned by the API
class NutritionalTargets {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double? bmi;

  NutritionalTargets({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.bmi,
  });

  factory NutritionalTargets.fromJson(Map<String, dynamic> json) {
    return NutritionalTargets(
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? 0.0,
      bmi: (json['bmi'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
      if (bmi != null) 'bmi': bmi,
    };
  }
}
