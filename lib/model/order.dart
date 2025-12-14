class Pelanggan {
  final int idPelanggan;
  final String nama;
  final String? nomorHp;
  final String? pathProfil;
  Pelanggan({
    required this.idPelanggan,
    required this.nama,
    this.nomorHp,
    this.pathProfil,
  });

  factory Pelanggan.fromJson(Map<String, dynamic> json) {
    return Pelanggan(
      idPelanggan: json['id_pelanggan'] ?? 0,
      nama: json['nama'] ?? '',
      nomorHp: json['nomor_hp'],
      pathProfil: json['path_profil'],
    );
  }
}

class Lokasi {
  final int idLokasi;
  final String namaLokasi;
  Lokasi({required this.idLokasi, required this.namaLokasi});

  factory Lokasi.fromJson(Map<String, dynamic> json) {
    return Lokasi(
      idLokasi: json['id_lokasi'] ?? 0,
      namaLokasi: json['nama_lokasi'] ?? '-',
    );
  }
}
class GroupedItem {
  final String nama;
  int jumlah;
  final int harga;

  GroupedItem({
    required this.nama,
    required this.jumlah,
    required this.harga,
  });
}
class ItemOrder {
  final int idItemOrder;
  final int idJenisBarang;
  final String? namaJenisBarang;
  final int hargaSaatOrder;

  ItemOrder({
    required this.idItemOrder,
    required this.idJenisBarang,
    this.namaJenisBarang,
    required this.hargaSaatOrder,
  });

  factory ItemOrder.fromJson(Map<String, dynamic> json) {
    return ItemOrder(
      idItemOrder: json['id_item_order'] ?? 0,
      idJenisBarang: json['id_jenis_barang'] ?? 0,
      namaJenisBarang: json['jenis_barang'] != null
          ? (json['jenis_barang']['jenis_barang'] ?? json['jenis_barang']['jenis_barang'] ?? "-")
          : null,
      hargaSaatOrder: json['harga_saat_order'] ?? 0,
    );
  }
}

class OrderModel {
  final int idOrder;
  final Pelanggan? pelanggan;
  final Lokasi? lokasi;
  final String tanggalPenitipan;
  final String tanggalPengambilan;
  final String status;
  final List<ItemOrder> itemOrders;
  final int jumlahItem; 
  final String pathGambar; 
  final int totalHarga; 

  OrderModel({
    required this.idOrder,
    required this.pelanggan,
    required this.lokasi,
    required this.tanggalPenitipan,
    required this.tanggalPengambilan,
    required this.status,
    required this.itemOrders,
    required this.jumlahItem,
    required this.totalHarga,
    required this.pathGambar,

  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['item_orders'] as List<dynamic>? ?? [];
    final items = itemsJson.map((e) => ItemOrder.fromJson(e as Map<String, dynamic>)).toList();

    // Fallback jika backend belum meng-inject jumlah_item / total_harga
    final int computedJumlah = json['jumlah_item'] ??
        items.length;
    final int computedTotal = json['total_harga'] ??
        items.fold<int>(0, (s, it) => s + it.hargaSaatOrder);

    return OrderModel(
      idOrder: json['id_order'] ?? 0,
      pelanggan: json['pelanggan'] != null ? Pelanggan.fromJson(json['pelanggan']) : null,
      lokasi: json['lokasi'] != null ? Lokasi.fromJson(json['lokasi']) : null,
      tanggalPenitipan: json['tanggal_penitipan'] ?? '',
      tanggalPengambilan: json['tanggal_pengambilan'] ?? '',
      status: (json['status'] ?? 'pending').toString(),
      itemOrders: items,
      pathGambar:json['path_gambar'] ?? '',
      jumlahItem: computedJumlah,
      totalHarga: computedTotal,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_order': idOrder,
        'pelanggan': pelanggan != null ? {'id_pelanggan': pelanggan!.idPelanggan, 'nama': pelanggan!.nama} : null,
        'lokasi': lokasi != null ? {'id_lokasi': lokasi!.idLokasi, 'nama_lokasi': lokasi!.namaLokasi} : null,
        'tanggal_penitipan': tanggalPenitipan,
        'tanggal_pengambilan': tanggalPengambilan,
        'status': status,
        'path_gambar': pathGambar,
        'jumlah_item': jumlahItem,
        'total_harga': totalHarga,
        'item_orders': itemOrders.map((i) => {
              'id_item_order': i.idItemOrder,
              'id_jenis_barang': i.idJenisBarang,
              'nama_jenis_barang': i.namaJenisBarang,
              'harga_saat_order': i.hargaSaatOrder,
            }).toList(),
      };
}
