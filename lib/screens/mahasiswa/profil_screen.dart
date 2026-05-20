import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.userProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.blueGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _showAvatarPickerSheet(context, provider),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 12)],
                                image: user.foto.isNotEmpty
                                    ? DecorationImage(
                                        image: (kIsWeb || user.foto.startsWith('http') || user.foto.startsWith('blob:') || user.foto.startsWith('data:'))
                                            ? NetworkImage(user.foto) as ImageProvider
                                            : FileImage(File(user.foto)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: user.foto.isEmpty
                                  ? const Icon(Icons.person_rounded, size: 44, color: AppColors.primary)
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(user.nama, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(user.email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('Profil', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                onPressed: () => _showEditProfilSheet(context, provider),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats
                  Row(
                    children: [
                      Expanded(child: StatChip(label: 'Streak', value: '${user.streakHari}H 🔥', color: AppColors.secondary)),
                      const SizedBox(width: 10),
                      Expanded(child: StatChip(
                        label: 'Belajar', 
                        value: (user.totalBelajar ~/ 60 > 0 && user.totalBelajar % 60 > 0) 
                            ? '${user.totalBelajar ~/ 60}J ${user.totalBelajar % 60}M' 
                            : (user.totalBelajar ~/ 60 > 0 ? '${user.totalBelajar ~/ 60}J' : (user.totalBelajar % 60 > 0 ? '${user.totalBelajar % 60}M' : '0J')),
                        color: AppColors.primary
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: StatChip(label: 'Target', value: '${user.targetSelesai}', color: AppColors.success)),
                      const SizedBox(width: 10),
                      Expanded(child: StatChip(label: 'Refleksi', value: '${user.totalRefleksi}', color: const Color(0xFF7B1FA2))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Menu profil
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: Column(
                      children: [
                        _menuItem(context, 'Edit Profil', Icons.person_outline_rounded, AppColors.primary, () => _showEditProfilSheet(context, provider)),
                        _divider(),
                        _menuItem(context, 'Ganti Password', Icons.lock_outline_rounded, AppColors.warning, () => _showGantiPasswordSheet(context, provider)),
                        _divider(),
                        _menuItem(context, 'Notifikasi', Icons.notifications_outlined, AppColors.secondary, () => Navigator.pushNamed(context, '/notifikasi')),
                        _divider(),
                        _menuItem(context, 'Tentang Aplikasi', Icons.info_outline_rounded, AppColors.accent, () => Navigator.pushNamed(context, '/tentang')),
                        _divider(),
                        _menuItem(context, 'Bantuan', Icons.help_outline_rounded, AppColors.success, () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: _menuItem(
                      context, 'Logout', Icons.logout_rounded, AppColors.error,
                      () => _showLogoutDialog(context),
                      textColor: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, {Color? textColor}) {
    return ListTile(
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: textColor ?? AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 64, endIndent: 16);

  void _showEditProfilSheet(BuildContext context, AppProvider provider) {
    final namaCtrl = TextEditingController(text: provider.userProfile.nama);
    final emailCtrl = TextEditingController(text: provider.userProfile.email);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Edit Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    provider.updateProfile(nama: namaCtrl.text, email: emailCtrl.text);
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
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

  void _showGantiPasswordSheet(BuildContext context, AppProvider provider) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureOld = true, obscureNew = true, obscureConfirm = true;

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
                const Text('Ganti Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                 TextField(
                  controller: oldCtrl,
                  obscureText: obscureOld,
                  keyboardType: TextInputType.visiblePassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Password Lama',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(icon: Icon(obscureOld ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setS(() => obscureOld = !obscureOld)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newCtrl,
                  obscureText: obscureNew,
                  keyboardType: TextInputType.visiblePassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(icon: Icon(obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setS(() => obscureNew = !obscureNew)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscureConfirm,
                  keyboardType: TextInputType.visiblePassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password Baru',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(icon: Icon(obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setS(() => obscureConfirm = !obscureConfirm)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (oldCtrl.text != provider.userProfile.password) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password lama salah!'), backgroundColor: AppColors.error));
                        return;
                      }
                      if (newCtrl.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password baru minimal 6 karakter!'), backgroundColor: AppColors.error));
                        return;
                      }
                      if (newCtrl.text != confirmCtrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfirmasi password tidak sama!'), backgroundColor: AppColors.error));
                        return;
                      }
                      provider.updateProfile(password: newCtrl.text);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah!'), backgroundColor: AppColors.success));
                    },
                    child: const Text('Simpan Password'),
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

  void _showAvatarPickerSheet(BuildContext context, AppProvider provider) {
    final List<String> avatars = [
      'https://i.pravatar.cc/150?img=11',
      'https://i.pravatar.cc/150?img=12',
      'https://i.pravatar.cc/150?img=20',
      'https://i.pravatar.cc/150?img=33',
      'https://i.pravatar.cc/150?img=47',
      'https://i.pravatar.cc/150?img=60',
      'https://i.pravatar.cc/150?img=68',
      'https://i.pravatar.cc/150?img=53',
    ];

    String selectedUrl = provider.userProfile.foto.isNotEmpty ? provider.userProfile.foto : '';
    File? selectedFile;
    final customUrlCtrl = TextEditingController(
      text: avatars.contains(provider.userProfile.foto) ? '' : provider.userProfile.foto,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setS) {
          // True jika ada file dipilih dari perangkat (mobile) atau blob URL dari web
          final bool hasPickedImage = selectedFile != null ||
              (kIsWeb &&
                  selectedUrl.isNotEmpty &&
                  (selectedUrl.startsWith('blob:') || selectedUrl.startsWith('data:')));

          Future<void> pickFromGallery() async {
            try {
              final picker = ImagePicker();
              final picked = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );
              if (picked != null) {
                setS(() {
                  // Di web, picked.path adalah blob URL; di mobile adalah path file lokal
                  selectedUrl = picked.path;
                  selectedFile = kIsWeb ? null : File(picked.path);
                  customUrlCtrl.clear();
                });
              }
            } catch (e) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Gagal memilih foto: $e'), backgroundColor: AppColors.error),
                );
              }
            }
          }

          Future<void> pickFromCamera() async {
            try {
              final picker = ImagePicker();
              final picked = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 80,
              );
              if (picked != null) {
                setS(() {
                  selectedUrl = picked.path;
                  selectedFile = kIsWeb ? null : File(picked.path);
                  customUrlCtrl.clear();
                });
              }
            } catch (e) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Kamera tidak tersedia di browser.'), backgroundColor: AppColors.warning),
                );
              }
            }
          }

          ImageProvider? getPickedImageProvider() {
            if (kIsWeb ||
                selectedUrl.startsWith('blob:') ||
                selectedUrl.startsWith('data:') ||
                selectedUrl.startsWith('http')) {
              return NetworkImage(selectedUrl);
            }
            if (selectedFile != null) return FileImage(selectedFile!);
            return null;
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Pilih Foto Profil',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Ambil dari galeri, kamera, atau pilih avatar',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 16),

                    // Tombol Galeri & Kamera
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Galeri'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.primary),
                              foregroundColor: AppColors.primary,
                            ),
                            onPressed: pickFromGallery,
                          ),
                        ),
                        if (!kIsWeb) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('Kamera'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: AppColors.primary),
                                foregroundColor: AppColors.primary,
                              ),
                              onPressed: pickFromCamera,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Preview foto yang dipilih dari perangkat
                    if (hasPickedImage) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Builder(builder: (_) {
                          final img = getPickedImageProvider();
                          if (img == null) return const SizedBox.shrink();
                          return Container(
                            width: 90, height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 3),
                              image: DecorationImage(image: img, fit: BoxFit.cover),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      const Center(
                        child: Text('Foto berhasil dipilih ✓',
                            style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                      ),
                    ],

                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 12),
                    const Text('Atau Pilih Avatar',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),

                    // Grid Avatars
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1,
                      ),
                      itemCount: avatars.length,
                      itemBuilder: (ctx, idx) {
                        final url = avatars[idx];
                        final isSelected = selectedUrl == url && selectedFile == null;
                        return GestureDetector(
                          onTap: () => setS(() {
                            selectedUrl = url;
                            selectedFile = null;
                            customUrlCtrl.clear();
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: isSelected ? 3 : 1),
                              image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                            ),
                            child: isSelected
                                ? Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                      child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 12),
                    const Text('Atau Gunakan URL Gambar Kustom',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.background, shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                            image: !avatars.contains(selectedUrl) &&
                                    selectedUrl.startsWith('http') &&
                                    selectedFile == null
                                ? DecorationImage(image: NetworkImage(selectedUrl), fit: BoxFit.cover)
                                : null,
                          ),
                          child: avatars.contains(selectedUrl) ||
                                  !selectedUrl.startsWith('http') ||
                                  selectedFile != null
                              ? const Icon(Icons.link_rounded, color: AppColors.textSecondary)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: customUrlCtrl,
                            decoration: const InputDecoration(
                              hintText: 'https://example.com/foto.png',
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            onChanged: (val) => setS(() {
                              selectedUrl = val.trim();
                              selectedFile = null;
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Simpan foto: prioritas selectedFile (mobile) lalu selectedUrl
                              String fotoToSave = '';
                              if (selectedFile != null) {
                                fotoToSave = selectedFile!.path;
                              } else if (selectedUrl.isNotEmpty) {
                                fotoToSave = selectedUrl;
                              }
                              if (fotoToSave.isNotEmpty) {
                                provider.updateProfile(foto: fotoToSave);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Foto profil berhasil diperbarui!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                              Navigator.pop(ctx);
                            },
                            child: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
