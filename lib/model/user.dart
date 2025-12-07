class User {
  final int ?idUser;
  final String nama;
  final String? email;
  final String? pathProfil;
  final String? alamat;
  final String? nomorHp;
  final double? latitude;
  final double? longitude;

  User({
    required this.idUser,
    required this.nama,
    this.email,
    this.pathProfil,
    this.alamat,
    this.nomorHp,
    this.latitude,
    this.longitude,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        idUser: json['id_user'] ?? 0,
        nama: json['nama'] ?? '',
        email: json['email']?.toString(),
        alamat: json['alamat']?.toString(),
        nomorHp: json['nomor_hp']?.toString(),
        pathProfil: json['path_profil']?.toString(),
        latitude: json['latitude'] != null
            ? (json['latitude'] as num).toDouble()
            : null,
        longitude: json['longitude'] != null
            ? (json['longitude'] as num).toDouble()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id_user': idUser,
        'nama': nama,
        'email': email,
        'alamat': alamat,
        'path_profil': pathProfil,
        'nomor_hp': nomorHp,
        'latitude': latitude,
        'longitude': longitude,
      };
}
