import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gobox/controllers/auth.dart';
import 'package:gobox/controllers/profil.dart';
import 'package:gobox/model/user.dart';

// --- WARNA KHUSUS ---
const Color primaryColor = Colors.green;
const Color accentColor = Color(0xFFE8F5E9); // Hijau muda

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;

  final _nama = TextEditingController();
  final _alamat = TextEditingController();
  final _nomorHp = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? imageFile;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    user = await AuthController().getUser();
    if (user != null) {
      _nama.text = user!.nama;
      _alamat.text = user!.alamat ?? "";
      _nomorHp.text = user!.nomorHp ?? "";
    }
    setState(() {});
  }

  Future<void> pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => imageFile = File(img.path));
    }
  }

  Future<void> updateProfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final res = await ProfilController().updateProfile(
      nama: _nama.text,
      alamat: _alamat.text,
      nomorHp: _nomorHp.text,
      password: _password.text.isEmpty ? null : _password.text,
      imageFile: imageFile,
      idUser: user!.idUser,
    );

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));

    if (res == "Profil berhasil diperbarui") {
      await loadUser();
      // Reset password field setelah berhasil update
      _password.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pengaturan Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. FOTO PROFIL (Dengan Tombol Edit)
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: accentColor,
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!)
                          : (user!.pathProfil != null
                                    ? NetworkImage(user!.pathProfil!)
                                    : const AssetImage("assets/default.png"))
                                as ImageProvider,
                      child: imageFile == null && user!.pathProfil == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: primaryColor,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 2. INPUT FIELD NAMA
              _buildTextField(
                controller: _nama,
                label: "Nama Lengkap",
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 15),

              // 3. INPUT FIELD EMAIL (READ ONLY)
              _buildTextField(
                controller: TextEditingController(text: user!.email ?? ""),
                label: "Email",
                icon: Icons.email_outlined,
                readOnly: true,
                suffixIcon: Icons.lock_outline,
                validator: (v) => null, // Tidak perlu validasi karena read-only
              ),
              const SizedBox(height: 15),

              // 4. INPUT FIELD ALAMAT
              _buildTextField(
                controller: _alamat,
                label: "Alamat",
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (v) =>
                    v!.isEmpty ? "Alamat tidak boleh kosong" : null,
              ),
              const SizedBox(height: 15),

              // 5. INPUT FIELD NOMOR HP
              _buildTextField(
                controller: _nomorHp,
                label: "Nomor HP",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v!.isEmpty ? "Nomor HP tidak boleh kosong" : null,
              ),
              const SizedBox(height: 15),

              // 6. INPUT FIELD PASSWORD BARU
              _buildTextField(
                controller: _password,
                label: "Password Baru (Kosongkan jika tidak diubah)",
                icon: Icons.lock_reset_outlined,
                obscureText: true,
              ),
              const SizedBox(height: 30),

              // 7. TOMBOL UPDATE (Lebar Penuh)
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : updateProfil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "SIMPAN PERUBAHAN",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  // --- WIDGET HELPER UNTUK TEXT FIELD REUSABLE ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    bool obscureText = false,
    IconData? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.grey)
            : null,
        filled: true,
        fillColor: readOnly ? accentColor.withOpacity(0.5) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600),
      ),
      validator: validator,
    );
  }
}
