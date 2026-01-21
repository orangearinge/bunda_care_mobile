import 'package:intl/intl.dart';

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

  // Mature state for UI
  String get formattedDate {
    final dt = DateTime.tryParse(date);
    if (dt == null) return date;
    return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(dt);
  }

  DateTime? get dateTime => DateTime.tryParse(date);

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      date: json['date'] ?? '',
      calories: (json['calories'] ?? 0).toInt(),
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
      mealCount: (json['meal_count'] ?? 0).toInt(),
      targetCalories: (json['target_calories'] ?? 0).toInt(),
      percentage: (json['percentage'] ?? 0).toInt(),
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
      calories: (json['calories'] ?? 0).toInt(),
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
      loggedAt: json['logged_at'] ?? '',
    );
  }

  String get formattedTime {
    try {
      final logTime = DateTime.parse(loggedAt);
      return "${logTime.hour.toString().padLeft(2, '0')}:${logTime.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return '';
    }
  }
}
