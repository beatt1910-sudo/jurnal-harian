import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'andi@email.com');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscurePassword = true;
  bool _isAdmin = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  // Akun demo yang valid
  final _akunDemo = {
    'andi@email.com': '123456',
    'mahasiswa@email.com': 'mahasiswa123',
  };
  final String _adminEmail = 'admin@email.com';
  final String _adminPassword = 'admin123';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text; // Jangan di-trim agar sama dengan saat register

    if (_isAdmin) {
      if (email == _adminEmail && password == _adminPassword) {
        context.read<AppProvider>().login(admin: true);
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Email atau password admin salah!\nGunakan: admin@email.com / admin123';
        });
      }
    } else {
      final provider = context.read<AppProvider>();
      if ((_akunDemo.containsKey(email) && _akunDemo[email] == password) || provider.isRegistered(email, password)) {
        provider.login(admin: false, email: email);
        Navigator.pushReplacementNamed(context, '/mahasiswa_dashboard');
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Email atau password salah!\nCoba periksa kembali data login Anda.';
        });
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() { _isGoogleLoading = true; _errorMessage = null; });

    // Simulasi Google Sign-In (tanpa Firebase SDK)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // Tampilkan dialog pilih akun Google
    _showGoogleAccountPicker();
  }

  void _showGoogleAccountPicker() {
    setState(() => _isGoogleLoading = false);

    // Ambil daftar akun secara dinamis dari provider
    final provider = context.read<AppProvider>();
    final mahasiswaList = provider.mahasiswaList;

    // Gabungkan akun bawaan + semua mahasiswa yang terdaftar
    final Set<String> addedEmails = {};
    final List<Map<String, String>> googleAccounts = [];

    for (final m in mahasiswaList) {
      final emailKey = m.email.toLowerCase();
      if (!addedEmails.contains(emailKey)) {
        addedEmails.add(emailKey);
        googleAccounts.add({'nama': m.nama, 'email': m.email});
      }
    }

    // Pastikan minimal ada akun demo jika list kosong
    if (googleAccounts.isEmpty) {
      googleAccounts.addAll([
        {'nama': 'Andi Setiawan', 'email': 'andi.setiawan@gmail.com'},
        {'nama': 'Budi Santoso', 'email': 'budi.santoso@gmail.com'},
        {'nama': 'Demo User', 'email': 'demo.user@gmail.com'},
      ]);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Icon(Icons.g_mobiledata_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              const Text('Masuk dengan Google', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 4),
              const Text('Pilih akun Google Anda', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: googleAccounts.map((acc) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withAlpha(20),
                      child: Text(
                        (acc['nama']?.isNotEmpty == true) ? acc['nama']![0].toUpperCase() : 'U', 
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)
                      ),
                    ),
                    title: Text(acc['nama'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: Text(acc['email'] ?? '', style: const TextStyle(fontSize: 13)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _processGoogleLogin(acc['nama'] ?? 'User', acc['email'] ?? '');
                    },
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processGoogleLogin(String nama, String email) async {
    setState(() => _isGoogleLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    context.read<AppProvider>().loginWithGoogle(nama: nama, email: email);
    Navigator.pushReplacementNamed(context, '/mahasiswa_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(gradient: AppColors.blueGradient, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 28),
                const Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                const Text('Selamat datang kembali!', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                const SizedBox(height: 36),

                // Error message
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withAlpha(80)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                      ],
                    ),
                  ),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() => _errorMessage = null),
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined), hintText: 'email@email.com'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  onChanged: (_) => setState(() => _errorMessage = null),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    hintText: '••••••••',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() { _isAdmin = !_isAdmin; _errorMessage = null; }),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24, height: 24,
                            child: Checkbox(
                              value: _isAdmin,
                              onChanged: (v) => setState(() { _isAdmin = v ?? false; _errorMessage = null; }),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Login sebagai Admin', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    TextButton(onPressed: () => _showLupaPassword(context), child: const Text('Lupa Password?', style: TextStyle(fontSize: 13))),
                  ],
                ),

                // Info akun demo
                if (_isAdmin)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.error.withAlpha(10), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Demo Admin: admin@email.com / admin123', style: TextStyle(fontSize: 11, color: AppColors.error)),
                  )
                else
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primary.withAlpha(10), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Demo: andi@email.com / 123456', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                  ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: _isAdmin ? AppColors.error : AppColors.primary,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_isAdmin ? 'Login Admin' : 'Login'),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('atau', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _isGoogleLoading ? null : _loginWithGoogle,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: _isGoogleLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.white,
                              ),
                              child: const Icon(Icons.g_mobiledata_rounded, size: 22, color: Colors.red),
                            ),
                            const SizedBox(width: 10),
                            const Text('Lanjut dengan Google', style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun? ', style: TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Daftar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLupaPassword(BuildContext context) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Lupa Password', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan email Anda untuk reset password.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link reset password telah dikirim ke email Anda.'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }
}
