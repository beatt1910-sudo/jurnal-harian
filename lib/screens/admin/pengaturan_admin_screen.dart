import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';

class PengaturanAdminScreen extends StatelessWidget {
  const PengaturanAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pengaturan Admin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard('Manajemen Akun', [
              _switchTile(
                'Izinkan Pendaftaran Baru',
                Icons.person_add_rounded,
                AppColors.success,
                provider.izinkanDaftar,
                (v) => provider.setIzinkanDaftar(v),
                subtitle: 'Mahasiswa baru bisa mendaftar',
              ),
              _switchTile(
                'Mode Maintenance',
                Icons.build_rounded,
                AppColors.warning,
                provider.modeMaintenance,
                (v) => provider.setModeMaintenance(v),
                subtitle: 'Aplikasi dalam pemeliharaan',
              ),
            ]),
            const SizedBox(height: 16),
            _sectionCard('Notifikasi', [
              _switchTile(
                'Notifikasi Aktif',
                Icons.notifications_rounded,
                AppColors.primary,
                provider.notifAktif,
                (v) => provider.setNotifAktif(v),
                subtitle: 'Kirim notifikasi ke mahasiswa',
              ),
            ]),
            const SizedBox(height: 16),
            _sectionCard('Statistik Sistem', [
              _infoTile('Total Mahasiswa', '${provider.mahasiswaList.length} pengguna', Icons.people_rounded, AppColors.primary),
              _infoTile('Total Jurnal', '${provider.catatanList.length} catatan', Icons.book_rounded, AppColors.success),
              _infoTile('Total Refleksi', '${provider.refleksiList.length} entri', Icons.psychology_rounded, const Color(0xFF7B1FA2)),
              _infoTile('Total Target', '${provider.targetList.length} target', Icons.flag_rounded, AppColors.secondary),
            ]),
            const SizedBox(height: 16),
            _sectionCard('Tentang Sistem', [
              _infoTile('Versi Aplikasi', '1.0.0', Icons.info_outline_rounded, AppColors.accent),
              _infoTile('Platform', 'Flutter', Icons.phone_android_rounded, AppColors.textSecondary),
              _infoTile('Backend', 'Firebase Auth', Icons.cloud_outlined, AppColors.warning),
            ]),
            const SizedBox(height: 16),
            // Reset Data
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.warning.withAlpha(100))),
              child: ListTile(
                leading: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: AppColors.warning.withAlpha(20), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.restart_alt_rounded, color: AppColors.warning, size: 20),
                ),
                title: const Text('Reset Semua Data', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.warning)),
                subtitle: const Text('Hapus semua jurnal, target, dan refleksi', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.warning),
                onTap: () => _showResetDialog(context),
              ),
            ),
            const SizedBox(height: 12),
            // Logout
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: ListTile(
                leading: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: AppColors.error.withAlpha(20), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                ),
                title: const Text('Logout Admin', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
                onTap: () => _showLogoutDialog(context),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _switchTile(String title, IconData icon, Color color, bool value, ValueChanged<bool> onChanged, {String? subtitle}) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)) : null,
      trailing: Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
    );
  }

  Widget _infoTile(String title, String value, IconData icon, Color color) {
    return ListTile(
      leading: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 16),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      trailing: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Semua Data?', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning)),
        content: const Text('Semua jurnal, target, dan refleksi akan dihapus. Akun mahasiswa tetap ada. Tindakan ini tidak dapat dibatalkan!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () {
              context.read<AppProvider>().resetSemuaData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Semua data berhasil direset.'), backgroundColor: AppColors.warning),
              );
            },
            child: const Text('Ya, Reset'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Apakah kamu yakin ingin logout dari akun Admin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<AppProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
