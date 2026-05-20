import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  String _formatWaktu(DateTime waktu) {
    final now = DateTime.now();
    final diff = now.difference(waktu);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  IconData _getIcon(String tipe) {
    switch (tipe) {
      case 'target': return Icons.flag_rounded;
      case 'streak': return Icons.local_fire_department_rounded;
      case 'refleksi': return Icons.psychology_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColor(String tipe) {
    switch (tipe) {
      case 'target': return AppColors.success;
      case 'streak': return AppColors.secondary;
      case 'refleksi': return const Color(0xFF7B1FA2);
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final notifList = provider.notifikasiList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          TextButton(
            onPressed: () => context.read<AppProvider>().tandaiBacaSemua(),
            child: const Text('Tandai Semua Dibaca'),
          ),
        ],
      ),
      body: notifList.isEmpty
          ? const Center(child: Text('Tidak ada notifikasi'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifList.length,
              separatorBuilder: (_, _a) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final n = notifList[i];
                final color = _getColor(n.tipe);
                return GestureDetector(
                  onTap: () => context.read<AppProvider>().tandaiBacaNotifikasi(n.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: n.dibaca ? Colors.white : AppColors.primary.withAlpha(8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: n.dibaca ? AppColors.border : AppColors.primary.withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(14)),
                          child: Icon(_getIcon(n.tipe), color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(n.judul, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary))),
                                  if (!n.dibaca)
                                    Container(
                                      width: 8, height: 8,
                                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(n.isi, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                              const SizedBox(height: 6),
                              Text(_formatWaktu(n.waktu), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
