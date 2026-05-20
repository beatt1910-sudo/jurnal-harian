import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class RefleksiScreen extends StatefulWidget {
  const RefleksiScreen({super.key});

  @override
  State<RefleksiScreen> createState() => _RefleksiScreenState();
}

class _RefleksiScreenState extends State<RefleksiScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final refleksiList = provider.refleksiListForUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Refleksi Diri')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: AppColors.purpleGradient, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(Icons.psychology_rounded, color: Colors.white, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Refleksi Diri', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('${refleksiList.length} catatan refleksi', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showTambahRefleksiSheet(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF7B1FA2)),
                  child: const Text('+ Tambah'),
                ),
              ],
            ),
          ),
          Expanded(
            child: refleksiList.isEmpty
                ? const EmptyState(icon: Icons.psychology_outlined, title: 'Belum ada refleksi', subtitle: 'Mulai refleksi dirimu hari ini!')
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: refleksiList.length,
                    separatorBuilder: (_, _a) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _RefleksiCard(refleksi: refleksiList[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTambahRefleksiSheet(context),
        backgroundColor: const Color(0xFF7B1FA2),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _showTambahRefleksiSheet(BuildContext context) {
    final provider = context.read<AppProvider>();
    final jawabanCtrl = TextEditingController();
    int mood = 3;
    String pertanyaan = 'Apa yang kamu pelajari hari ini?';
    final pertanyaanList = [
      'Apa yang kamu pelajari hari ini?',
      'Apa hambatan belajarmu?',
      'Apa yang ingin kamu tingkatkan?',
      'Hal positif apa yang kamu lakukan hari ini?',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Tambah Refleksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: pertanyaan,
                  decoration: const InputDecoration(labelText: 'Pertanyaan Refleksi'),
                  items: pertanyaanList.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setS(() => pertanyaan = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: jawabanCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Jawabanmu', hintText: 'Tulis refleksimu di sini...'),
                ),
                const SizedBox(height: 16),
                const Text('Mood Hari Ini', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (i) {
                    final m = i + 1;
                    final emojis = ['😞', '😕', '😐', '😊', '😄'];
                    return GestureDetector(
                      onTap: () => setS(() => mood = m),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: mood == m ? AppColors.primary.withAlpha(25) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: mood == m ? AppColors.primary : Colors.transparent),
                        ),
                        child: Text(emojis[i], style: TextStyle(fontSize: mood == m ? 32 : 24)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B1FA2)),
                    onPressed: () {
                      if (jawabanCtrl.text.isNotEmpty) {
                        provider.tambahRefleksi(RefleksiDiri(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          pertanyaan: pertanyaan,
                          jawaban: jawabanCtrl.text,
                          tanggal: DateTime.now(),
                          mood: mood,
                          mahasiswaEmail: provider.userProfile.email,
                          mahasiswaNama: provider.userProfile.nama,
                        ));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Simpan Refleksi'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RefleksiCard extends StatelessWidget {
  final RefleksiDiri refleksi;
  const _RefleksiCard({required this.refleksi});

  String _formatDate(DateTime d) {
    final m = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(refleksi.pertanyaan, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary))),
              MoodWidget(mood: refleksi.mood),
            ],
          ),
          const SizedBox(height: 10),
          Text(refleksi.jawaban, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(_formatDate(refleksi.tanggal), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
