class PendaftaranModel {
  final String id;
  final String namaMahasiswa;
  final String namaUkm;
  final String nim;
  final String fakultas;
  final String alasanBergabung;
  final String status;

  const PendaftaranModel({
    required this.id,
    required this.namaMahasiswa,
    required this.namaUkm,
    required this.nim,
    required this.fakultas,
    required this.alasanBergabung,
    required this.status,
  });

  factory PendaftaranModel.fromJson(Map<String, dynamic> json) {
    return PendaftaranModel(
      id: (json['id'] ?? json['id_pendaftaran'] ?? '').toString(),
      namaMahasiswa: json['nama_mahasiswa']?.toString() ?? json['nama']?.toString() ?? '',
      namaUkm: json['nama_ukm']?.toString() ?? '',
      nim: json['nim']?.toString() ?? '',
      fakultas: json['fakultas']?.toString() ?? '',
      alasanBergabung: json['alasan_bergabung']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Menunggu',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_mahasiswa': namaMahasiswa,
      'nama_ukm': namaUkm,
      'nim': nim,
      'fakultas': fakultas,
      'alasan_bergabung': alasanBergabung,
      'status': status,
    };
  }
}
