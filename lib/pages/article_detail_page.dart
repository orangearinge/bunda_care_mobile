import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/article_provider.dart';
import '../models/article.dart'; // Add this import

class ArticleDetailPage extends StatefulWidget {
  final String slug;

  const ArticleDetailPage({Key? key, required this.slug}) : super(key: key);

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleProvider>().fetchArticleDetail(widget.slug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ArticleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text("Error: ${provider.error}")),
            );
          }

          final article = provider.selectedArticle;
          if (article == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text("Artikel tidak ditemukan")),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: article.coverImage != null
                      ? CachedNetworkImage(
                          imageUrl: article.coverImage!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[200]),
                          errorWidget: (context, url, _) =>
                              Container(color: Colors.grey[300]),
                        )
                      : Container(color: Colors.grey[300]),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            article.publishedAt != null
                                ? DateFormat(
                                    "d MMMM yyyy",
                                  ).format(article.publishedAt!)
                                : "Draft",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Html(
                        data: article.content ?? "",
                        style: {
                          "body": Style(
                            fontSize: FontSize(16),
                            lineHeight: LineHeight(1.6),
                            margin: Margins.zero,
                          ),
                          "h1": Style(
                            fontSize: FontSize(22),
                            fontWeight: FontWeight.bold,
                          ),
                          "h2": Style(
                            fontSize: FontSize(20),
                            fontWeight: FontWeight.bold,
                          ),
                          "h3": Style(
                            fontSize: FontSize(18),
                            fontWeight: FontWeight.bold,
                          ),
                          "img": Style(
                            width: Width(100, Unit.percent),
                            height: Height.auto(),
                            padding: HtmlPaddings.symmetric(vertical: 10),
                          ),
                          "blockquote": Style(
                            backgroundColor: Colors.grey[100],
                            border: const Border(
                              left: BorderSide(color: Colors.blue, width: 4),
                            ),
                            padding: HtmlPaddings.all(10),
                            margin: Margins.symmetric(vertical: 10),
                          ),
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
