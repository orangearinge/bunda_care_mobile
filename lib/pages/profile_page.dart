import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/user_preference_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_preference.dart';
import 'edit_profile_page.dart';
import '../utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/styles.dart';
import '../widgets/shimmer_loading.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ignore: unused_field
  final int _selectedIndex = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if mounted before creating provider access, though initState implies mounted
      if (mounted) {
        Provider.of<UserPreferenceProvider>(
          context,
          listen: false,
        ).fetchPreference();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Selector2<UserPreferenceProvider, AuthProvider,
                  ({
                    PreferenceStatus status,
                    String? errorMessage,
                    bool isLoading
                  })>(
                selector: (_, provider, auth) => (
                  status: provider.status,
                  errorMessage: provider.errorMessage,
                  isLoading: provider.isLoading,
                ),
                builder: (context, data, child) {
                  if (data.isLoading) {
                    return const ProfileSkeleton();
                  }

                  if (data.status == PreferenceStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(data.errorMessage ?? 'Gagal memuat data'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<UserPreferenceProvider>()
                                .fetchPreference(),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Selector2<UserPreferenceProvider, AuthProvider,
                      ({UserPreference? pref, String? avatar, String? name})>(
                    selector: (_, provider, auth) => (
                      pref: provider.currentPreference,
                      avatar: auth.currentUser?.avatar,
                      name: auth.currentUser?.name,
                    ),
                    builder: (context, data, _) {
                      final pref = data.pref;
                      if (pref == null) {
                        return const Center(
                          child: Text('Data profil tidak ditemukan.'),
                        );
                      }

                      final avatarUrl = data.avatar;
                      final userNameFallback = data.name ?? 'Bunda';

                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Column(
                          children: [
                            _buildHeader(
                                context, pref, avatarUrl, userNameFallback),
                            const SizedBox(height: 24),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Informasi Pribadi'),
                                  _buildPersonalInfoCard(pref),
                                  const SizedBox(height: 24),
                                  _buildSectionTitle('Kesehatan Fisik'),
                                  _buildHealthMetricsGrid(pref),
                                  if (pref.foodProhibitions.isNotEmpty ||
                                      pref.allergens.isNotEmpty) ...[
                                    const SizedBox(height: 24),
                                    _buildAllergyInfo(pref),
                                  ],
                                  const SizedBox(height: 24),
                                  if (pref.nutritionalTargets != null) ...[
                                    _buildSectionTitle('Target Nutrisi Harian'),
                                    _buildNutritionCard(
                                        pref.nutritionalTargets!),
                                    const SizedBox(height: 24),
                                  ],
                                  _buildSectionTitle('Lainnya'),
                                  _buildSettingsCard(context),
                                  const SizedBox(height: 40),
                                  _buildVersionInfo(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserPreference pref,
      String? avatarUrl, String userNameFallback) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        children: [
          Stack(
            children: [
              Builder(
                builder: (context) {
                  final hasAvatar =
                      avatarUrl != null && avatarUrl.isNotEmpty;

                  String? finalUrl;
                  if (hasAvatar) {
                    if (avatarUrl.startsWith('http')) {
                      finalUrl = avatarUrl;
                    } else {
                      final baseUrl = ApiConstants.baseUrl;
                      finalUrl = avatarUrl.startsWith('/')
                          ? '$baseUrl$avatarUrl'
                          : '$baseUrl/$avatarUrl';
                    }
                  }

                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.pink.shade50, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.pink[50],
                      backgroundImage: hasAvatar
                          ? CachedNetworkImageProvider(finalUrl!)
                          : null,
                      onBackgroundImageError: hasAvatar
                          ? (exception, stackTrace) {
                              debugPrint('Error loading avatar: $exception');
                            }
                          : null,
                      child: !hasAvatar
                          ? Text(
                              context
                                      .read<AuthProvider>()
                                      .currentUser
                                      ?.getInitials() ??
                                  'B',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink[400],
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          initialPreference: pref,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            pref.name ?? userNameFallback,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              pref.role.replaceAll('_', ' '),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.pink[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(UserPreference pref) {
    return _ContentCard(
      child: Column(
        children: [
          _ProfileRow(
            icon: Icons.cake_outlined,
            label: pref.role == 'ANAK_BATITA' ? 'Usia Anak' : 'Usia',
            value: pref.role == 'ANAK_BATITA'
                ? (pref.ageYear > 0
                    ? '${pref.ageYear} Tahun ${pref.ageMonth ?? 0} Bulan'
                    : '${pref.ageMonth ?? 0} Bulan')
                : '${pref.ageYear} Tahun',
          ),
          const Divider(height: 24, indent: 44),
          _ProfileRow(
            icon: Icons.person_outline,
            label: 'Peran',
            value: pref.role.replaceAll('_', ' '),
          ),
          if (pref.role == 'IBU_HAMIL' && pref.hpht != null) ...[
            const Divider(height: 24, indent: 44),
            _ProfileRow(
              icon: Icons.calendar_today_outlined,
              label: 'HPHT',
              value: pref.hpht!,
            ),
          ],
          if (pref.role == 'IBU_HAMIL' &&
              pref.gestationalAgeWeeks != null) ...[
            const Divider(height: 24, indent: 44),
            _ProfileRow(
              icon: Icons.child_friendly_outlined,
              label: 'Usia Kandungan',
              value: '${pref.gestationalAgeWeeks} Minggu',
            ),
          ],
           if (pref.role == 'IBU_MENYUSUI' &&
              pref.lactationPhase != null) ...[
            const Divider(height: 24, indent: 44),
            _ProfileRow(
              icon: Icons.baby_changing_station_outlined,
              label: 'Fase Menyusui',
              value: pref.lactationPhase == '0-6'
                  ? '6 Bulan Pertama'
                  : '6 Bulan Kedua',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthMetricsGrid(UserPreference pref) {
    final metrics = [
      _MetricData(
        pref.role == 'ANAK_BATITA' ? 'Tinggi Anak' : 'Tinggi Badan',
        '${pref.heightCm} cm',
        Icons.height,
        Colors.blue,
      ),
      _MetricData(
        pref.role == 'ANAK_BATITA' ? 'Berat Anak' : 'Berat Badan',
        '${pref.weightKg} kg',
        Icons.monitor_weight_outlined,
        Colors.green,
      ),
      _MetricData(
        'BMI',
        pref.nutritionalTargets?.bmi?.toStringAsFixed(2) ?? '-',
        Icons.speed,
        Colors.orange,
      ),
    ];

    if (pref.lilaCm != null) {
      metrics.add(_MetricData(
        'LiLA',
        '${pref.lilaCm} cm',
        Icons.straighten,
        Colors.purple,
      ));
    }

    return LayoutBuilder(builder: (context, constraints) {
      // Simple grid calculation
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: metrics.map((m) {
          final width = (constraints.maxWidth - 12) / 2;
          return _MetricCard(data: m, width: width);
        }).toList(),
      );
    });
  }

  Widget _buildAllergyInfo(UserPreference pref) {
    return Column(
      children: [
        if (pref.foodProhibitions.isNotEmpty)
          _InfoContainer(
            icon: Icons.no_food_outlined,
            title: 'Pantangan Makanan',
            items: pref.foodProhibitions,
            color: Colors.red,
          ),
        if (pref.foodProhibitions.isNotEmpty && pref.allergens.isNotEmpty)
          const SizedBox(height: 12),
        if (pref.allergens.isNotEmpty)
          _InfoContainer(
            icon: Icons.coronavirus_outlined,
            title: 'Alergi',
            items: pref.allergens,
            color: Colors.orange,
          ),
      ],
    );
  }

  Widget _buildNutritionCard(NutritionalTargets targets) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppStyles.pinkGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NutrientItem(
                label: 'Kalori',
                value: '${targets.calories.toInt()}',
                unit: 'kkal',
                icon: Icons.local_fire_department,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
              ),
              _NutrientItem(
                label: 'Protein',
                value: '${targets.proteinG.toInt()}',
                unit: 'g',
                icon: Icons.fitness_center,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NutrientItem(
                label: 'Karbohidrat',
                value: '${targets.carbsG.toInt()}',
                unit: 'g',
                icon: Icons.rice_bowl,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
              ),
              _NutrientItem(
                label: 'Lemak',
                value: '${targets.fatG.toInt()}',
                unit: 'g',
                icon: Icons.opacity,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return _ContentCard(
      child: Column(
        children: [
          ListTile(
            onTap: () => context.push('/feedback'),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
            ),
            title: const Text(
              'Beri Feedback',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          const Divider(height: 1),
          ListTile(
            onTap: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout, color: Colors.red[400], size: 20),
            ),
            title: Text(
              'Keluar Aplikasi',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.red[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Text(
        'versi 1.0-0',
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// --- Helper Widgets ---

class _ContentCard extends StatelessWidget {
  final Widget child;
  const _ContentCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8), // Padding for ListTile clicks
      child: child,
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.pink[400], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _MetricData(this.label, this.value, this.icon, this.color);
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;
  final double width;

  const _MetricCard({required this.data, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;
  final Color color;

  const _InfoContainer({
    required this.icon,
    required this.title,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.1)),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _NutrientItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  const _NutrientItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$unit $label',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
