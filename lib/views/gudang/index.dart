import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gobox/controllers/gudang.dart';
import 'package:gobox/controllers/auth.dart';
import 'package:gobox/views/widgets/bnavbar.dart';
import 'add.dart';
import 'update.dart';
import 'detail.dart';

const Color goBox = Color(0xFF4CAF50);

class ManajemenGudangPage extends StatefulWidget {
  const ManajemenGudangPage({super.key});

  @override
  State<ManajemenGudangPage> createState() => _ManajemenGudangPageState();
}

class _ManajemenGudangPageState extends State<ManajemenGudangPage> {
  String filter = "gudang"; 
  String idUser = '';
  bool isLoading = true;

  List<dynamic> lokasiList = [];
  List<dynamic> filteredLokasi = [];

  List<dynamic> barangList = [];
  List<dynamic> filteredBarang = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSetup();
    searchController.addListener(filterSearch);
  }

  @override
  void dispose() {
    searchController.removeListener(filterSearch);
    searchController.dispose();
    super.dispose();
  }

  Future<void> initSetup() async {
    final user = await AuthController().getUser();
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    idUser = user.idUser.toString();
    await loadData();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadData() async {
    final controller = ManagemenGudang();

    if (idUser.isEmpty) return;

    final loadedLokasi = await controller.getLokasiMitra(idUser);
    final loadedBarang = await controller.getJenisBarang(idUser);

    setState(() {
      lokasiList = loadedLokasi;
      barangList = loadedBarang;
    });

    filterSearch();
  }

  void filterSearch() {
    String q = searchController.text.toLowerCase();

    setState(() {
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
    });
  }

  void showSnackBar(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? goBox : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Manajemen Gudang",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddItem(),
        backgroundColor: goBox,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: const Icon(Icons.add_rounded, size: 30),
      ),

      body: RefreshIndicator(
        onRefresh: loadData,
        color: goBox,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SEARCH FIELD 
              _buildSearchField(),

              const SizedBox(height: 16),

              // FILTER BUTTONS
              _buildFilterButtons(),

              const SizedBox(height: 16),

              // LIST DATA
              Expanded(
                child: isLoading 
                    ? const Center(child: CircularProgressIndicator(color: goBox))
                    : _buildDataList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Bnavbar(currentIndex: 1),
    );
  }
  
  // --- WIDGET BUILDER ---

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: "Cari ${filter == "gudang" ? "nama gudang" : "jenis barang"}...",
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: goBox, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _filterButton("gudang", "Gudang"),
          _filterButton("harga", "Harga Sewa Barang"),
        ],
      ),
    );
  }

  Widget _filterButton(String name, String label) {
    bool active = filter == name;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (filter != name) {
            setState(() {
              filter = name;
              searchController.clear();
            });
            filterSearch();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? goBox : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: goBox.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.black87,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataList() {
    final list = filter == "gudang" ? filteredLokasi : filteredBarang;
    final emptyMessage = filter == "gudang" 
        ? "Anda belum menambahkan lokasi gudang." 
        : "Anda belum menambahkan jenis barang atau harga sewa.";

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return filter == "gudang"
            ? _gudangCard(item)
            : _hargaBarangCard(item);
      },
    );
  }

  // Card Gudang - Stylish
  Widget _gudangCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailGudangPage(
                idLokasi: item['id_lokasi'].toString(),
              ),
            ),
          ).then((_) => loadData()); 
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Gambar/Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item['path_area'] ?? '',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.warehouse_rounded, size: 40, color: goBox),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nama_lokasi'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['deskripsi'] ?? 'Tanpa deskripsi',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hargaBarangCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditItemForm(
                type: 'harga',
                initialData: item,
                idUser: idUser,
                onUpdate: () async {
                  await loadData();
                  showSnackBar("Harga barang berhasil diperbarui.", success: true);
                },
              ),
            ),
          );
          
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_rounded, color: goBox, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['jenis_barang'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Harga Sewa per unit",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                "Rp ${item['harga_sewa'] ?? 0}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: goBox,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit_rounded, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Logic Navigasi ke Form Tambah Item
  void _navigateToAddItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddItemForm(
          type: filter,
          onSubmit: (data) async {
            final controller = ManagemenGudang();
            bool success = false;
            String message;

            if (filter == "gudang") {
              success = await controller.addLokasiMitra(
                idMitra: idUser,
                namaLokasi: data['nama_lokasi'],
                deskripsi: data['deskripsi'] ?? '',
                imageFile: data['path_area'] as File,
              );
              message = success ? "Lokasi gudang berhasil ditambahkan." : "Gagal menambahkan lokasi gudang.";
            } else {
              success = await controller.addJenisBarang(
                idMitra: idUser,
                jenisBarang: data['jenis_barang'],
                hargaSewa: data['harga_sewa'].toString(),
              );
              message = success ? "Jenis barang berhasil ditambahkan." : "Gagal menambahkan jenis barang.";
            }

            if (mounted) {
              Navigator.pop(context);
              if (success) {
                await loadData();
              }
              showSnackBar(message, success: success);
            }
          },
        ),
      ),
    );
  }
}