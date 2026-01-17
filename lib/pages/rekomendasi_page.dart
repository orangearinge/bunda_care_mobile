import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import 'meal_log_page.dart';
import 'food_detail_page.dart';
import '../widgets/shimmer_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/styles.dart';



class RekomendasiPage extends StatefulWidget {
  final String mealType;
  final List<int>? detectedIds;

  const RekomendasiPage({
    super.key,
    required this.mealType,
    this.detectedIds,
  });

  @override
  _RekomendasiPageState createState() => _RekomendasiPageState();
}

class _RekomendasiPageState extends State<RekomendasiPage> {
  late String _selectedMealType;
  final List<String> _mealTypes = ['BREAKFAST', 'LUNCH', 'DINNER'];

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType.toUpperCase();
    
    // Fetch initial recommendations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    context.read<FoodProvider>().fetchRecommendations(
      mealType: _selectedMealType,
      detectedIds: widget.detectedIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: Text("Rekomendasi ${_selectedMealType}"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppStyles.pinkGradient,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, child) {
          return Column(
            children: [
              // --- Header & Dropdown ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pilih Waktu Makan:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.pink[200]!),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedMealType,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.pink),
                        underline: Container(),
                        style: TextStyle(color: Colors.pink[900], fontSize: 16),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedMealType = newValue;
                            });
                            _fetchData();
                          }
                        },
                        items: _mealTypes.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Content ---
              Expanded(
                child: foodProvider.isLoading
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 3,
                        itemBuilder: (context, index) => const MenuCardSkeleton(),
                      )
                    : foodProvider.errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  foodProvider.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchData,
                                  child: const Text("Coba Lagi"),
                                ),
                              ],
                            ),
                          )
                        : _buildRecommendationList(foodProvider.recommendations),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecommendationList(Map<String, dynamic>? data) {
    if (data == null || data['recommendations'] == null || (data['recommendations'] as List).isEmpty) {
      return const Center(
        child: Text("Tidak ada rekomendasi yang sesuai dengan preferensi Anda."),
      );
    }

    final recommendations = data['recommendations'] as List;
    // The backend returns a list of objects per meal type
    // Since we filter by meal type, we take the first matching one
    final currentMealRec = recommendations.firstWhere(
      (r) => r['meal_type'] == _selectedMealType,
      orElse: () => null,
    );

    if (currentMealRec == null || (currentMealRec['options'] as List).isEmpty) {
      return const Center(
        child: Text("Tidak ada opsi menu untuk waktu makan ini."),
      );
    }

    final options = currentMealRec['options'] as List;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        return _buildMenuCard(option);
      },
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> option) {
    final nutrition = option['nutrition'];
    final ingredients = option['ingredients'] as List;
    final imageUrl = option['image_url'] as String?;
    final menuId = option['menu_id'] as int;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodDetailPage(menuId: menuId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerImage(
                  width: double.infinity,
                  height: 180,
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.restaurant,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        option['menu_name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${nutrition['calories'].toInt()} kkal",
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Bahan: ${ingredients.map((i) => i['name']).join(', ')}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientInfo("Protein", "${nutrition['protein_g'].toStringAsFixed(1)}g"),
                    _buildNutrientInfo("Karbo", "${nutrition['carbs_g'].toStringAsFixed(1)}g"),
                    _buildNutrientInfo("Lemak", "${nutrition['fat_g'].toStringAsFixed(1)}g"),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              final success = await context.read<FoodProvider>().logMeal(
                menuId: option['menu_id'],
                isConsumed: false,
              );
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${option['menu_name']} ditambahkan ke rencana makan'),
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
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: AppStyles.pinkGradient,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: const Center(
                child: Text(
                  "TAMBAH KE RENCANA MAKAN",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }


  Widget _buildNutrientInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
