import 'package:flutter/material.dart';
import 'chatbot_page.dart';
import 'scan_page.dart';
import 'edukasi_page.dart';
import 'profile_detail_page.dart';
import 'rekam_medis_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pop(context);
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScanPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EdukasiPage()),
        );
        break;
      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundImage: const NetworkImage(
                        'https://i.pravatar.cc/150?img=47',
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Nadia Febriani',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '0882-0034-85047',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Akun',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 6),
                _buildMenuItem('Profil Saya', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileDetailPage(),
                    ),
                  );
                }),
                _buildMenuItem('Rekam Medis', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RekamMedisPage(),
                    ),
                  );
                }),
                _buildMenuItem('Keluarga Saya'),
                _buildMenuItem('Ubah Kata Sandi'),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Aplikasi mobile-KIA',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 6),
                _buildMenuItem('Tentang Kami'),
                _buildMenuItem('Privasi'),
                _buildMenuItem('Syarat dan Ketentuan'),
                _buildMenuItem('Hubungi Kami'),

                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'versi 5.50-117',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                    ),
                    child: const Text(
                      'logout',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, Icons.home, 0),
                _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 1),
                _buildNavItem(Icons.qr_code_scanner, Icons.qr_code_scanner, 2),
                _buildNavItem(
                  Icons.notifications_outlined,
                  Icons.notifications,
                  3,
                ),
                _buildNavItem(Icons.person_outline, Icons.person, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black54),
        onTap: onTap ?? () {},
      ),
    );
  }

  Widget _buildNavItem(IconData iconOutlined, IconData iconFilled, int index) {
    bool isSelected = _selectedIndex == index;

    List<Color> gradientColors;
    switch (index) {
      case 0:
        gradientColors = [Colors.pink[300]!, Colors.pink[400]!];
        break;
      case 1:
        gradientColors = [Colors.purple[300]!, Colors.purple[400]!];
        break;
      case 2:
        gradientColors = [Colors.blue[300]!, Colors.blue[400]!];
        break;
      case 3:
        gradientColors = [Colors.orange[300]!, Colors.orange[400]!];
        break;
      case 4:
        gradientColors = [Colors.teal[300]!, Colors.teal[400]!];
        break;
      default:
        gradientColors = [Colors.grey[300]!, Colors.grey[400]!];
    }

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isSelected ? iconFilled : iconOutlined,
          color: isSelected ? Colors.white : Colors.grey[400],
          size: 28,
        ),
      ),
    );
  }
}
