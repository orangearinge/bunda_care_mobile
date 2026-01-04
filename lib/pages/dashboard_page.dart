import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../models/dashboard_summary.dart';
import '../utils/constants.dart';
import 'rekomendasi_page.dart';
import 'scan_page.dart';
import 'chatbot_page.dart';
import 'edukasi_page.dart';
import 'profile_page.dart';
import 'meal_log_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  DashboardSummary? _dashboardSummary;
  bool _isLoading = true;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final summary = await _userService.getDashboardSummary();
      if (mounted) {
        setState(() {
          _dashboardSummary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (ApiConstants.isDevelopment) {
        print('DASHBOARD FETCH ERROR: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Welcome Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Halo, Bunda 👋",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _dashboardSummary?.user.name ?? userName,
                              style: GoogleFonts.poppins(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (_isLoading)
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.pink,
                                    ),
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.grey),
                              onPressed: _fetchDashboardData,
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
                      ],
                    ),
                    const SizedBox(height: 30),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pilihan Untuk Bunda",
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Horizontal Recommendations List
              SizedBox(
                height: 220,
                child: _isLoading && _dashboardSummary == null
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _dashboardSummary?.recommendations.length ?? 0,
                        itemBuilder: (context, index) {
                          final rec = _dashboardSummary!.recommendations[index];
                          final colors = [
                            Colors.green,
                            Colors.teal,
                            Colors.orange,
                            Colors.amber
                          ];
                          return _buildRekomendasiCard(
                            rec.name,
                            "${rec.calories} kkal",
                            rec.description,
                            rec.imageUrl,
                            colors[index % colors.length],
                          );
                        },
                      ),
              ),
              // Nutrition Analysis Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pencapaian Target Gizi",
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
                              MaterialPageRoute(builder: (_) => const MealLogPage()),
                            );
                          },
                          child: Text(
                            "Daftar Rencana",
                            style: TextStyle(
                              color: Colors.pink[300],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Builder(
                                builder: (context) {
                                  final consumed =
                                      _dashboardSummary?.todayNutrition.calories ?? 0;
                                  final target =
                                      _dashboardSummary?.targets.calories ?? 1;
                                  final percentage = (consumed / target * 100).clamp(0, 100).toInt();
                                  
                                  return SizedBox(
                                    height: 120,
                                    width: 120,
                                    child: Stack(
                                      children: [
                                        PieChart(
                                          PieChartData(
                                            sectionsSpace: 0,
                                            centerSpaceRadius: 35,
                                            startDegreeOffset: -90,
                                            sections: [
                                              PieChartSectionData(
                                                color: Colors.pink[400],
                                                value: percentage.toDouble(),
                                                showTitle: false,
                                                radius: 15,
                                              ),
                                              PieChartSectionData(
                                                color: Colors.pink[50],
                                                value: (100 - percentage).toDouble(),
                                                showTitle: false,
                                                radius: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "$percentage%",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.pink[400],
                                                ),
                                              ),
                                              const Text(
                                                "Kalori",
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Status Kebutuhan Gizi",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      "Berdasarkan preferensi Bunda",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildNutrientSmallProgress(
                                      "Protein",
                                      _dashboardSummary?.todayNutrition.proteinG ?? 0,
                                      _dashboardSummary?.targets.proteinG ?? 1,
                                      Colors.orange,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildNutrientSmallProgress(
                                      "Karbo",
                                      _dashboardSummary?.todayNutrition.carbsG ?? 0,
                                      _dashboardSummary?.targets.carbsG ?? 1,
                                      Colors.blue,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildNutrientSmallProgress(
                                      "Lemak",
                                      _dashboardSummary?.todayNutrition.fatG ?? 0,
                                      _dashboardSummary?.targets.fatG ?? 1,
                                      Colors.teal,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_dashboardSummary != null) ...[
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildRemainingItem(
                                  "Sisa Kalori",
                                  "${_dashboardSummary!.remaining.calories} kkal",
                                  Icons.local_fire_department,
                                  Colors.pink[300]!,
                                ),
                                _buildRemainingItem(
                                  "Protein",
                                  "${_dashboardSummary!.remaining.proteinG.toStringAsFixed(1)}g",
                                  Icons.egg_outlined,
                                  Colors.orange[300]!,
                                ),
                                _buildRemainingItem(
                                  "Karbo",
                                  "${_dashboardSummary!.remaining.carbsG.toStringAsFixed(1)}g",
                                  Icons.bakery_dining_outlined,
                                  Colors.blue[300]!,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
  Widget _buildNutrientSmallProgress(
    String label,
    double consumed,
    double target,
    Color color,
  ) {
    double progress = (consumed / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String text,
    required String subText,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              subText,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
