import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

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
         if (success) {
           // Login berhasil - navigasi berdasarkan status user
           if (authProvider.isUserComplete) {
             context.go('/');
           } else {
             context.go('/role-selection');
           }
         } else {
          // Login gagal: Tampilkan pesan error menggunakan SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Login failed'),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating, // SnackBar mengambang
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // SafeArea memastikan konten tidak tertutup status bar (di atas)
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) => SafeArea(
        // **HAPUS SingleChildScrollView** agar tidak scroll di awal.
        // Flutter otomatis menggeser layar saat keyboard muncul (resizeToAvoidBottomInset: true default)
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),

          // Form wrapper untuk validasi
          child: Form(
            key: _formKey,
            // Column untuk menampung semua elemen form
            child: Column(
              // MainAxisSize.max agar column mengisi ruang vertikal yang tersedia
              mainAxisSize: MainAxisSize.max,
              children: [
                // Jarak di atas dikurangi secara signifikan
                const SizedBox(height: 16), // Disesuaikan dari 40
                // --- Header Section dengan Logo dan Ilustrasi ---
                Container(
                  width: double.infinity,
                  // Tinggi dikurangi dari 280 menjadi 200 agar konten di bawahnya muat
                  height: 200, // <--- PERUBAHAN TINGGI DI SINI
                  decoration: BoxDecoration(
                    // Gradient background dari pink terang ke pink muda
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.pink[200]!, Colors.pink[100]!],
                    ),
                    borderRadius: BorderRadius.circular(200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nama aplikasi
                      const Text(
                        "Bundacare",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      // Tagline aplikasi
                      const Text(
                        "Analisis gizi Ibu dan anak",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),

                      const SizedBox(height: 10), // Spasi dikurangi
                      // Ilustrasi icon
                      Container(
                        width: 80, // Ukuran Icon dikurangi dari 120
                        height: 80, // Ukuran Icon dikurangi dari 120
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.local_hospital,
                            size: 40,
                            color: Colors.blue[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Jarak di bawah header dikurangi
                const SizedBox(height: 20), // Disesuaikan dari 40
                // --- Input Email ---
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'email',
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),

                    // Border styling
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.pink[200]!,
                        width: 2,
                      ),
                    ),
                  ),
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
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),

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

                    // Border styling
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.pink[200]!,
                        width: 2,
                      ),
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
                      style: TextStyle(color: Colors.blue[400], fontSize: 12),
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
                      backgroundColor: Colors.pink[200],
                      foregroundColor: Colors.white,
                      elevation: 0,
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
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),

                // Spasi dikurangi dan diganti dengan Spacer untuk mengisi ruang kosong yang tersisa
                // Ini memastikan elemen di bawah terdorong ke bawah/atas dengan seimbang
                const Spacer(), // <--- PENGGUNAAN SPACER DI SINI
                // --- Divider Text ---
                const Text(
                  'Or Log in With',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 10), // Disesuaikan dari 16
                // --- Social Login Buttons ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google Login
                    _socialLoginButton(
                      icon: Icons.g_mobiledata,
                      color: Colors.red,
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _handleGoogleSignIn(authProvider),
                    ),
                    const SizedBox(width: 16),

                    // Facebook Login
                    _socialLoginButton(
                      icon: Icons.facebook,
                      color: Colors.blue[700]!,
                      onPressed: () {
                        // Handle Facebook login
                      },
                    ),
                    const SizedBox(width: 16),

                    // Apple Login
                    _socialLoginButton(
                      icon: Icons.apple,
                      color: Colors.black,
                      onPressed: () {
                        // Handle Apple login
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10), // Disesuaikan dari 24
                // --- Link Sign Up ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),

                    // Tombol navigasi ke halaman Sign Up
                    TextButton(
                      onPressed: () {
                        context.push('/register');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
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

                const SizedBox(height: 16), // Disesuaikan dari 20
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
       if (success) {
         // Add longer delay to ensure Google UI is fully dismissed before navigating
         Future.delayed(const Duration(milliseconds: 3000), () {
           if (mounted) {
             // Set authenticated state after navigation to prevent router conflicts
             authProvider.completeGoogleSignIn();

             // Login berhasil - navigasi berdasarkan status user
             if (authProvider.isUserComplete) {
               context.go('/');
             } else {
               context.go('/role-selection');
             }
           }
         });
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

  /// Widget untuk membuat tombol social media login
  Widget _socialLoginButton({
    required IconData icon,
    required Color color,
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
        icon: Icon(icon, size: 28),
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
