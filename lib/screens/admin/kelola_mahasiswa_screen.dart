import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

class KelolaMahasiswaScreen extends StatefulWidget {
  const KelolaMahasiswaScreen({super.key});
  @override
  State<KelolaMahasiswaScreen> createState() => _KelolaMahasiswaScreenState();
}

class _KelolaMahasiswaScreenState extends State<KelolaMahasiswaScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final list = provider.mahasiswaList.where((m) =>
      m.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      m.email.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Mahasiswa'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Cari mahasiswa...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
          ),
        ),
      ),
      body: list.isEmpty
          ? const Center(child: Text('Tidak ada hasil'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final m = list[i];
                final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
                final bergabung = '${m.bergabung.day} ${months[m.bergabung.month-1]} ${m.bergabung.year}';
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                  child: Row(
                    children: [
                      _buildAvatar(m, radius: 24, fontSize: 18),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(m.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _chip('${m.totalJurnal} jurnal', AppColors.primary),
                                const SizedBox(width: 6),
                                _chip('${m.totalTarget} target', AppColors.success),
                                const SizedBox(width: 6),
                                _chip('${m.totalRefleksi} refleksi', const Color(0xFF7B1FA2)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'hapus') { _showHapusDialog(context, m); }
                              else if (v == 'detail') { _showDetailDialog(context, m); }
                              else if (v == 'edit') { _showEditDialog(context, m); }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'detail', child: Row(children: [Icon(Icons.info_outline, size: 16), SizedBox(width: 8), Text('Lihat Detail')])),
                              PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit Data')])),
                              PopupMenuItem(value: 'hapus', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppColors.error), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: AppColors.error))])),
                            ],
                            child: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(bergabung, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTambahDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildAvatar(MahasiswaAdmin m, {double radius = 24, double fontSize = 16}) {
    if (m.foto.isNotEmpty) {
      ImageProvider img;
      if (kIsWeb || m.foto.startsWith('http') || m.foto.startsWith('blob:') || m.foto.startsWith('data:')) {
        img = NetworkImage(m.foto);
      } else {
        img = FileImage(File(m.foto));
      }
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary.withAlpha(20),
        backgroundImage: img,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withAlpha(20),
      child: Text(m.nama.isNotEmpty ? m.nama[0].toUpperCase() : 'M', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: fontSize)),
    );
  }

  void _showTambahDialog(BuildContext context) {
    final namaCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Mahasiswa', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 12),
            TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (namaCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                final provider = context.read<AppProvider>();
                final email = emailCtrl.text.trim();
                final password = passwordCtrl.text.trim();
                provider.tambahMahasiswa(MahasiswaAdmin(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  nama: namaCtrl.text.trim(),
                  email: email,
                  bergabung: DateTime.now(),
                  totalJurnal: 0,
                  totalTarget: 0,
                  totalRefleksi: 0,
                ));
                // Daftarkan ke akun agar mahasiswa bisa login
                if (password.isNotEmpty) {
                  provider.registerUser(
                    nama: namaCtrl.text.trim(),
                    email: email,
                    password: password,
                  );
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mahasiswa berhasil ditambahkan!'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, MahasiswaAdmin m) {
    final namaCtrl = TextEditingController(text: m.nama);
    final emailCtrl = TextEditingController(text: m.email);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Data Mahasiswa', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (namaCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                context.read<AppProvider>().editMahasiswa(m.id, nama: namaCtrl.text.trim(), email: emailCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showHapusDialog(BuildContext context, MahasiswaAdmin m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Mahasiswa', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Apakah Anda yakin ingin menghapus data ${m.nama}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<AppProvider>().hapusMahasiswa(m.id);
              Navigator.pop(ctx);
            },
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, MahasiswaAdmin m) {
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final bergabung = '${m.bergabung.day} ${months[m.bergabung.month-1]} ${m.bergabung.year}';
    final provider = context.read<AppProvider>();
    final catatanMhs = provider.getCatatanForEmail(m.email);
    final refleksiMhs = provider.getRefleksiForEmail(m.email);
    final targetMhs = provider.getTargetForEmail(m.email);
    final targetSelesai = targetMhs.where((t) => t.selesai).length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            _buildAvatar(m, radius: 22, fontSize: 16),
            const SizedBox(width: 10),
            Expanded(child: Text(m.nama, style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(Icons.email_outlined, 'Email', m.email),
              const SizedBox(height: 8),
              _detailRow(Icons.calendar_today_outlined, 'Bergabung', bergabung),
              const Divider(height: 24),
              const Text('Statistik Aktivitas', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              _detailRow(Icons.book_outlined, 'Total Jurnal', '${catatanMhs.length}', color: AppColors.primary),
              const SizedBox(height: 8),
              _detailRow(Icons.flag_outlined, 'Total Target', '${targetMhs.length} (selesai: $targetSelesai)', color: AppColors.success),
              const SizedBox(height: 8),
              _detailRow(Icons.psychology_outlined, 'Total Refleksi', '${refleksiMhs.length}', color: const Color(0xFF7B1FA2)),
              if (catatanMhs.isNotEmpty) ...[
                const Divider(height: 24),
                const Text('Jurnal Terbaru', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                ...catatanMhs.take(2).map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primary.withAlpha(10), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.judul, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(c.mataPelajaran, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )),
              ],
              if (refleksiMhs.isNotEmpty) ...[
                const Divider(height: 24),
                const Text('Refleksi Terbaru', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                ...refleksiMhs.take(2).map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF7B1FA2).withAlpha(10), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.pertanyaan, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(r.jawaban, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary))),
      ],
    );
  }
}
