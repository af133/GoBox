// Dashboard.dart
import "package:flutter/material.dart";
import "package:gobox/controllers/order.dart";
import 'package:gobox/controllers/auth.dart';
// Pastikan import ini menunjuk ke AppbarHome yang baru Anda modifikasi
import "package:gobox/views/widgets/app_bar.dart";
import 'package:gobox/views/widgets/bnavbar.dart';
import 'package:gobox/controllers/notifikasi.dart';
import 'package:gobox/model/notifikasi.dart';

// Asumsi warna goBox (Hijau Primer GoBox)
const Color goBox = Color(0xFF4CAF50);

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int? idUser;
  String? nama;
  String? pathProfil;

  Map<String, dynamic>? dashboardData;
  bool loading = true;

  List<AppNotification> notif = [];
  int countUnRead = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await getUser();
    if (idUser != null) {
      await fetchData();
      await getNotifikasi();
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> getUser() async {
    final user = await AuthController().getUser();
    if (user == null) return;

    setState(() {
      idUser = user.idUser;
      nama = user.nama;
      pathProfil = user.pathProfil;
    });
  }

  Future<void> getNotifikasi() async {
    if (idUser == null) return ;
    final service = NotificationService();

    final List<AppNotification> data = await service.fetchNotifications(
      idUser: idUser!,
      autoRead: false,
    );

    setState(() {
      notif = data;
      countUnRead = data.where((n) => !n.isRead).length;
    });
  }

  Future<void> fetchData() async {
    final data = await OrderController().showDashboard(idUser: idUser!);

    setState(() {
      dashboardData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // Panggil AppbarHome yang sudah dimodifikasi
      appBar: AppbarHome(
        name: nama ?? 'Mitra',
        pathProfil: pathProfil,
        idUser: idUser!,
        countUnRead: countUnRead,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: goBox))
          : RefreshIndicator(
              onRefresh: init,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ROW CARD SUMMARY (Menggunakan desain modern yang dibuat sebelumnya)
                    _buildSummaryCard(context),

                    const SizedBox(height: 20),

                    // HEADER ORDER TERBARU
                    Text(
                      "Order Terbaru",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // LIST ORDER TERBARU
                    _buildOrderNowList(dashboardData?['orderanNow'] ?? []),
                  ],
                ),
              ),
            ),
      // Panggil Bnavbar yang sudah dimodifikasi (currentIndex: 0 untuk Home)
      bottomNavigationBar: const Bnavbar(currentIndex: 0),
    );
  }

  // --- WIDGET HELPER DASHBOARD (Dipertahankan dari perbaikan sebelumnya) ---

  Widget _buildSummaryCard(BuildContext context) {
    final totalOrders = dashboardData?['total_orders'].toString() ?? "0";
    final totalPenghasilan =
        dashboardData?['total_penghasilan'].toString() ?? "0";
    final saldoTersedia = dashboardData?['saldo_tersedia'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CARD TOTAL ORDER
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [goBox.withValues(alpha: 0.05), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Penghasilan",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalPenghasilan,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: goBox,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.payments_rounded,
                color: goBox.withValues(alpha: 0.8),
                size: 40,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // CARD PENGHASILAN & SALDO
        Row(
          children: [
            Expanded(
              child: _buildStatsItem(
                title: "Total Order",
                value: totalOrders,
                icon: Icons.shopping_cart_rounded,
                color: goBox,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatsItem(
                title: "Saldo Tersedia",
                value: "Rp ${saldoTersedia}",
                icon: Icons.account_balance_wallet_rounded,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Icon(icon, color: color.withValues(alpha: 0.7), size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderNowList(List orders) {
    if (orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            "Belum ada order terbaru.",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Column(
      children: orders.map((order) {
        final status = order['status'] ?? '-';

        Color statusColor;
        Color statusBgColor;

        if (status.toString().toLowerCase() == "diterima") {
          statusColor = Colors.green.shade700;
          statusBgColor = Colors.green.shade100;
        } else if (status.toString().toLowerCase() == "pending") {
          statusColor = Colors.orange.shade700;
          statusBgColor = Colors.orange.shade100;
        } else {
          statusColor = Colors.red.shade700;
          statusBgColor = Colors.red.shade100;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: goBox.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_shipping_rounded, color: goBox),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${order['id_order'] ?? '-'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tanggal Penitipan: ${order['tanggal_penitipan'] ?? "-"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
