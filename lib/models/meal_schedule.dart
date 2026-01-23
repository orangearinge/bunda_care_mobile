import 'package:flutter/material.dart';

class MealSchedule {
  final int id;
  final String mealType; // 'sarapan', 'makan_siang', 'makan_malam'
  final TimeOfDay scheduledTime;
  final bool isEnabled;
  final String? customMessage;

  MealSchedule({
    required this.id,
    required this.mealType,
    required this.scheduledTime,
    this.isEnabled = true,
    this.customMessage,
  });

  factory MealSchedule.fromJson(Map<String, dynamic> json) {
    return MealSchedule(
      id: json['id'],
      mealType: json['meal_type'],
      scheduledTime: TimeOfDay(hour: json['hour'], minute: json['minute']),
      isEnabled: json['is_enabled'] ?? true,
      customMessage: json['custom_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal_type': mealType,
      'hour': scheduledTime.hour,
      'minute': scheduledTime.minute,
      'is_enabled': isEnabled,
      'custom_message': customMessage,
    };
  }

  String get displayName {
    switch (mealType) {
      case 'sarapan':
        return 'Sarapan';
      case 'makan_siang':
        return 'Makan Siang';
      case 'makan_malam':
        return 'Makan Malam';
      default:
        return mealType;
    }
  }

  String get defaultMessage {
    switch (mealType) {
      case 'sarapan':
        return 'Waktunya sarapan, Bunda! Jaga energi untuk hari ini.';
      case 'makan_siang':
        return 'Saatnya makan siang yang sehat!';
      case 'makan_malam':
        return 'Makan malam seimbang untuk kesehatan Bunda.';
      default:
        return 'Waktunya makan!';
    }
  }

  MealSchedule copyWith({
    int? id,
    String? mealType,
    TimeOfDay? scheduledTime,
    bool? isEnabled,
    String? customMessage,
  }) {
    return MealSchedule(
      id: id ?? this.id,
      mealType: mealType ?? this.mealType,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isEnabled: isEnabled ?? this.isEnabled,
      customMessage: customMessage ?? this.customMessage,
    );
  }
}
