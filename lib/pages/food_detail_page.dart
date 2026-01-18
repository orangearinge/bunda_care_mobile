import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/food_detail.dart';
import '../models/api_error.dart';
import '../services/food_service.dart';
import '../providers/food_provider.dart';
import '../providers/user_preference_provider.dart';
import 'meal_log_page.dart';
import '../widgets/shimmer_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/offline_placeholder.dart';
import '../utils/styles.dart';


class FoodDetailPage extends StatefulWidget {
  final int menuId;

  const FoodDetailPage({
    super.key,
    required this.menuId,
  });

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFoodDetail();
      _fetchDashboardData();
    });
  }

  Future<void> _fetchDashboardData() async {
    final prefProvider = context.read<UserPreferenceProvider>();
    // Refresh dashboard data to get current consumption
    await prefProvider.fetchDashboardSummary();
  }

  Future<void> _fetchFoodDetail() async {
    context.read<FoodProvider>().fetchFoodDetail(widget.menuId);
  }

  Future<void> _addToMealPlan(bool isConsumed) async {
    final foodProvider = context.read<FoodProvider>();
    final foodDetail = foodProvider.selectedFoodDetail;
    if (foodDetail == null) return;

    if (isConsumed) {
      final prefProvider = context.read<UserPreferenceProvider>();
      final summary = prefProvider.dashboardSummary;

      if (summary != null) {
        final newCalories = foodDetail.nutrition.calories;

        // Jika sudah melebihi atau akan melebihi target
        if (summary.isTargetMet() || summary.wouldExceedTarget(newCalories)) {
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
                summary.isTargetMet()
                    ? "Bunda sudah memenuhi target gizi hari ini. Tetap ingin mencatat makanan ini?"
                    : "Mencatat makanan ini akan membuat asupan kalori Bunda melebihi target harian. Tetap simpan?",
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Batal", style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (context.mounted) Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppStyles.pinkGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: const Text("Tetap Simpan", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          );

          if (proceed != true) return;
        }
      }
    }

    final success = await foodProvider.logMeal(
          menuId: foodDetail.id,
          isConsumed: isConsumed,
        );

    if (mounted && success) {
      // Refresh dashboard summary in provider after logging
      context.read<UserPreferenceProvider>().fetchDashboardSummary();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isConsumed
                ? '${foodDetail.name} ditandai sudah dikonsumsi'
                : '${foodDetail.name} ditambahkan ke rencana makan',
          ),
          action: SnackBarAction(
            label: 'Lihat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MealLogPage()),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        final foodDetail = foodProvider.selectedFoodDetail;
        final isLoading = foodProvider.isLoading;
        final errorMessage = foodProvider.errorMessage;

        return Scaffold(
          backgroundColor: Colors.pink[50],
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: AppStyles.pinkGradient,
              ),
            ),
            foregroundColor: Colors.white,
            title: Text(
              foodDetail?.name ?? 'Detail Makanan',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 0,
          ),
          body: isLoading && foodDetail == null
              ? const FoodDetailSkeleton()
                  : errorMessage != null
                  ? _buildErrorState(errorMessage)
                  : _buildContent(foodDetail),
        );
      },
    );
  }

  Widget _buildErrorState(String errorMessage) {
    final isNetworkError = errorMessage.contains('koneksi') ||
        errorMessage.contains('timeout') ||
        errorMessage.contains('internet');

    if (isNetworkError) {
      return OfflinePlaceholder(
        onRetry: _fetchFoodDetail,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchFoodDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(FoodDetail? foodDetail) {
    if (foodDetail == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroImage(foodDetail),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(foodDetail),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                if (foodDetail.description != null &&
                    foodDetail.description!.isNotEmpty)
                  _buildDescription(foodDetail),
                const SizedBox(height: 20),
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildNutritionSection(foodDetail),
                const SizedBox(height: 24),
                _buildIngredientsSection(foodDetail),
                if (foodDetail.cookingInstructions != null &&
                    foodDetail.cookingInstructions!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildCookingInstructions(foodDetail),
                ],
                const SizedBox(height: 32),
                _buildActionButtons(foodDetail),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(FoodDetail foodDetail) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: foodDetail.imageUrl != null && foodDetail.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
              child: CachedNetworkImage(
                imageUrl: foodDetail.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerImage(
                  width: double.infinity,
                  height: 250,
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.restaurant,
                  size: 64,
                  color: Colors.grey[400],
                ),
              ),
            )
          : Icon(
              Icons.restaurant,
              size: 64,
              color: Colors.grey[400],
            ),
    );
  }

  Widget _buildHeader(FoodDetail foodDetail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                foodDetail.name,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (foodDetail.tags != null && foodDetail.tags!.isNotEmpty)
                _buildTags(foodDetail),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildCategoryBadge(foodDetail),
                  if (foodDetail.cookingTimeMinutes != null) ...[
                    const SizedBox(width: 8),
                    _buildTimeBadge(foodDetail),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildCalorieBadge(foodDetail),
      ],
    );
  }

  Widget _buildCategoryBadge(FoodDetail foodDetail) {
    final categoryColors = {
      'BREAKFAST': Colors.orange,
      'LUNCH': Colors.green,
      'DINNER': Colors.blue
    };

    final categoryLabels = {
      'BREAKFAST': 'BREAKFAST',
      'LUNCH': 'LUNCH',
      'DINNER': 'DINNER'
    };

    final color = categoryColors[foodDetail.category] ?? Colors.grey;
    final label = categoryLabels[foodDetail.category] ?? foodDetail.category;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeBadge(FoodDetail foodDetail) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            '${foodDetail.cookingTimeMinutes} mnt',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(FoodDetail foodDetail) {
    final tagsList = foodDetail.tags!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: tagsList.map((tag) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.pink[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.pink[100]!),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: Colors.pink[400],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCalorieBadge(FoodDetail foodDetail) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppStyles.pinkGradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '${foodDetail.nutrition.calories.toInt()} kkal',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(FoodDetail foodDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tentang Menu Ini',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          foodDetail.description!,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.grey[700],
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.pink[100]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.pink[400],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Menu ini disesuaikan dengan kebutuhan gizi harian Bunda berdasarkan profil kesehatan Bunda.',
              style: TextStyle(
                color: Colors.pink[700],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSection(FoodDetail foodDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Gizi',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildNutrientRow(
                'Kalori',
                '${foodDetail.nutrition.calories.toInt()}',
                'kkal',
                Icons.local_fire_department,
                Colors.pink,
              ),
              const Divider(height: 24),
              _buildNutrientRow(
                'Protein',
                foodDetail.nutrition.proteinG.toStringAsFixed(1),
                'g',
                Icons.egg_outlined,
                Colors.orange,
              ),
              const Divider(height: 24),
              _buildNutrientRow(
                'Karbohidrat',
                foodDetail.nutrition.carbsG.toStringAsFixed(1),
                'g',
                Icons.bakery_dining_outlined,
                Colors.blue,
              ),
              const Divider(height: 24),
              _buildNutrientRow(
                'Lemak',
                foodDetail.nutrition.fatG.toStringAsFixed(1),
                'g',
                Icons.water_drop_outlined,
                Colors.teal,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientRow(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          '$value $unit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection(FoodDetail foodDetail) {
    if (foodDetail.ingredients.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bahan-Bahan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: foodDetail.ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ingredient = entry.value;
              final isLast = index == foodDetail.ingredients.length - 1;

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.pink[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ingredient.name,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '${ingredient.quantity % 1 == 0 ? ingredient.quantity.toInt() : ingredient.quantity.toStringAsFixed(1)} ${ingredient.unit}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCookingInstructions(FoodDetail foodDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cara Memasak',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            foodDetail.cookingInstructions!,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(FoodDetail foodDetail) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () => _addToMealPlan(false),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              shadowColor: Colors.pink.withOpacity(0.3),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: AppStyles.pinkGradient,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'TAMBAH KE RENCANA MAKAN',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            onPressed: () => _addToMealPlan(true),
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              'TANDAI SUDAH DIKONSUMSI',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.pink[400],
              side: BorderSide(color: Colors.pink[400]!, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
