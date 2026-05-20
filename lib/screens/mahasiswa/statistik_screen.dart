import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    // belajarPerMinggu: index 0 = hari ini, index 6 = 6 hari lalu
    // Balik agar grafik tampil dari kiri (terlama) ke kanan (hari ini)
    final belajarRaw = provider.belajarPerMinggu;
    final belajar = belajarRaw.reversed.toList();
    final maxVal = belajar.isEmpty ? 0.0 : belajar.reduce((a, b) => a > b ? a : b).toDouble();

    // Buat label hari dinamis untuk 7 hari terakhir (indeks 0 = 6 hari lalu)
    final now = DateTime.now();
    final dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return dayNames[d.weekday % 7];
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Statistik')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(child: _statCard('Total Belajar', provider.totalBelajarDisplay, Icons.timer_rounded, AppColors.blueGradient)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Streak', '${provider.userProfile.streakHari} Hari', Icons.local_fire_department_rounded, AppColors.orangeGradient)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statCard('Target Selesai', '${provider.targetSelesaiCount}/${provider.targetTotalCount}', Icons.flag_rounded, AppColors.greenGradient)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Refleksi', '${provider.refleksiListForUser.length}', Icons.psychology_rounded, AppColors.purpleGradient)),
              ],
            ),
            const SizedBox(height: 24),

            // Grafik belajar mingguan
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Waktu Belajar Minggu Ini', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                  const Text('Total waktu dalam menit', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (i) {
                        final h = maxVal > 0 ? (belajar[i] / maxVal) * 130 : 0.0;
                        final isToday = i == 6; // index 6 = hari ini (setelah dibalik)
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('${belajar[i]}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isToday ? AppColors.primary : AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 600),
                                  height: h,
                                  decoration: BoxDecoration(
                                    gradient: isToday ? AppColors.blueGradient : LinearGradient(colors: [AppColors.border, AppColors.border]),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(days[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isToday ? AppColors.primary : AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Progress target
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Progress Target', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 80, height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: provider.persentaseTarget,
                              backgroundColor: AppColors.border,
                              color: AppColors.success,
                              strokeWidth: 8,
                            ),
                            Text('${(provider.persentaseTarget * 100).toInt()}%',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _progressRow('Selesai', provider.targetSelesaiCount, AppColors.success),
                            const SizedBox(height: 8),
                            _progressRow('Belum Selesai', provider.targetTotalCount - provider.targetSelesaiCount, AppColors.error),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Distribusi mood refleksi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Distribusi Mood Refleksi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['😞','😕','😐','😊','😄'].map((e) {
                      final idx = ['😞','😕','😐','😊','😄'].indexOf(e) + 1;
                      final count = provider.refleksiListForUser.where((r) => r.mood == idx).length;
                      return Column(
                        children: [
                          Text(e, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 6),
                          Text('$count', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, LinearGradient gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Text('$count', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
      ],
    );
  }
}
