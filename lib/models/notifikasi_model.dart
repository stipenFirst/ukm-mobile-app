class NotifikasiModel {
  final String id;
  final String judul;
  final String pesan;
  final String tanggal;

  const NotifikasiModel({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tanggal,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: (json['id'] ?? json['id_notifikasi'] ?? '').toString(),
      judul: json['judul']?.toString() ?? '',
      pesan: json['pesan']?.toString() ?? json['message']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'pesan': pesan,
      'tanggal': tanggal,
    };
  }
}
