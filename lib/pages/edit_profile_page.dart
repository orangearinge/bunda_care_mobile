import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';
import '../utils/cloudinary_uploader.dart';
import '../providers/user_preference_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_preference.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/styles.dart';
import '../widgets/shimmer_loading.dart';


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
  late TextEditingController _ageMonthController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _hphtController;
  late TextEditingController _lilaController;
  String? _selectedLactationPhase;

  String _selectedRole = '';
  List<String> _allergens = [];
  List<String> _foodProhibitions = [];

  // Cross-platform avatar handling
  File? _avatarImage; // Mobile
  Uint8List? _avatarImageBytes; // Web
  String? _avatarUrl;

  final List<Map<String, String>> _roles = [
    {'value': 'IBU_HAMIL', 'label': 'Ibu Hamil'},
    {'value': 'IBU_MENYUSUI', 'label': 'Ibu Menyusui'},
    {'value': 'ANAK_BATITA', 'label': 'Anak Batita (0-24 bulan)'},
  ];

  @override
  void initState() {
    super.initState();
    final pref = widget.initialPreference;
    _nameController = TextEditingController(text: pref.name);
    _ageController = TextEditingController(text: pref.ageYear.toString());
    _ageMonthController =
        TextEditingController(text: pref.ageMonth?.toString() ?? '0');
    _heightController = TextEditingController(text: pref.heightCm.toString());
    _weightController = TextEditingController(text: pref.weightKg.toString());
    _hphtController = TextEditingController(text: pref.hpht ?? '');
    _lilaController = TextEditingController(
      text: pref.lilaCm?.toString() ?? '',
    );
    _selectedLactationPhase = pref.lactationPhase;
    _selectedRole = pref.role;
    _allergens = List.from(pref.allergens);
    _foodProhibitions = List.from(pref.foodProhibitions);

    // Get current avatar from AuthProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _avatarUrl = authProvider.currentUser?.avatar;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _ageMonthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _hphtController.dispose();
    _lilaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        // Web: Convert XFile to bytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _avatarImageBytes = bytes;
          _avatarImage = null;
        });
      } else {
        // Mobile: Use File
        setState(() {
          _avatarImage = File(pickedFile.path);
          _avatarImageBytes = null;
        });
      }

      // Upload to Cloudinary immediately
      await _uploadToCloudinary();
    }
  }

  Future<void> _uploadToCloudinary() async {
    if ((kIsWeb && _avatarImageBytes == null) ||
        (!kIsWeb && _avatarImage == null)) {
      return;
    }

    try {
      // Show loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mengupload gambar...')));

      // Cloudinary config from ApiConstants
      final cloudName = ApiConstants.cloudinaryCloudName;
      final uploadPreset = ApiConstants.cloudinaryUploadPreset;
      final folder = ApiConstants.cloudinaryFolder;

      final uploadedUrl = await CloudinaryUploader.uploadImage(
        kIsWeb ? _avatarImageBytes : _avatarImage,
        cloudName: cloudName,
        uploadPreset: uploadPreset,
        folder: folder,
      );

      if (!mounted) return;

      setState(() {
        _avatarUrl = uploadedUrl;
        _avatarImage = null;
        _avatarImageBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar berhasil diupload!'),
          backgroundColor: Colors.green,
        ),
      );

      // Persist to backend
      try {
        final provider = Provider.of<UserPreferenceProvider>(
          context,
          listen: false,
        );
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        await provider.updateAvatar(avatarUrl: uploadedUrl);

        // Refresh auth provider to get updated avatar
        await authProvider.checkAuthStatus();
      } catch (_) {
        // tolerate backend issues for now
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiConstants.getErrorMessage('UPLOAD_FAILED')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // 42 minggu yang lalu
    final minDate = DateTime.now().subtract(const Duration(days: 42 * 7));
    DateTime initialDate =
        DateTime.tryParse(_hphtController.text) ?? DateTime.now();

    if (initialDate.isBefore(minDate)) {
      initialDate = minDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helperText,
          helperMaxLines: 2,
          suffixIcon: suffixIcon,
        ),
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
      ),
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
            ...tags.map(
              (tag) => Chip(
                label: Text(
                  tag,
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
                backgroundColor: color,
                deleteIcon: Icon(Icons.close, size: 14, color: textColor),
                onDeleted: () => onRemove(tag),
              ),
            ),
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
                      decoration: InputDecoration(
                        hintText: 'Contoh: Kacang, Seafood',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
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

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedRole,
        decoration: InputDecoration(
          labelText: 'Peran',
          prefixIcon: Icon(Icons.people_outline, color: Colors.pink[300]),
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
            // Optional: clear irrelevant fields when role changes?
            // For now we keep them to avoid data loss if switched back.
          });
        },
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<UserPreferenceProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final nameValue = _nameController.text.trim();

      // Validate role-specific required fields
      if (_selectedRole == 'IBU_HAMIL' && _hphtController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HPHT wajib diisi untuk Ibu Hamil'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedRole == 'IBU_MENYUSUI' &&
          (_selectedLactationPhase == null ||
              _selectedLactationPhase!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fase menyusui wajib dipilih'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final result = await provider.updatePreference(
        role: _selectedRole,
        name: nameValue,
        ageYear: int.parse(_ageController.text),
        ageMonth: int.tryParse(_ageMonthController.text),
        heightCm: double.parse(_heightController.text),
        weightKg: double.parse(_weightController.text),
        hpht: _selectedRole == 'IBU_HAMIL' ? _hphtController.text : null,
        lilaCm: _selectedRole == 'IBU_HAMIL'
            ? double.tryParse(_lilaController.text)
            : null,
        lactationPhase: _selectedRole == 'IBU_MENYUSUI'
            ? _selectedLactationPhase
            : null,
        allergens: _allergens,
        foodProhibitions: _foodProhibitions,
      );

      if (mounted) {
        if (result.success) {
          // Update name, role, and token in AuthProvider
          if (nameValue.isNotEmpty &&
              nameValue != (widget.initialPreference.name ?? '')) {
            await authProvider.updateUserName(nameValue);
          }

          // Always update role and pass potential new token (e.g. if role changed)
          await authProvider.updateUserRole(_selectedRole, token: result.token);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil berhasil diperbarui'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  provider.errorMessage ??
                      ApiConstants.getErrorMessage('SERVER_ERROR'),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic labels based on role
    String nameLabel = "Nama Lengkap";
    String ageLabel = "Usia (tahun)";
    String heightLabel = "Tinggi Badan (cm)";
    String weightLabel = "Berat Badan (kg)";

    if (_selectedRole == 'ANAK_BATITA') {
      nameLabel = "Nama Anak";
      ageLabel = "Usia Anak (tahun)";
      heightLabel = "Tinggi Anak (cm)";
      weightLabel = "Berat Anak (kg)";
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, // Mencegah header melengkung rusak saat keyboard muncul
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppStyles.pinkGradient,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<UserPreferenceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentPreference == null) {
            return const EditProfileSkeleton();
          }
          return SingleChildScrollView(
            child: Column(
              children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppStyles.pinkGradient,
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
            // Avatar Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                children: [
                  const Text(
                    'Foto Profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      children: [
                        Builder(
                          builder: (context) {
                            final hasLocalImage =
                                _avatarImage != null ||
                                _avatarImageBytes != null;
                            final hasRemoteImage =
                                _avatarUrl != null && _avatarUrl!.isNotEmpty;

                            // Construct final remote URL if path is relative
                            String? finalRemoteUrl;
                            if (hasRemoteImage) {
                              if (_avatarUrl!.startsWith('http')) {
                                finalRemoteUrl = _avatarUrl;
                              } else {
                                finalRemoteUrl =
                                    '${ApiConstants.baseUrl}$_avatarUrl';
                              }
                            }

                            return CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.pink[100],
                              backgroundImage: _avatarImage != null
                                  ? FileImage(_avatarImage!)
                                  : _avatarImageBytes != null
                                  ? MemoryImage(_avatarImageBytes!)
                                  : hasRemoteImage
                                  ? CachedNetworkImageProvider(finalRemoteUrl!)
                                  : null,
                              onBackgroundImageError:
                                  (hasLocalImage || hasRemoteImage)
                                  ? (exception, stackTrace) {
                                      debugPrint(
                                        'Error loading avatar preview: $exception',
                                      );
                                    }
                                  : null,
                              child: !hasLocalImage && !hasRemoteImage
                                  ? Text(
                                      _nameController.text.isNotEmpty
                                          ? _nameController.text[0]
                                                .toUpperCase()
                                          : 'B',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pink,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.pink[400],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ketuk ikon kamera untuk mengubah foto profil',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                    _buildDropdown(),

                    _buildTextField(
                      controller: _nameController,
                      label: nameLabel,
                      hint: 'Masukkan nama',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _ageController,
                      label: ageLabel,
                      hint: 'Masukkan usia',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Usia tidak boleh kosong';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 0) {
                          return 'Usia harus berupa angka positif';
                        }
                        // Special validation for batita: max 2 years
                        if (_selectedRole == 'ANAK_BATITA' && age > 2) {
                          return 'Usia anak batita maksimal 2 tahun';
                        }
                        // Special validation for mothers
                        if (_selectedRole == 'IBU_HAMIL') {
                          if (age < 19) return 'Usia ibu hamil minimal 19 tahun';
                          if (age > 45) return 'Usia ibu hamil maksimal 45 tahun';
                        } else if (_selectedRole == 'IBU_MENYUSUI') {
                          if (age < 15) return 'Usia ibu menyusui minimal 15 tahun';
                          if (age > 65) return 'Usia ibu menyusui maksimal 65 tahun';
                        }
                        return null;
                      },
                    ),
                    if (_selectedRole == 'ANAK_BATITA')
                      _buildTextField(
                        controller: _ageMonthController,
                        label: 'Usia Anak (bulan)',
                        hint: 'Masukkan usia dalam bulan',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Usia bulan tidak boleh kosong';
                          }
                          final months = int.tryParse(value);
                          if (months == null || months < 0) {
                            return 'Usia bulan harus berupa angka positif';
                          }
                          return null;
                        },
                      ),
                    _buildTextField(
                      controller: _heightController,
                      label: heightLabel,
                      hint: 'Masukkan tinggi badan',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tinggi badan tidak boleh kosong';
                        }
                        final height = double.tryParse(value);
                        if (height == null || height <= 0) {
                          return 'Tinggi badan harus berupa angka positif';
                        }
                        // Khusus untuk batita
                        if (_selectedRole == 'ANAK_BATITA') {
                          if (height < 45) return 'Tinggi badan anak batita minimal 45 cm';
                          if (height > 100) return 'Tinggi badan anak batita maksimal 100 cm';
                        }
                        // Khusus untuk ibu hamil dan ibu menyusui
                        if (_selectedRole == 'IBU_HAMIL' || _selectedRole == 'IBU_MENYUSUI') {
                          if (height < 140) return 'Tinggi badan ibu ${_selectedRole == 'IBU_HAMIL' ? 'hamil' : 'menyusui'} minimal 140 cm';
                          if (height > 180) return 'Tinggi badan ibu ${_selectedRole == 'IBU_HAMIL' ? 'hamil' : 'menyusui'} maksimal 180 cm';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _weightController,
                      label: weightLabel,
                      hint: 'Masukkan berat badan',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Berat badan tidak boleh kosong';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return 'Berat badan harus berupa angka positif';
                        }
                        // Khusus untuk batita
                        if (_selectedRole == 'ANAK_BATITA') {
                          if (weight < 4) return 'Berat badan anak batita minimal 4 kg';
                          if (weight > 16) return 'Berat badan anak batita maksimal 16 kg';
                        }
                        // Khusus untuk ibu hamil dan ibu menyusui
                        if (_selectedRole == 'IBU_HAMIL' || _selectedRole == 'IBU_MENYUSUI') {
                          if (weight < 35) return 'Berat badan ibu ${_selectedRole == 'IBU_HAMIL' ? 'hamil' : 'menyusui'} minimal 35 kg';
                          if (weight > 120) return 'Berat badan ibu ${_selectedRole == 'IBU_HAMIL' ? 'hamil' : 'menyusui'} maksimal 120 kg';
                        }
                        return null;
                      },
                    ),

                    if (_selectedRole == 'IBU_HAMIL') ...[
                      const SizedBox(height: 16),
                      _buildSectionTitle('Informasi Kehamilan'),
                      _buildTextField(
                        controller: _hphtController,
                        label: 'HPHT (Hari Pertama Haid Terakhir)',
                        hint: 'YYYY-MM-DD',
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        suffixIcon: const Icon(Icons.calendar_today),
                        helperText: 'Otomatis menghitung usia kandungan',
                        validator: (value) {
                          if (_selectedRole == 'IBU_HAMIL' &&
                              (value == null || value.isEmpty)) {
                            return 'HPHT tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        controller: _lilaController,
                        label: 'LiLA (cm)',
                        hint: 'Masukkan LiLA',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    if (_selectedRole == 'IBU_MENYUSUI') ...[
                      const SizedBox(height: 16),
                      _buildSectionTitle('Informasi Menyusui'),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedLactationPhase,
                          decoration: InputDecoration(
                            labelText: 'Fase Menyusui',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: '0-6',
                              child: Text('6 Bulan Pertama'),
                            ),
                            DropdownMenuItem(
                              value: '6-12',
                              child: Text('6 Bulan Kedua'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedLactationPhase = value;
                            });
                          },
                          validator: (value) {
                            if (_selectedRole == 'IBU_MENYUSUI' &&
                                (value == null || value.isEmpty)) {
                              return 'Fase menyusui wajib dipilih';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],

                    // ANAK_BATITA doesn't have extra fields beyond age/height/weight in backend
                    const SizedBox(height: 24),
                    _buildSectionTitle('Preferensi Makanan'),
                    _buildTagInput(
                      label: 'Alergi Makanan',
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
                      onAdd: (val) =>
                          setState(() => _foodProhibitions.add(val)),
                      onRemove: (val) =>
                          setState(() => _foodProhibitions.remove(val)),
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
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: AppStyles.pinkGradient,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: provider.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'SIMPAN PERUBAHAN',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
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
      );
    },
  ),
);
  }
}
