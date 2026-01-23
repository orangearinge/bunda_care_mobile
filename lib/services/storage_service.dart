import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/meal_schedule.dart';
import '../utils/constants.dart';

/// Service for securely storing authentication data
/// Uses flutter_secure_storage for encrypted storage
class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ==================== Token Management ====================

  /// Save JWT token securely
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: ApiConstants.tokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }

  /// Get stored JWT token
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: ApiConstants.tokenKey);
    } catch (e) {
      throw Exception('Failed to read token: $e');
    }
  }

  /// Delete JWT token
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: ApiConstants.tokenKey);
    } catch (e) {
      throw Exception('Failed to delete token: $e');
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== User Data Management ====================

  /// Save user data
  Future<void> saveUser(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: ApiConstants.userKey, value: userJson);
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  /// Get stored user data
  Future<User?> getUser() async {
    try {
      final userJson = await _storage.read(key: ApiConstants.userKey);
      if (userJson == null) return null;
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to read user: $e');
    }
  }

  /// Delete user data
  Future<void> deleteUser() async {
    try {
      await _storage.delete(key: ApiConstants.userKey);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // ==================== Meal Schedule Management ====================

  /// Save meal schedules
  Future<void> saveMealSchedules(List<MealSchedule> schedules) async {
    try {
      final schedulesJson = jsonEncode(
        schedules.map((s) => s.toJson()).toList(),
      );
      await _storage.write(key: 'meal_schedules', value: schedulesJson);

      // Also sync to Android SharedPreferences for AlarmManager access
      await _syncToAndroidSharedPreferences(schedulesJson);
    } catch (e) {
      throw Exception('Failed to save meal schedules: $e');
    }
  }

  /// Sync meal schedules to Android SharedPreferences
  Future<void> _syncToAndroidSharedPreferences(String schedulesJson) async {
    try {
      const platform = MethodChannel(
        'com.example.bunda_care/meal_notifications',
      );
      await platform.invokeMethod('syncMealSchedules', {
        'schedules': schedulesJson,
      });
    } catch (e) {
      // If platform channel fails, continue without error
      // This might happen during initial setup or on unsupported platforms
    }
  }

  /// Get stored meal schedules
  Future<List<MealSchedule>> getMealSchedules() async {
    try {
      final schedulesJson = await _storage.read(key: 'meal_schedules');
      if (schedulesJson == null) return [];
      final schedulesList = jsonDecode(schedulesJson) as List<dynamic>;
      return schedulesList
          .map((json) => MealSchedule.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to read meal schedules: $e');
    }
  }

  // ==================== Clear All ====================

  /// Clear all stored data (use on logout)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }
}
