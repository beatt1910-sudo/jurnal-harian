import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';

// Auth screens
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

// Mahasiswa screens
import 'screens/mahasiswa/dashboard_screen.dart';
import 'screens/mahasiswa/catatan_screen.dart';
import 'screens/mahasiswa/tambah_catatan_screen.dart';
import 'screens/mahasiswa/detail_catatan_screen.dart';
import 'screens/mahasiswa/target_screen.dart';
import 'screens/mahasiswa/refleksi_screen.dart';
import 'screens/mahasiswa/statistik_screen.dart';
import 'screens/mahasiswa/notifikasi_screen.dart';
import 'screens/mahasiswa/profil_screen.dart';
import 'screens/mahasiswa/tentang_screen.dart';

// Admin screens
import 'screens/admin/dashboard_admin_screen.dart';
import 'screens/admin/kelola_mahasiswa_screen.dart';
import 'screens/admin/pengaturan_admin_screen.dart';
import 'screens/admin/kelola_refleksi_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const JurnalBelajarApp(),
    ),
  );
}

class JurnalBelajarApp extends StatelessWidget {
  const JurnalBelajarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jurnal Belajar Harian',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return _fade(const SplashScreen());
          case '/onboarding':
            return _fade(const OnboardingScreen());
          case '/login':
            return _slide(const LoginScreen());
          case '/register':
            return _slide(const RegisterScreen());
          case '/mahasiswa_dashboard':
            return _fade(const DashboardMahasiswaScreen());
          case '/catatan':
            return _slide(const CatatanScreen());
          case '/tambah_catatan':
            return _slideUp(const TambahCatatanScreen());
          case '/detail_catatan':
            return _slide(DetailCatatanScreen(), arguments: settings.arguments);
          case '/target':
            return _slide(const TargetScreen());
          case '/refleksi':
            return _slide(const RefleksiScreen());
          case '/statistik':
            return _slide(const StatistikScreen());
          case '/notifikasi':
            return _slide(const NotifikasiScreen());
          case '/profil':
            return _slide(const ProfilScreen());
          case '/tentang':
            return _slide(const TentangScreen());
          case '/admin_dashboard':
            return _fade(const DashboardAdminScreen());
          case '/admin_mahasiswa':
            return _slide(const KelolaMahasiswaScreen());
          case '/admin_pengaturan':
            return _slide(const PengaturanAdminScreen());
          case '/admin_refleksi':
            return _slide(const KelolaRefleksiScreen());
          default:
            return _fade(const SplashScreen());
        }
      },
      builder: (context, child) {
        return Container(
          color: Colors.grey[100],
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        );
      },
    );
  }

  PageRoute _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, _a, _b) => page,
        transitionsBuilder: (_, anim, _a, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );

  PageRoute _slide(Widget page, {Object? arguments}) => PageRouteBuilder(
        settings: RouteSettings(arguments: arguments),
        pageBuilder: (_, _a, _b) => page,
        transitionsBuilder: (_, anim, _a, child) => SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      );

  PageRoute _slideUp(Widget page) => PageRouteBuilder(
        pageBuilder: (_, _a, _b) => page,
        transitionsBuilder: (_, anim, _a, child) => SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      );
}
