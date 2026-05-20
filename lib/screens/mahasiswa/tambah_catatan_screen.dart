import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

class TambahCatatanScreen extends StatefulWidget {
  final CatatanBelajar? catatan; // Jika tidak null, mode EDIT
  const TambahCatatanScreen({super.key, this.catatan});

  @override
  State<TambahCatatanScreen> createState() => _TambahCatatanScreenState();
}

class _TambahCatatanScreenState extends State<TambahCatatanScreen> {
  late TextEditingController _judulCtrl;
  late TextEditingController _isiCtrl;
  late TextEditingController _durasiCtrl;
  String _status = 'berlangsung';
  String _mataPelajaran = 'Pemrograman Mobile';
  bool _isLoading = false;

  bool get _isEditMode => widget.catatan != null;

  final List<String> _mataPelajaranList = [
    'Pemrograman Mobile',
    'Struktur Data',
    'Kecerdasan Buatan',
    'Basis Data',
    'Jaringan Komputer',
    'Algoritma',
    'Matematika Diskrit',
    'Rekayasa Perangkat Lunak',
    'Sistem Operasi',
    'Umum',
  ];

  @override
  void initState() {
    super.initState();
    _judulCtrl = TextEditingController(text: widget.catatan?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.catatan?.isi ?? '');
    _durasiCtrl = TextEditingController(text: widget.catatan?.durasi.toString() ?? '');
    _status = widget.catatan?.status ?? 'berlangsung';

    // Tentukan mata pelajaran awal
    if (widget.catatan != null && _mataPelajaranList.contains(widget.catatan!.mataPelajaran)) {
      _mataPelajaran = widget.catatan!.mataPelajaran;
    } else if (widget.catatan != null) {
      _mataPelajaran = 'Umum';
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _durasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_judulCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul catatan tidak boleh kosong!'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_isiCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi catatan tidak boleh kosong!'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final provider = context.read<AppProvider>();

    if (_isEditMode) {
      // Update catatan yang sudah ada
      provider.editCatatan(widget.catatan!.copyWith(
        judul: _judulCtrl.text.trim(),
        mataPelajaran: _mataPelajaran,
        isi: _isiCtrl.text.trim(),
        status: _status,
        durasi: int.tryParse(_durasiCtrl.text) ?? 0,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil diperbarui!'), backgroundColor: AppColors.success),
        );
      }
    } else {
      // Tambah catatan baru
      provider.tambahCatatan(CatatanBelajar(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        judul: _judulCtrl.text.trim(),
        mataPelajaran: _mataPelajaran,
        isi: _isiCtrl.text.trim(),
        tanggal: DateTime.now(),
        status: _status,
        durasi: int.tryParse(_durasiCtrl.text) ?? 0,
        mahasiswaEmail: provider.userProfile.email,
        mahasiswaNama: provider.userProfile.nama,
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Catatan' : 'Tambah Catatan'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _simpan,
            child: _isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    _isEditMode ? 'Update' : 'Simpan',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header badge mode
            if (_isEditMode)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    const Text('Mode Edit Catatan', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informasi Catatan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _judulCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Judul Catatan *',
                      hintText: 'Contoh: Belajar Flutter...',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _mataPelajaran,
                    decoration: const InputDecoration(
                      labelText: 'Mata Pelajaran',
                      prefixIcon: Icon(Icons.school_rounded),
                    ),
                    items: _mataPelajaranList.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) => setState(() => _mataPelajaran = v ?? _mataPelajaran),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _durasiCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Durasi Belajar',
                      hintText: '90',
                      suffixText: 'menit',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status Belajar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Row(
                    children: ['berlangsung', 'selesai', 'tertunda'].map((s) {
                      final isSelected = _status == s;
                      final colors = {
                        'selesai': AppColors.success,
                        'berlangsung': AppColors.primary,
                        'tertunda': AppColors.warning,
                      };
                      final c = colors[s]!;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _status = s),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? c : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSelected ? c : AppColors.border),
                              ),
                              child: Text(
                                s[0].toUpperCase() + s.substring(1),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Catatan / Materi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _isiCtrl,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: 'Tulis catatan belajarmu di sini...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _simpan,
                icon: Icon(_isEditMode ? Icons.update_rounded : Icons.save_rounded),
                label: Text(_isEditMode ? 'Update Catatan' : 'Simpan Catatan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isEditMode ? AppColors.warning : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
