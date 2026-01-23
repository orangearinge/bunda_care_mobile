import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bunda_care/pages/login_page.dart';
import 'package:bunda_care/providers/auth_provider.dart';
import 'test_helper.dart';

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    // Berikan nilai default untuk provider agar tidak error saat build widget
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: const LoginPage(),
      ),
    );
  }

  testWidgets('LoginPage menyuguhkan form email, password, dan tombol login', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Cek apakah ada teks "email" dan "password" sebagai hint
    expect(find.text('email'), findsOneWidget);
    expect(find.text('password'), findsOneWidget);
    
    // Cek apakah ada tombol LOGIN
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('LoginPage test: menampilkan error jika tombol login ditekan saat form kosong', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // 1. Cari tombol LOGIN dan tekan (Tap)
    await tester.tap(find.text('LOGIN'));

    // 2. Tunggu sebentar sampai animasi/validasi selesai
    await tester.pump();

    // 3. Cek apakah pesan error validasi muncul di layar
    expect(find.text('Masukkan email Anda'), findsOneWidget);
    expect(find.text('Masukkan password Anda'), findsOneWidget);
  });
}
