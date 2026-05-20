import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.menu_book_rounded, size: 44, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text('Jurnal Belajar Harian', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text('Versi 1.0.0', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text('© 2026 Jurnal Belajar Harian', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _infoCard('Tentang', 'Aplikasi Jurnal Belajar Harian dirancang untuk membantu mahasiswa mencatat aktivitas belajar, menetapkan target harian, melakukan refleksi diri, dan memantau perkembangan belajar secara konsisten.'),
            const SizedBox(height: 12),
            _featureCard('Fitur Utama', [
              {'icon': Icons.book_rounded, 'title': 'Catatan Belajar', 'desc': 'Catat aktivitas dan materi belajar'},
              {'icon': Icons.flag_rounded, 'title': 'Target Harian', 'desc': 'Tetapkan dan pantau target belajarmu'},
              {'icon': Icons.psychology_rounded, 'title': 'Refleksi Diri', 'desc': 'Evaluasi dan tingkatkan kualitas belajar'},
              {'icon': Icons.bar_chart_rounded, 'title': 'Statistik', 'desc': 'Pantau grafik perkembangan belajarmu'},
              {'icon': Icons.notifications_rounded, 'title': 'Notifikasi', 'desc': 'Dapatkan pengingat belajar harian'},
            ]),
            const SizedBox(height: 12),
            _infoCard('Teknologi', 'Dibangun menggunakan Flutter untuk cross-platform, dengan Firebase sebagai backend untuk autentikasi dan penyimpanan data real-time.'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _featureCard(String title, List<Map<String, dynamic>> features) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(10)),
                  child: Icon(f['icon'] as IconData, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                      Text(f['desc'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
