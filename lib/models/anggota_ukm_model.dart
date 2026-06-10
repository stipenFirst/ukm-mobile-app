class AnggotaUkmModel {
  final String id;
  final String nama;
  final String nim;
  final String fakultas;
  final String status;

  const AnggotaUkmModel({
    required this.id,
    required this.nama,
    required this.nim,
    required this.fakultas,
    required this.status,
  });

  factory AnggotaUkmModel.fromJson(Map<String, dynamic> json) {
    return AnggotaUkmModel(
      id: (json['id'] ?? json['id_user'] ?? '').toString(),
      nama: json['nama']?.toString() ?? json['nama_mahasiswa']?.toString() ?? '',
      nim: json['nim']?.toString() ?? '',
      fakultas: json['fakultas']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nim': nim,
      'fakultas': fakultas,
      'status': status,
    };
  }
}
