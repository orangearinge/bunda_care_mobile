import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../providers/user_preference_provider.dart';
import '../widgets/shimmer_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';


class MealLogPage extends StatefulWidget {
  const MealLogPage({super.key});

  @override
  State<MealLogPage> createState() => _MealLogPageState();
}

class _MealLogPageState extends State<MealLogPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().fetchMealLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Rencana Makan Bunda",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FoodProvider>().fetchMealLogs(),
          ),
        ],
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, child) {
          if (foodProvider.isLoading && foodProvider.mealLogs.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 5,
              itemBuilder: (context, index) => const MealLogSkeleton(),
            );
          }

          if (foodProvider.mealLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada rencana makan",
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[300],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cari Rekomendasi"),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => foodProvider.fetchMealLogs(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: foodProvider.mealLogs.length,
              itemBuilder: (context, index) {
                final log = foodProvider.mealLogs[index];
                return _buildMealLogCard(log, foodProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealLogCard(Map<String, dynamic> log, FoodProvider provider) {
    final bool isConsumed = log['is_consumed'] ?? false;
    final String menuName = log['menu_name'] ?? 'Menu';
    final String calories = "${log['total']['calories']} kkal";
    final int logId = log['meal_log_id'];

    final String? imageUrl = log['image_url'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerImage(
                        width: 60,
                        height: 60,
                        borderRadius: 12,
                      ),
                      errorWidget: (_, __, ___) => _buildIconPlaceholder(isConsumed),
                    ),
                  )
                else
                  _buildIconPlaceholder(isConsumed),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menuName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        calories,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (isConsumed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Selesai",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Terencana",
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          if (!isConsumed)
            InkWell(
              onTap: () async {
                final prefProvider = context.read<UserPreferenceProvider>();
                final summary = prefProvider.dashboardSummary;

                if (summary != null) {
                  final currentCalories = summary.todayNutrition.calories;
                  final targetCalories = summary.targets.calories;
                  final menuCalories = log['total']['calories'] ?? 0;

                  if (currentCalories >= targetCalories || (currentCalories + menuCalories) > targetCalories) {
                    final bool? proceed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            const Text("Target Terpenuhi"),
                          ],
                        ),
                        content: Text(
                          currentCalories >= targetCalories
                              ? "Bunda sudah memenuhi target kalori hari ini. Tetap ingin mengonfirmasi makanan ini?"
                              : "Mengonfirmasi makanan ini akan membuat asupan kalori Bunda melebihi target harian. Tetap simpan?",
                          style: GoogleFonts.poppins(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Batal", style: TextStyle(color: Colors.grey[600])),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Tetap Konfirmasi"),
                          ),
                        ],
                      ),
                    );

                    if (proceed != true) return;
                  }
                }

                final success = await provider.confirmMeal(logId);
                if (success && mounted) {
                  // Refresh global nutritional data
                  context.read<UserPreferenceProvider>().fetchDashboardSummary();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selamat Makan! Gizi Anda telah diperbarui.')),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.pink[300],
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: const Center(
                  child: Text(
                    "KONFIRMASI MAKAN",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconPlaceholder(bool isConsumed) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isConsumed ? Colors.green[50] : Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isConsumed ? Icons.check_circle : Icons.schedule,
        color: isConsumed ? Colors.green : Colors.pink[300],
      ),
    );
  }
}
