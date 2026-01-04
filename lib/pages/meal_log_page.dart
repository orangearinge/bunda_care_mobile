import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';

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
            return const Center(child: CircularProgressIndicator());
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
                    child: Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildIconPlaceholder(isConsumed),
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
                final success = await provider.confirmMeal(logId);
                if (success && mounted) {
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
