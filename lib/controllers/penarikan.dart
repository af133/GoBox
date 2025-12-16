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

    // ===== DEBUG TOKEN =====
    print('🔐 LOAD TOKEN');
    print('Token: $token');
    print('Is Null: ${token == null}');
    print('========================');
  }

  Map<String, String> _headers() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ================= GET SALDO =================
  Future<List<Saldo>> getSaldo(int idMitra) async {
    await _loadToken();

    final url = '$baseUrl/saldo/$idMitra';

    print('🟢 GET SALDO');
    print('URL     : $url');
    print('Headers : ${_headers()}');

    final res = await http.get(
      Uri.parse(url),
      headers: _headers(),
    );

    print('🔵 RESPONSE SALDO');
    print('Status : ${res.statusCode}');
    print('Body   : ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed fetch saldo (${res.statusCode})');
    }

    final jsonBody = jsonDecode(res.body);
    final data = jsonBody['data'] as List? ?? [];

    return data.map((e) => Saldo.fromJson(e)).toList();
  }

  // ================= CREATE PENARIKAN =================
  Future<Penarikan> createPenarikan({
    required int idMitra,
    required int jumlah,
    required String tanggal,
    String? alasan,
  }) async {
    await _loadToken();

    if (token == null) {
      throw Exception('AUTH TOKEN NULL – user belum login');
    }

    final url = '$baseUrl/penarikan';

    final bodyData = {
      'id_mitra': idMitra,
      'jumlah_penarikan': jumlah,
      'tanggal_penarikan': tanggal,
      if (alasan != null) 'alasan_penarikan': alasan,
    };

    print('🟢 CREATE PENARIKAN REQUEST');
    print('URL     : $url');
    print('Headers : ${_headers()}');
    print('Body    : ${jsonEncode(bodyData)}');

    final res = await http.post(
      Uri.parse(url),
      headers: _headers(),
      body: jsonEncode(bodyData),
    );

    print('🔵 CREATE PENARIKAN RESPONSE');
    print('Status  : ${res.statusCode}');
    print('Body    : ${res.body}');

    if (res.statusCode != 200) {
      throw Exception(
        'CREATE PENARIKAN FAILED\n'
        'Status: ${res.statusCode}\n'
        'Body  : ${res.body}',
      );
    }

    final decoded = jsonDecode(res.body);

    if (decoded['data'] == null) {
      throw Exception('Response data kosong');
    }

    return Penarikan.fromJson(decoded['data']);
  }
}
