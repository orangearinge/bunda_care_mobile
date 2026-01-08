import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pregnancy Age Validation Logic', () {
    // Helper function to calculate gestational age (copied from implementation)
    Map<String, int> calculateGestationalAge(String hphtDate) {
      try {
        final hpht = DateTime.parse(hphtDate);
        final now = DateTime.now();
        final difference = now.difference(hpht);

        final totalDays = difference.inDays;
        final weeks = totalDays ~/ 7;
        final days = totalDays % 7;

        return {'weeks': weeks, 'days': days};
      } catch (e) {
        return {'weeks': 0, 'days': 0};
      }
    }

    // Helper function to check validation
    bool isGestationalAgeValid(String hphtDate) {
      final gestationalAge = calculateGestationalAge(hphtDate);
      return gestationalAge['weeks']! <= 42;
    }

    test('Calculates gestational age correctly for recent date', () {
      final today = DateTime.now();
      final dateString =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final result = calculateGestationalAge(dateString);

      // Today should be 0 weeks, 0 days
      expect(result['weeks'], equals(0));
      expect(result['days'], equals(0));
    });

    test('Calculates gestational age correctly for past date', () {
      final twentyWeeksAgo = DateTime.now().subtract(
        const Duration(days: 20 * 7),
      );
      final dateString =
          "${twentyWeeksAgo.year}-${twentyWeeksAgo.month.toString().padLeft(2, '0')}-${twentyWeeksAgo.day.toString().padLeft(2, '0')}";

      final result = calculateGestationalAge(dateString);

      // Should be approximately 20 weeks
      expect(result['weeks']!, greaterThanOrEqualTo(19));
      expect(result['weeks']!, lessThanOrEqualTo(21));
    });

    test('Validates pregnancy age correctly', () {
      // Test with a date that's ~30 weeks ago (should be valid)
      final thirtyWeeksAgo = DateTime.now().subtract(
        const Duration(days: 30 * 7),
      );
      final validDateString =
          "${thirtyWeeksAgo.year}-${thirtyWeeksAgo.month.toString().padLeft(2, '0')}-${thirtyWeeksAgo.day.toString().padLeft(2, '0')}";

      expect(isGestationalAgeValid(validDateString), isTrue);
    });

    test('Rejects pregnancy age that exceeds 42 weeks', () {
      // Test with a date that's ~45 weeks ago (should be invalid)
      final fortyFiveWeeksAgo = DateTime.now().subtract(
        const Duration(days: 45 * 7),
      );
      final invalidDateString =
          "${fortyFiveWeeksAgo.year}-${fortyFiveWeeksAgo.month.toString().padLeft(2, '0')}-${fortyFiveWeeksAgo.day.toString().padLeft(2, '0')}";

      expect(isGestationalAgeValid(invalidDateString), isFalse);
    });

    test('Handles edge case at exactly 42 weeks', () {
      // Test with a date that's exactly 42 weeks ago (should be valid)
      final fortyTwoWeeksAgo = DateTime.now().subtract(
        const Duration(days: 42 * 7),
      );
      final edgeCaseDateString =
          "${fortyTwoWeeksAgo.year}-${fortyTwoWeeksAgo.month.toString().padLeft(2, '0')}-${fortyTwoWeeksAgo.day.toString().padLeft(2, '0')}";

      expect(isGestationalAgeValid(edgeCaseDateString), isTrue);
    });

    test('Handles invalid date format gracefully', () {
      expect(
        isGestationalAgeValid('invalid-date'),
        isTrue,
      ); // Returns 0 weeks, which is valid
    });
  });
}
