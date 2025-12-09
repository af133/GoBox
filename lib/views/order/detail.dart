import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gobox/model/order.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderModel order;
  const OrderDetailPage({super.key, required this.order});

  String formatCurrency(int value) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return f.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Order #${order.idOrder}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Status
            Center(
              child: Text(
                order.status,
                style: TextStyle(
                  color: order.status.toLowerCase() == 'diterima'
                      ? Colors.green
                      : order.status.toLowerCase() == 'ditolak'
                          ? Colors.red
                          : Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pelanggan
            Text('Informasi Pelanggan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Nama: ${order.pelanggan?.nama ?? '-'}'),
            if (order.pelanggan?.nomorHp != null) Text('No HP: ${order.pelanggan!.nomorHp}'),
            const SizedBox(height: 16),

            // Lokasi & tanggal
            Text('Detail Order', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Lokasi: ${order.lokasi?.namaLokasi ?? "-"}'),
            Text('Tanggal Titip: ${order.tanggalPenitipan}'),
            Text('Tanggal Ambil: ${order.tanggalPengambilan}'),
            const SizedBox(height: 16),

            // Foto barang
          
            const Text("Foto Barang:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                order.pathGambar,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const Text("Gambar tidak tersedia"),
              ),
            ),
            const SizedBox(height: 16),
          

            Text('Daftar Barang', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (order.itemOrders.isEmpty)
              Text('Tidak ada item terdaftar.')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, idx) {
                  final it = order.itemOrders[idx];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(it.namaJenisBarang ?? 'Item #${it.idItemOrder}'),
                    subtitle: Text('Harga: ${formatCurrency(it.hargaSaatOrder)}'),
                  );
                },
                separatorBuilder: (_, __) => const Divider(),
                itemCount: order.itemOrders.length,
              ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Jumlah Item: ${order.jumlahItem}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Total: ${formatCurrency(order.totalHarga)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),


            ],
        ),
      ),
    );
  }
}
