
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/article_provider.dart';
import '../widgets/article_card.dart';
import 'article_detail_page.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/offline_placeholder.dart';
import '../utils/styles.dart';

class EdukasiPage extends StatefulWidget {
  const EdukasiPage({super.key});

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure we have data
      final provider = context.read<ArticleProvider>();
      if (provider.articles.isEmpty) {
        provider.fetchArticles(refresh: true);
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<ArticleProvider>();
        if (!provider.isLoadingMore && provider.hasMore) {
          provider.fetchArticles();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edukasi Gizi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppStyles.pinkGradient,
          ),
        ),
        elevation: 0,
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.articles.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) => const ArticleCardSkeleton(),
            );
          }

          if (provider.error != null && provider.articles.isEmpty) {
            return OfflinePlaceholder(
              message: 'Gagal memuat artikel: ${provider.error}',
              onRetry: () => provider.fetchArticles(refresh: true),
            );
          }

          if (provider.articles.isEmpty) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Belum ada artikel edukasi saat ini.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchArticles(refresh: true),
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                     child: const Text('Refresh', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchArticles(refresh: true),
            color: Colors.pink,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.articles.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                 if (index == provider.articles.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: ShimmerCircle(size: 30)),
                  );
                }

                final article = provider.articles[index];
                return ArticleCard(
                  article: article,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailPage(slug: article.slug),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
