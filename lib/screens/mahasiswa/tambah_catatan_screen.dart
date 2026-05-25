import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
  String? _fotoPath;

  // Stopwatch variables
  Timer? _timer;
  int _seconds = 0;
  bool _isTimerRunning = false;

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
    _durasiCtrl = TextEditingController(text: widget.catatan?.durasi.toString() ?? '0');
    _status = widget.catatan?.status ?? 'berlangsung';
    _fotoPath = widget.catatan?.fotoPenugasan;
    
    // Inisialisasi detik dari durasi menit
    if (widget.catatan != null) {
      _seconds = widget.catatan!.durasi * 60;
    }

    if (widget.catatan != null && _mataPelajaranList.contains(widget.catatan!.mataPelajaran)) {
      _mataPelajaran = widget.catatan!.mataPelajaran;
    } else if (widget.catatan != null) {
      _mataPelajaran = 'Umum';
    }

    // Timer berjalan otomatis tanpa perlu di-klik
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _durasiCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isTimerRunning) return;
    setState(() => _isTimerRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        _durasiCtrl.text = (_seconds ~/ 60).toString(); // Update durasi dalam menit
      });
    });
  }

  void _pauseTimer() {
    if (!_isTimerRunning) return;
    _timer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  String _formatTime(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        setState(() {
          _fotoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil gambar'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
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
    
    // Pause timer saat menyimpan
    _pauseTimer();
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final provider = context.read<AppProvider>();
    
    // Ambil durasi dari stopwatch jika tidak 0, jika tidak gunakan input manual
    int durasiMenit = int.tryParse(_durasiCtrl.text) ?? 0;
    if (durasiMenit == 0 && _seconds > 0) {
      durasiMenit = _seconds ~/ 60;
    }

    if (_isEditMode) {
      provider.editCatatan(widget.catatan!.copyWith(
        judul: _judulCtrl.text.trim(),
        mataPelajaran: _mataPelajaran,
        isi: _isiCtrl.text.trim(),
        status: _status,
        durasi: durasiMenit,
        fotoPenugasan: _fotoPath,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil diperbarui!'), backgroundColor: AppColors.success),
        );
      }
    } else {
      provider.tambahCatatan(CatatanBelajar(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        judul: _judulCtrl.text.trim(),
        mataPelajaran: _mataPelajaran,
        isi: _isiCtrl.text.trim(),
        tanggal: DateTime.now(),
        status: _status,
        durasi: durasiMenit,
        mahasiswaEmail: provider.userProfile.email,
        mahasiswaNama: provider.userProfile.nama,
        fotoPenugasan: _fotoPath,
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
                  const Text('Waktu Belajar (Otomatis)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _formatTime(_seconds),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.primary, fontFeatures: [FontFeature.tabularFigures()]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
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
                      labelText: 'Durasi Manual (opsional jika pakai stopwatch)',
                      hintText: '0',
                      suffixText: 'menit',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 0;
                      if (!_isTimerRunning && parsed > 0) {
                        setState(() => _seconds = parsed * 60);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Foto Penugasan (Opsional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                      if (_fotoPath != null)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                          onPressed: () => setState(() => _fotoPath = null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                      ),
                      child: _fotoPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: kIsWeb || _fotoPath!.startsWith('http') || _fotoPath!.startsWith('blob:')
                                  ? Image.network(_fotoPath!, fit: BoxFit.cover)
                                  : Image.file(File(_fotoPath!), fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.textSecondary.withAlpha(150)),
                                const SizedBox(height: 8),
                                Text('Ketuk untuk menambah foto', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ],
                            ),
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
