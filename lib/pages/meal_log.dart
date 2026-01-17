import 'package:flutter/material.dart';
import '../utils/styles.dart';

class MealLogPage extends StatelessWidget {
  final String makanan;
  final String nutrisi;
  final String protein;

  const MealLogPage({
    super.key,
    required this.makanan,
    required this.nutrisi,
    required this.protein,
  });

  // Mock data for recommendations based on the scanned item
  List<Map<String, String>> _getRecommendations(String item) {
    if (item.toLowerCase().contains("ayam")) {
      return [
        {
          "title": "Bubur Ayam Wortel",
          "desc": "Bubur lembut dengan suwiran ayam dan potongan wortel manis.",
          "time": "20 Menit",
          "cal": "150 kkal"
        },
        {
          "title": "Tim Ayam Brokoli",
          "desc": "Nasi tim dengan kaldu ayam asli dan cincangan brokoli segar.",
          "time": "30 Menit",
          "cal": "180 kkal"
        },
        {
          "title": "Sup Ayam Jagung",
          "desc": "Sup bening kaya nutrisi untuk meningkatkan imun si kecil.",
          "time": "25 Menit",
          "cal": "140 kkal"
        },
      ];
    } else if (item.toLowerCase().contains("ikan")) {
      return [
        {
          "title": "Tim Ikan Kembung",
          "desc": "Ikan kembung kaya Omega-3 dikukus dengan jahe dan bawang.",
          "time": "25 Menit",
          "cal": "160 kkal"
        },
        {
          "title": "Bubur Ikan Bayam",
          "desc": "Kombinasi protein ikan dan zat besi dari bayam.",
          "time": "15 Menit",
          "cal": "130 kkal"
        },
      ];
    } else if (item.toLowerCase().contains("telur")) {
      return [
        {
          "title": "Orak-arik Telur Sayur",
          "desc": "Telur dadar oseng dengan irisan wortel dan buncis halus.",
          "time": "10 Menit",
          "cal": "110 kkal"
        },
        {
          "title": "Telur Rebus Saus Tomat",
          "desc": "Telur rebus matang dengan saus tomat alami buatan rumah.",
          "time": "15 Menit",
          "cal": "100 kkal"
        },
      ];
    } else if (item.toLowerCase().contains("sayur")) {
      return [
        {
          "title": "Sup Pelangi Wortel Kentang",
          "desc": "Sup bening gurih dengan potongan sayuran lembut.",
          "time": "20 Menit",
          "cal": "90 kkal"
        },
        {
          "title": "Puree Bayam Jagung",
          "desc": "Tekstur sangat halus, kaya akan zat besi dan serat.",
          "time": "15 Menit",
          "cal": "85 kkal"
        },
      ];
    } else {
      return [
        {
          "title": "Nasi Tim Sayur Spesial",
          "desc": "Nasi tim dengan campuran berbagai sayuran nutrisi lengkap.",
          "time": "20 Menit",
          "cal": "120 kkal"
        },
        {
          "title": "Puree Buah Campur",
          "desc": "Kombinasi buah pilihan untuk camilan sehat si kecil.",
          "time": "10 Menit",
          "cal": "80 kkal"
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = _getRecommendations(makanan);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Rekomendasi Menu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppStyles.pinkGradient,
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppStyles.pinkGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Berdasarkan Scan:",
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            Text(
                              makanan,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniInfo("Protein", protein),
                      _buildMiniInfo("Nutrisi", nutrisi),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Recommendations Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                "Menu Rekomendasi Hari Ini",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Recommendations List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = recommendations[index];
                  return _buildRecommendationCard(context, item);
                },
                childCount: recommendations.length,
              ),
            ),
          ),

          // Nutrition Tips section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue[400]),
                      const SizedBox(width: 8),
                      const Text(
                        "Tips Nutrisi Si Kecil",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Pastikan makanan diolah dengan tingkat kelembutan yang sesuai dengan usia si kecil. Hindari penggunaan garam dan gula berlebih pada MPASI.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.pink[50]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Membuka resep ${item['title']}..."),
                backgroundColor: Colors.pink[300],
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 100,
                    color: Colors.pink[50],
                    child: Center(
                      child: Icon(Icons.flatware, color: Colors.pink[200], size: 40),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['desc']!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.pink[300]),
                              const SizedBox(width: 4),
                              Text(item['time']!, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 16),
                              Icon(Icons.local_fire_department, size: 14, color: Colors.orange[300]),
                              const SizedBox(width: 4),
                              Text(item['cal']!, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
