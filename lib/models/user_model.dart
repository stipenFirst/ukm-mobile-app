class UserModel {
  final String idUser;
  final String nama;
  final String email;
  final String role;
  final String token;
  final String? fotoProfil;
  final String? nim;
  final String? fakultas;
  final String? prodi;
  final String? alamat;

  const UserModel({
    required this.idUser,
    required this.nama,
    required this.email,
    required this.role,
    required this.token,
    this.fotoProfil,
    this.nim,
    this.fakultas,
    this.prodi,
    this.alamat,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: (json['id_user'] ?? json['id'] ?? '').toString(),
      nama: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      token: json['token']?.toString() ?? '',
      fotoProfil: json['foto_profil']?.toString(),
      nim: json['nim']?.toString(),
      fakultas: json['fakultas']?.toString(),
      prodi: json['prodi']?.toString(),
      alamat: json['alamat']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'nama': nama,
      'email': email,
      'role': role,
      'token': token,
      'foto_profil': fotoProfil,
      'nim': nim,
      'fakultas': fakultas,
      'prodi': prodi,
      'alamat': alamat,
    };
  }
}
