import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:image_picker/image_picker.dart';

const Color goBox = Color(0xFF4CAF50);

class AddItemForm extends StatefulWidget {
  final String type;
  final Function(Map<String, dynamic>) onSubmit;

  const AddItemForm({
    super.key,
    required this.type,
    required this.onSubmit,
  });

  @override
  State<AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  File? pickedImage;
  String? imageError;

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    super.dispose();
  }

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

  void submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.type == "gudang" && pickedImage == null) {
      setState(() {
        imageError = "Silakan pilih gambar gudang";
      });
      return;
    }
    
    if (widget.type == "gudang" && pickedImage != null && imageError != null) {
        setState(() {
          imageError = null;
        });
    }

    Map<String, dynamic> data = {};
    if (widget.type == "gudang") {
      data = {
        "nama_lokasi": nameController.text.trim(),
        "deskripsi": descController.text.trim(),
        "path_area": pickedImage,
      };
    } else if (widget.type == "harga") {
      final int hargaSewa = int.tryParse(priceController.text.trim()) ?? 0;
      data = {
        "jenis_barang": nameController.text.trim(),
        "harga_sewa": hargaSewa,
      };
    }

    widget.onSubmit(data);
  }

  @override
  Widget build(BuildContext context) {
    final bool isGudang = widget.type == "gudang";
    final String title = isGudang ? "Tambah Lokasi Gudang" : "Tambah Harga Barang";

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              _buildNameInput(isGudang),
              const SizedBox(height: 16),

              if (isGudang) 
                _buildGudangFields()
              else 
                _buildHargaFields(),

              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goBox,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "SIMPAN DATA",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameInput(bool isGudang) {
    return TextFormField(
      controller: nameController,
      decoration: InputDecoration(
        labelText: isGudang ? "Nama Lokasi Gudang" : "Jenis Barang",
        hintText: isGudang ? "Masukkan nama lokasi" : "Contoh: Pallet Kayu",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(isGudang ? Icons.warehouse_rounded : Icons.category_rounded, color: goBox),
      ),
      validator: (v) => v == null || v.trim().isEmpty ? "Input tidak boleh kosong" : null,
    );
  }

  Widget _buildGudangFields() {
    return Column(
      children: [
        // Deskripsi
        TextFormField(
          controller: descController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "Deskripsi Lokasi (Opsional)",
            hintText: "Contoh: Gudang kering, berpendingin, area bongkar muat luas.",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 40.0, left: 0),
              child: Icon(Icons.description_rounded, color: goBox),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                child: pickedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(pickedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_rounded, color: goBox, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            "Ketuk untuk Pilih Gambar",
                            style: TextStyle(color: goBox, fontWeight: FontWeight.w600),
                          ),
                        ],
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
        ),
      ],
    );
  }

  Widget _buildHargaFields() {
    return Column(
      children: [
        TextFormField(
          controller: priceController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: "Harga Sewa per Satuan (Angka Saja)",
            hintText: "Contoh: 50000",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixText: 'Rp ', 
            prefixIcon: const Icon(Icons.payments_rounded, color: goBox),
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