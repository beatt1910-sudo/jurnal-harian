import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import 'kelola_refleksi_screen.dart';
import '../../models/models.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});
  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  int _selectedIndex = 0;

  void _goToTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      _AdminHomeTab(onNavigateTab: _goToTab),
      const _KelolaJurnalTab(),
      const _KelolaTargetTab(),
      const KelolaRefleksiScreen(),
      const _LaporanTab(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Jurnal'),
          BottomNavigationBarItem(icon: Icon(Icons.flag_rounded), label: 'Target'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_rounded), label: 'Refleksi'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Laporan'),
        ],
      ),
    );
  }
}

// ---- Admin Home ----
class _AdminHomeTab extends StatelessWidget {
  final void Function(int) onNavigateTab;
  const _AdminHomeTab({required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final totalJurnal = provider.mahasiswaList.fold(0, (s, m) => s + m.totalJurnal);
    final totalTarget = provider.mahasiswaList.fold(0, (s, m) => s + m.totalTarget);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_rounded), onPressed: () => Navigator.pushNamed(context, '/admin_pengaturan')),
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: () => _showLogoutDialog(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientCard(
              gradient: AppColors.blueGradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selamat Datang, Admin!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Pantau dan kelola aktivitas belajar mahasiswa', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _adminStat('Total\nMahasiswa', '${provider.mahasiswaList.length}', Icons.people_rounded),
                      const SizedBox(width: 12),
                      _adminStat('Total\nJurnal', '$totalJurnal', Icons.book_rounded),
                      const SizedBox(width: 12),
                      _adminStat('Total\nTarget', '$totalTarget', Icons.flag_rounded),
                      const SizedBox(width: 12),
                      _adminStat('Refleksi', '${provider.refleksiList.length}', Icons.psychology_rounded),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Menu Admin'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _adminMenuCard(context, 'Kelola Mahasiswa', Icons.people_rounded, AppColors.primary, () => Navigator.pushNamed(context, '/admin_mahasiswa')),
                _adminMenuCard(context, 'Kelola Jurnal', Icons.book_rounded, AppColors.success, () => onNavigateTab(1)),
                _adminMenuCard(context, 'Kelola Target', Icons.flag_rounded, AppColors.secondary, () => onNavigateTab(2)),
                _adminMenuCard(context, 'Kelola Refleksi', Icons.psychology_rounded, const Color(0xFF7B1FA2), () => onNavigateTab(3)),
                _adminMenuCard(context, 'Laporan & Statistik', Icons.bar_chart_rounded, AppColors.accent, () => onNavigateTab(4)),
                _adminMenuCard(context, 'Pengaturan', Icons.settings_rounded, AppColors.error, () => Navigator.pushNamed(context, '/admin_pengaturan')),
              ],
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Mahasiswa Aktif'),
            const SizedBox(height: 12),
            ...provider.mahasiswaList.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Row(
                  children: [
                    _buildAvatar(m),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                          Text(m.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${m.totalJurnal} jurnal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        Text('${m.totalTarget} target', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _adminStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _adminMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary))),
            const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(MahasiswaAdmin m, {double radius = 22, double fontSize = 15}) {
    if (m.foto.isNotEmpty) {
      ImageProvider img;
      if (kIsWeb || m.foto.startsWith('http') || m.foto.startsWith('blob:') || m.foto.startsWith('data:')) {
        img = NetworkImage(m.foto);
      } else {
        img = FileImage(File(m.foto));
      }
      return CircleAvatar(
        radius: radius,
        backgroundImage: img,
        backgroundColor: AppColors.primary.withAlpha(20),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withAlpha(20),
      child: Text(
        m.nama.isNotEmpty ? m.nama[0].toUpperCase() : 'M',
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: fontSize),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout Admin', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Apakah kamu yakin ingin logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<AppProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
            child: const Text('Ya, Logout'),
          ),
        ],
      ),
    );
  }
}

