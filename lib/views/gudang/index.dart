import 'dart:io'; // Penting untuk File
import 'package:flutter/material.dart';
import 'package:gobox/controllers/gudang.dart';
import 'package:gobox/controllers/auth.dart';
import 'package:gobox/views/widgets/bnavbar.dart';
import 'add.dart';
import 'detail.dart';
class ManajemenGudangPage extends StatefulWidget {
  const ManajemenGudangPage({super.key});

  @override
  State<ManajemenGudangPage> createState() => _ManajemenGudangPageState();
}

class _ManajemenGudangPageState extends State<ManajemenGudangPage> {
  String filter = "gudang"; 
  String idUser = '';

  List<dynamic> lokasiList = [];
  List<dynamic> filteredLokasi = [];

  List<dynamic> barangList = [];
  List<dynamic> filteredBarang = [];

  final TextEditingController searchController = TextEditingController();

  Future<void> loadData() async {
    final controller = ManagemenGudang();

    lokasiList = await controller.getLokasiMitra(idUser);
    barangList = await controller.getJenisBarang(idUser);

    if (filter == "gudang") {
      filteredLokasi = List.from(lokasiList);
    } else {
      filteredBarang = List.from(barangList);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initSetup();
    searchController.addListener(filterSearch);
  }

  Future<void> initSetup() async {
    final user = await AuthController().getUser();
    if (user == null) return;
    idUser = user.idUser.toString(); 
    await loadData();
  }

  void filterSearch() {
    String q = searchController.text.toLowerCase();

    if (filter == "gudang") {
      filteredLokasi = lokasiList.where((item) {
        final name = (item["nama_lokasi"] ?? "").toString().toLowerCase();
        return name.contains(q);
      }).toList();
    } else {
      filteredBarang = barangList.where((item) {
        final name = item["jenis_barang"].toString().toLowerCase();
        return name.contains(q);
      }).toList();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Gudang"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemForm(
                type: filter, // "gudang" atau "harga"
                onSubmit: (data) async {
                  final controller = ManagemenGudang();
                  bool success = false;

                  if (filter == "gudang") {
                    success = await controller.addLokasiMitra(
                      idMitra: idUser,
                      namaLokasi: data['nama_lokasi'],
                      deskripsi: data['deskripsi'] ?? '',
                      imageFile: data['path_area'] as File,
                    );
                  } else {
                    success = await controller.addJenisBarang(
                      idMitra: idUser,
                      jenisBarang: data['jenis_barang'],
                      hargaSewa: data['harga_sewa'].toString(),
                    );
                  }

                  if (success) {
                    Navigator.pop(context);
                    await loadData(); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Berhasil menyimpan data")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gagal menyimpan data")),
                    );
                  }
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SEARCH FIELD
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Cari...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // FILTER BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                filterButton("gudang", "Gudang"),
                const SizedBox(width: 10),
                filterButton("harga", "Harga Sewa Barang"),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: filter == "gudang"
                  ? ListView(
                      children: filteredLokasi
                          .map((e) => gudangCard(e))
                          .toList(),
                    )
                  : ListView(
                      children: filteredBarang
                          .map((e) => hargaBarangCard(e))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Bnavbar(currentIndex: 1),
    );
  }

  Widget filterButton(String name, String label) {
    bool active = filter == name;

    return ElevatedButton(
      onPressed: () async {
        if (filter != name) {
          setState(() {
            filter = name;
          });
          await loadData(); // load ulang data sesuai filter
          filterSearch(); // apply search jika ada text
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? Colors.blue : Colors.grey[300],
        foregroundColor: active ? Colors.white : Colors.black,
      ),
      child: Text(label),
    );
  }

  // Di ManajemenGudangPage
Widget gudangCard(dynamic item) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailGudangPage(
              idLokasi: item['id_lokasi'].toString(),
            ),
          ),
        );
      },
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item['path_area'] ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.image_not_supported, size: 40),
          ),
        ),
        title: Text(
          item['nama_lokasi'] ?? '-',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(item['deskripsi'] ?? '-'),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
      ),
    ),
  );
}


  Widget hargaBarangCard(dynamic item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          item['jenis_barang'] ?? '-',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Rp ${item['harga_sewa']}"),
        trailing: const Icon(Icons.edit, size: 20),
      ),
    );
  }
}
