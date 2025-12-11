import 'dart:convert';
import '../models/api_error.dart';

/// User model representing authenticated user data
class User {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String? avatar; // Nullable - only populated for Google users

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
  });

  /// Create User from JSON (from API response)
  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id == null || id is! int) {
      throw ApiError(
        code: 'INVALID_USER_ID',
        message: 'Invalid user ID in response',
      );
    }

    final name = json['name'];
    if (name == null || name is! String) {
      throw ApiError(
        code: 'INVALID_USER_NAME',
        message: 'Invalid user name in response',
      );
    }

    final email = json['email'];
    if (email == null || email is! String) {
      throw ApiError(
        code: 'INVALID_USER_EMAIL',
        message: 'Invalid user email in response',
      );
    }

    return User(
      id: id,
      name: name,
      email: email,
      role: json['role'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  /// Convert User to JSON (for storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
    };
  }

  /// Convert User to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create User from JSON string
  factory User.fromJsonString(String jsonString) {
    return User.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Get user initials for avatar fallback
  String getInitials() {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 2 ? 2 : name.length).toUpperCase();
  }

  /// Copy with method for creating modified copies
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.avatar == avatar;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, role, avatar);
  }
}
