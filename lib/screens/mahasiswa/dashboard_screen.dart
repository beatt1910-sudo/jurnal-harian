import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import 'catatan_screen.dart';
import 'target_screen.dart';
import 'statistik_screen.dart';
import 'profil_screen.dart';

class DashboardMahasiswaScreen extends StatefulWidget {
  const DashboardMahasiswaScreen({super.key});

  @override
  State<DashboardMahasiswaScreen> createState() => _DashboardMahasiswaScreenState();
}

class _DashboardMahasiswaScreenState extends State<DashboardMahasiswaScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
      const CatatanScreen(),
      const TargetScreen(),
      const StatistikScreen(),
      const ProfilScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final now = DateTime.now();
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final dayName = days[now.weekday - 1];
    final dateStr = '$dayName, ${now.day} ${months[now.month - 1]} ${now.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.blueGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Halo, ${provider.userProfile.nama.split(' ')[0]} 👋',
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(dateStr, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
                                  onPressed: () => Navigator.pushNamed(context, '/notifikasi'),
                                ),
                                if (provider.jumlahBelumDibaca > 0)
                                  Positioned(
                                    right: 8, top: 8,
                                    child: Container(
                                      width: 16, height: 16,
                                      decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                                      child: Center(child: Text('${provider.jumlahBelumDibaca}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF6B35), size: 18),
                            const SizedBox(width: 4),
                            Text('${provider.userProfile.streakHari} Hari Streak!',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: const Text('Jurnal Belajar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/notifikasi'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stat cards
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(context, 'Total Belajar', provider.totalBelajarDisplay, Icons.timer_rounded, AppColors.blueGradient)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(context, 'Target Selesai', '${provider.targetSelesaiCount}', Icons.check_circle_rounded, AppColors.greenGradient)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(context, 'Refleksi', '${provider.refleksiListForUser.length}', Icons.psychology_rounded, AppColors.purpleGradient)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Menu Utama
                  const SectionHeader(title: 'Menu Utama'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.95,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildMenuCard(context, 'Catatan\nBelajar', Icons.book_rounded, AppColors.primary, '/catatan'),
                      _buildMenuCard(context, 'Target\nHarian', Icons.flag_rounded, AppColors.success, '/target'),
                      _buildMenuCard(context, 'Refleksi\nDiri', Icons.psychology_rounded, const Color(0xFF7B1FA2), '/refleksi'),
                      _buildMenuCard(context, 'Statistik', Icons.bar_chart_rounded, AppColors.secondary, '/statistik'),
                      _buildMenuCard(context, 'Notifikasi', Icons.notifications_rounded, AppColors.error, '/notifikasi'),
                      _buildMenuCard(context, 'Profil', Icons.person_rounded, AppColors.accent, '/profil'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Catatan terbaru
                  SectionHeader(title: 'Catatan Terbaru', actionLabel: 'Lihat Semua', onAction: () {}),
                  const SizedBox(height: 12),
                  ...provider.catatanListForUser.take(3).map((catatan) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.book_rounded, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(catatan.judul, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                Text(catatan.mataPelajaran, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          StatusBadge(status: catatan.status),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 24),

                  // Target hari ini
                  SectionHeader(title: 'Target Hari Ini', actionLabel: 'Lihat Semua', onAction: () {}),
                  const SizedBox(height: 12),
                  ...provider.targetListForUser.take(3).map((target) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.read<AppProvider>().toggleTarget(target.id),
                            child: Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                color: target.selesai ? AppColors.success : Colors.transparent,
                                border: Border.all(color: target.selesai ? AppColors.success : AppColors.border, width: 2),
                                shape: BoxShape.circle,
                              ),
                              child: target.selesai ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              target.judul,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: target.selesai ? AppColors.textSecondary : AppColors.textPrimary,
                                decoration: target.selesai ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          PrioritasBadge(prioritas: target.prioritas),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/tambah_catatan'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Catatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, LinearGradient gradient) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: gradient.colors.first.withAlpha(50), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3)),
          ],
        ),
      ),
    );
  }
}
