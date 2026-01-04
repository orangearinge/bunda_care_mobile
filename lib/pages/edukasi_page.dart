import 'package:flutter/material.dart';

class EdukasiPage extends StatelessWidget {
  const EdukasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Colors.pink.shade400;

    // Daftar artikel dummy
    final List<Map<String, dynamic>> articles = [
      {
        'title': 'Kebutuhan Protein Ibu Hamil Trimester 1',
        'subtitle': 'Pentingnya asam folat dan zat besi.',
        'icon': Icons.pregnant_woman,
        'color': Colors.pink.shade400,
      },
      {
        'title': 'Menu MPASI Pertama: Mulai dengan Bubur Tunggal',
        'subtitle': 'Panduan langkah demi langkah MPASI untuk 6 bulan.',
        'icon': Icons.baby_changing_station,
        'color': Colors.pink.shade300,
      },
      {
        'title': 'Mencegah Stunting Sejak Dini',
        'subtitle': 'Peran gizi seimbang selama 1000 hari pertama kehidupan.',
        'icon': Icons.height,
        'color': Colors.pink.shade500,
      },
      {
        'title': 'Snack Sehat untuk Balita Aktif',
        'subtitle': 'Resep mudah dan bergizi tinggi.',
        'icon': Icons.apple,
        'color': Colors.pink.shade200,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edukasi Gizi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pink[400]!, Colors.pink[200]!],
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Kolom Pencarian (Search Bar)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Cari artikel, resep, atau tips gizi...",
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Judul Bagian Artikel
            const Text(
              "Artikel Terbaru",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Daftar Artikel (ListView.builder untuk efisiensi)
            ListView.builder(
              shrinkWrap: true, // Agar ListView menyesuaikan tinggi kontennya
              physics:
                  const NeverScrollableScrollPhysics(), // Agar tidak konflik dengan SingleChildScrollView utama
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return _buildArticleCard(
                  context,
                  title: article['title'],
                  subtitle: article['subtitle'],
                  icon: article['icon'],
                  color: article['color'],
                );
              },
            ),

            const SizedBox(height: 20),

            // Tambahan Artikel Lain (Opsional)
            Text(
              "Lihat Semua Topik",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk membuat kartu artikel
  Widget _buildArticleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // Aksi ketika artikel diklik
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Membuka artikel: $title')));
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              // Ikon yang berwarna
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 15),
              // Judul dan Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