// ---- Kelola Jurnal ----
class _KelolaJurnalTab extends StatelessWidget {
  const _KelolaJurnalTab();
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final allCatatan = provider.catatanList;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Kelola Jurnal')),
      body: allCatatan.isEmpty
          ? const EmptyState(icon: Icons.book_outlined, title: 'Tidak ada jurnal', subtitle: 'Belum ada mahasiswa yang menambahkan jurnal.')
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: allCatatan.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = allCatatan[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(c.judul, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary))),
                          StatusBadge(status: c.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(c.mataPelajaran, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Oleh: ${c.mahasiswaNama} (${c.mahasiswaEmail})',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(c.isi, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${c.durasi} menit', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          const Spacer(),
                          TextButton(onPressed: () => _showDetailJurnal(context, c), child: const Text('Detail', style: TextStyle(fontSize: 12))),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            onPressed: () => _showHapusJurnalDialog(context, c, provider),
                            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
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

  void _showDetailJurnal(BuildContext context, dynamic c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(c.judul, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('Durasi Belajar: ${c.durasi} menit', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              if (c.fotoPenugasan != null) ...[
                const Text('Foto Penugasan:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb || c.fotoPenugasan.startsWith('http') || c.fotoPenugasan.startsWith('blob:')
                      ? Image.network(c.fotoPenugasan, fit: BoxFit.cover)
                      : Image.file(File(c.fotoPenugasan), fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
              ],
              const Text('Catatan:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Text(c.isi),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
      ),
    );
  }

  void _showHapusJurnalDialog(BuildContext context, dynamic c, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Jurnal?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Hapus jurnal "${c.judul}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () { provider.hapusCatatan(c.id); Navigator.pop(ctx); },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// ---- Kelola Target ----
class _KelolaTargetTab extends StatelessWidget {
  const _KelolaTargetTab();
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final targets = provider.targetList;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Kelola Target')),
      body: targets.isEmpty
          ? const EmptyState(icon: Icons.flag_outlined, title: 'Tidak ada target', subtitle: 'Belum ada data target.')
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: targets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final t = targets[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                  child: Row(
                    children: [
                      Icon(t.selesai ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: t.selesai ? AppColors.success : AppColors.textSecondary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(t.judul, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
                                 color: t.selesai ? AppColors.textSecondary : AppColors.textPrimary,
                                 decoration: t.selesai ? TextDecoration.lineThrough : null)),
                             const SizedBox(height: 4),
                             Row(
                               children: [
                                 const Icon(Icons.person_rounded, size: 11, color: AppColors.textSecondary),
                                 const SizedBox(width: 4),
                                 Expanded(
                                   child: Text(
                                     'Oleh: ${t.mahasiswaNama} (${t.mahasiswaEmail})',
                                     overflow: TextOverflow.ellipsis,
                                     maxLines: 1,
                                     style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                   ),
                                 ),
                               ],
                             ),
                             if (t.deskripsi.isNotEmpty) ...[
                               const SizedBox(height: 4),
                               Text(t.deskripsi, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                             ],
                          ],
                        ),
                      ),
                      PrioritasBadge(prioritas: t.prioritas),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        onPressed: () => _showHapusTargetDialog(context, t, provider),
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showHapusTargetDialog(BuildContext context, dynamic t, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Target?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Hapus target "${t.judul}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () { provider.hapusTarget(t.id); Navigator.pop(ctx); },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// ---- Laporan & Statistik ----
class _LaporanTab extends StatelessWidget {
  const _LaporanTab();
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final mahasiswaList = provider.mahasiswaList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Laporan & Statistik')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _laporanCard('Total Jurnal', '${mahasiswaList.fold(0, (s, m) => s + m.totalJurnal)}', Icons.book_rounded, AppColors.blueGradient)),
                const SizedBox(width: 12),
                Expanded(child: _laporanCard('Total Target', '${mahasiswaList.fold(0, (s, m) => s + m.totalTarget)}', Icons.flag_rounded, AppColors.greenGradient)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _laporanCard('Refleksi', '${provider.refleksiList.length}', Icons.psychology_rounded, AppColors.purpleGradient)),
                const SizedBox(width: 12),
                Expanded(child: _laporanCard('Mahasiswa', '${mahasiswaList.length}', Icons.people_rounded, AppColors.orangeGradient)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Top Mahasiswa Aktif', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...mahasiswaList.asMap().entries.map((e) {
              final idx = e.key + 1;
              final m = e.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Row(
                  children: [
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        gradient: idx <= 3 ? AppColors.blueGradient : const LinearGradient(colors: [AppColors.border, AppColors.border]),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text('$idx', style: TextStyle(color: idx <= 3 ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                          Text(m.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${m.totalJurnal} jurnal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        Text('${m.totalTarget} target', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _laporanCard(String title, String value, IconData icon, LinearGradient gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
