import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bunda_care/pages/splash_page.dart';

void main() {
  testWidgets('SplashPage displays logo and app name', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashPage(),
      ),
    );

    // Verify that the app name is displayed
    expect(find.text('Bunda Care'), findsOneWidget);
    
    // Verify that the status text is displayed
    expect(find.text('Masuk ke aplikasi...'), findsOneWidget);

    // Verify that the logo image is present
    // Note: In widget tests, images are often found by their asset path
    expect(find.byType(Image), findsOneWidget);
  });
}
