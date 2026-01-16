import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/user_preference_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_preference.dart';
import 'edit_profile_page.dart';
import '../utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserPreferenceProvider>(
        context,
        listen: false,
      ).fetchPreference();
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Selector2<UserPreferenceProvider, AuthProvider,
                  ({PreferenceStatus status, String? errorMessage, bool isLoading})>(
                selector: (_, provider, auth) => (
                  status: provider.status,
                  errorMessage: provider.errorMessage,
                  isLoading: provider.isLoading,
                ),
                builder: (context, data, child) {
                  if (data.isLoading) {
                    return const Center(child: CircularProgressIndicator());
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
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      final hasAvatar = avatarUrl != null &&
                                          avatarUrl.isNotEmpty;

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

                                      return CircleAvatar(
                                        radius: 34,
                                        backgroundColor: Colors.pink[100],
                                        backgroundImage: hasAvatar
                                            ? CachedNetworkImageProvider(
                                                finalUrl!,
                                              )
                                            : null,
                                        onBackgroundImageError: hasAvatar
                                            ? (exception, stackTrace) {
                                                debugPrint(
                                                  'Error loading avatar: $exception',
                                                );
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
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.pink[400],
                                                ),
                                              )
                                            : null,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pref.name ?? userNameFallback,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          pref.role.replaceAll('_', ' '),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditProfilePage(
                                            initialPreference: pref,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.pink[50],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.pink[400],
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSectionHeader('Profil Saya'),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _ProfileField(
                                      label: pref.role == 'ANAK_BATITA'
                                          ? 'Usia Anak'
                                          : 'Usia',
                                      value: pref.role == 'ANAK_BATITA'
                                          ? (pref.ageYear > 0
                                              ? '${pref.ageYear} Tahun ${pref.ageMonth ?? 0} Bulan'
                                              : '${pref.ageMonth ?? 0} Bulan')
                                          : '${pref.ageYear} Tahun',
                                    ),
                                    const Divider(height: 24),
                                    _ProfileField(
                                      label: 'Peran',
                                      value: pref.role.replaceAll('_', ' '),
                                    ),
                                    if (pref.role == 'IBU_HAMIL' &&
                                        pref.hpht != null) ...[
                                      const Divider(height: 24),
                                      _ProfileField(
                                        label: 'HPHT',
                                        value: pref.hpht!,
                                      ),
                                    ],
                                    if (pref.role == 'IBU_HAMIL' &&
                                        pref.gestationalAgeWeeks != null) ...[
                                      const Divider(height: 24),
                                      _ProfileField(
                                        label: 'Usia Kandungan',
                                        value:
                                            '${pref.gestationalAgeWeeks} Minggu',
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildSectionHeader('Rekam Medis'),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50]!,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _StatPill(
                                          title: pref.role == 'ANAK_BATITA'
                                              ? 'Tinggi\nAnak'
                                              : 'Tinggi\nBadan',
                                          value: '${pref.heightCm} cm',
                                        ),
                                        _StatPill(
                                          title: pref.role == 'ANAK_BATITA'
                                              ? 'Berat\nAnak'
                                              : 'Berat\nBadan',
                                          value: '${pref.weightKg} kg',
                                        ),
                                        _StatPill(
                                          title: 'BMI',
                                          valueBold: pref.nutritionalTargets
                                                  ?.bmi
                                                  ?.toStringAsFixed(2) ??
                                              '-',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (pref.foodProhibitions.isNotEmpty)
                                      _AllergyCard(
                                        title: 'Pantangan Makanan',
                                        items: pref.foodProhibitions,
                                      ),
                                    if (pref.foodProhibitions.isNotEmpty &&
                                        pref.allergens.isNotEmpty)
                                      const SizedBox(height: 12),
                                    if (pref.allergens.isNotEmpty)
                                      _AllergyCard(
                                        title: 'Alergi',
                                        items: pref.allergens,
                                      ),
                                    if (pref.lilaCm != null) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _StatPillSmall(
                                            label: 'LiLA',
                                            value: '${pref.lilaCm} cm',
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (pref.role == 'IBU_MENYUSUI' &&
                                        pref.lactationPhase != null) ...[
                                      const SizedBox(height: 12),
                                      _ProfileField(
                                        label: 'Fase Menyusui',
                                        value: pref.lactationPhase == '0-6'
                                            ? '6 Bulan Pertama'
                                            : '6 Bulan Kedua',
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (pref.nutritionalTargets != null) ...[
                                _buildSectionHeader('Target Nutrisi Harian'),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.pink[300]!,
                                        Colors.purple[300]!
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _NutrientInfo(
                                            label: 'Kalori',
                                            value:
                                                '${pref.nutritionalTargets!.calories.toInt()}',
                                            unit: 'kkal',
                                          ),
                                          Container(
                                            width: 1,
                                            height: 40,
                                            color: Colors.white24,
                                          ),
                                          _NutrientInfo(
                                            label: 'Protein',
                                            value:
                                                '${pref.nutritionalTargets!.proteinG.toInt()}',
                                            unit: 'g',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _NutrientInfo(
                                            label: 'Karbohidrat',
                                            value:
                                                '${pref.nutritionalTargets!.carbsG.toInt()}',
                                            unit: 'g',
                                          ),
                                          Container(
                                            width: 1,
                                            height: 40,
                                            color: Colors.white24,
                                          ),
                                          _NutrientInfo(
                                            label: 'Lemak',
                                            value:
                                                '${pref.nutritionalTargets!.fatG.toInt()}',
                                            unit: 'g',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                              const SizedBox(height: 40),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'versi 5.50-117',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final authProvider =
                                            Provider.of<AuthProvider>(
                                          context,
                                          listen: false,
                                        );
                                        await authProvider.logout();
                                        if (context.mounted) {
                                          context.go('/login');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.pink[50],
                                        foregroundColor: Colors.pink[400],
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          side: BorderSide(
                                            color: Colors.pink[100]!,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 48,
                                          vertical: 14,
                                        ),
                                      ),
                                      child: const Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
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

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.pink[100]!),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.pink[400],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
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
    );
  }
}

class _StatPill extends StatelessWidget {
  final String title;
  final String? value;
  final String? valueBold;

  const _StatPill({required this.title, this.value, this.valueBold});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
          const SizedBox(height: 8),
          if (value != null)
            Text(
              value!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          if (valueBold != null)
            Text(
              valueBold!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.pink[400],
              ),
            ),
        ],
      ),
    );
  }
}

class _AllergyCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _AllergyCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.pink[400],
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red[100]!),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
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

class _NutrientInfo extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _NutrientInfo({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatPillSmall extends StatelessWidget {
  final String label;
  final String value;

  const _StatPillSmall({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
