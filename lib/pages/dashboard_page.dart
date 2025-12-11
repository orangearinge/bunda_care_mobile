import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'rekomendasi_page.dart';
import 'scan_page.dart';
import 'chatbot_page.dart';
import 'edukasi_page.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    // GoRouter will automatically redirect to login
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi berdasarkan index
    switch (index) {
      case 0:
        // Home - sudah di dashboard
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScanPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EdukasiPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.name ?? "Pengguna";
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo, Bunda 👋",
                          style: GoogleFonts.poppins(
                            fontStyle:
                                AppBarThemeData().titleTextStyle?.fontStyle,

                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: GoogleFonts.poppins(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.logout, color: Colors.pink[300]),
                        onPressed: () => _logout(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Welcome Card dengan Gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.pink[300]!, Colors.purple[300]!],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Bundacare",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Analisis gizi Ibu dan anak",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Kesehatan Ibu & Bayi",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pregnant_woman,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Section Rekomendasi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Rekomendasi Hari Ini",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const RekomendasiPage(mealType: 'lunch'),
                          ),
                        );
                      },
                      child: Text(
                        "Lihat Semua",
                        style: TextStyle(
                          color: Colors.pink[300],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildRekomendasiCard(
                        "Sup Bayam Sehat",
                        "120 kkal",
                        "Tinggi zat besi",
                        "https://picsum.photos/200",
                        Colors.green,
                      ),
                      _buildRekomendasiCard(
                        "Tumis Brokoli Tofu",
                        "135 kkal",
                        "Kaya protein",
                        "https://picsum.photos/201",
                        Colors.teal,
                      ),
                      _buildRekomendasiCard(
                        "Bubur Labu Kuning",
                        "90 kkal",
                        "Vitamin A tinggi",
                        "https://picsum.photos/202",
                        Colors.orange,
                      ),
                      _buildRekomendasiCard(
                        "Sop Ayam Jahe",
                        "150 kkal",
                        "Hangat & bergizi",
                        "https://picsum.photos/203",
                        Colors.amber,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Pie Chart Section
                const SizedBox(height: 20),
                const Text(
                  "Analisis Asupan Gizi",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 199, 199, 199),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          color: Colors.pink[300],
                          value: 60, // <-- persentase tercukupi
                          title: 'Tercukupi\n60%',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.grey[300],
                          value: 40, // <-- persentase kurang
                          title: 'Kurang\n40%',
                          radius: 70,
                          titleStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
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
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, Icons.home, 0),
                _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 1),
                _buildNavItem(Icons.qr_code_scanner, Icons.qr_code_scanner, 2),
                _buildNavItem(
                  Icons.notifications_outlined,
                  Icons.notifications,
                  3,
                ),
                _buildNavItem(Icons.person_outline, Icons.person, 4),
              ],
            ),
          ),
        ),
      ),

    );
  }

  Widget _buildNavItem(IconData iconOutlined, IconData iconFilled, int index) {
    bool isSelected = _selectedIndex == index;

    // Warna gradient untuk setiap item
    List<Color> gradientColors;
    switch (index) {
      case 0:
        gradientColors = [Colors.pink[300]!, Colors.pink[400]!];
        break;
      case 1:
        gradientColors = [Colors.purple[300]!, Colors.purple[400]!];
        break;
      case 2:
        gradientColors = [Colors.blue[300]!, Colors.blue[400]!];
        break;
      case 3:
        gradientColors = [Colors.orange[300]!, Colors.orange[400]!];
        break;
      case 4:
        gradientColors = [Colors.teal[300]!, Colors.teal[400]!];
        break;
      default:
        gradientColors = [Colors.grey[300]!, Colors.grey[400]!];
    }

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isSelected ? iconFilled : iconOutlined,
          color: isSelected ? Colors.white : Colors.grey[400],
          size: 28,
        ),
      ),
    );
  }

  static Widget _buildRekomendasiCard(
    String nama,
    String kalori,
    String deskripsi,
    String imageUrl,
    Color accentColor,
  ) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: accentColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          kalori,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  deskripsi,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
