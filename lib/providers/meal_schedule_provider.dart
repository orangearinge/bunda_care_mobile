import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/meal_schedule.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';

class MealScheduleProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final StorageService _storageService = StorageService();

  List<MealSchedule> _mealSchedules = [];
  bool _isLoading = false;

  static const platform = MethodChannel('com.example.bunda_care/meal_notifications');

  List<MealSchedule> get mealSchedules => _mealSchedules;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    await _loadMealSchedules();
    // Storage sync will automatically trigger alarm scheduling
  }

  /// Check and request notification permission
  Future<bool> checkNotificationPermission() async {
    try {
      // Check current permission status
      final status = await Permission.notification.status;

      if (status.isDenied || status.isPermanentlyDenied) {
        // Request permission
        final result = await Permission.notification.request();
        return result.isGranted;
      }

      return status.isGranted;
    } catch (e) {
      // Permission check failed
      return false;
    }
  }

  /// Refresh all notifications - useful after app restart
  Future<void> refreshNotifications() async {
    try {
      await platform.invokeMethod('scheduleMealAlarms');
      AppLogger.i('Meal alarms refreshed successfully');
    } catch (e) {
      AppLogger.e('Failed to refresh meal alarms: $e');
    }
  }

  Future<void> _loadMealSchedules() async {
    _isLoading = true;
    notifyListeners();

    try {
      final schedules = await _storageService.getMealSchedules();
      _mealSchedules = schedules.isNotEmpty ? schedules : _getDefaultSchedules();
    } catch (e) {
      // If loading fails, use default schedules
      _mealSchedules = _getDefaultSchedules();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<MealSchedule> _getDefaultSchedules() {
    return [
      MealSchedule(
        id: 1,
        mealType: 'sarapan',
        scheduledTime: const TimeOfDay(hour: 7, minute: 0),
      ),
      MealSchedule(
        id: 2,
        mealType: 'makan_siang',
        scheduledTime: const TimeOfDay(hour: 12, minute: 0),
      ),
      MealSchedule(
        id: 3,
        mealType: 'makan_malam',
        scheduledTime: const TimeOfDay(hour: 18, minute: 0),
      ),
    ];
  }

  Future<void> updateMealSchedule(MealSchedule schedule) async {
    final index = _mealSchedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _mealSchedules[index] = schedule;
      await _storageService.saveMealSchedules(_mealSchedules);
      // Alarms will be automatically re-scheduled due to storage sync

      notifyListeners();
    }
  }

  // Background scheduling is now handled by Android AlarmManager

  Future<void> toggleSchedule(int id, bool isEnabled) async {
    final index = _mealSchedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      final updatedSchedule = _mealSchedules[index].copyWith(isEnabled: isEnabled);
      await updateMealSchedule(updatedSchedule);
    }
  }

  /// Test notification immediately for a specific meal schedule
  Future<bool> testNotification(int id) async {
    try {
      // First check if we have permission
      final hasPermission = await checkNotificationPermission();
      if (!hasPermission) {
        return false;
      }

      final schedule = _mealSchedules.firstWhere((s) => s.id == id);

      // Show notification immediately for testing
      await _notificationService.showNotification(
        id: 999, // Use different ID for test notifications
        title: '🔔 Test Notifikasi - ${schedule.displayName}',
        body: schedule.customMessage ?? schedule.defaultMessage,
      );

      return true;
    } catch (e) {
      // Test notification failed - this might be due to permission issues
      return false;
    }
  }
}