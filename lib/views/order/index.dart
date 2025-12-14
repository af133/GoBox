import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:gobox/controllers/order.dart';
import 'package:gobox/model/order.dart';
import 'package:gobox/views/order/detail.dart'; 
import 'package:gobox/views/widgets/bnavbar.dart';

const Color goBox = Color(0xFF4CAF50);

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final OrderController controller = OrderController();
  List<OrderModel> allOrders = [];
  List<OrderModel> filteredOrders = [];
  bool loading = true;
  String? idMitra;
  
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // ===================================
  // LOGIC INITIALIZATION & DATA FETCHING
  // ===================================

  Future<void> _initializeApp() async {
    await _loadMitraId();
    await _loadOrders();
  }
  
  Future<void> _loadMitraId() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      final userJson = jsonDecode(userString) as Map<String, dynamic>;
      final possibleKeys = ['id_mitra', 'idMitra', 'id', 'id_user', 'idUser'];
      
      for (var key in possibleKeys) {
        if (userJson.containsKey(key) && userJson[key] != null) {
          idMitra = userJson[key].toString();
          break;
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadOrders({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() => loading = true);
    }

    if (idMitra == null) {
      if (mounted) {
        setState(() {
          loading = false;
          allOrders = [];
          filteredOrders = [];
        });
      }
      return;
    }

    try {
      final orders = await controller.getOrdersMitra(idMitra!);
      if (mounted) {
        setState(() {
          allOrders = orders;
          filteredOrders = orders;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data order: $e'), backgroundColor: Colors.red),
        );
        setState(() {
          loading = false;
          allOrders = [];
          filteredOrders = [];
        });
      }
    }
  }

  // ===================================
  // LOGIC SEARCH & UTILITY
  // ===================================

  void onSearch(String q) {
    final query = q.toLowerCase().trim();
    setState(() {
      filteredOrders = allOrders.where((o) {
        final namaPelanggan = o.pelanggan?.nama.toLowerCase() ?? '';
        final idOrder = o.idOrder.toString();
        return namaPelanggan.contains(query) || idOrder.contains(query);
      }).toList();
    });
  }

  Color statusColor(String status) {
    final s = status.toLowerCase();
    switch (s) {
      case 'diterima':
        return Colors.green.shade600;
      case 'ditolak':
        return Colors.red.shade600;
      case 'diproses':
        return goBox; // Menggunakan warna GoBox untuk status sedang diproses
      case 'menunggu':
      default:
        return Colors.orange.shade700;
    }
  }

  // ===================================
  // WIDGET BUILDER
  // ===================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Order', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: goBox,
        elevation: 1,
      ),
      body: _buildBody(),
      bottomNavigationBar: const Bnavbar(currentIndex: 2),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: goBox));
    }
    
    if (idMitra == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Informasi Mitra tidak ditemukan. Harap login kembali.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade700, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: goBox),
              hintText: 'Cari nama pelanggan atau ID order...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: goBox.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: goBox, width: 2),
              ),
            ),
            onChanged: onSearch,
          ),
        ),
        
        // List Orders (Pull-to-Refresh)
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadOrders,
            color: goBox,
            child: filteredOrders.isEmpty && allOrders.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada order untuk Mitra ini.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                : filteredOrders.isEmpty
                    ? const Center(
                        child: Text(
                          'Order tidak ditemukan dalam pencarian.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, i) {
                          final o = filteredOrders[i];
                          return _buildOrderCard(o);
                        },
                      ),
          ),
        ),
      ],
    );
  }

  // Widget untuk menampilkan tiap item Order
  Widget _buildOrderCard(OrderModel o) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailPage(order: o),
            ),
          );
          if (shouldRefresh == true) {
            _loadOrders(showLoading: false); 
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID Order & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${o.idOrder}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: goBox)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor(o.status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      o.status.toUpperCase(), 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)
                    ),
                  )
                ],
              ),
              const Divider(height: 16),

              // Detail Order
              _buildDetailRow(Icons.person_rounded, 'Pelanggan', o.pelanggan?.nama ?? "-"),
              _buildDetailRow(Icons.location_on_rounded, 'Lokasi Gudang', o.lokasi?.namaLokasi ?? "-"),
              _buildDetailRow(Icons.calendar_month_rounded, 'Tgl Titip', o.tanggalPenitipan),
              _buildDetailRow(Icons.calendar_month_rounded, 'Tgl Ambil', o.tanggalPengambilan),
              const SizedBox(height: 10),
              
              // Footer: Jumlah Barang & Total Harga
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📦 ${o.jumlahItem} Item', 
                    style: const TextStyle(fontSize: 14, color: Colors.black87)
                  ),
                  Text(
                    'Total: ${currencyFormatter.format(o.totalHarga)}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: goBox)
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper Widget untuk baris detail
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}