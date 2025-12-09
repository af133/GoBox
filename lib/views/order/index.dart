// lib/views/order/index.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:gobox/controllers/order.dart';
import 'package:gobox/model/order.dart';
import 'package:gobox/views/order/detail.dart'; 
import 'package:gobox/views/widgets/bnavbar.dart';
class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final OrderController controller = OrderController();
  List<OrderModel> allOrders = [];
  List<OrderModel> filtered = [];
  bool loading = true;
  String query = '';
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString == null) {
      // no user
      setState(() {
        loading = false;
        allOrders = [];
        filtered = [];
      });
      return;
    }

    final userJson = jsonDecode(userString) as Map<String, dynamic>;

    String? idMitra;
   if (userJson.containsKey('id_mitra')) {
    idMitra = userJson['id_mitra'].toString();
  } else if (userJson.containsKey('idMitra')) {
    idMitra = userJson['idMitra'].toString();
  } else if (userJson.containsKey('id')) {
    idMitra = userJson['id'].toString();
  } else if (userJson.containsKey('id_user')) {
    idMitra = userJson['id_user'].toString();
  } else if (userJson.containsKey('idUser')) {
    idMitra = userJson['idUser'].toString();
  }

    if (idMitra == null) {
      setState(() {
        loading = false;
        allOrders = [];
        filtered = [];
      });
      return;
    }

    final orders = await controller.getOrdersMitra(idMitra);
    setState(() {
      allOrders = orders;
      filtered = orders;
      loading = false;
    });
  }

  void onSearch(String q) {
    q = q.toLowerCase();
    setState(() {
      filtered = allOrders.where((o) {
        final nama = o.pelanggan?.nama.toLowerCase() ?? '';
        final id = o.idOrder.toString();
        return nama.contains(q) || id.contains(q);
      }).toList();
    });
  }

  Color statusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'diterima') return Colors.green;
    if (s == 'ditolak') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Order (Mitra)'),
        backgroundColor: Colors.blue,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Cari nama pelanggan atau ID order...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: onSearch,
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('Tidak ada order ditemukan'))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final o = filtered[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderDetailPage(order: o),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Order #${o.idOrder}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusColor(o.status),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(o.status, style: const TextStyle(color: Colors.white)),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text('Pelanggan: ${o.pelanggan?.nama ?? "-"}'),
                                      Text('Lokasi: ${o.lokasi?.namaLokasi ?? "-"}'),
                                      Text('Tgl Titip: ${o.tanggalPenitipan}'),
                                      Text('Tgl Ambil: ${o.tanggalPengambilan}'),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Barang: ${o.jumlahItem} item'),
                                          Text('Total: ${currency.format(o.totalHarga)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: Bnavbar(currentIndex: 2,),
    );
  }
}
