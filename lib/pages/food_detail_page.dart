import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/food_detail.dart';
import '../models/api_error.dart';
import '../services/food_service.dart';
import '../providers/food_provider.dart';
import 'meal_log_page.dart';

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
  final FoodService _foodService = FoodService();
  FoodDetail? _foodDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFoodDetail();
  }

  Future<void> _fetchFoodDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _foodService.getFoodDetail(widget.menuId);
      setState(() {
        _foodDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e is ApiError ? e.message : 'Gagal memuat detail makanan';
      });
    }
  }

  Future<void> _addToMealPlan(bool isConsumed) async {
    if (_foodDetail == null) return;

    final success = await context.read<FoodProvider>().logMeal(
          menuId: _foodDetail!.id,
          isConsumed: isConsumed,
        );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isConsumed
                ? '${_foodDetail!.name} ditandai sudah dikonsumsi'
                : '${_foodDetail!.name} ditambahkan ke rencana makan',
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
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        foregroundColor: Colors.white,
        title: Text(
          _foodDetail?.name ?? 'Detail Makanan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
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
              _errorMessage!,
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

  Widget _buildContent() {
    if (_foodDetail == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroImage(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                if (_foodDetail!.description != null &&
                    _foodDetail!.description!.isNotEmpty)
                  _buildDescription(),
                const SizedBox(height: 20),
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildNutritionSection(),
                const SizedBox(height: 24),
                _buildIngredientsSection(),
                if (_foodDetail!.cookingInstructions != null &&
                    _foodDetail!.cookingInstructions!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildCookingInstructions(),
                ],
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: _foodDetail!.imageUrl != null && _foodDetail!.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
              child: Image.network(
                _foodDetail!.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.restaurant,
                  size: 64,
                  color: Colors.grey[400],
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            )
          : Icon(
              Icons.restaurant,
              size: 64,
              color: Colors.grey[400],
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _foodDetail!.name,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildCategoryBadge(),
                  if (_foodDetail!.cookingTimeMinutes != null) ...[
                    const SizedBox(width: 8),
                    _buildTimeBadge(),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildCalorieBadge(),
      ],
    );
  }

  Widget _buildCategoryBadge() {
    final categoryColors = {
      'BREAKFAST': Colors.orange,
      'LUNCH': Colors.green,
      'DINNER': Colors.blue,
      'SNACK': Colors.purple,
    };

    final categoryLabels = {
      'BREAKFAST': 'Sarapan',
      'LUNCH': 'Makan Siang',
      'DINNER': 'Makan Malam',
      'SNACK': 'Snack',
    };

    final color = categoryColors[_foodDetail!.category] ?? Colors.grey;
    final label = categoryLabels[_foodDetail!.category] ?? _foodDetail!.category;

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

  Widget _buildTimeBadge() {
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
            '${_foodDetail!.cookingTimeMinutes} mnt',
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

  Widget _buildCalorieBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink[400]!, Colors.pink[300]!],
        ),
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
            '${_foodDetail!.nutrition.calories.toInt()} kkal',
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

  Widget _buildDescription() {
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
          _foodDetail!.description!,
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

  Widget _buildNutritionSection() {
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
                '${_foodDetail!.nutrition.calories.toInt()}',
                'kkal',
                Icons.local_fire_department,
                Colors.pink,
              ),
              const Divider(height: 24),
              _buildNutrientRow(
                'Protein',
                _foodDetail!.nutrition.proteinG.toStringAsFixed(1),
                'g',
                Icons.egg_outlined,
                Colors.orange,
              ),
              const Divider(height: 24),
              _buildNutrientRow(
                'Karbohidrat',
                _foodDetail!.nutrition.carbsG.toStringAsFixed(1),
                'g',
                Icons.bakery_dining_outlined,
                Colors.blue,
              ),
              const Divider(height: 24),
              _buildNutrientRow(
                'Lemak',
                _foodDetail!.nutrition.fatG.toStringAsFixed(1),
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

  Widget _buildIngredientsSection() {
    if (_foodDetail!.ingredients.isEmpty) return const SizedBox.shrink();

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
            children: _foodDetail!.ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ingredient = entry.value;
              final isLast = index == _foodDetail!.ingredients.length - 1;

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

  Widget _buildCookingInstructions() {
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
            _foodDetail!.cookingInstructions!,
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () => _addToMealPlan(false),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'TAMBAH KE RENCANA MAKAN',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
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
            label: const Text(
              'TANDAI SUDAH DIKONSUMSI',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
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
