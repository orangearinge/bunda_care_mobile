import 'package:flutter/material.dart';
import '../utils/styles.dart';

class OfflinePlaceholder extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback onRetry;
  final IconData icon;

  const OfflinePlaceholder({
    super.key,
    required this.onRetry,
    this.message = 'Yah, lagi offline nih. Cek koneksi internet kamu!',
    this.title = 'Offline Mode',
    this.icon = Icons.cloud_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container dengan gradient background dan shadow
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.pink[50]!.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
              ),
              child: Column(
                children: [
                  // Icon dengan background circle
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppStyles.pinkGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppStyles.primaryPink.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Message
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Action Button
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 280),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Optional secondary message
            Text(
              'Koneksi stabil biar bisa sync data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
