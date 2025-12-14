import 'package:flutter/material.dart';
import 'package:gobox/controllers/penarikan.dart';
import 'package:intl/intl.dart';

// --- DEFINISI WARNA ---
const Color primaryColor = Colors.green;

class SaldoAddPage extends StatefulWidget {
  final int idMitra;

  const SaldoAddPage({super.key, required this.idMitra});

  @override
  State<SaldoAddPage> createState() => _SaldoAddPageState();
}

class _SaldoAddPageState extends State<SaldoAddPage> {
  final SaldoService service = SaldoService();
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController alasanController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    jumlahController.dispose();
    alasanController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    final jumlah = int.tryParse(jumlahController.text.replaceAll('.', ''));

    try {
      await service.createPenarikan(
        idMitra: widget.idMitra,
        jumlah: jumlah!,
        tanggal: selectedDate.toIso8601String(),
        alasan: alasanController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Pengajuan penarikan berhasil dibuat!")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Gagal membuat pengajuan: $e")));
    }
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Ajukan Penarikan Dana",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detail Penarikan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20),

              // JUMLAH
              TextFormField(
                controller: jumlahController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: "Jumlah Penarikan (Rp)",
                  prefixText: "Rp ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  final amount = int.tryParse(value?.replaceAll('.', '') ?? '');
                  if (amount == null || amount <= 0) {
                    return "Jumlah penarikan harus diisi";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ALASAN
              TextFormField(
                controller: alasanController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Alasan Penarikan (Opsional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // TANGGAL
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                leading: const Icon(Icons.calendar_today, color: primaryColor),
                title: const Text("Tanggal Pengajuan"),
                subtitle: Text(
                  DateFormat(
                    'EEEE, dd MMMM yyyy',
                    'id_ID',
                  ).format(selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.edit, color: primaryColor),
                onTap: pickDate,
              ),
              const SizedBox(height: 30),

              // SUBMIT
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: submit,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    "AJUKAN PENARIKAN",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
