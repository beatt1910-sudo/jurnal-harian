import 'package:flutter/material.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  // ---- User State ----
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  bool _isGoogleLogin = false;
  UserProfile _userProfile = UserProfile(
    nama: 'Andi Setiawan',
    email: 'andi@email.com',
    foto: '',
    streakHari: 6,
    totalBelajar: 90,
    targetSelesai: 2,
    totalRefleksi: 1,
    password: '123456',
  );

  // Menyimpan akun yang didaftarkan (untuk demo)
  final Map<String, String> _registeredAccounts = {
    'andi@email.com': '123456',
    'mahasiswa@email.com': 'mahasiswa123',
    'budi@email.com': 'budi123',
    'citra@email.com': 'citra123',
  };

  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  bool get isGoogleLogin => _isGoogleLogin;
  UserProfile get userProfile => _userProfile;

  void login({bool admin = false, String? email}) {
    _isLoggedIn = true;
    _isAdmin = admin;
    _isGoogleLogin = false;
    
    if (!admin && email != null) {
      final idx = _mahasiswaList.indexWhere((m) => m.email.toLowerCase() == email.toLowerCase());
      final name = idx != -1 ? _mahasiswaList[idx].nama : 'Mahasiswa';
      
      final userJurnalsCount = _catatanList.where((c) => c.mahasiswaEmail.toLowerCase() == email.toLowerCase()).length;
      final userTargetsCount = _targetList.where((t) => t.mahasiswaEmail.toLowerCase() == email.toLowerCase()).length;
      final userRefleksiCount = _refleksiList.where((r) => r.mahasiswaEmail.toLowerCase() == email.toLowerCase()).length;
      final userTotalBelajar = _catatanList.where((c) => c.mahasiswaEmail.toLowerCase() == email.toLowerCase()).fold(0, (s, c) => s + c.durasi);
      final userStreak = email.toLowerCase() == 'andi@email.com' ? 6 : (userJurnalsCount > 0 ? 3 : 0);

      _userProfile = UserProfile(
        nama: name,
        email: email,
        foto: _userProfile.email.toLowerCase() == email.toLowerCase() ? _userProfile.foto : '',
        streakHari: userStreak,
        totalBelajar: userTotalBelajar,
        targetSelesai: _targetList.where((t) => t.mahasiswaEmail.toLowerCase() == email.toLowerCase() && t.selesai).length,
        totalRefleksi: userRefleksiCount,
        password: _registeredAccounts[email] ?? '',
      );
    }
    notifyListeners();
  }

  void loginWithGoogle({required String nama, required String email}) {
    _isLoggedIn = true;
    _isAdmin = false;
    _isGoogleLogin = true;
    
    final existingStudentIndex = _mahasiswaList.indexWhere((m) => m.email.toLowerCase() == email.toLowerCase());
    
    if (existingStudentIndex != -1) {
      final existingM = _mahasiswaList[existingStudentIndex];
      final userJurnalsCount = _catatanList.where((c) => c.mahasiswaEmail.toLowerCase() == email.toLowerCase()).length;
      final userRefleksiCount = _refleksiList.where((r) => r.mahasiswaEmail.toLowerCase() == email.toLowerCase()).length;
      final userTotalBelajar = _catatanList.where((c) => c.mahasiswaEmail.toLowerCase() == email.toLowerCase()).fold(0, (s, c) => s + c.durasi);
      final userStreak = userJurnalsCount > 0 ? 6 : 0;

      _userProfile = UserProfile(
        nama: existingM.nama,
        email: existingM.email,
        foto: _userProfile.email.toLowerCase() == email.toLowerCase() ? _userProfile.foto : '',
        streakHari: userStreak,
        totalBelajar: userTotalBelajar,
        targetSelesai: _targetList.where((t) => t.mahasiswaEmail.toLowerCase() == email.toLowerCase() && t.selesai).length,
        totalRefleksi: userRefleksiCount,
        password: '',
      );
      // Pastikan ada di _registeredAccounts agar bisa login ulang
      if (!_registeredAccounts.containsKey(email.toLowerCase())) {
        _registeredAccounts[email.toLowerCase()] = '__google__';
      }
    } else {
      // Mahasiswa baru via Google — daftarkan ke semua daftar
      _userProfile = UserProfile(
        nama: nama,
        email: email,
        foto: '',
        streakHari: 0,
        totalBelajar: 0,
        targetSelesai: 0,
        totalRefleksi: 0,
        password: '',
      );

      _mahasiswaList.add(MahasiswaAdmin(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        email: email,
        bergabung: DateTime.now(),
        totalJurnal: 0,
        totalTarget: 0,
        totalRefleksi: 0,
      ));
      // Daftarkan ke _registeredAccounts agar terdeteksi sebagai akun valid
      _registeredAccounts[email.toLowerCase()] = '__google__';
    }
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _isAdmin = false;
    _isGoogleLogin = false;
    notifyListeners();
  }

  void registerUser({required String nama, required String email, required String password}) {
    // Normalisasi email ke lowercase agar login selalu cocok
    final normalizedEmail = email.toLowerCase().trim();
    _registeredAccounts[normalizedEmail] = password;
    _userProfile = UserProfile(
      nama: nama,
      email: normalizedEmail,
      foto: '',
      streakHari: 0,
      totalBelajar: 0,
      targetSelesai: 0,
      totalRefleksi: 0,
      password: password,
    );

    final exists = _mahasiswaList.any((m) => m.email.toLowerCase() == normalizedEmail);
    if (!exists) {
      _mahasiswaList.add(MahasiswaAdmin(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        email: normalizedEmail,
        bergabung: DateTime.now(),
        totalJurnal: 0,
        totalTarget: 0,
        totalRefleksi: 0,
      ));
    }
    notifyListeners();
  }

  bool isRegistered(String email, String password) {
    // Normalisasi email agar pengecekan tidak sensitif huruf besar/kecil
    final normalizedEmail = email.toLowerCase().trim();
    return _registeredAccounts.containsKey(normalizedEmail) &&
        _registeredAccounts[normalizedEmail] == password;
  }

  void updateProfile({String? nama, String? email, String? password, String? foto}) {
    _userProfile = _userProfile.copyWith(
      nama: nama ?? _userProfile.nama,
      email: email ?? _userProfile.email,
      password: password ?? _userProfile.password,
      foto: foto ?? _userProfile.foto,
    );

    final idx = _mahasiswaList.indexWhere((m) => m.email.toLowerCase() == _userProfile.email.toLowerCase());
    if (idx != -1) {
      if (nama != null) _mahasiswaList[idx].nama = nama;
      if (email != null) _mahasiswaList[idx].email = email;
      if (foto != null) _mahasiswaList[idx].foto = foto; // sinkronisasi foto
    }
    notifyListeners();
  }

  // ---- Catatan Belajar ----
  final List<CatatanBelajar> _catatanList = [
    CatatanBelajar(
      id: '1',
      judul: 'Belajar Flutter',
      mataPelajaran: 'Pemrograman Mobile',
      isi: 'Mempelajari widget dasar Flutter seperti Row, Column, Container. Juga belajar tentang StatefulWidget dan StatelessWidget, serta bagaimana menggunakan setState untuk memperbarui UI.',
      tanggal: DateTime(2026, 5, 21),
      status: 'selesai',
      durasi: 90,
      mahasiswaEmail: 'andi@email.com',
      mahasiswaNama: 'Andi Setiawan',
    ),
    CatatanBelajar(
      id: '2',
      judul: 'Algoritma Sorting',
      mataPelajaran: 'Struktur Data',
      isi: 'Memahami Bubble Sort, Quick Sort, dan Merge Sort. Menganalisis kompleksitas waktu O(n²) untuk Bubble Sort dan O(n log n) untuk Quick Sort dalam kasus rata-rata.',
      tanggal: DateTime(2026, 5, 20),
      status: 'berlangsung',
      durasi: 60,
      mahasiswaEmail: 'budi@email.com',
      mahasiswaNama: 'Budi Santoso',
    ),
    CatatanBelajar(
      id: '3',
      judul: 'Machine Learning Dasar',
      mataPelajaran: 'Kecerdasan Buatan',
      isi: 'Mempelajari konsep dasar supervised learning. Memahami perbedaan antara klasifikasi dan regresi, serta mengenal algoritma seperti Linear Regression dan Decision Tree.',
      tanggal: DateTime(2026, 5, 19),
      status: 'tertunda',
      durasi: 45,
      mahasiswaEmail: 'citra@email.com',
      mahasiswaNama: 'Citra Dewi',
    ),
  ];

  List<CatatanBelajar> get catatanList => List.unmodifiable(_catatanList);

  List<CatatanBelajar> get catatanListForUser {
    return _catatanList.where((c) => c.mahasiswaEmail.toLowerCase() == _userProfile.email.toLowerCase()).toList();
  }

  void tambahCatatan(CatatanBelajar catatan) {
    _catatanList.insert(0, catatan);
    _tambahNotifikasi(
      judul: 'Catatan Baru Ditambahkan!',
      isi: 'Catatan "${catatan.judul}" berhasil disimpan.',
      tipe: 'catatan',
    );

    final idx = _mahasiswaList.indexWhere((m) => m.email.toLowerCase() == catatan.mahasiswaEmail.toLowerCase());
    if (idx != -1) {
      _mahasiswaList[idx].totalJurnal++;
    }

    _userProfile = _userProfile.copyWith(
      totalBelajar: _userProfile.totalBelajar + catatan.durasi,
    );

    notifyListeners();
  }

  void editCatatan(CatatanBelajar catatan) {
    final index = _catatanList.indexWhere((c) => c.id == catatan.id);
    if (index != -1) {
      final oldDurasi = _catatanList[index].durasi;
      _catatanList[index] = catatan;

      _userProfile = _userProfile.copyWith(
        totalBelajar: _userProfile.totalBelajar - oldDurasi + catatan.durasi,
      );

      notifyListeners();
    }
  }

  void hapusCatatan(String id) {
    final idxCatatan = _catatanList.indexWhere((c) => c.id == id);
    if (idxCatatan != -1) {
      final email = _catatanList[idxCatatan].mahasiswaEmail;
      final durasi = _catatanList[idxCatatan].durasi;
      _catatanList.removeAt(idxCatatan);
      
      final idxMhs = _mahasiswaList.indexWhere((m) => m.email.toLowerCase() == email.toLowerCase());
      if (idxMhs != -1 && _mahasiswaList[idxMhs].totalJurnal > 0) {
        _mahasiswaList[idxMhs].totalJurnal--;
      }

      if (email.toLowerCase() == _userProfile.email.toLowerCase()) {
        _userProfile = _userProfile.copyWith(
          totalBelajar: _userProfile.totalBelajar - durasi >= 0 ? _userProfile.totalBelajar - durasi : 0,
        );
      }
    }
    notifyListeners();
  }

  // ---- Target Harian ----
  final List<TargetHarian> _targetList = [
    TargetHarian(id: '1', judul: 'Belajar Flutter 2 jam', deskripsi: 'Fokus pada state management', tanggal: DateTime(2026, 5, 21), selesai: true, prioritas: 'tinggi', mahasiswaEmail: 'andi@email.com', mahasiswaNama: 'Andi Setiawan'),
    TargetHarian(id: '2', judul: 'Membaca buku algoritma', deskripsi: 'Bab 5-7 tentang graph', tanggal: DateTime(2026, 5, 21), selesai: false, prioritas: 'sedang', mahasiswaEmail: 'budi@email.com', mahasiswaNama: 'Budi Santoso'),
    TargetHarian(id: '3', judul: 'Kerjakan soal latihan', deskripsi: '10 soal pemrograman', tanggal: DateTime(2026, 5, 21), selesai: false, prioritas: 'rendah', mahasiswaEmail: 'citra@email.com', mahasiswaNama: 'Citra Dewi'),
    TargetHarian(id: '4', judul: 'Review catatan kemarin', deskripsi: 'Catatan dari kelas Basis Data', tanggal: DateTime(2026, 5, 21), selesai: true, prioritas: 'sedang', mahasiswaEmail: 'andi@email.com', mahasiswaNama: 'Andi Setiawan'),
  ];

  List<TargetHarian> get targetList => List.unmodifiable(_targetList);

  List<TargetHarian> get targetListForUser {
    return _targetList.where((t) => t.mahasiswaEmail.toLowerCase() == _userProfile.email.toLowerCase()).toList();
  }

  void tambahTarget(TargetHarian target) {
    _targetList.insert(0, target);
    
    final idx = _mahasiswaList.indexWhere((m) => m.email.toLowerCase() == target.mahasiswaEmail.toLowerCase());
    if (idx != -1) {
      _mahasiswaList[idx].totalTarget++;
    }

    notifyListeners();
  }

  void editTarget(String id, {required String judul, required String deskripsi, required String prioritas}) {
    final index = _targetList.indexWhere((t) => t.id == id);
    if (index != -1) {
      _targetList[index].judul = judul;
      _targetList[index].deskripsi = deskripsi;
      _targetList[index].prioritas = prioritas;
      notifyListeners();
    }
  }

  void toggleTarget(String id) {
    final index = _targetList.indexWhere((t) => t.id == id);
    if (index != -1) {
      _targetList[index].selesai = !_targetList[index].selesai;
      final isSelesai = _targetList[index].selesai;
      final email = _targetList[index].mahasiswaEmail;
      
      if (isSelesai) {
        _tambahNotifikasi(
          judul: 'Target Selesai! 🎉',
          isi: 'Target "${_targetList[index].judul}" berhasil diselesaikan.',
          tipe: 'target',
        );
      }

      if (email.toLowerCase() == _userProfile.email.toLowerCase()) {
        _userProfile = _userProfile.copyWith(
          targetSelesai: _userProfile.targetSelesai + (isSelesai ? 1 : -1),
        );
      }

      notifyListeners();
    }
  }

  void hapusTarget(String id) {
    final index = _targetList.indexWhere((t) => t.id == id);
    if (index != -1) {
      final email = _targetList[index].mahasiswaEmail;
      final wasSelesai = _targetList[index].selesai;
      _targetList.removeAt(index);

      final idxMhs = _mahasiswaList.indexWhere((m) => m.email.toLowerCase() == email.toLowerCase());
      if (idxMhs != -1 && _mahasiswaList[idxMhs].totalTarget > 0) {
        _mahasiswaList[idxMhs].totalTarget--;
      }

      if (email.toLowerCase() == _userProfile.email.toLowerCase()) {
        _userProfile = _userProfile.copyWith(
          targetSelesai: wasSelesai && _userProfile.targetSelesai > 0 ? _userProfile.targetSelesai - 1 : _userProfile.targetSelesai,
        );
      }
    }
    notifyListeners();
  }

  // ---- Refleksi Diri ----
  final List<RefleksiDiri> _refleksiList = [
    RefleksiDiri(id: '1', pertanyaan: 'Apa yang kamu pelajari hari ini?', jawaban: 'Mempelajari state management di Flutter menggunakan Provider. Sangat menarik bagaimana data dapat mengalir dari parent ke child widget.', tanggal: DateTime(2026, 5, 21), mood: 4, mahasiswaEmail: 'andi@email.com', mahasiswaNama: 'Andi Setiawan'),
    RefleksiDiri(id: '2', pertanyaan: 'Apa hambatan belajarmu?', jawaban: 'Sulit memahami konsep asynchronous programming, terutama Future dan Stream. Perlu lebih banyak latihan.', tanggal: DateTime(2026, 5, 20), mood: 3, mahasiswaEmail: 'budi@email.com', mahasiswaNama: 'Budi Santoso'),
    RefleksiDiri(id: '3', pertanyaan: 'Apa yang ingin kamu tingkatkan?', jawaban: 'Konsistensi belajar setiap hari minimal 2 jam. Juga perlu meningkatkan kemampuan problem solving.', tanggal: DateTime(2026, 5, 19), mood: 5, mahasiswaEmail: 'citra@email.com', mahasiswaNama: 'Citra Dewi'),
  ];

  List<RefleksiDiri> get refleksiList => List.unmodifiable(_refleksiList);

  List<RefleksiDiri> get refleksiListForUser {
    return _refleksiList.where((r) => r.mahasiswaEmail.toLowerCase() == _userProfile.email.toLowerCase()).toList();
  }

  // Helper getter untuk admin: ambil data spesifik per mahasiswa
  List<CatatanBelajar> getCatatanForEmail(String email) =>
      _catatanList.where((c) => c.mahasiswaEmail.toLowerCase() == email.toLowerCase()).toList();

  List<RefleksiDiri> getRefleksiForEmail(String email) =>
      _refleksiList.where((r) => r.mahasiswaEmail.toLowerCase() == email.toLowerCase()).toList();

  List<TargetHarian> getTargetForEmail(String email) =>
      _targetList.where((t) => t.mahasiswaEmail.toLowerCase() == email.toLowerCase()).toList();

  void tambahRefleksi(RefleksiDiri refleksi) {
    _refleksiList.insert(0, refleksi);

    // Sinkronisasi totalRefleksi di _mahasiswaList
    final idxMhs = _mahasiswaList.indexWhere((m) => m.email.toLowerCase() == refleksi.mahasiswaEmail.toLowerCase());
    if (idxMhs != -1) {
      _mahasiswaList[idxMhs].totalRefleksi++;
    }
    
    if (refleksi.mahasiswaEmail.toLowerCase() == _userProfile.email.toLowerCase()) {
      _userProfile = _userProfile.copyWith(totalRefleksi: _userProfile.totalRefleksi + 1);
    }
    
    _tambahNotifikasi(
      judul: 'Refleksi Diri Disimpan',
      isi: 'Refleksi harianmu berhasil dicatat. Terus berkembang!',
      tipe: 'refleksi',
    );
    notifyListeners();
  }

  void hapusRefleksi(String id) {
    final index = _refleksiList.indexWhere((r) => r.id == id);
    if (index != -1) {
      final email = _refleksiList[index].mahasiswaEmail;
      _refleksiList.removeAt(index);

      // Sinkronisasi totalRefleksi di _mahasiswaList
      final idxMhs = _mahasiswaList.indexWhere((m) => m.email.toLowerCase() == email.toLowerCase());
      if (idxMhs != -1 && _mahasiswaList[idxMhs].totalRefleksi > 0) {
        _mahasiswaList[idxMhs].totalRefleksi--;
      }

      if (email.toLowerCase() == _userProfile.email.toLowerCase() && _userProfile.totalRefleksi > 0) {
        _userProfile = _userProfile.copyWith(totalRefleksi: _userProfile.totalRefleksi - 1);
      }
    }
    notifyListeners();
  }

  // ---- Notifikasi ----
  final List<Notifikasi> _notifikasiList = [
    Notifikasi(id: '1', judul: 'Pengingat Target', isi: 'Kamu punya 2 target yang belum selesai hari ini!', waktu: DateTime(2026, 5, 21, 8, 0), dibaca: false, tipe: 'target'),
    Notifikasi(id: '2', judul: 'Streak 6 Hari! 🔥', isi: 'Selamat! Kamu berhasil belajar 6 hari berturut-turut.', waktu: DateTime(2026, 5, 20, 20, 0), dibaca: false, tipe: 'streak'),
    Notifikasi(id: '3', judul: 'Waktu Refleksi Diri', isi: 'Sudahkah kamu merefleksi belajarmu hari ini?', waktu: DateTime(2026, 5, 20, 19, 0), dibaca: true, tipe: 'refleksi'),
    Notifikasi(id: '4', judul: 'Target Mingguan Tercapai!', isi: 'Kamu berhasil menyelesaikan 90% target minggu ini.', waktu: DateTime(2026, 5, 19, 17, 0), dibaca: true, tipe: 'target'),
  ];

  List<Notifikasi> get notifikasiList => List.unmodifiable(_notifikasiList);
  int get jumlahBelumDibaca => _notifikasiList.where((n) => !n.dibaca).length;

  void _tambahNotifikasi({required String judul, required String isi, required String tipe}) {
    _notifikasiList.insert(0, Notifikasi(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      judul: judul,
      isi: isi,
      waktu: DateTime.now(),
      dibaca: false,
      tipe: tipe,
    ));
  }

  void tandaiBacaNotifikasi(String id) {
    final index = _notifikasiList.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifikasiList[index].dibaca = true;
      notifyListeners();
    }
  }

  void tandaiBacaSemua() {
    for (var n in _notifikasiList) {
      n.dibaca = true;
    }
    notifyListeners();
  }

  void hapusNotifikasi(String id) {
    _notifikasiList.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // ---- Admin: Mahasiswa ----
  final List<MahasiswaAdmin> _mahasiswaList = [
    MahasiswaAdmin(id: '1', nama: 'Andi Setiawan', email: 'andi@email.com', bergabung: DateTime(2026, 1, 5), totalJurnal: 1, totalTarget: 2, totalRefleksi: 1),
    MahasiswaAdmin(id: '2', nama: 'Budi Santoso', email: 'budi@email.com', bergabung: DateTime(2026, 1, 12), totalJurnal: 1, totalTarget: 1, totalRefleksi: 1),
    MahasiswaAdmin(id: '3', nama: 'Citra Dewi', email: 'citra@email.com', bergabung: DateTime(2026, 2, 3), totalJurnal: 1, totalTarget: 1, totalRefleksi: 1),
    MahasiswaAdmin(id: '4', nama: 'Dani Firmansyah', email: 'dani@email.com', bergabung: DateTime(2026, 2, 15), totalJurnal: 0, totalTarget: 0, totalRefleksi: 0),
    MahasiswaAdmin(id: '5', nama: 'Eka Prasetya', email: 'eka@email.com', bergabung: DateTime(2026, 3, 1), totalJurnal: 0, totalTarget: 0, totalRefleksi: 0),
    MahasiswaAdmin(id: '6', nama: 'Fira Nanda', email: 'fira@email.com', bergabung: DateTime(2026, 3, 10), totalJurnal: 0, totalTarget: 0, totalRefleksi: 0),
    MahasiswaAdmin(id: '7', nama: 'Galih Pratama', email: 'galih@email.com', bergabung: DateTime(2026, 4, 1), totalJurnal: 0, totalTarget: 0, totalRefleksi: 0),
  ];

  void syncMahasiswaCounts() {
    for (var m in _mahasiswaList) {
      m.totalJurnal = _catatanList.where((c) => c.mahasiswaEmail.toLowerCase() == m.email.toLowerCase()).length;
      m.totalTarget = _targetList.where((t) => t.mahasiswaEmail.toLowerCase() == m.email.toLowerCase()).length;
      m.totalRefleksi = _refleksiList.where((r) => r.mahasiswaEmail.toLowerCase() == m.email.toLowerCase()).length;
    }
  }

  List<MahasiswaAdmin> get mahasiswaList {
    syncMahasiswaCounts();
    // Urutkan berdasarkan total aktivitas (jurnal + target + refleksi) descending
    // agar "Top Mahasiswa" selalu mencerminkan mahasiswa paling aktif
    final sorted = List<MahasiswaAdmin>.from(_mahasiswaList)
      ..sort((a, b) {
        final totalA = a.totalJurnal + a.totalTarget + a.totalRefleksi;
        final totalB = b.totalJurnal + b.totalTarget + b.totalRefleksi;
        return totalB.compareTo(totalA);
      });
    return List.unmodifiable(sorted);
  }

  void tambahMahasiswa(MahasiswaAdmin mahasiswa) {
    _mahasiswaList.add(mahasiswa);
    notifyListeners();
  }

  void editMahasiswa(String id, {required String nama, required String email}) {
    final index = _mahasiswaList.indexWhere((m) => m.id == id);
    if (index != -1) {
      final oldEmail = _mahasiswaList[index].email;
      _mahasiswaList[index].nama = nama;
      _mahasiswaList[index].email = email;

      for (var c in _catatanList) {
        if (c.mahasiswaEmail.toLowerCase() == oldEmail.toLowerCase()) {
          final idx = _catatanList.indexWhere((x) => x.id == c.id);
          _catatanList[idx] = c.copyWith(mahasiswaEmail: email, mahasiswaNama: nama);
        }
      }
      for (var t in _targetList) {
        if (t.mahasiswaEmail.toLowerCase() == oldEmail.toLowerCase()) {
          t.judul = t.judul; 
        }
      }

      if (_userProfile.email.toLowerCase() == oldEmail.toLowerCase()) {
        _userProfile = _userProfile.copyWith(nama: nama, email: email);
      }

      notifyListeners();
    }
  }

  void hapusMahasiswa(String id) {
    final index = _mahasiswaList.indexWhere((m) => m.id == id);
    if (index != -1) {
      final email = _mahasiswaList[index].email;
      _mahasiswaList.removeAt(index);
      
      _catatanList.removeWhere((c) => c.mahasiswaEmail.toLowerCase() == email.toLowerCase());
      _targetList.removeWhere((t) => t.mahasiswaEmail.toLowerCase() == email.toLowerCase());
      _refleksiList.removeWhere((r) => r.mahasiswaEmail.toLowerCase() == email.toLowerCase());

      notifyListeners();
    }
  }

  // ---- Admin: Pengaturan ----
  bool _izinkanDaftar = true;
  bool _modeMaintenance = false;
  bool _notifAktif = true;

  bool get izinkanDaftar => _izinkanDaftar;
  bool get modeMaintenance => _modeMaintenance;
  bool get notifAktif => _notifAktif;

  void setIzinkanDaftar(bool v) { _izinkanDaftar = v; notifyListeners(); }
  void setModeMaintenance(bool v) { _modeMaintenance = v; notifyListeners(); }
  void setNotifAktif(bool v) { _notifAktif = v; notifyListeners(); }

  void resetSemuaData() {
    _catatanList.clear();
    _targetList.clear();
    _refleksiList.clear();
    _notifikasiList.clear();
    notifyListeners();
  }

  // Statistik helpers
  int get totalBelajarJam => _userProfile.totalBelajar ~/ 60;
  int get totalBelajarMenit => _userProfile.totalBelajar % 60;

  /// Format tampilan: "1j 30m", "45 Menit", atau "0 Menit"
  String get totalBelajarDisplay {
    final jam = _userProfile.totalBelajar ~/ 60;
    final menit = _userProfile.totalBelajar % 60;
    if (jam > 0 && menit > 0) return '${jam}j ${menit}m';
    if (jam > 0) return '$jam Jam';
    if (menit > 0) return '$menit Menit';
    return '0 Menit';
  }
  int get targetSelesaiCount => targetListForUser.where((t) => t.selesai).length;
  int get targetTotalCount => targetListForUser.length;
  double get persentaseTarget => targetTotalCount > 0 ? targetSelesaiCount / targetTotalCount : 0;

  List<int> get belajarPerMinggu {
    // Hitung dari data catatan asli untuk 7 hari terakhir
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (i) {
      final targetDay = today.subtract(Duration(days: i));
      return _catatanList
          .where((c) =>
              c.mahasiswaEmail.toLowerCase() == _userProfile.email.toLowerCase() &&
              DateTime(c.tanggal.year, c.tanggal.month, c.tanggal.day) == targetDay)
          .fold(0, (sum, c) => sum + c.durasi);
    });
  }

  // Mood rata-rata
  double get rataRataMood {
    final list = refleksiListForUser;
    if (list.isEmpty) return 0;
    final total = list.fold(0, (s, r) => s + r.mood);
    return total / list.length;
  }
}
