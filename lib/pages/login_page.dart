import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';

/// Halaman Login untuk autentikasi user
/// Stateful widget yang mengelola form login dengan validasi
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Form key untuk validasi form secara keseluruhan
  final _formKey = GlobalKey<FormState>();

  // Controller untuk mengambil dan mengontrol value dari text field
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State untuk mengontrol visibility password (tampil/sembunyi)
  bool _obscurePassword = true;

  /// Fungsi untuk memproses login user
  /// Melakukan validasi dan pengecekan kredensial
  void _login(AuthProvider authProvider) async {
    // Validasi semua input field menggunakan validator
    if (_formKey.currentState!.validate()) {
      // Ambil nilai dari controller
      final email = _emailController.text;
      final password = _passwordController.text;

      // Call auth provider to login
      final success = await authProvider.login(
        email: email,
        password: password,
      );

      if (mounted) {
        if (!success) {
          // Login gagal: Tampilkan pesan error menggunakan SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.errorMessage ??
                    ApiConstants.getErrorMessage('INVALID_CREDENTIALS'),
              ),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating, // SnackBar mengambang
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        // Jika sukses, AppRouter akan menangani navigasi otomatis
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //  Mencegah resize saat keyboard muncul
      // SafeArea memastikan konten tidak tertutup status bar (di atas)
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) => SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Jarak di atas dikurangi secara signifikan
                  // --- Header Section dengan Desain Modern ---
                  ClipPath(
                    clipper: HeaderClipper(),
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: AppStyles.pinkGradient,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ), // Padding tambahan agar konten tidak terlalu ke atas
                          // Logo BundaCare
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                'lib/assets/images/logo_bundacare.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Bundacare",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Text(
                            "Analisis gizi Ibu dan anak",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ), // Spacer bawah untuk menjaga jarak dari lengkungan
                        ],
                      ),
                    ),
                  ),

                  // Container Form
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        // --- Input Email ---
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(hintText: 'email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan email Anda';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // --- Input Password ---
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'password',
                            // Tombol untuk toggle visibility password
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),

                          // Validasi input password
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan password Anda';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        // --- Link Forgot Password ---
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Handle forgot password
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.blue[400],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                        // Spasi sebelum tombol login dikurangi
                        const SizedBox(height: 10), // Disesuaikan dari 20
                        // --- Tombol Login ---
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () => _login(authProvider),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: AppStyles.pinkGradient,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                alignment: Alignment.center,
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
                                        'LOGIN',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // --- Divider Text ---
                  const Text(
                    'Or Log in With',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 20),
                  // --- Social Login Buttons ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialLoginButton(
                        image: 'lib/assets/images/google_logo.png',
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _handleGoogleSignIn(authProvider),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  // --- Link Sign Up ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.blue[400],
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle Google Sign-In
  Future<void> _handleGoogleSignIn(AuthProvider authProvider) async {
    final success = await authProvider.signInWithGoogle();

    if (mounted) {
      if (!success && authProvider.errorMessage != null) {
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
      // Jika sukses, AppRouter akan menangani navigasi otomatis
    }
  }

  /// Widget untuk membuat tombol social media login
  Widget _socialLoginButton({
    IconData? icon,
    Color? color,
    String? image,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: image != null
            ? Image.asset(image, width: 28, height: 28)
            : Icon(icon, size: 28),
        color: color,
        onPressed: onPressed,
      ),
    );
  }

  /// Dispose controllers saat widget dihancurkan
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

/// Clipper untuk membuat background header melengkung seperti setengah lingkaran
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Mulai dari kiri bawah (dengan offset)
    path.lineTo(0, size.height - 80);

    // Buat kurva quadratic beizer ke kanan bawah
    // Control point ada di tengah paling bawah (size.width / 2, size.height)
    // End point ada di kanan bawah (size.width, size.height - 80)
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 80,
    );

    // Garis ke kanan atas
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
