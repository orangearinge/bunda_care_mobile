import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_preference_provider.dart';
import '../services/user_service.dart';
import '../models/dashboard_summary.dart';
import 'rekomendasi_page.dart';
import 'meal_log_page.dart';
import 'food_detail_page.dart';
import 'history_page.dart';
import '../widgets/shimmer_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/styles.dart';



class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _fetchDashboardData() async {
    await context.read<UserPreferenceProvider>().fetchDashboardSummary();
  }

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    // GoRouter will automatically redirect to login
  }


  @override
  Widget build(BuildContext context) {
    // Watch only the profileUpdated flag at the top level to trigger the side effect.
    // However, it's better to wrap this in a Selector if we want to avoid full rebuild.
    // For now, let's keep it minimal.
    final profileUpdated =
        context.select<UserPreferenceProvider, bool>((p) => p.profileUpdated);

    if (profileUpdated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchDashboardData();
        context.read<UserPreferenceProvider>().resetProfileUpdatedFlag();
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchDashboardData,
          color: Colors.pink,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                          // User Info Section - Optimized with Selector
                          Selector2<AuthProvider, UserPreferenceProvider,
                              ({String name, String? dashboardName})>(
                            selector: (_, auth, pref) => (
                              name: auth.currentUser?.name ?? "Pengguna",
                              dashboardName: pref.dashboardSummary?.user.name,
                            ),
                            builder: (context, data, _) {
                              return Column(
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
                                    data.dashboardName ?? data.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          Row(
                            children: [
                              // Loading indicator - Optimized with Selector
                              Selector<UserPreferenceProvider, bool>(
                                selector: (_, p) => p.isLoading,
                                builder: (context, isLoading, _) {
                                  if (!isLoading) return const SizedBox.shrink();
                                  return const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: ShimmerCircle(size: 20),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.grey,
                                ),
                                onPressed: _fetchDashboardData,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.history,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HistoryPage(),
                                    ),
                                  );
                                },
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
                                icon: Icon(
                                  Icons.logout,
                                  color: Colors.pink[300],
                                ),
                                onPressed: () => _logout(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Selector<UserPreferenceProvider, DashboardSummary?>(
                      selector: (_, p) => p.dashboardSummary,
                      builder: (context, dashboardSummary, _) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppStyles.pinkGradient,
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
                                      child: Text(
                                        dashboardSummary?.user.statusText ?? "Kesehatan Ibu & Bayi",
                                        style: const TextStyle(
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
                        );
                      },
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
              Selector<UserPreferenceProvider,
                  ({bool isLoading, DashboardSummary? summary})>(
                selector: (_, p) =>
                    (isLoading: p.isLoading, summary: p.dashboardSummary),
                builder: (context, data, _) {
                  final isLoading = data.isLoading;
                  final dashboardSummary = data.summary;

                  return SizedBox(
                    height: 220,
                    child: isLoading && dashboardSummary == null
                        ? ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) =>
                                const FoodCardSkeleton(),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount:
                                dashboardSummary?.recommendations.length ?? 0,
                            itemBuilder: (context, index) {
                              final rec =
                                  dashboardSummary!.recommendations[index];
                              final colors = [
                                Colors.green,
                                Colors.teal,
                                Colors.orange,
                                Colors.amber,
                              ];
                              return _buildRekomendasiCard(
                                context,
                                rec,
                                colors[index % colors.length],
                              );
                            },
                          ),
                  );
                },
              ),
              Selector<UserPreferenceProvider, DashboardSummary?>(
                selector: (_, p) => p.dashboardSummary,
                builder: (context, dashboardSummary, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
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
                                  MaterialPageRoute(
                                    builder: (_) => const MealLogPage(),
                                  ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
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
                                      final percentage = dashboardSummary?.caloriePercentage ?? 0;

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
                                                    value:
                                                        percentage.toDouble(),
                                                    showTitle: false,
                                                    radius: 15,
                                                  ),
                                                  PieChartSectionData(
                                                    color: Colors.pink[50],
                                                    value: (100 - percentage)
                                                        .toDouble(),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.pink[400],
                                                    ),
                                                  ),
                                                  const Text(
                                                    "Kalori",
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          dashboardSummary?.proteinPercentage ?? 0,
                                          Colors.orange,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildNutrientSmallProgress(
                                          "Karbo",
                                          dashboardSummary?.carbsPercentage ?? 0,
                                          Colors.blue,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildNutrientSmallProgress(
                                          "Lemak",
                                          dashboardSummary?.fatPercentage ?? 0,
                                          Colors.teal,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (dashboardSummary != null) ...[
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildRemainingItem(
                                      "Sisa Kalori",
                                      "${dashboardSummary.remaining.calories} kkal",
                                      Icons.local_fire_department,
                                      Colors.pink[300]!,
                                    ),
                                    _buildRemainingItem(
                                      "Protein",
                                      "${dashboardSummary.remaining.proteinG.toStringAsFixed(1)}g",
                                      Icons.egg_outlined,
                                      Colors.orange[300]!,
                                    ),
                                    _buildRemainingItem(
                                      "Karbo",
                                      "${dashboardSummary.remaining.carbsG.toStringAsFixed(1)}g",
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildRekomendasiCard(
    BuildContext context,
    DashboardRecommendation rec,
    Color accentColor,
  ) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showFoodDetail(context, rec, accentColor),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: rec.imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ShimmerImage(
                          width: double.infinity,
                          height: 120,
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.grey,
                          ),
                        ),
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
                            color: Colors.white.withOpacity(0.9),
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
                                "${rec.calories} kkal",
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
                        rec.name,
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
                        rec.description,
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFoodDetail(
    BuildContext context,
    DashboardRecommendation rec,
    Color accentColor,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodDetailPage(menuId: rec.id),
      ),
    );
  }


  Widget _buildNutrientSmallProgress(
    String label,
    double progress,
    Color color,
  ) {
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
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }
}
