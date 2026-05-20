class CatatanBelajar {
  final String id;
  final String judul;
  final String mataPelajaran;
  final String isi;
  final DateTime tanggal;
  final String status; // 'selesai', 'berlangsung', 'tertunda'
  final int durasi; // menit
  final String mahasiswaEmail;
  final String mahasiswaNama;

  CatatanBelajar({
    required this.id,
    required this.judul,
    required this.mataPelajaran,
    required this.isi,
    required this.tanggal,
    required this.status,
    required this.durasi,
    required this.mahasiswaEmail,
    required this.mahasiswaNama,
  });

  CatatanBelajar copyWith({
    String? id,
    String? judul,
    String? mataPelajaran,
    String? isi,
    DateTime? tanggal,
    String? status,
    int? durasi,
    String? mahasiswaEmail,
    String? mahasiswaNama,
  }) {
    return CatatanBelajar(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      mataPelajaran: mataPelajaran ?? this.mataPelajaran,
      isi: isi ?? this.isi,
      tanggal: tanggal ?? this.tanggal,
      status: status ?? this.status,
      durasi: durasi ?? this.durasi,
      mahasiswaEmail: mahasiswaEmail ?? this.mahasiswaEmail,
      mahasiswaNama: mahasiswaNama ?? this.mahasiswaNama,
    );
  }
}

class TargetHarian {
  final String id;
  String judul;
  String deskripsi;
  final DateTime tanggal;
  bool selesai;
  String prioritas; // 'tinggi', 'sedang', 'rendah'
  final String mahasiswaEmail;
  final String mahasiswaNama;

  TargetHarian({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.tanggal,
    required this.selesai,
    required this.prioritas,
    required this.mahasiswaEmail,
    required this.mahasiswaNama,
  });
}

class RefleksiDiri {
  final String id;
  final String pertanyaan;
  final String jawaban;
  final DateTime tanggal;
  final int mood; // 1-5 (sangat buruk - sangat baik)
  final String mahasiswaEmail;
  final String mahasiswaNama;

  RefleksiDiri({
    required this.id,
    required this.pertanyaan,
    required this.jawaban,
    required this.tanggal,
    required this.mood,
    required this.mahasiswaEmail,
    required this.mahasiswaNama,
  });
}

class Notifikasi {
  final String id;
  final String judul;
  final String isi;
  final DateTime waktu;
  bool dibaca;
  final String tipe; // 'target', 'refleksi', 'streak'

  Notifikasi({
    required this.id,
    required this.judul,
    required this.isi,
    required this.waktu,
    required this.dibaca,
    required this.tipe,
  });
}

class UserProfile {
  final String nama;
  final String email;
  final String foto;
  final int streakHari;
  final int totalBelajar; // menit
  final int targetSelesai;
  final int totalRefleksi;
  final String password;

  UserProfile({
    required this.nama,
    required this.email,
    required this.foto,
    required this.streakHari,
    required this.totalBelajar,
    required this.targetSelesai,
    required this.totalRefleksi,
    this.password = '123456',
  });

  UserProfile copyWith({
    String? nama,
    String? email,
    String? foto,
    int? streakHari,
    int? totalBelajar,
    int? targetSelesai,
    int? totalRefleksi,
    String? password,
  }) {
    return UserProfile(
      nama: nama ?? this.nama,
      email: email ?? this.email,
      foto: foto ?? this.foto,
      streakHari: streakHari ?? this.streakHari,
      totalBelajar: totalBelajar ?? this.totalBelajar,
      targetSelesai: targetSelesai ?? this.targetSelesai,
      totalRefleksi: totalRefleksi ?? this.totalRefleksi,
      password: password ?? this.password,
    );
  }
}

class MahasiswaAdmin {
  final String id;
  String nama;
  String email;
  String foto;
  final DateTime bergabung;
  int totalJurnal;
  int totalTarget;
  int totalRefleksi;

  MahasiswaAdmin({
    required this.id,
    required this.nama,
    required this.email,
    this.foto = '',
    required this.bergabung,
    required this.totalJurnal,
    required this.totalTarget,
    this.totalRefleksi = 0,
  });
}
