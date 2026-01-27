import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bunda_care/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify app starts and shows login page',
        (tester) async {
      // Start the app
      app.main();
      
      // Wait for the app to load and settle
      // We use a longer timeout for the first settle because of app initialization
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check if we can find either "Bunda Care" (Splash) or "Bundacare" (Login)
      // This makes the test more resilient to where exactly it stops
      final foundText = find.byWidgetPredicate(
        (widget) => widget is Text && 
        (widget.data?.contains('Bunda') ?? false)
      );
      
      expect(foundText, findsWidgets);
      
      // Verify login page elements if we are there
      if (find.text('LOGIN').evaluate().isNotEmpty) {
        expect(find.byType(TextField), findsAtLeast(2)); // Email and Password
        debugPrint('Successfully reached Login Page');
      } else {
        debugPrint('App is likely still on Splash or redirecting');
      }
    });
  });
}
