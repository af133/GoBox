import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'http.dart';

class ProfilController {
  final String baseUrl = httpss;
  
  Future<String> updateProfile({
    required String nama,
    String? alamat,
    String? nomorHp,
    String? password,
    File? imageFile,
    String role = 'mitra',
    int? idUser,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/profile/update"),
      );

      request.headers['Authorization'] = "Bearer $token";
      request.fields['nama'] = nama;
      request.fields['role'] = role;
      request.fields['id_user'] = idUser.toString();

      if (alamat != null) request.fields['alamat'] = alamat;
      if (nomorHp != null) request.fields['nomor_hp'] = nomorHp;
      if (password != null && password.trim().isNotEmpty) {
        request.fields['password'] = password;
      }

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('path_profil', imageFile.path),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      if (response.statusCode == 200) {
        await prefs.setString("user", jsonEncode(data['user']));
        return "Profil berhasil diperbarui";
      }

      return data['message'] ?? "Gagal update";
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ UPDATE PROFILE ERROR: $e');
      }
      return "Error: $e";
    }
  }
}