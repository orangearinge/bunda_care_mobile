import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bunda_care/pages/signup_page.dart';
import 'package:bunda_care/providers/auth_provider.dart';
import 'test_helper.dart';

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: const SignUpPage(),
      ),
    );
  }

  testWidgets('SignUpPage menyuguhkan input pendaftaran lengkap', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Cek judul halaman
    expect(find.text('Buat Akun Baru'), findsOneWidget);
    
    // Cek keberadaan checkbox syarat dan ketentuan
    expect(find.byType(Checkbox), findsOneWidget);
    
    // Cek tombol DAFTAR
    expect(find.text('DAFTAR'), findsOneWidget);
  });

  testWidgets('SignUpPage test: menampilkan error jika tombol daftar ditekan saat form kosong', (WidgetTester tester) async {
    // Set screen size to a standard mobile size to ensure proper layout
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createWidgetUnderTest());

    // 1. Cari tombol DAFTAR dan pastikan terlihat (scroll jika perlu)
    final tombolDaftar = find.text('DAFTAR');
    await tester.ensureVisible(tombolDaftar);
    await tester.tap(tombolDaftar);

    // 2. Tunggu sebentar sampai validasi selesai
    await tester.pumpAndSettle();

    // 3. Cek apakah pesan error validasi muncul di layar
    expect(find.text('Username tidak boleh kosong'), findsOneWidget);
    expect(find.text('Masukkan email Anda'), findsOneWidget);
    expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    expect(find.text('Konfirmasi password Anda'), findsOneWidget);

    // Reset view properties
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
