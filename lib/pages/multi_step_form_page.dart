import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/user_preference_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class MultiStepFormPage extends StatefulWidget {
  final String userRole; // 'IbuHamil', 'IbuMenyusui', atau 'AnakBatita'

  const MultiStepFormPage({Key? key, required this.userRole}) : super(key: key);

  @override
  State<MultiStepFormPage> createState() => _MultiStepFormPageState();
}

class _MultiStepFormPageState extends State<MultiStepFormPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalSteps = 4;
  bool _isLoadingSubmit = false;

  final List<GlobalKey<FormState>> _formKeys = List.generate(
    4,
    (_) => GlobalKey<FormState>(),
  );

  Map<String, dynamic> formData = {};

  final Color primaryPink = Colors.pink[300]!;
  final Color secondaryBlue = Colors.blue[300]!;

  // Required fields per role (excluding optional dietary preferences)
  final Map<String, List<String>> _roleRequiredFields = {
    'IbuHamil': [
      'nama',
      'usia',
      'hpht',
      'berat_badan',
      'tinggi_badan',
      'lingkar_lengan_atas',
    ],
    'IbuMenyusui': [
      'nama',
      'usia',
      'lactation_phase',
      'tinggi_badan',
      'berat_badan',
    ],
    'AnakBatita': ['nama', 'berat_badan', 'tinggi_badan', 'usia', 'usia_bulan'],
  };

  // ===================== HELPER FUNCTIONS =====================
  /// Calculate gestational age from HPHT date
  /// Returns Map with 'weeks' and 'days' keys
  Map<String, int> _calculateGestationalAge(String hphtDate) {
    try {
      final hpht = DateTime.parse(hphtDate);
      final now = DateTime.now();
      final difference = now.difference(hpht);

      // Calculate total days and convert to weeks + days
      final totalDays = difference.inDays;
      final weeks = totalDays ~/ 7;
      final days = totalDays % 7;

      return {'weeks': weeks, 'days': days};
    } catch (e) {
      return {'weeks': 0, 'days': 0};
    }
  }

  /// Check if gestational age exceeds 42 weeks
  bool _isGestationalAgeValid(String hphtDate) {
    final gestationalAge = _calculateGestationalAge(hphtDate);
    return gestationalAge['weeks']! <= 42;
  }

  /// Get minimum allowed HPHT date (42 weeks ago from today)
  DateTime _getMinHphtDate() {
    final now = DateTime.now();
    return now.subtract(const Duration(days: 42 * 7));
  }

  /// Build widget to display calculated gestational age
  Widget _buildGestationalAgeDisplay() {
    final gestationalAge = _calculateGestationalAge(formData['hpht']);
    final weeks = gestationalAge['weeks']!;
    final days = gestationalAge['days']!;

    Color textColor = Colors.green;
    String statusText = "Normal";

    if (weeks > 42) {
      textColor = Colors.red;
      statusText = "Melebihi batas";
    } else if (weeks > 40) {
      textColor = Colors.orange;
      statusText = "Mendekati batas";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: textColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Usia Kandungan: $weeks minggu $days hari ($statusText)",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  Widget _getFormStep(int step) {
    if (step == 3) {
      return _buildDietaryPreferencesForm(step);
    }

    switch (widget.userRole) {
      case 'IbuHamil':
        return _buildIbuHamilForm(step);
      case 'IbuMenyusui':
        return _buildIbuMenyusuiForm(step);
      case 'AnakBatita':
        return _buildAnakBatitaForm(step);
      default:
        return _buildDefaultForm(step);
    }
  }

  // ===================== DIETARY PREFERENCES (GLOBAL) =====================
  Widget _buildDietaryPreferencesForm(int step) {
    return _buildFormTemplate(
      step: step,
      title: "Langkah 4: Pantangan & Alergi",
      titleColor: Colors.orange[700]!,
      fields: [
        _buildTextField(
          "Pantangan Makanan (pisahkan dengan koma)",
          "food_prohibitions",
          TextInputType.text,
          required: false,
        ),
        _buildTextField(
          "Alergi (pisahkan dengan koma)",
          "allergens",
          TextInputType.text,
          required: false,
        ),
        const SizedBox(height: 16),
        const Text(
          "Contoh: Durian, Nanas, Udang, Kacang",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  // ===================== IBU HAMIL =====================
  Widget _buildIbuHamilForm(int step) {
    switch (step) {
      case 0:
        return _buildFormTemplate(
          step: step,
          title: "Langkah 1: Data Pribadi",
          titleColor: primaryPink,
          fields: [
            _buildTextField("Nama Lengkap", "nama", TextInputType.name),
            _buildTextField("Usia", "usia", TextInputType.number),
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
                  color: primaryPink,
                ),
              ),
              const SizedBox(height: 24),

              // ✅ DIGANTI DATE PICKER (HPHT)
              _buildDateField(
                label: "HPHT (Tanggal Haid Terakhir)",
                keyName: "hpht",
              ),

              // Show calculated gestational age if HPHT is selected
              if (formData['hpht'] != null && formData['hpht'].isNotEmpty)
                _buildGestationalAgeDisplay(),

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
          titleColor: primaryPink,
          fields: [
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

  // ===================== IBU MENYUSUI =====================
  Widget _buildIbuMenyusuiForm(int step) {
    switch (step) {
      case 0:
        return _buildFormTemplate(
          step: step,
          title: "Langkah 1: Data Pribadi",
          titleColor: secondaryBlue,
          fields: [
            _buildTextField("Nama Lengkap", "nama", TextInputType.name),
            _buildTextField("Usia", "usia", TextInputType.number),
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
                  color: secondaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              _buildDropdownField(
                label: "Fase Menyusui",
                keyName: "lactation_phase",
                items: [
                  {'value': '0-6', 'label': '6 Bulan Pertama'},
                  {'value': '6-12', 'label': '6 Bulan Kedua'},
                ],
              ),
            ],
          ),
        );

      case 2:
        return _buildFormTemplate(
          step: step,
          title: "Langkah 3: IMT Bunda",
          titleColor: secondaryBlue,
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

  // ===================== BATITA =====================
  Widget _buildAnakBatitaForm(int step) {
    switch (step) {
      case 0:
        return _buildFormTemplate(
          step: step,
          title: "Langkah 1: Data Dasar",
          titleColor: secondaryBlue,
          fields: [_buildTextField("Nama Anak", "nama", TextInputType.name)],
        );

      case 1:
        return _buildFormTemplate(
          step: step,
          title: "Langkah 2: Antropometri Anak",
          titleColor: secondaryBlue,
          fields: [
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
        );

      case 2:
        return _buildFormTemplate(
          step: step,
          title: "Langkah 3: Usia Anak",
          titleColor: secondaryBlue,
          fields: [
            _buildTextField(
              "Usia Anak (tahun)",
              "usia",
              TextInputType.number,
              hintText: "Contoh: 0 untuk bayi, 1 untuk anak 1 tahun",
            ),
            _buildTextField(
              "Usia Anak (bulan)",
              "usia_bulan",
              TextInputType.number,
              hintText: "Contoh: 6 untuk usia 6 bulan",
            ),
          ],
        );

      default:
        return Container();
    }
  }

  // ===================== TEMPLATE =====================
  Widget _buildFormTemplate({
    required int step,
    required String title,
    required Color titleColor,
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
              color: titleColor,
            ),
          ),
          const SizedBox(height: 24),
          ...fields,
        ],
      ),
    );
  }

  // ===================== TEXT FIELD =====================
  Widget _buildTextField(
    String label,
    String key,
    TextInputType inputType, {
    bool required = true,
    String? hintText,
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primaryPink, width: 2),
          ),
        ),
        keyboardType: inputType,
        maxLines: maxLines ?? 1,
        validator: (value) {
          bool isRequired =
              required ||
              (_roleRequiredFields[widget.userRole]?.contains(key) ?? false);
          if (!isRequired) return null;
          if (value == null || value.isEmpty) return '$label wajib diisi';
          // Additional validation for numeric fields
          if (inputType == TextInputType.number) {
            double? num = double.tryParse(value);
            if (num == null || num < 0) return '$label harus angka positif';
          }
          return null;
        },
        onSaved: (value) => formData[key] = value,
      ),
    );
  }

  // ===================== DATE PICKER (HPHT) =====================
  Widget _buildDateField({required String label, required String keyName}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: _getMinHphtDate(),
            lastDate: DateTime.now(),
          );

          if (pickedDate != null) {
            setState(() {
              formData[keyName] =
                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            });
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            controller: TextEditingController(text: formData[keyName] ?? ""),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label wajib dipilih';
              }

              // Check gestational age validation
              if (!_isGestationalAgeValid(value)) {
                return 'Usia kandungan tidak boleh melebihi 42 minggu';
              }

              return null;
            },
          ),
        ),
      ),
    );
  }

  // ===================== DROPDOWN FIELD =====================
  Widget _buildDropdownField({
    required String label,
    required String keyName,
    required List<Map<String, String>> items,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        value: formData[keyName],
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['value'],
            child: Text(item['label']!),
          );
        }).toList(),
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

  // ===================== NAVIGASI =====================
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
      // Kembali ke halaman pemilihan 'role' (RegistrationFormPage)
      context.go('/role-selection');
    }
  }

  void _submitForm() async {
    // Pre-submit validation
    List<String> requiredFields = _roleRequiredFields[widget.userRole] ?? [];
    for (String key in requiredFields) {
      if (formData[key] == null || formData[key].toString().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Field $key wajib diisi'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Validate numeric fields
      if ([
        'berat_badan',
        'tinggi_badan',
        'usia',
        'usia_bulan',
        'lingkar_lengan_atas',
      ].contains(key)) {
        double? num = double.tryParse(formData[key].toString());
        if (num == null || num < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Field $key harus angka nol atau positif'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    final preferenceProvider = Provider.of<UserPreferenceProvider>(
      context,
      listen: false,
    );

    // Map UI role to backend role
    String backendRole = 'IBU_HAMIL';
    if (widget.userRole == 'IbuMenyusui') {
      backendRole = 'IBU_MENYUSUI';
    } else if (widget.userRole == 'AnakBatita') {
      backendRole = 'ANAK_BATITA';
    }

    // Helper to parse double safely
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    // Helper to parse int safely
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    print("Submitting Form Data: $formData");
    print("Backend Role: $backendRole");

    // Helper to parse list from comma separated string
    List<String> parseList(dynamic value) {
      if (value == null || value.toString().isEmpty) return [];
      return value
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Prepare data based on role
    Map<String, dynamic> preferenceData = {
      'role': backendRole,
      'name': formData['nama'],
      'heightCm': parseDouble(formData['tinggi_badan']) ?? 0.0,
      'weightKg': parseDouble(formData['berat_badan']) ?? 0.0,
      'ageYear': parseInt(formData['usia']) ?? 0,
      'ageMonth': parseInt(formData['usia_bulan']),
      'foodProhibitions': parseList(formData['food_prohibitions']),
      'allergens': parseList(formData['allergens']),
    };

    // Add role-specific data
    if (backendRole == 'IBU_HAMIL') {
      preferenceData['hpht'] = formData['hpht'];
      preferenceData['lilaCm'] = parseDouble(formData['lingkar_lengan_atas']);
    } else if (backendRole == 'IBU_MENYUSUI') {
      preferenceData['lactationPhase'] = formData['lactation_phase'];
    } else if (backendRole == 'ANAK_BATITA') {
      // For ANAK_BATITA, only basic fields are required
      // Don't include hpht as it's not expected for this role
      preferenceData.remove('hpht');
      preferenceData['lilaCm'] = null;
    }

    // Show loading state if possible
    setState(() {
      _isLoadingSubmit = true;
    });

    final result = await preferenceProvider.updatePreference(
      role: preferenceData['role'],
      name: preferenceData['name'],
      hpht: preferenceData['hpht'],
      heightCm: preferenceData['heightCm'],
      weightKg: preferenceData['weightKg'],
      ageYear: preferenceData['ageYear'],
      ageMonth: preferenceData['ageMonth'],
      lilaCm: preferenceData['lilaCm'],
      lactationPhase: preferenceData['lactationPhase'],
      foodProhibitions: preferenceData['foodProhibitions'],
      allergens: preferenceData['allergens'],
    );

    if (result.success && mounted) {
      final gestationalAge =
          preferenceProvider.currentPreference?.gestationalAgeWeeks;
      String snackBarMessage = 'Pendaftaran berhasil!';
      if (gestationalAge != null) {
        snackBarMessage += ' Usia kandungan: $gestationalAge minggu.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBarMessage), backgroundColor: Colors.green),
      );

      String displayName = formData['nama'] ?? widget.userRole;

      // Ensure AuthProvider is updated with the real role from backend
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Pass the new token if returned
      await authProvider.updateUserRole(backendRole, token: result.token);

      context.go('/', extra: {'userName': displayName});
    } else if (mounted) {
      setState(() {
        _isLoadingSubmit = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            preferenceProvider.errorMessage ??
                ApiConstants.getErrorMessage('SERVER_ERROR'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = primaryPink;

    return Scaffold(
      appBar: AppBar(
        title: Text("Langkah ${_currentPage + 1} dari $_totalSteps"),
        backgroundColor: accentColor,
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
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
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
                backgroundColor: accentColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoadingSubmit
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _currentPage == _totalSteps - 1
                          ? 'Selesai & Masuk'
                          : 'Lanjut',
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
