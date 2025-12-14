import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gobox/controllers/penarikan.dart';
import 'package:gobox/model/penarikan.dart';
import 'package:gobox/controllers/auth.dart';
import 'package:gobox/views/widgets/bnavbar.dart';
import 'penarikan.dart';

// --- DEFINISI WARNA KHUSUS ---
const Color primaryColor = Colors.green; // Warna utama aplikasi
const Color pemasukanColor = Colors.green;
const Color pengeluaranColor = Colors.red;
const Color backgroundLight = Color(0xFFF7F7F7); // Latar belakang abu-abu muda

class SaldoIndexPage extends StatefulWidget {
  const SaldoIndexPage({super.key});

  @override
  State<SaldoIndexPage> createState() => _SaldoIndexPageState();
}

class _SaldoIndexPageState extends State<SaldoIndexPage> {
  final SaldoService service = SaldoService();
  final MaterialColor primaryColor = MaterialColor(0xFF2ECC71, <int, Color>{
    50: Color(0xFFE9F9F0),
    100: Color(0xFFC8F0DA),
    200: Color(0xFFA5E7C2),
    300: Color(0xFF82DEAA),
    400: Color(0xFF5FD592),
    500: Color(0xFF2ECC71),
    600: Color(0xFF27B863),
    700: Color(0xFF22A455),
    800: Color(0xFF1D9047),
    900: Color(0xFF167A39),
  });
  late int idMitra;
  late Future<List<Saldo>> saldoFuture;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final user = await AuthController().getUser();
    if (user == null) return;

    idMitra = user.idUser!; // pastikan idUser = idMitra
    saldoFuture = service.getSaldo(idMitra);

    setState(() {
      isLoading = false;
    });
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // 1. Loading Indicator dengan warna primer
      return Scaffold(
        backgroundColor: backgroundLight,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundLight,
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Riwayat Transaksi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          Expanded(
            // 3. DAFTAR RIWAYAT SALDO
            child: FutureBuilder<List<Saldo>>(
              future: saldoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final saldoList = snapshot.data ?? [];
                if (saldoList.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada riwayat transaksi.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  itemCount: saldoList.length,
                  itemBuilder: (context, index) {
                    final s = saldoList[index];
                    return _buildTransactionItem(s);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Bnavbar(currentIndex: 4),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SaldoAddPage(idMitra: idMitra),
            ),
          ).then((_) {
            // refresh saldo setelah kembali dari halaman tambah
            setState(() {
              saldoFuture = service.getSaldo(idMitra);
            });
          });
        },
        backgroundColor: primaryColor, // FAB berwarna hijau
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- WIDGET UNTUK TAMPILAN RIWAYAT TRANSAKSI (ITEM LIST) ---
  Widget _buildTransactionItem(Saldo s) {
    final bool isPemasukan = s.type == 'pemasukan';
    final Color itemColor = isPemasukan ? pemasukanColor : pengeluaranColor;

    // Format jumlah Rp
    final formattedJumlah = formatCurrency(s.jumlah.toDouble());

    // Format tanggal
    final formattedTanggal = DateFormat(
      'dd MMM yyyy',
    ).format(DateTime.parse(s.tanggal));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ikon Pemasukan/Pengeluaran
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: itemColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPemasukan
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: itemColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),

          // Detail Transaksi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPemasukan ? "Pemasukan Saldo" : "Penarikan Dana",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tanggal: $formattedTanggal",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  "Status: ${s.status}",
                  style: TextStyle(
                    color: s.status.toLowerCase() == 'berhasil'
                        ? pemasukanColor
                        : pengeluaranColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Jumlah Saldo
          Text(
            formattedJumlah,
            style: TextStyle(
              color: itemColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
