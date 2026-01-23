import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/meal_schedule_provider.dart';
import '../models/meal_schedule.dart';
import '../utils/styles.dart';
import '../router/app_router.dart';

class MealNotificationSettingsPage extends StatelessWidget {
  const MealNotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          "Pengaturan Notifikasi Makan",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppStyles.pinkGradient),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<MealScheduleProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.mealSchedules.length,
              itemBuilder: (context, index) {
                final schedule = provider.mealSchedules[index];
                return _buildScheduleCard(context, schedule);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, MealSchedule schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${schedule.scheduledTime.format(context)} • ${schedule.customMessage ?? schedule.defaultMessage}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Builder(
                        builder: (context) => Text(
                          _getNextNotificationTime(schedule, context),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: schedule.isEnabled,
                  onChanged: (value) {
                    context.read<MealScheduleProvider>().toggleSchedule(
                      schedule.id,
                      value,
                    );
                  },
                  thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppStyles.primaryPink;
                    }
                    return Colors.grey;
                  }),
                  trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppStyles.primaryPink.withValues(alpha: 0.5);
                    }
                    return Colors.grey.withValues(alpha: 0.3);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showScheduleDialog(context, schedule),
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(
                      'Ubah',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppStyles.radiusSmall,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final provider = context.read<MealScheduleProvider>();

                      // First check permission
                      final hasPermission = await provider
                          .checkNotificationPermission();
                      if (!hasPermission) {
                        // Show permission dialog
                        await _showPermissionDialog(context);
                        return;
                      }

                      final success = await provider.testNotification(
                        schedule.id,
                      );

                      // Use post-frame callback for safe snackbar display
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final mainContext =
                            AppRouter.navigatorKey.currentContext;
                        if (mainContext != null && mainContext.mounted) {
                          ScaffoldMessenger.of(mainContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? '🔔 Notifikasi test muncul sekarang!'
                                    : '❌ Gagal mengirim notifikasi test',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: success
                                  ? AppStyles.primaryPink
                                  : Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      });
                    },
                    icon: const Icon(Icons.notifications_active, size: 18),
                    label: Text(
                      'Test',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppStyles.primaryPink),
                      foregroundColor: AppStyles.primaryPink,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppStyles.radiusSmall,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleDialog(BuildContext context, MealSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleDialog(schedule: schedule),
    );
  }

  String _getNextNotificationTime(MealSchedule schedule, BuildContext context) {
    if (!schedule.isEnabled) {
      return 'Notifikasi dinonaktifkan';
    }

    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      schedule.scheduledTime.hour,
      schedule.scheduledTime.minute,
    );

    String nextTime;
    if (scheduledTime.isBefore(now)) {
      // If already passed today, will show tomorrow
      nextTime = 'Besok pukul ${schedule.scheduledTime.format(context)}';
    } else {
      // Will show at the scheduled time today
      nextTime = 'Hari ini pukul ${schedule.scheduledTime.format(context)}';
    }

    return nextTime;
  }

  Future<void> _showPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Izin Notifikasi Diperlukan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Untuk menerima pengingat makan, aplikasi memerlukan izin notifikasi. '
            'Apakah Anda ingin memberikan izin?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Nanti',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryPink,
              ),
              child: Text(
                'Buka Pengaturan',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScheduleDialog extends StatefulWidget {
  final MealSchedule schedule;

  const _ScheduleDialog({required this.schedule});

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  late TimeOfDay _selectedTime;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.schedule.scheduledTime;
    _messageController = TextEditingController(
      text: widget.schedule.customMessage,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atur ${widget.schedule.displayName}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Waktu Notifikasi',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppStyles.primaryPink,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (time != null) {
                  setState(() => _selectedTime = time);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: AppStyles.primaryPink),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime.format(context),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pesan Kustom (Opsional)',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Masukkan pesan notifikasi kustom',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                  borderSide: BorderSide(color: AppStyles.primaryPink),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppStyles.primaryPink),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppStyles.radiusSmall,
                        ),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.poppins(
                        color: AppStyles.primaryPink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final updatedSchedule = widget.schedule.copyWith(
                        scheduledTime: _selectedTime,
                        customMessage: _messageController.text.isEmpty
                            ? null
                            : _messageController.text,
                      );

                      await context
                          .read<MealScheduleProvider>()
                          .updateMealSchedule(updatedSchedule);

                      // Close dialog first
                      if (mounted) {
                        Navigator.pop(context);
                      }

                      // Show success message after dialog closes
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        // Get the parent context from the main page
                        final mainContext =
                            AppRouter.navigatorKey.currentContext;
                        if (mainContext != null && mainContext.mounted) {
                          ScaffoldMessenger.of(mainContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${widget.schedule.displayName} berhasil diperbarui',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryPink,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppStyles.radiusSmall,
                        ),
                      ),
                    ),
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
