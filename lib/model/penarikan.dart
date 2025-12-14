class Saldo {
  final int idTransaksi;
  final String type; 
  final int jumlah;
  final String tanggal;
  final String status;

  Saldo({
    required this.idTransaksi,
    required this.type,
    required this.jumlah,
    required this.tanggal,
    required this.status,
  });

 factory Saldo.fromJson(Map<String, dynamic> json) => Saldo(
      idTransaksi: json['id_transaksi'], // sesuaikan dengan JSON Laravel
      type: json['type'],
      jumlah: int.parse(json['jumlah'].toString()),
      tanggal: json['tanggal'],
      status: json['status'],
    );

}

class Penarikan {
  final int id;
  final int idMitra;
  final int jumlah;
  final String tanggal;
  final String status;
  final String? alasan;

  Penarikan({
    required this.id,
    required this.idMitra,
    required this.jumlah,
    required this.tanggal,
    required this.status,
    this.alasan,
  });

  factory Penarikan.fromJson(Map<String, dynamic> json) => Penarikan(
        id: json['id'],
        idMitra: json['id_mitra'],
        jumlah: json['jumlah_penarikan'],
        tanggal: json['tanggal_penarikan'],
        status: json['status'],
        alasan: json['alasan_penarikan'],
      );
}