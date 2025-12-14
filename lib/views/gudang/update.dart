import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gobox/controllers/gudang.dart';

// Asumsi warna GoBox (Hijau Primer)
const Color goBox = Color(0xFF4CAF50);

class EditItemForm extends StatefulWidget {
  final String type; 
  final Map<String, dynamic> initialData;
  final String idUser; // idUser tidak digunakan di sini, tapi dipertahankan
  final VoidCallback? onUpdate;

  const EditItemForm({
    super.key,
    required this.type,
    required this.initialData,
    required this.idUser,
    this.onUpdate,
  });

  @override
  State<EditItemForm> createState() => _EditItemFormState();
}

class _EditItemFormState extends State<EditItemForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController priceController;

  File? pickedImage;
  String? imageError;
  bool loading = false;

  final managemenGudang = ManagemenGudang();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.type == "gudang"
          ? widget.initialData["nama_lokasi"]
          : widget.initialData["jenis_barang"],
    );
    
    descController =
        TextEditingController(text: widget.initialData["deskripsi"] ?? "");
        
    // Pastikan harga_sewa adalah string dari int/double, atau kosong.
    priceController = TextEditingController(
      text: widget.initialData["harga_sewa"]?.toString() ?? "",
    );
  }
  
  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // ===================================
  // LOGIC PICK IMAGE
  // ===================================
  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final file = File(image.path);
      final bytes = await file.length();
      const int maxFileSizeMB = 2;

      if (bytes > maxFileSizeMB * 1024 * 1024) {
        if (mounted) {
          setState(() {
            pickedImage = null;
            imageError = "Ukuran gambar maksimal $maxFileSizeMB MB";
          });
        }
        return;
      }
      
      if (mounted) {
        setState(() {
          pickedImage = file;
          imageError = null;
        });
      }
    }
  }

  // ===================================
  // LOGIC SUBMIT FORM
  // ===================================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.type == "harga" && (int.tryParse(priceController.text) == null || int.parse(priceController.text) <= 0)) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga Sewa harus berupa angka positif yang valid.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => loading = true);

    bool success = false;
    String message = 'Berhasil diperbarui!';

    try {
      if (widget.type == "gudang") {
        success = await managemenGudang.updateLokasi(
          idLokasi: widget.initialData["id_lokasi"].toString(),
          namaLokasi: nameController.text.trim(),
          deskripsi: descController.text.trim(),
          imageFile: pickedImage, // Mengirim File yang baru dipilih
          latitude: widget.initialData["latitude"]?.toString(),
          longitude: widget.initialData["longitude"]?.toString(),
        );
      } else if (widget.type == "harga") {
        success = await managemenGudang.editJenisBarang(
          jenisBarang: nameController.text.trim(),
          hargaSewa: priceController.text.trim(),
          idJenisBarang: widget.initialData["id_jenis_barang"].toString(),
        );
      }
    } catch (e) {
      success = false;
      message = 'Terjadi kesalahan: $e';
    }

    if (!mounted) return;
    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? message : 'Gagal memperbarui: $message'),
        backgroundColor: success ? goBox : Colors.red,
      ),
    );
    
    if (success) {
      widget.onUpdate?.call();
      Navigator.pop(context, true); 
    }
  }

  // ===================================
  // WIDGET BUILDER
  // ===================================

  @override
  Widget build(BuildContext context) {
    final isGudang = widget.type == "gudang";

    return Scaffold(
      appBar: AppBar(
        title: Text(isGudang ? "Edit Lokasi Gudang" : "Edit Jenis Barang", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Nama Lokasi / Jenis Barang
              TextFormField(
                controller: nameController,
                decoration: _inputDecoration(
                  isGudang ? "Nama Lokasi" : "Jenis Barang",
                  isGudang ? Icons.warehouse_rounded : Icons.category_rounded,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? "Input tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              // 2. Fields Khusus
              if (isGudang) 
                _buildGudangFields()
              else 
                _buildHargaFields(),

              const SizedBox(height: 24),
              
              // 3. Tombol Simpan
              ElevatedButton(
                onPressed: loading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goBox,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: loading
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(
                          color: Colors.white, 
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "SIMPAN PERUBAHAN",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Input Decoration
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(icon, color: goBox),
    );
  }

  // Widget Fields Khusus Gudang
  Widget _buildGudangFields() {
    // URL gambar lama (jika ada dan belum ada gambar baru dipilih)
    final String? oldImageUrl = widget.initialData["path_area"];
    final bool isImagePicked = pickedImage != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Deskripsi
        TextFormField(
          controller: descController,
          maxLines: 3,
          decoration: _inputDecoration(
            "Deskripsi Lokasi", 
            Icons.description_rounded,
          ).copyWith(alignLabelWithHint: true),
        ),
        const SizedBox(height: 16),
        
       
        const SizedBox(height: 16),

        // Picker Gambar
        Text("Gambar Gudang (Maks 2 MB)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: pickImage,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(
                color: imageError != null ? Colors.red : Colors.grey.shade400,
                width: imageError != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isImagePicked
                  ? Image.file(pickedImage!, fit: BoxFit.cover) // Gambar baru
                  : oldImageUrl != null && oldImageUrl.isNotEmpty
                      ? Image.network(
                          oldImageUrl, 
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _imagePlaceholder('Gagal memuat gambar lama', Colors.red),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(goBox)));
                          },
                        ) 
                      : _imagePlaceholder('Pilih/Ganti Gambar', goBox), // Placeholder
            ),
          ),
        ),
        
        if (imageError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              "⚠️ $imageError",
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
      ],
    );
  }
  
  Widget _imagePlaceholder(String text, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_rounded, color: color, size: 40),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
  
  

  // Widget Fields Khusus Harga
  Widget _buildHargaFields() {
    return Column(
      children: [
        TextFormField(
          controller: priceController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Hanya izinkan angka
          ],
          decoration: _inputDecoration(
            "Harga Sewa per Satuan (Angka Saja)",
            Icons.payments_rounded,
          ).copyWith(
            prefixText: 'Rp ', 
            hintText: "Contoh: 50000",
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return "Harga sewa tidak boleh kosong";
            }
            if (int.tryParse(v.trim()) == null || int.parse(v.trim()) <= 0) {
              return "Harga harus berupa angka positif";
            }
            return null;
          },
        ),
      ],
    );
  }
}