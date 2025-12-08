import "package:flutter/material.dart";
import "package:gobox/controllers/order.dart";
import 'package:gobox/controllers/auth.dart';
import "package:gobox/views/widgets/app_bar.dart";
import 'package:gobox/views/widgets/bnavbar.dart';
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String idUser = '';
  String? nama ;
  String? pathProfil;
  Map<String, dynamic>? dashboardData;

  @override
  void initState() {
    super.initState();
    init();
  }
  
  Future<void> init() async {
    await getUser();
    await fetchData();
  }

  Future<void> getUser() async {
    final user = await AuthController().getUser();
    if (user == null) return;

    setState(() {
      idUser = user.idUser.toString();
      nama= user.nama;
      pathProfil= user.pathProfil;
    });
  }

  Future<void> fetchData() async {
    final data = await OrderController().showDashboard(idUser: idUser);

    setState(() {
      dashboardData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppbarHome(
          name: nama ?? 'User' ,
          pathProfil:pathProfil ,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CARD TOTAL ORDER
            buildCard(
              title: "Total Order",
              value: dashboardData?['total_orders'].toString() ?? "0",
              icon: Icons.inventory_2,
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            // CARD TOTAL PENGHASILAN
            buildCard(
              title: "Total Penghasilan",
              value: "Rp ${dashboardData?['total_penghasilan'] ?? 0}",
              icon: Icons.payments,
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            // CARD SALDO TERSISA
            buildCard(
              title: "Saldo Tersedia",
              value: "Rp ${dashboardData?['saldo_tersedia'] ?? 0}",
              icon: Icons.account_balance_wallet,
              color: Colors.orange,
            ),

            const SizedBox(height: 20),

            // ORDERAN NOW LIST
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Order Terbaru",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),

            buildOrderNowList(dashboardData?['orderanNow'] ?? []),
          ],
        ),
      ),
      bottomNavigationBar: Bnavbar(currentIndex: 0,),
    );
  }

  Widget buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 14, color: Colors.black54)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget buildOrderNowList(List orders) {
    if (orders.isEmpty) {
      return const Text(
        "Belum ada order terbaru",
        style: TextStyle(fontSize: 14),
      );
    }

    return Column(
      children: orders.map((order) {
        final status = order['status'] ?? '-';

        Color statusColor =
            status.toString().toLowerCase() == "diterima" ? Colors.green : Colors.red;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICON
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_shipping, color: Colors.blue),
              ),
              const SizedBox(width: 12),

              // LEFT TEXT SECTION
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${order['id_order'] ?? '-'}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 6),

                    const Text(
                      'Tanggal Penitipan',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      order['tanggal_penitipan'] ?? "-",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),

              // STATUS
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Pembayaran",
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

}
