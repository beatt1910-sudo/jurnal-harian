import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class TargetScreen extends StatefulWidget {
  const TargetScreen({super.key});

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final targets = provider.targetListForUser;
    final selesai = targets.where((t) => t.selesai).length;
    final total = targets.length;
    final persen = total > 0 ? selesai / total : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Target Harian')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.greenGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.success.withAlpha(77), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Progress Hari Ini', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('$selesai dari $total target',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    SizedBox(
                      width: 60, height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(value: persen, backgroundColor: Colors.white24, color: Colors.white, strokeWidth: 6),
                          Text('${(persen * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: persen, backgroundColor: Colors.white24, color: Colors.white, minHeight: 8),
                ),
              ],
            ),
          ),
          Expanded(
            child: targets.isEmpty
                ? const EmptyState(icon: Icons.flag_outlined, title: 'Belum ada target', subtitle: 'Buat target harianmu sekarang!')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: targets.length,
                    separatorBuilder: (_, _a) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _TargetCard(target: targets[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTambahTargetSheet(context),
        backgroundColor: AppColors.success,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Target', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showTambahTargetSheet(BuildContext context) {
    final provider = context.read<AppProvider>();
    final judulCtrl = TextEditingController();
    final deskCtrl = TextEditingController();
    String prioritas = 'sedang';
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
                const Text('Tambah Target', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(controller: judulCtrl, decoration: const InputDecoration(labelText: 'Judul Target')),
                const SizedBox(height: 12),
                TextField(controller: deskCtrl, decoration: const InputDecoration(labelText: 'Deskripsi')),
                const SizedBox(height: 12),
                const Text('Prioritas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: ['tinggi', 'sedang', 'rendah'].map((p) {
                    final colors = {'tinggi': AppColors.error, 'sedang': AppColors.warning, 'rendah': AppColors.success};
                    final c = colors[p]!;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(p[0].toUpperCase() + p.substring(1)),
                        selected: prioritas == p,
                        selectedColor: c.withAlpha(40),
                        onSelected: (_) => setS(() => prioritas = p),
                        labelStyle: TextStyle(color: prioritas == p ? c : AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (judulCtrl.text.isNotEmpty) {
                        provider.tambahTarget(TargetHarian(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          judul: judulCtrl.text,
                          deskripsi: deskCtrl.text,
                          tanggal: DateTime.now(),
                          selesai: false,
                          prioritas: prioritas,
                          mahasiswaEmail: provider.userProfile.email,
                          mahasiswaNama: provider.userProfile.nama,
                        ));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Simpan Target'),
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

class _TargetCard extends StatelessWidget {
  final TargetHarian target;
  const _TargetCard({required this.target});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(target.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => context.read<AppProvider>().hapusTarget(target.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: target.selesai ? AppColors.success.withAlpha(100) : AppColors.border),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.read<AppProvider>().toggleTarget(target.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: target.selesai ? AppColors.success : Colors.transparent,
                  border: Border.all(color: target.selesai ? AppColors.success : AppColors.border, width: 2),
                  shape: BoxShape.circle,
                ),
                child: target.selesai ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(target.judul, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
                    color: target.selesai ? AppColors.textSecondary : AppColors.textPrimary,
                    decoration: target.selesai ? TextDecoration.lineThrough : null)),
                  if (target.deskripsi.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(target.deskripsi, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            PrioritasBadge(prioritas: target.prioritas),
          ],
        ),
      ),
    );
  }
}
