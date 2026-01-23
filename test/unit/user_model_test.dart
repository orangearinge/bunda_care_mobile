import 'package:flutter_test/flutter_test.dart';
import 'package:bunda_care/models/user.dart';
import 'package:bunda_care/models/api_error.dart';

void main() {
  group('User Model Tests', () {
    final userData = {
      'id': 1,
      'name': 'Bunda Maria',
      'email': 'maria@example.com',
      'role': 'ibu_hamil',
      'avatar': 'https://example.com/avatar.jpg',
    };

    test('should create User instance from JSON', () {
      final user = User.fromJson(userData);

      expect(user.id, 1);
      expect(user.name, 'Bunda Maria');
      expect(user.email, 'maria@example.com');
      expect(user.role, 'ibu_hamil');
      expect(user.avatar, 'https://example.com/avatar.jpg');
    });

    test('should throw ApiError if id is missing', () {
      final invalidData = Map<String, dynamic>.from(userData)..remove('id');

      expect(() => User.fromJson(invalidData), throwsA(isA<ApiError>()));
    });

    test('getInitials should return correct initials for two names', () {
      final user = User.fromJson(userData);
      expect(user.getInitials(), 'BM');
    });

    test('getInitials should return correct initials for single name', () {
      final user = User(
        id: 2,
        name: 'Maria',
        email: 'maria@example.com',
        role: 'user',
      );
      expect(user.getInitials(), 'MA');
    });

    test('toJson should return correct map', () {
      final user = User.fromJson(userData);
      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Bunda Maria');
    });
  });
}
