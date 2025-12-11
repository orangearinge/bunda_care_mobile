import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

/// Halaman Sign Up untuk pendaftaran user baru
/// Stateful widget yang mengelola form registrasi dengan validasi
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Form key untuk validasi form secara keseluruhan
  final _formKey = GlobalKey<FormState>();

  // Controller untuk mengambil dan mengontrol value dari text field
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // State untuk mengontrol visibility password (tampil/sembunyi)
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // State untuk checkbox persetujuan syarat & ketentuan
  bool _agreeToTerms = false;

  // Konstanta warna untuk konsistensi desain di seluruh halaman
  static const Color primaryColor = Color(0xFF9C27B0); // Deep Purple
  static const Color secondaryColor = Color(0xFFE91E63); // Pink

  /// Fungsi helper untuk membuat dekorasi input field yang konsisten
  /// Parameter:
  /// - hintText: teks placeholder dalam input
  /// - icon: icon yang ditampilkan di sebelah kiri input
  /// - suffixIcon: optional icon di sebelah kanan (untuk toggle password)
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true, // Mengisi background input dengan warna
      fillColor: Colors.grey[50], // Warna background input
      prefixIcon: Icon(icon, color: Colors.grey[600]), // Icon di sebelah kiri
      suffixIcon: suffixIcon, // Icon di sebelah kanan (opsional)
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

      // Border default (tidak terlihat)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),

      // Border saat input tidak aktif
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
      ),

      // Border saat input aktif (fokus)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),

      // Border saat ada error
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),

      // Border saat fokus dan ada error
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  /// Fungsi untuk memproses pendaftaran user
  /// Melakukan validasi form dan checkbox persetujuan
  void _signUp(AuthProvider authProvider) async {
    // Validasi semua input field menggunakan validator yang sudah didefinisikan
    if (_formKey.currentState!.validate()) {
      // Cek apakah user sudah menyetujui syarat & ketentuan
      if (!_agreeToTerms) {
        // Tampilkan peringatan jika belum menyetujui
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Anda harus menyetujui Syarat & Ketentuan'),
            backgroundColor: secondaryColor.withOpacity(0.8),
            behavior: SnackBarBehavior.floating, // Snackbar mengambang
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return; // Hentikan proses jika belum setuju
      }

      // Call auth provider to register
      final success = await authProvider.register(
        name: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          // Registration successful
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, ${authProvider.currentUser?.name}!'),
              backgroundColor: Colors.green[500],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          // Force redirect to role selection since new users don't have complete data
          context.pushReplacement('/role-selection');
        } else {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Registration failed'),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  /// Handle Google Sign-In
  Future<void> _handleGoogleSignUp(AuthProvider authProvider) async {
    final success = await authProvider.signInWithGoogle();

    if (mounted) {
      if (success) {
        // Registration successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, ${authProvider.currentUser?.name}!'),
            backgroundColor: Colors.green[500],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Force redirect to role selection since new users don't have complete data
        context.pushReplacement('/role-selection');
      } else if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar dengan tombol back
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () =>
              Navigator.pop(context), // Kembali ke halaman sebelumnya
        ),
        backgroundColor: Colors.transparent, // AppBar transparan
        elevation: 0, // Tidak ada bayangan
      ),

      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SafeArea(
            // SingleChildScrollView agar bisa scroll jika keyboard muncul
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),

                // Form wrapper untuk validasi
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Header dengan gradient dan icon
                      _buildHeaderSection(),

                      const SizedBox(height: 30),

                      // Input Username dengan validasi
                      TextFormField(
                        controller: _usernameController,
                        decoration: _buildInputDecoration(
                          hintText: 'Username',
                          icon: Icons.person_outline,
                        ),
                        validator: (value) {
                          // Validasi: tidak boleh kosong
                          if (value == null || value.isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          // Validasi: minimal 3 karakter
                          if (value.length < 3) {
                            return 'Username minimal 3 karakter';
                          }
                          return null; // Valid
                        },
                      ),

                      const SizedBox(height: 16),

                      // Input Email dengan validasi format email
                      TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration(
                          hintText: 'Email',
                          icon: Icons.email_outlined,
                        ),
                        keyboardType:
                            TextInputType.emailAddress, // Keyboard khusus email
                        validator: (value) {
                          // Validasi: tidak boleh kosong
                          if (value == null || value.isEmpty) {
                            return 'Masukkan email Anda';
                          }
                          // Validasi: format email harus benar menggunakan regex
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Format email tidak valid';
                          }
                          return null; // Valid
                        },
                      ),

                      const SizedBox(height: 16),

                      // Input Password dengan toggle visibility
                      TextFormField(
                        controller: _passwordController,
                        obscureText:
                            _obscurePassword, // Sembunyikan/tampilkan password
                        decoration: _buildInputDecoration(
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          // Tombol untuk toggle visibility password
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              // Toggle state visibility password
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          // Validasi: tidak boleh kosong
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          // Validasi: minimal 6 karakter
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null; // Valid
                        },
                      ),

                      const SizedBox(height: 16),

                      // Input Konfirmasi Password dengan validasi kesamaan
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: _buildInputDecoration(
                          hintText: 'Konfirmasi Password',
                          icon: Icons.lock_outline,
                          // Tombol untuk toggle visibility confirm password
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              // Toggle state visibility confirm password
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          // Validasi: tidak boleh kosong
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password Anda';
                          }
                          // Validasi: harus sama dengan password
                          if (value != _passwordController.text) {
                            return 'Password tidak cocok';
                          }
                          return null; // Valid
                        },
                      ),

                      const SizedBox(height: 20),

                      // Checkbox persetujuan syarat & ketentuan
                      _buildTermsAndConditionsCheckbox(),

                      const SizedBox(height: 24),

                      // Tombol Daftar/Sign Up
                      SizedBox(
                        width: double.infinity, // Full width
                        height: 55,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () => _signUp(authProvider), // Panggil fungsi sign up
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 5, // Bayangan untuk depth
                            shadowColor: primaryColor.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'DAFTAR',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5, // Spasi antar huruf
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Divider dengan teks "Atau daftar dengan"
                      _buildDividerWithText('Atau daftar dengan'),

                      const SizedBox(height: 20),

                      // Tombol social media sign up (Google, Facebook, Apple)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google Sign Up
                          _socialSignUpButton(
                            icon: Icons.g_mobiledata,
                            color: Colors.red,
                            onPressed: authProvider.isLoading
                                ? null
                                : () => _handleGoogleSignUp(authProvider),
                          ),
                          const SizedBox(width: 16),

                          // Facebook Sign Up
                          _socialSignUpButton(
                            icon: Icons.facebook,
                            color: const Color(
                              0xFF1877F2,
                            ), // Official Facebook blue
                            onPressed: () {
                              /* Handle Facebook sign up */
                            },
                          ),
                          const SizedBox(width: 16),

                          // Apple Sign Up
                          _socialSignUpButton(
                            icon: Icons.apple,
                            color: Colors.black,
                            onPressed: () {
                              /* Handle Apple sign up */
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Link ke halaman Login untuk user yang sudah punya akun
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Sudah punya akun? ",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go('/login'); // Navigate back to login
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widget Helper Functions ---

  /// Widget untuk membuat header section dengan gradient background
  /// Berisi icon, title, dan subtitle
  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        // Gradient dari primary ke secondary color
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, secondaryColor],
        ),
        borderRadius: BorderRadius.circular(30),
        // Shadow untuk depth effect
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5), // Bayangan ke bawah
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 5),

          // Icon dalam lingkaran putih
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_alt_1,
              size: 40,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          const Text(
            "Buat Akun Baru",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle
          const Text(
            "Bergabunglah dengan Bundacare",
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),

          const SizedBox(height: 5),
        ],
      ),
    );
  }

  /// Widget untuk membuat checkbox persetujuan syarat & ketentuan
  /// Dengan link yang bisa diklik untuk melihat detail S&K
  Widget _buildTermsAndConditionsCheckbox() {
    return Row(
      children: [
        // Checkbox dengan ukuran custom
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              // Update state ketika checkbox diklik
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            activeColor: primaryColor, // Warna saat checked
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Teks dengan link clickable
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Saya setuju dengan ',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),

              // Link clickable untuk Syarat & Ketentuan
              GestureDetector(
                onTap: () {
                  // Simulasi: Tampilkan SnackBar (dalam real app, buka halaman S&K)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Menampilkan Syarat & Ketentuan... (Simulasi)',
                      ),
                      backgroundColor: Colors.blueGrey,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Syarat & Ketentuan',
                  style: TextStyle(
                    fontSize: 13,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget untuk membuat divider dengan teks di tengah
  /// Digunakan untuk memisahkan form utama dengan opsi social login
  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        // Garis kiri
        const Expanded(child: Divider(color: Color(0xFFE0E0E0))),

        // Teks di tengah
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),

        // Garis kanan
        const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
      ],
    );
  }

  /// Widget untuk membuat tombol social media sign up
  /// Dengan icon dalam lingkaran dan efek ripple saat diklik
  Widget _socialSignUpButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        // Shadow untuk efek depth
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        // InkWell untuk efek ripple saat diklik
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(), // Ripple berbentuk lingkaran
          child: Center(child: Icon(icon, size: 28, color: color)),
        ),
      ),
    );
  }

  /// Dispose controllers saat widget dihancurkan
  /// Untuk menghindari memory leak
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
