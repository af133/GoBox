import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gobox/model/penarikan.dart';
import 'http.dart';

class SaldoService {
  static final SaldoService _instance = SaldoService._internal();
  factory SaldoService() => _instance;
  SaldoService._internal();
  final String baseUrl = httpss;
  String? token;
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  Map<String, String> _headers() => {
    if (token != null) 'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<Saldo>> getSaldo(int idMitra) async {
    await _loadToken();
    final url = '$baseUrl/saldo/$idMitra';
    final res = await http.get(Uri.parse(url), headers: _headers());
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch saldo');
    }
    final jsonBody = jsonDecode(res.body);
    if (jsonBody['data'] == null) {
      return [];
    }
    final data = jsonBody['data'] as List;
    return data.map((e) {
      return Saldo.fromJson(e);
    }).toList();
  }

  Future<Penarikan> createPenarikan({
    required int idMitra,
    required int jumlah,
    required String tanggal,
    String? alasan,
  }) async {
    await _loadToken();

    final url = '$baseUrl/penarikan';
    final headers = _headers();

    final bodyData = {
      'id_mitra': idMitra,
      'jumlah_penarikan': jumlah,
      'tanggal_penarikan': tanggal,
      if (alasan != null) 'alasan_penarikan': alasan,
    };

    /// ================= DEBUG REQUEST =================
    print('🟢 CREATE PENARIKAN REQUEST');
    print('URL      : $url');
    print('Headers  : $headers');
    print('Body     : ${jsonEncode(bodyData)}');

    /// =================================================

    final res = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(bodyData),
    );

    /// ================= DEBUG RESPONSE =================
    print('🔵 CREATE PENARIKAN RESPONSE');
    print('Status   : ${res.statusCode}');
    print('Body     : ${res.body}');

    /// ==================================================

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to create penarikan | Status: ${res.statusCode} | Body: ${res.body}',
      );
    }

    try {
      final decoded = jsonDecode(res.body);

      if (decoded['data'] == null) {
        throw Exception('Response data is null');
      }

      return Penarikan.fromJson(decoded['data']);
    } catch (e) {
      print('❌ PARSE ERROR: $e');
    }
    throw Exception("Failed to parse penarikan response");
  }
}
