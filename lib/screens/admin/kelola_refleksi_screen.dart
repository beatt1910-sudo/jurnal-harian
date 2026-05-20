import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';

class KelolaRefleksiScreen extends StatelessWidget {
  const KelolaRefleksiScreen({super.key});

  String _formatDate(DateTime d) {
    final m = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final list = provider.refleksiList;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Refleksi'),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7B1FA2).withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${list.length} data', style: const TextStyle(color: Color(0xFF7B1FA2), fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: list.isEmpty
          ? const EmptyState(icon: Icons.psychology_outlined, title: 'Belum ada refleksi', subtitle: 'Belum ada mahasiswa yang menambahkan refleksi.')
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final r = list[i];
                final emojis = ['😞','😕','😐','😊','😄'];
                final emoji = r.mood >= 1 && r.mood <= 5 ? emojis[r.mood - 1] : '😐';
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(r.pertanyaan, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                          ),
                          Text(emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _showHapusDialog(context, r.id, r.pertanyaan),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(r.jawaban, maxLines: 3, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 12, color: Color(0xFF7B1FA2)),
                          const SizedBox(width: 4),
                          Text(
                            'Oleh: ${r.mahasiswaNama} (${r.mahasiswaEmail})',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(_formatDate(r.tanggal), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _showDetailDialog(context, r.pertanyaan, r.jawaban, r.mood, _formatDate(r.tanggal), r.mahasiswaNama, r.mahasiswaEmail),
                            child: const Text('Lihat Detail', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showHapusDialog(BuildContext context, String id, String pertanyaan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Refleksi?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Hapus refleksi "$pertanyaan"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<AppProvider>().hapusRefleksi(id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, String pertanyaan, String jawaban, int mood, String tanggal, String nama, String email) {
    final emojis = ['😞','😕','😐','😊','😄'];
    final emoji = mood >= 1 && mood <= 5 ? emojis[mood - 1] : '😐';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Expanded(child: Text(pertanyaan, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
            Text(emoji, style: const TextStyle(fontSize: 28)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(jawaban, style: const TextStyle(fontSize: 14, height: 1.6)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_rounded, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Oleh: $nama ($email)',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Tanggal: $tanggal', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
      ),
    );
  }
}
