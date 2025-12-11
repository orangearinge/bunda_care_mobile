import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MultiStepFormPage extends StatefulWidget {
  final String userRole; // 'IbuHamil', 'IbuMenyusui', atau 'Batita'

  const MultiStepFormPage({Key? key, required this.userRole}) : super(key: key);

  @override
  State<MultiStepFormPage> createState() => _MultiStepFormPageState();
}

class _MultiStepFormPageState extends State<MultiStepFormPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalSteps = 3;

  final List<GlobalKey<FormState>> _formKeys = List.generate(
    3,
    (_) => GlobalKey<FormState>(),
  );

  Map<String, dynamic> formData = {};

  // Dropdown values
  String? selectedUsiaKehamilan;
  String? selectedUsiaBatita;
  String? selectedFrekuensiMenyusui;

  // --- WARNA TEMA BARU ---
  final Color primaryPink = Colors.pink[300]!;
  final Color secondaryBlue = Colors.blue[300]!;
  // -------------------------

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  // Fungsi untuk mendapatkan widget form berdasarkan role
  Widget _getFormStep(int step) {
    switch (widget.userRole) {
      case 'IbuHamil':
        return _buildIbuHamilForm(step);
      case 'IbuMenyusui':
        return _buildIbuMenyusuiForm(step);
      case 'Batita':
        return _buildBatitaForm(step);
      default:
        return _buildDefaultForm(step);
    }
  }

  // Form untuk Ibu Hamil
  Widget _buildIbuHamilForm(int step) {
    switch (step) {
      case 0:
        return _buildFormTemplate(
          step: step,
          title: "Langkah 1: Data Pribadi",
          titleColor: primaryPink, // Diganti Pink
          fields: [
            _buildTextField("Nama Lengkap", "nama", TextInputType.name),
            _buildTextField("Usia", "usia", TextInputType.number),
            _buildTextField("Alamat", "alamat", TextInputType.streetAddress),
          ],
        );

      case 1:
        return Form(
          key: _formKeys[step],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Langkah 2: Data Kehamilan",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryPink, // Diganti Pink
                ),
              ),
              const SizedBox(height: 24),
              _buildDropdownField(
                label: "Usia Kehamilan (minggu)",
                keyName: "usia_kehamilan",
                items: List.generate(42, (i) => "${i + 1} Minggu"),
              ),
              _buildTextField(
                "Berat Badan (kg)",
                "berat_badan",
                TextInputType.number,
              ),
              _buildTextField(
                "Tinggi Badan (cm)",
                "tinggi_badan",
                TextInputType.number,
              ),
            ],
          ),
        );

      case 2:
        return _buildFormTemplate(
          step: step,
          title: "Langkah 3: Informasi Bunda",
          titleColor: primaryPink, // Diganti Pink
          fields: [
            _buildTextField(
              "Lingkar Perut (cm)",
              "lingkar_perut",
              TextInputType.number,
            ),
            _buildTextField(
              "Lingkar Lengan Atas (cm)",
              "lingkar_lengan_atas",
              TextInputType.number,
            ),
          ],
        );

      default:
        return Container();
    }
  }

  // Form untuk Ibu Menyusui
  Widget _buildIbuMenyusuiForm(int step) {
    switch (step) {
      case 0:
        return _buildFormTemplate(
          step: step,
          title: "Langkah 1: Data Pribadi",
          titleColor: secondaryBlue, // Diganti Biru
          fields: [
            _buildTextField("Nama Lengkap", "nama", TextInputType.name),
            _buildTextField("Usia", "usia", TextInputType.number),
            _buildTextField("Alamat", "alamat", TextInputType.streetAddress),
          ],
        );

      case 1:
        return Form(
          key: _formKeys[step],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Langkah 2: Data Menyusui",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: secondaryBlue, // Diganti Biru
                ),
              ),
              const SizedBox(height: 24),
              _buildDropdownField(
                label: "Frekuensi Menyusui (berdasarkan Usia Bayi)",
                keyName: "frekuensi_menyusui",
                items: [
                  "8-12 kali/hari",
                  "7-9 kali/hari",
                  "6-8 kali/hari",
                  "5-7 kali/hari",
                ],
              ),
              // Idealnya ini menggunakan Dropdown/Radio Button, tapi mengikuti format yang ada:
              _buildTextField(
                "ASI Eksklusif? (Ya/Tidak)",
                "asi_eksklusif",
                TextInputType.text,
              ),
            ],
          ),
        );

      case 2:
        return _buildFormTemplate(
          step: step,
          title: "Langkah 3: IMT Bunda",
          titleColor: secondaryBlue, // Diganti Biru
          fields: [
            _buildTextField(
              "Tinggi Badan (cm)",
              "tinggi_badan",
              TextInputType.number,
            ),
            _buildTextField(
              "Berat Badan (kg)",
              "berat_badan",
              TextInputType.number,
            ),
          ],
        );

      default:
        return Container();
    }
  }

  // Form untuk Batita
  Widget _buildBatitaForm(int step) {
    switch (step) {
      case 0:
        return _buildFormTemplate(
          step: step,
          title: "Langkah 1: Data Pribadi",
          titleColor: secondaryBlue, // Diganti Biru
          fields: [
            _buildTextField("Nama Lengkap", "nama", TextInputType.name),
            _buildTextField("Alamat", "alamat", TextInputType.streetAddress),
          ],
        );

      case 1:
        return _buildFormTemplate(
          step: step,
          title: "Langkah 2: IMT Anak",
          titleColor: secondaryBlue, // Diganti Biru
          fields: [
            _buildTextField(
              "Tinggi Badan (cm)",
              "tinggi_badan",
              TextInputType.number,
            ),
          ],
        );

      case 2:
        return _buildFormTemplate(
          step: step,
          title: "Langkah 3: Umur Anak",
          titleColor: secondaryBlue, // Diganti Biru
          fields: [
            _buildDropdownField(
              label: "Umur Anak (bulan)",
              keyName: "umur_anak",
              items: List<String>.generate(24, (index) => "${index + 1} bulan"),
            ),
          ],
        );

      default:
        return Container();
    }
  }

  // Template form umum
  Widget _buildFormTemplate({
    required int step,
    required String title,
    required Color titleColor, // Ditambahkan parameter warna
    required List<Widget> fields,
  }) {
    return Form(
      key: _formKeys[step],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: titleColor, // Menggunakan warna dari parameter
            ),
          ),
          const SizedBox(height: 24),
          ...fields,
        ],
      ),
    );
  }
  // ✅

  // Widget TextField reusable
  Widget _buildTextField(String label, String key, TextInputType inputType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
          // --- PERUBAHAN WARNA BORDER FOCUS ---
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: primaryPink,
              width: 2,
            ), // Menggunakan Pink
          ),
          // ------------------------------------
        ),
        keyboardType: inputType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label wajib diisi';
          }
          return null;
        },
        onSaved: (value) => formData[key] = value,
      ),
    );
  }

  // ✅ Widget Dropdown reusable
  Widget _buildDropdownField({
    required String label,
    required String keyName,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
          // --- PERUBAHAN WARNA BORDER FOCUS ---
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: primaryPink,
              width: 2,
            ), // Menggunakan Pink
          ),
          // ------------------------------------
        ),
        value: formData[keyName],
        hint: Text("Pilih $label"),
        items: items
            .map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            formData[keyName] = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label wajib dipilih';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDefaultForm(int step) {
    return _buildFormTemplate(
      step: step,
      title: "Langkah ${step + 1}",
      titleColor: primaryPink,
      fields: [
        _buildTextField("Field 1", "field1", TextInputType.text),
        _buildTextField("Field 2", "field2", TextInputType.text),
      ],
    );
  }

  // Navigasi antar halaman
  void _nextPage() {
    if (_formKeys[_currentPage].currentState!.validate()) {
      _formKeys[_currentPage].currentState!.save();

      if (_currentPage < _totalSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      } else {
        _submitForm();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    } else {
      context.pop();
    }
  }

  void _submitForm() {
    print("Data Lengkap ${widget.userRole}: $formData");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pendaftaran berhasil!'),
        backgroundColor: Colors.green,
      ),
    );

    String displayName =
        formData['nama'] ?? formData['nama_anak'] ?? widget.userRole;

    context.go('/', extra: {'userName': displayName});
  }

  @override
  Widget build(BuildContext context) {
    // Menetapkan warna pink sebagai warna utama aplikasi (accentColor)
    final Color accentColor = primaryPink; // Diubah ke primaryPink

    return Scaffold(
      appBar: AppBar(
        title: Text("Langkah ${_currentPage + 1} dari $_totalSteps"),
        backgroundColor: accentColor, // Menggunakan Pink
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousPage,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _totalSteps,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                accentColor,
              ), // Menggunakan Pink
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _totalSteps,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: _getFormStep(index),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(32, 10, 32, 32),
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor, // Menggunakan Pink
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _currentPage == _totalSteps - 1 ? 'Selesai & Masuk' : 'Lanjut',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
