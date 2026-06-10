class AbsensiUkmModel {
  final int idAbsensi;
  final int idAktivitas;
  final int idUser;
  final int idUkm;
  final String judulAktivitas;
  final String namaUkm;
  final String status;
  final String waktuAbsen;
  final double? jarakMeter;

  const AbsensiUkmModel({
    required this.idAbsensi,
    required this.idAktivitas,
    required this.idUser,
    required this.idUkm,
    required this.judulAktivitas,
    required this.namaUkm,
    required this.status,
    required this.waktuAbsen,
    this.jarakMeter,
  });

  factory AbsensiUkmModel.fromJson(Map<String, dynamic> json) {
    return AbsensiUkmModel(
      idAbsensi: int.tryParse(json['id_absensi'].toString()) ?? 0,
      idAktivitas: int.tryParse(json['id_aktivitas'].toString()) ?? 0,
      idUser: int.tryParse(json['id_user'].toString()) ?? 0,
      idUkm: int.tryParse(json['id_ukm'].toString()) ?? 0,
      judulAktivitas: json['judul']?.toString() ?? '',
      namaUkm: json['nama_ukm']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Hadir',
      waktuAbsen: json['waktu_absen']?.toString() ?? '',
      jarakMeter: double.tryParse(json['jarak_meter']?.toString() ?? ''),
    );
  }
}
