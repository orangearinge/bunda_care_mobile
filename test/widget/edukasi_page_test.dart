import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bunda_care/pages/edukasi_page.dart';
import 'package:bunda_care/providers/article_provider.dart';
import 'test_helper.dart';

void main() {
  late MockArticleProvider mockArticleProvider;

  setUp(() {
    mockArticleProvider = MockArticleProvider();
    when(() => mockArticleProvider.isLoading).thenReturn(false);
    when(() => mockArticleProvider.isLoadingMore).thenReturn(false);
    when(() => mockArticleProvider.hasMore).thenReturn(false);
    // Kita set status ke success agar tidak menampilkan Skeleton
    when(() => mockArticleProvider.status).thenReturn(ArticleStatus.success);
    when(() => mockArticleProvider.articles).thenReturn([]);
    when(() => mockArticleProvider.error).thenReturn(null);
    when(() => mockArticleProvider.fetchArticles(refresh: any(named: 'refresh')))
        .thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<ArticleProvider>.value(
        value: mockArticleProvider,
        child: const EdukasiPage(),
      ),
    );
  }

  testWidgets('EdukasiPage menyuguhkan judul dan pesan saat data kosong', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    // Tunggu post frame callback berjalan (fetchArticles di initState)
    await tester.pump(); 

    // Cek judul di AppBar
    expect(find.text('Edukasi Gizi'), findsOneWidget);
    
    // Cek pesan saat tidak ada artikel (Empty State)
    expect(find.text('Belum ada artikel edukasi saat ini.'), findsOneWidget);
  });
}
