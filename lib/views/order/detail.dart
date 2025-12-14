import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gobox/model/order.dart';

const Color goBox = Color(0xFF4CAF50);

class OrderDetailPage extends StatelessWidget {
  final OrderModel order;
  const OrderDetailPage({super.key, required this.order});

  // ===================================
  // UTILITY METHODS
  // ===================================
  String formatCurrency(int value) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return f.format(value);
  }

  Color statusColor(String status) {
    final s = status.toLowerCase();
    switch (s) {
      case 'Diterima':
        return Colors.green.shade600;
      case 'pending':
        return const Color.fromARGB(255, 237, 244, 26);
      case 'Ditolak':
        return Colors.red.shade600;
      case 'menunggu':
      default:
        return Colors.orange.shade700;
    }
  }

  List<GroupedItem> getGroupedItems() {
    final Map<String, GroupedItem> map = {};

    for (var item in order.itemOrders) {
      final nama = item.namaJenisBarang ?? 'Item #${item.idItemOrder}';

      if (map.containsKey(nama)) {
        map[nama]!.jumlah += 1;
      } else {
        map[nama] = GroupedItem(
          nama: nama,
          jumlah: 1,
          harga: item.hargaSaatOrder,
        );
      }
    }

    return map.values.toList();
  }

  // ===================================
  // BUILD METHOD
  // ===================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Order #${order.idOrder}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: goBox,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Status Badge
            _buildStatusBadge(),
            const SizedBox(height: 20),

            // 2. Foto Barang
            _buildPhotoSection(),
            const SizedBox(height: 20),

            // 3. Informasi Pelanggan
            _buildSectionCard('Pelanggan', Icons.person_rounded, [
              _buildInfoRow(
                'Nama',
                order.pelanggan?.nama ?? '-',
                Icons.person_outline,
              ),
              if (order.pelanggan?.nomorHp != null)
                _buildInfoRow(
                  'No. HP',
                  order.pelanggan?.nomorHp ?? '-',
                  Icons.phone_outlined,
                ),
            ]),
            const SizedBox(height: 16),

            // 4. Detail Order & Lokasi
            _buildSectionCard(
              'Detail Penempatan',
              Icons.local_shipping_rounded,
              [
                _buildInfoRow(
                  'Lokasi Gudang',
                  order.lokasi?.namaLokasi ?? "-",
                  Icons.warehouse_outlined,
                ),
                _buildInfoRow(
                  'Tgl. Titip',
                  order.tanggalPenitipan,
                  Icons.date_range_outlined,
                ),
                _buildInfoRow(
                  'Tgl. Ambil',
                  order.tanggalPengambilan,
                  Icons.date_range,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. Daftar Barang
            _buildItemSection(),
            const SizedBox(height: 24),

            // 6. Total Harga & Aksi
            _buildTotalAndActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = statusColor(order.status);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          order.status.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: goBox, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk Baris Informasi Sederhana
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Builder: Foto Barang
  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.camera_alt_rounded, color: goBox, size: 24),
            const SizedBox(width: 8),
            Text(
              'Foto Barang',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Image.network(
              order.pathGambar,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: const AlwaysStoppedAnimation<Color>(goBox),
                  ),
                );
              },
              errorBuilder: (c, o, s) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_rounded,
                      color: Colors.grey.shade500,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Gambar tidak tersedia",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget Builder: Daftar Barang
  Widget _buildItemSection() {
    final items = getGroupedItems();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.inventory_2_rounded, color: goBox, size: 24),
            const SizedBox(width: 8),
            Text(
              'Daftar Item (${order.itemOrders.length} Item)',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(height: 16),

        if (order.itemOrders.isEmpty)
          const Text(
            'Tidak ada item terdaftar.',
            style: TextStyle(color: Colors.black54),
          )
        else
          ...items.map(
            (it) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${it.nama} (x${it.jumlah})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    formatCurrency(it.harga * it.jumlah),
                    style: const TextStyle(
                      fontSize: 15,
                      color: goBox,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Widget Builder: Total dan Aksi
  Widget _buildTotalAndActions(BuildContext context) {
    bool isPending =
        order.status.toLowerCase() == 'menunggu' ||
        order.status.toLowerCase() == 'diproses';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: goBox.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: goBox),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL HARGA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: goBox,
                ),
              ),
              Text(
                formatCurrency(order.totalHarga),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: goBox,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Tombol Aksi (Hanya tampil jika status memungkinkan)
        if (isPending)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Setelah sukses: Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Aksi Tolak Order belum diimplementasikan.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  label: const Text(
                    'TOLAK',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Setelah sukses: Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Aksi Terima Order belum diimplementasikan.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                  label: const Text(
                    'TERIMA',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goBox,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Center(
            child: Text(
              'Order sudah berstatus ${order.status.toUpperCase()}.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
