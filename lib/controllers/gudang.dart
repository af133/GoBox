import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ManagemenGudang {
  static final ManagemenGudang _instance = ManagemenGudang._internal();
  factory ManagemenGudang() => _instance;
  ManagemenGudang._internal();

  final String baseUrl = 'http://10.0.2.2:8000/api';
  String? token;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  Map<String, String> _headers() => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

  // ============================================================
  // GET LOKASI GUDANG MITRA
  // ============================================================
  Future<List<dynamic>> 
    jogetLokasiMitra(String idMitra) async {
    await _loadToken();

    final response = await http.post(
      Uri.parse('$baseUrl/show/lokasi/mitra'),
      headers: _headers(),
      body: {'id_mitra': idMitra},
    );

    final data = jsonDecode(response.body);
    return data['lokasi'] ?? [];
  }

  // ============================================================
  // GET JENIS BARANG + HARGA
  // ============================================================
  Future<List<dynamic>> getJenisBarang(String idLokasi) async {
    await _loadToken();

    final response = await http.post(
      Uri.parse('$baseUrl/jenis/barang'),
      headers: _headers(),
      body: {'id_lokasi': idLokasi},
    );

    final data = jsonDecode(response.body);
    return data['jenisBarang'] ?? [];
  }

  // ============================================================
  // ADD LOKASI MITRA (DENGAN GAMBAR)
  // ============================================================
  Future<bool> addLokasiMitra({
    required String idMitra,
    required String namaLokasi,
    required String deskripsi,
    required String latitude,
    required String longitude,
    required String imagePath,
  }) async {
    await _loadToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/add/lokasi/mitra'),
    );

    request.headers.addAll(_headers());

    request.fields['id_mitra'] = idMitra;
    request.fields['nama_lokasi'] = namaLokasi;
    request.fields['deskripsi'] = deskripsi;
    request.fields['latitude'] = latitude;
    request.fields['longitude'] = longitude;

    request.files.add(await http.MultipartFile.fromPath('path_area', imagePath));

    var result = await request.send();
    return result.statusCode == 200;
  }

  // ============================================================
  // ADD POLYGON
  // ============================================================
  Future<bool> addPolygon({
    required String idLokasi,
    required String polygonJson,
  }) async {
    await _loadToken();

    final response = await http.post(
      Uri.parse('$baseUrl/add/polygon'),
      headers: _headers(),
      body: {
        'id_lokasi': idLokasi,
        'polygon': polygonJson,
      },
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // UPDATE LOKASI MITRA
  // ============================================================
  Future<bool> updateLokasi({
    required String idLokasi,
    String? namaLokasi,
    String? deskripsi,
    String? latitude,
    String? longitude,
    String? imagePath,
  }) async {
    await _loadToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/update/lokasi/mitra'),
    );

    request.headers.addAll(_headers());

    request.fields['id_lokasi'] = idLokasi;
    if (namaLokasi != null) request.fields['nama_lokasi'] = namaLokasi;
    if (deskripsi != null) request.fields['deskripsi'] = deskripsi;
    if (latitude != null) request.fields['latitude'] = latitude;
    if (longitude != null) request.fields['longitude'] = longitude;

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('path_area', imagePath));
    }

    var res = await request.send();
    return res.statusCode == 200;
  }

  // ============================================================
  // ADD JENIS BARANG (harga mitra)
  // ============================================================
  Future<bool> addJenisBarang({
    required String idMitra,
    required String idJenisBarang,
    required String hargaSewa,
  }) async {
    await _loadToken();

    final response = await http.post(
      Uri.parse('$baseUrl/add/jenis/barang'),
      headers: _headers(),
      body: {
        'id_mitra': idMitra,
        'id_jenis_barang': idJenisBarang,
        'harga_sewa': hargaSewa,
      },
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // UPDATE JENIS BARANG (harga mitra)
  // ============================================================
  Future<bool> updateJenisBarang({
    required String idHargaMitra,
    required String hargaSewa,
  }) async {
    await _loadToken();

    final response = await http.post(
      Uri.parse('$baseUrl/update/jenis/barang'),
      headers: _headers(),
      body: {
        'id_harga_mitra': idHargaMitra,
        'harga_sewa': hargaSewa,
      },
    );

    return response.statusCode == 200;
  }
}
