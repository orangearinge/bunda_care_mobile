import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bunda_care/providers/auth_provider.dart';
import 'package:bunda_care/providers/article_provider.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockArticleProvider extends Mock implements ArticleProvider {}
