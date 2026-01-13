class HistoryEntry {
  final String date;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final int mealCount;
  final int targetCalories;
  final int percentage;

  HistoryEntry({
    required this.date,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.mealCount,
    required this.targetCalories,
    required this.percentage,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      date: json['date'] ?? '',
      calories: json['calories'] ?? 0,
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
      mealCount: json['meal_count'] ?? 0,
      targetCalories: json['target_calories'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }
}

class HistoryDetailItem {
  final int id;
  final String menuName;
  final String imageUrl;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String loggedAt;

  HistoryDetailItem({
    required this.id,
    required this.menuName,
    required this.imageUrl,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.loggedAt,
  });

  factory HistoryDetailItem.fromJson(Map<String, dynamic> json) {
    return HistoryDetailItem(
      id: json['id'] ?? 0,
      menuName: json['menu_name'] ?? 'Makanan',
      imageUrl: json['image_url'] ?? '',
      calories: json['calories'] ?? 0,
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
      loggedAt: json['logged_at'] ?? '',
    );
  }
}
