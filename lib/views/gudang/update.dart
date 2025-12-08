import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gobox/controllers/gudang.dart';

class EditItemForm extends StatefulWidget {
  final String type; 
  final Map<String, dynamic> initialData;
  final String idUser; 
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
            : widget.initialData["jenis_barang"]);
    
    descController =
        TextEditingController(text: widget.initialData["deskripsi"] ?? "");
    priceController =
        TextEditingController(text: widget.initialData["harga_sewa"]?.toString() ?? "");
  }

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

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    bool success = false;
    

    if (widget.type == "gudang") {
      success = await managemenGudang.updateLokasi(
        idLokasi: widget.initialData["id_lokasi"].toString(),
        namaLokasi: nameController.text,
        deskripsi: descController.text,
        imageFile: pickedImage,
        latitude: widget.initialData["latitude"]?.toString(),
        longitude: widget.initialData["longitude"]?.toString(),

      );
    } else if (widget.type == "harga") {
        success= await managemenGudang.editJenisBarang(
          jenisBarang: nameController.text,
          hargaSewa: priceController.text,
          idJenisBarang: widget.initialData["id_jenis_barang"].toString()
        );
      }

    setState(() => loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil diperbarui!')),

      );
    if (widget.onUpdate != null) widget.onUpdate!();
        Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui, coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == "gudang" ? "Edit Lokasi" : "Edit Jenis Barang"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: widget.type == "gudang" ? "Nama Lokasi" : "Jenis Barang",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 12),

              if (widget.type == "gudang") ...[
                
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: "Deskripsi",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
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
                        : widget.initialData["path_area"] != null
                            ? Image.network(widget.initialData["path_area"], fit: BoxFit.cover)
                            : const Center(child: Text("Pilih Gambar")),
                  ),
                ),
                if (imageError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(imageError!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 12),
              ],

              if (widget.type == "harga") ...[
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Harga Sewa",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Tidak boleh kosong" : null,
                ),
                const SizedBox(height: 20),
              ],

              ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
