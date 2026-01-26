import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../utils/logger.dart';
import '../utils/styles.dart';

class RegistrationFormPage extends StatefulWidget {
  const RegistrationFormPage({super.key});

  @override
  State<RegistrationFormPage> createState() => _RegistrationFormPageState();
}

class _RegistrationFormPageState extends State<RegistrationFormPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _handleLogout();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pilih Kategori"),
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: AppStyles.pinkGradient),
          ),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _handleLogout,
          ),
        ),
        resizeToAvoidBottomInset:
            false, // Mencegah layout flicker saat keyboard navigasi/transisi
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Judul
                const Text(
                  "Silakan Pilih Kategori Anda",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Pilih salah satu kategori di bawah ini untuk melanjutkan pendaftaran",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 50),

                // Tombol 1: Ibu Hamil
                _buildRoleButton(
                  context: context,
                  role: 'IbuHamil',
                  label: 'Ibu Hamil',
                  icon: Icons.pregnant_woman,
                  color: Colors.pink.shade400,
                ),
                const SizedBox(height: 20),

                // Tombol 2: Ibu Menyusui
                _buildRoleButton(
                  context: context,
                  role: 'IbuMenyusui',
                  label: 'Ibu Menyusui',
                  icon: Icons.child_care,
                  color: Colors.purple.shade400,
                ),
                const SizedBox(height: 20),

                // Tombol 3: Anak Batita
                _buildRoleButton(
                  context: context,
                  role: 'AnakBatita',
                  label: 'Anak Batita',
                  icon: Icons.baby_changing_station,
                  color: Colors.cyan.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout() async {
    // Cukup logout, AppRouter akan otomatis mengarahkan ke halaman login
    // karena status akan berubah menjadi unauthenticated
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
  }

  // Widget untuk membuat tombol dengan icon
  Widget _buildRoleButton({
    required BuildContext context,
    required String role,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: () async {
        // Debug: Log untuk memastikan fungsi dipanggil
        AppLogger.d('Tombol $label ditekan!');

        // Navigasi ke MultiStepFormPage
        context.go('/multi-step-form/$role');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
