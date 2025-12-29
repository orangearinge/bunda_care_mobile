import 'package:flutter/material.dart';
import 'rekomendasi_page.dart';
import 'meal_log.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isScanned = false;
  String scannedItem = "";
  String nutrisi = "";
  String protein = "";

  // Fungsi simulasi hasil scan
  void _simulateScan() {
    setState(() {
      isScanned = true;
      scannedItem = "Ayam";
      nutrisi = "30%";
      protein = "40%";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text("Scan Makanan"),
        backgroundColor: Colors.pink[300],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // === Area Kamera ===
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.pink, width: 2),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.camera_alt, size: 50, color: Colors.pink),
                    SizedBox(height: 8),
                    Text(
                      "Arahkan kamera ke makanan",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text("untuk menganalisis nutrisinya"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === Info pencahayaan ===
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lightbulb, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Pastikan pencahayaan cukup untuk hasil terbaik",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // === Tombol Scan ===
            ElevatedButton.icon(
              onPressed: _simulateScan,
              icon: const Icon(Icons.camera),
              label: const Text("SCAN MAKANAN"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[300],
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === Hasil Scan (tampil setelah tombol ditekan) ===
            if (isScanned) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "📊 Hasil Scan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Makanan: $scannedItem",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Nutrisi: $nutrisi",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Protein: $protein",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // === Tombol ke Rekomendasi ===
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MealLogPage(
                                makanan: scannedItem,
                                nutrisi: nutrisi,
                                protein: protein,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text("Rekomendasi Makanan"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
