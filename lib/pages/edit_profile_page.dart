import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_preference_provider.dart';
import '../models/user_preference.dart';

class EditProfilePage extends StatefulWidget {
  final UserPreference initialPreference;

  const EditProfilePage({super.key, required this.initialPreference});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _hphtController;
  late TextEditingController _bellyController;
  late TextEditingController _lilaController;
  late TextEditingController _lactationController;
  
  String _selectedRole = '';
  List<String> _allergens = [];
  List<String> _foodProhibitions = [];

  final List<Map<String, String>> _roles = [
    {'value': 'IBU_HAMIL', 'label': 'Ibu Hamil'},
    {'value': 'IBU_MENYUSUI', 'label': 'Ibu Menyusui'},
    {'value': 'UMUM', 'label': 'Lainnya'},
  ];

  @override
  void initState() {
    super.initState();
    final pref = widget.initialPreference;
    _nameController = TextEditingController(text: pref.name);
    _ageController = TextEditingController(text: pref.ageYear.toString());
    _heightController = TextEditingController(text: pref.heightCm.toString());
    _weightController = TextEditingController(text: pref.weightKg.toString());
    _hphtController = TextEditingController(text: pref.hpht ?? '');
    _bellyController = TextEditingController(text: pref.bellyCircumferenceCm?.toString() ?? '');
    _lilaController = TextEditingController(text: pref.lilaCm?.toString() ?? '');
    _lactationController = TextEditingController(text: pref.lactationMl?.toString() ?? '');
    _selectedRole = pref.role;
    _allergens = List.from(pref.allergens);
    _foodProhibitions = List.from(pref.foodProhibitions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _hphtController.dispose();
    _bellyController.dispose();
    _lilaController.dispose();
    _lactationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.tryParse(_hphtController.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink[400]!,
              onPrimary: Colors.white,
              onSurface: Colors.pink[900]!,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _hphtController.text = picked.toString().split(' ')[0];
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<UserPreferenceProvider>(context, listen: false);
      
      final success = await provider.updatePreference(
        role: _selectedRole,
        name: _nameController.text.trim(),
        ageYear: int.parse(_ageController.text),
        heightCm: double.parse(_heightController.text),
        weightKg: double.parse(_weightController.text),
        hpht: _selectedRole == 'IBU_HAMIL' ? _hphtController.text : null,
        bellyCircumferenceCm: _selectedRole == 'IBU_HAMIL' ? double.tryParse(_bellyController.text) : null,
        lilaCm: _selectedRole == 'IBU_HAMIL' ? double.tryParse(_lilaController.text) : null,
        lactationMl: _selectedRole == 'IBU_MENYUSUI' ? double.tryParse(_lactationController.text) : null,
        allergens: _allergens,
        foodProhibitions: _foodProhibitions,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.errorMessage ?? 'Gagal memperbarui profil'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.pink[400],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.pink[400],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
              child: const Text(
                'Perbarui data diri Bunda untuk mendapatkan rekomendasi yang tepat',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Informasi Dasar'),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nama Lengkap',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _ageController,
                            label: 'Usia (Tahun)',
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Metrik Tubuh'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _heightController,
                            label: 'Tinggi (cm)',
                            icon: Icons.height,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _weightController,
                            label: 'Berat (kg)',
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    if (_selectedRole == 'IBU_HAMIL') ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _hphtController,
                            label: 'HPHT (Tanggal)',
                            icon: Icons.calendar_today_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _bellyController,
                              label: 'Lingkar Perut (cm)',
                              icon: Icons.circle_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _lilaController,
                              label: 'LiLA (cm)',
                              icon: Icons.straighten,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (_selectedRole == 'IBU_MENYUSUI') ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _lactationController,
                        label: 'Volume ASI (ml/hari)',
                        icon: Icons.water_drop_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    const SizedBox(height: 24),
                    _buildSectionTitle('Kesehatan & Alergi'),
                    _buildTagInput(
                      label: 'Alergi',
                      tags: _allergens,
                      color: Colors.red[100]!,
                      textColor: Colors.red[700]!,
                      onAdd: (val) => setState(() => _allergens.add(val)),
                      onRemove: (val) => setState(() => _allergens.remove(val)),
                    ),
                    const SizedBox(height: 16),
                     _buildTagInput(
                      label: 'Pantangan Makanan',
                      tags: _foodProhibitions,
                      color: Colors.orange[100]!,
                      textColor: Colors.orange[800]!,
                      onAdd: (val) => setState(() => _foodProhibitions.add(val)),
                      onRemove: (val) => setState(() => _foodProhibitions.remove(val)),
                    ),

                    const SizedBox(height: 40),
                    Consumer<UserPreferenceProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                            ),
                            child: provider.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'SIMPAN PERUBAHAN',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.pink[700],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.pink[300]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.pink[400]!, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          if (label.contains('Nama') || label.contains('Usia') || label.contains('Tinggi') || label.contains('Berat')) {
            return '$label wajib diisi';
          }
        }
        return null;
      },
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Peran',
        prefixIcon: Icon(Icons.people_outline, color: Colors.pink[300]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      items: _roles.map((role) {
        return DropdownMenuItem(
          value: role['value'],
          child: Text(role['label']!),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRole = value!;
        });
      },
    );
  }

  Widget _buildTagInput({
    required String label,
    required List<String> tags,
    required Color color,
    required Color textColor,
    required Function(String) onAdd,
    required Function(String) onRemove,
  }) {
    final controller = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...tags.map((tag) => Chip(
                  label: Text(tag, style: TextStyle(color: textColor, fontSize: 12)),
                  backgroundColor: color,
                  deleteIcon: Icon(Icons.close, size: 14, color: textColor),
                  onDeleted: () => onRemove(tag),
                )),
            ActionChip(
              label: const Icon(Icons.add, size: 18),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Tambah $label'),
                    content: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(hintText: 'Contoh: Kacang, Seafood'),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                      TextButton(
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            onAdd(controller.text.trim());
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Tambah'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
