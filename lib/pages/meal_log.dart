import 'package:flutter/material.dart';

class MealLogPage extends StatelessWidget {
  final String makanan;
  final String nutrisi;
  final String protein;

  const MealLogPage({
    super.key,
    required this.makanan,
    required this.nutrisi,
    required this.protein,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Log"),
        backgroundColor: Colors.pink[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Makanan: $makanan", style: TextStyle(fontSize: 16)),
            Text("Nutrisi: $nutrisi", style: TextStyle(fontSize: 16)),
            Text("Protein: $protein", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
