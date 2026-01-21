import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/history_entry.dart';
import '../providers/history_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/offline_placeholder.dart';
import '../utils/styles.dart';


class HistoryDetailPage extends StatefulWidget {
  final String date;
  final String formattedDate;

  const HistoryDetailPage({
    super.key,
    required this.date,
    required this.formattedDate,
  });

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetchHistoryDetail(widget.date);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.formattedDate,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppStyles.pinkGradient,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          final items = historyProvider.historyDetails;
          final isLoading = historyProvider.isLoading;
          final errorMessage = historyProvider.errorMessage;

          if ((isLoading || historyProvider.status == HistoryStatus.initial) && items.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            );
          }

          if (errorMessage != null && items.isEmpty) {
            return OfflinePlaceholder(
              message: errorMessage,
              onRetry: () => context
                  .read<HistoryProvider>()
                  .fetchHistoryDetail(widget.date),
            );
          }

          if (items.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildLogCard(items[index]);
            },
          );
        },
      ),
    );
  }



  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_meals_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Tidak ada makanan tercatat",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(HistoryDetailItem item) {
    final String timeStr = item.formattedTime;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.menuName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.pink[300],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item.calories} kkal",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMiniNutr("P", "${item.proteinG}g", Colors.orange),
                      const SizedBox(width: 12),
                      _buildMiniNutr("K", "${item.carbsG}g", Colors.blue),
                      const SizedBox(width: 12),
                      _buildMiniNutr("L", "${item.fatG}g", Colors.teal),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniNutr(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
