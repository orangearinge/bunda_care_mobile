import 'package:flutter/material.dart';

// --- Data Dummy Rekomendasi ---
// Fungsi atau Map untuk mendapatkan rekomendasi berdasarkan waktu makan
String getRecommendation(String mealTime) {
  final Map<String, String> dummyRecommendations = {
    'lunch':
        "🥗 Menu Makan Siang:\n- Nasi Merah (1 porsi)\n- Ayam Panggang (1 potong tanpa kulit)\n- Tumis Buncis dan Wortel\n- Buah (Pisang)",
    'dinner':
        "🍽️ Menu Makan Malam:\n- Sup Ikan Fillet (Tanpa santan)\n- Kentang Rebus (1 buah kecil)\n- Salad Timun Tomat\n- Air Putih Hangat",
    'breakfast':
        "☀️ Menu Sarapan:\n- Oatmeal (1 mangkuk)\n- 1 Telur Rebus\n- Segelas Susu Rendah Lemak\n- Buah Berry",
  };
  return dummyRecommendations[mealTime] ?? "Pilihan waktu makan tidak valid.";
}

class RekomendasiPage extends StatefulWidget {
  // Terima mealType Awal dari ScanPage (seharusnya selalu 'lunch' dari ScanPage)
  final String mealType;
  const RekomendasiPage({super.key, required this.mealType});

  @override
  _RekomendasiPageState createState() => _RekomendasiPageState();
}

class _RekomendasiPageState extends State<RekomendasiPage> {
  // State yang akan menyimpan pilihan waktu makan saat ini (default-nya 'lunch')
  late String _selectedMealTime;

  // Daftar opsi waktu makan untuk Dropdown
  final List<String> _mealTimes = ['lunch', 'dinner', 'breakfast'];

  @override
  void initState() {
    super.initState();
    // Inisialisasi state dengan nilai yang dikirim dari widget sebelumnya
    _selectedMealTime = widget.mealType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Judul AppBar menyesuaikan dengan pilihan yang sedang aktif
        title: Text("Rekomendasi ${_selectedMealTime.toUpperCase()}"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pink[400]!, Colors.pink[200]!],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Dropdown Menu di Kanan ---
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  color: Colors.pink[100],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButton<String>(
                  value: _selectedMealTime,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.pink),
                  underline: Container(), // Menghilangkan garis bawah default
                  style: TextStyle(color: Colors.pink[900], fontSize: 16),

                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      // Gunakan setState untuk mengubah pilihan dan me-refresh UI
                      setState(() {
                        _selectedMealTime = newValue;
                      });
                    }
                  },

                  items: _mealTimes.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- Area Konten Rekomendasi ---
            // Teks yang akan berubah sesuai dengan pilihan drop-down
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                // Panggil fungsi untuk mendapatkan rekomendasi dummy
                getRecommendation(_selectedMealTime),
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),

            const SizedBox(height: 30),

            // Teks statis tambahan dari screenshot
            Center(
              child: Text(
                "ini halaman rekomendasi makanan untuk $_selectedMealTime",
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
