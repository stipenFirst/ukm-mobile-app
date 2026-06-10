class AktivitasUkmModel {
  final int idAktivitas;
  final int idUkm;
  final String namaUkm;
  final String judul;
  final String deskripsi;
  final String tanggalMulai;
  final String lokasi;
  final double? latitude;
  final double? longitude;

  const AktivitasUkmModel({
    required this.idAktivitas,
    required this.idUkm,
    required this.namaUkm,
    required this.judul,
    required this.deskripsi,
    required this.tanggalMulai,
    required this.lokasi,
    this.latitude,
    this.longitude,
  });

  factory AktivitasUkmModel.fromJson(Map<String, dynamic> json) {
    return AktivitasUkmModel(
      idAktivitas: int.tryParse(json['id_aktivitas'].toString()) ?? 0,
      idUkm: int.tryParse(json['id_ukm'].toString()) ?? 0,
      namaUkm: json['nama_ukm']?.toString() ?? '',
      judul: json['judul']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      tanggalMulai: json['tanggal_mulai']?.toString() ?? '',
      lokasi: json['lokasi']?.toString() ?? 'Sekretariat UKM',
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
    );
  }
}
