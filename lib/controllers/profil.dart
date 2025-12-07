import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilController {
  final String baseUrl = "http://backend_go_box.test/api";
  Future<String> updateProfile({
    required String nama,
    String? alamat,
    String? nomorHp,
    String? password,
    File? imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/profile/update"),
      );

      request.headers['Authorization'] = "Bearer $token";

      request.fields['nama'] = nama;
      if (alamat != null) {
        request.fields['alamat'] = alamat;
      }
      if (nomorHp != null) {
        request.fields['nomor_hp'] = nomorHp;
      }

      if (password != null && password.trim().isNotEmpty) {
        request.fields['password'] = password;
      }

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('path_profil', imageFile.path),
        );
      }

      var response = await request.send();
      var body = await response.stream.bytesToString();
      var data = jsonDecode(body);

      if (response.statusCode == 200) {
        await prefs.setString("user", jsonEncode(data['user']));
        return "Profil berhasil diperbarui";
      }
      return data['message'] ?? "Gagal update";
    } catch (e) {
      return "Error: $e";
    }
  }
}
