class UkmModel {
  final String id;
  final String namaUkm;
  final String kategori;
  final String deskripsi;
  final double? latitude;
  final double? longitude;

  const UkmModel({
    required this.id,
    required this.namaUkm,
    required this.kategori,
    required this.deskripsi,
    this.latitude,
    this.longitude,
  });

  factory UkmModel.fromJson(Map<String, dynamic> json) {
    return UkmModel(
      id: (json['id'] ?? json['id_ukm'] ?? '').toString(),
      namaUkm: json['nama_ukm']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? 'UMUM',
      deskripsi: json['deskripsi']?.toString() ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_ukm': namaUkm,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
