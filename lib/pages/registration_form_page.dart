import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class RegistrationFormPage extends StatelessWidget {
  RegistrationFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Colors.pink[300]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Kategori"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pink[400]!, Colors.pink[300]!],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            // Logout dulu supaya tidak terkena redirect otomatis kembali ke sini
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            await authProvider.logout();

            // Gunakan context.go untuk pindah ke halaman login
            if (context.mounted) {
              context.go('/login');
            }
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul
            Text(
              "Silakan Pilih Kategori Anda",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Pilih salah satu kategori di bawah ini untuk melanjutkan pendaftaran",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 50),

            // Tombol 1: Ibu Hamil
            _buildRoleButton(
              context: context,
              role: 'IbuHamil',
              label: 'Ibu Hamil',
              icon: Icons.pregnant_woman,
              color: Colors.pink.shade400,
            ),
            SizedBox(height: 20),

            // Tombol 2: Ibu Menyusui
            _buildRoleButton(
              context: context,
              role: 'IbuMenyusui',
              label: 'Ibu Menyusui',
              icon: Icons.child_care,
              color: Colors.purple.shade400,
            ),
            SizedBox(height: 20),

            // Tombol 3: Anak Batita
            _buildRoleButton(
              context: context,
              role: 'AnakBatita',
              label: 'Anak Batita (0-24 bulan)',
              icon: Icons.baby_changing_station,
              color: Colors.cyan.shade400,
            ),
          ],
        ),
      ),
    );
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
        // Debug: Print untuk memastikan fungsi dipanggil
        print('Tombol $label ditekan!');

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
