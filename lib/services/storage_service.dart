import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';
import '../utils/constants.dart';

/// Service for securely storing authentication data
/// Uses flutter_secure_storage for encrypted storage
class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
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
