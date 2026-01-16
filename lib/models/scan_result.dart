class ScanResult {
  final List<String> detectedItems;
  final List<int> detectedIds;
  final List<FoodCandidate> candidates;

  ScanResult({
    required this.detectedItems,
    required this.detectedIds,
    required this.candidates,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      detectedItems: List<String>.from(json['detected_items'] ?? []),
      detectedIds: List<int>.from(json['detected_ids'] ?? []),
      candidates: (json['candidates'] as List<dynamic>?)
              ?.map((c) => FoodCandidate.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class FoodCandidate {
  final String name;
  final ScanNutrition nutrition;

  FoodCandidate({
    required this.name,
    required this.nutrition,
  });

  factory FoodCandidate.fromJson(Map<String, dynamic> json) {
    return FoodCandidate(
      name: json['name'] ?? '',
      nutrition: ScanNutrition.fromJson(json['per_100g'] ?? {}),
    );
  }
}

class ScanNutrition {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  ScanNutrition({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory ScanNutrition.fromJson(Map<String, dynamic> json) {
    return ScanNutrition(
      calories: (json['calories'] ?? 0).toDouble(),
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
    );
  }
}
