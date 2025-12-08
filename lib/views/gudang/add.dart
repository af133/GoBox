import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  File? pickedImage;
  String? imageError;

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      final bytes = await file.length();

      if (bytes > 2 * 1024 * 1024) {
        setState(() {
          pickedImage = null;
          imageError = "Ukuran gambar maksimal 2 MB";
        });
        return;
      }

      setState(() {
        pickedImage = file;
        imageError = null;
      });
    }
  }
  void submit() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.type == "gudang" && pickedImage == null) {
      setState(() {
        imageError = "Silakan pilih gambar gudang";
      });
      return;
    }

    Map<String, dynamic> data = {};
    if (widget.type == "gudang") {
      data = {
        "nama_lokasi": nameController.text,
        "deskripsi": descController.text,
        "path_area": pickedImage,
      };
    } else if (widget.type == "harga") {
      data = {
        "jenis_barang": nameController.text,
        "harga_sewa": int.tryParse(priceController.text) ?? 0,
      };
    }

    widget.onSubmit(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == "gudang" ? "Tambah Lokasi" : "Tambah Harga Barang"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nama Lokasi / Jenis Barang
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: widget.type == "gudang" ? "Nama Lokasi" : "Jenis Barang",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 12),

              if (widget.type == "gudang") const SizedBox(height: 12),
              if (widget.type == "gudang")
                TextFormField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: "Deskripsi",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              if (widget.type == "gudang") const SizedBox(height: 12),

              if (widget.type == "gudang")
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: pickedImage != null
                        ? Image.file(pickedImage!, fit: BoxFit.cover)
                        : const Center(child: Text("Pilih Gambar")),
                  ),
                ),
              if (widget.type == "gudang" && imageError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    imageError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (widget.type == "gudang") const SizedBox(height: 12),

              if (widget.type == "harga")
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Harga Sewa",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Tidak boleh kosong" : null,
                ),
              if (widget.type == "harga") const SizedBox(height: 20),

              ElevatedButton(
                onPressed: submit,
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
