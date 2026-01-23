import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/styles.dart';
import 'rekomendasi_page.dart';
import '../models/scan_result.dart';

class ScanResultPage extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imagePath;
  final ScanResult results;

  const ScanResultPage({
    super.key,
    this.imageBytes,
    this.imagePath,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final List<int> detectedIds = results.detectedIds;

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text("Hasil Scan"),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppStyles.pinkGradient),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Hero section with food image
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (imageBytes != null || imagePath != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      child: kIsWeb
                          ? Image.memory(
                              imageBytes!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(imagePath!),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (imageBytes == null && imagePath == null)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.pink[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.fastfood,
                              size: 80,
                              color: Colors.pink[300],
                            ),
                          ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: results.detectedItems
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.pink[50],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.pink[200]!,
                                    ),
                                  ),
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink[800],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          results.detectedItems.isEmpty
                              ? "Tidak ada makanan terdeteksi"
                              : "Identifikasi Terdeteksi",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Nutrition Candidates
            if (results.candidates.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 12),
                    child: Text(
                      "Detail Nutrisi (estimasi per 100g)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...results.candidates.map((c) => _buildCandidateTile(c)),
                ],
              ),

            const SizedBox(height: 40),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RekomendasiPage(
                        mealType: 'lunch',
                        detectedIds: detectedIds,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: Colors.pink.withValues(alpha: 0.3),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppStyles.pinkGradient,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "LIHAT REKOMENDASI",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Scan Ulang",
                style: TextStyle(
                  color: Colors.pink[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateTile(FoodCandidate candidate) {
    final nutrition = candidate.nutrition;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Kalori: ${nutrition.calories} kkal",
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "P: ${nutrition.proteinG}g",
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                "K: ${nutrition.carbsG}g",
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                "L: ${nutrition.fatG}g",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
