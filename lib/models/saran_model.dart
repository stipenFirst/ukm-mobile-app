class SaranModel {
  final String id;
  final String nama;
  final String isiSaran;
  final String tanggal;

  const SaranModel({
    required this.id,
    required this.nama,
    required this.isiSaran,
    required this.tanggal,
  });

  factory SaranModel.fromJson(Map<String, dynamic> json) {
    return SaranModel(
      id: (json['id'] ?? json['id_saran'] ?? '').toString(),
      nama: json['nama']?.toString() ?? '',
      isiSaran: json['isi_saran']?.toString() ?? json['saran']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'isi_saran': isiSaran,
      'tanggal': tanggal,
    };
  }
}
