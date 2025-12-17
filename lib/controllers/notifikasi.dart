import 'dart:convert';
import 'package:gobox/controllers/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gobox/model/notifikasi.dart';
import 'http.dart'

class NotificationService {
  final String baseUrl = httpss;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<AppNotification>> fetchNotifications({
    required int idUser,
    required bool autoRead,
  }) async {
    final token = await _getToken();
    

    final res = await http.post(
      Uri.parse('$baseUrl/notifikasi'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_user': idUser,
        'user_type': 'mitra',
        'auto_read': autoRead,
      }),
    );

    if (res.statusCode != 200) {
      print(idUser);
      print(autoRead);
      print(res.headers);
      print(res.statusCode);
      print(res.body);
      print(res.statusCode);
      throw Exception('Gagal ambil notifikasi');
    }

    final decoded = jsonDecode(res.body);
    print(decoded);
    final List data = decoded['data'];

    return data.map((e) => AppNotification.fromJson(e)).toList();
  }
}
