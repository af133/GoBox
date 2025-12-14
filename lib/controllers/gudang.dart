import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'http.dart';

class ManagemenGudang {
  static final ManagemenGudang _instance = ManagemenGudang._internal();
  factory ManagemenGudang() => _instance;
  ManagemenGudang._internal();

  final String baseUrl = httpss;
  String? token;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  Map<String, String> _headers() => {
    if (token != null) 'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  // GET LOKASI DETAIL

  Future<Map<String, dynamic>?> getLokasiDetail(String idLokasi) async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/lokasi/$idLokasi'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // UPDATE TITIK LOKASI + POLYGON

  Future<bool> updateLokasiAndPolygon({
    required String idLokasi,
    required String latitude,
    required String longitude,
    required List<Map<String, dynamic>> polygons,
  }) async {
    await _loadToken();

    try {
      final url = Uri.parse('$baseUrl/update/or/add/titik/polygon');

      final body = jsonEncode({
        "id_lokasi": idLokasi,
        "latitude": latitude,
        "longitude": longitude,
        "polygons": polygons,
      });

      final res = await http.post(
        url,
        headers: {..._headers(), "Content-Type": "application/json"},
        body: body,
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // UPDATE LOKASI SAJA

  Future<bool> updateLokasi({
    required String idLokasi,
    String? namaLokasi,
    String? deskripsi,
    String? latitude,
    String? longitude,
    File? imageFile,
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

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('path_area', imageFile.path),
      );
    }

    var res = await request.send();
    return res.statusCode == 200;
  }

  // GET LOKASI GUDANG MITRA

  Future<List<dynamic>> getLokasiMitra(String idUser) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/show/mitra/lokasi'),
      headers: _headers(),
      body: {'id_mitra': idUser},
    );
    final data = jsonDecode(response.body);
    return data['lokasi'] ?? [];
  }

  // ADD LOKASI MITRA

  Future<bool> addLokasiMitra({
    required String idMitra,
    required String namaLokasi,
    required String deskripsi,
    required File imageFile,
  }) async {
    await _loadToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/add/mitra/lokasi'),
    );

    request.headers.addAll(_headers());
    request.fields['id_mitra'] = idMitra;
    request.fields['nama_lokasi'] = namaLokasi;
    request.fields['deskripsi'] = deskripsi;

    request.files.add(
      await http.MultipartFile.fromPath('path_area', imageFile.path),
    );

    var response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<dynamic>> getJenisBarang(String idUser) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/jenis/barang'),
      headers: _headers(),
      body: {'id_mitra': idUser},
    );
    final data = jsonDecode(response.body);
    return data['jenisBarang'] ?? [];
  }

  Future<bool> addJenisBarang({
    required String idMitra,
    required String jenisBarang,
    required String hargaSewa,
  }) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/add/jenis/barang'),
      headers: _headers(),
      body: {
        'id_mitra': idMitra,
        'jenis_barang': jenisBarang,
        'harga_sewa': hargaSewa,
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> editJenisBarang({
    required String jenisBarang,
    required String hargaSewa,
    required String idJenisBarang,
  }) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/update/jenis/barang'),
      headers: _headers(),
      body: {
        'id_jenis_barang': idJenisBarang,
        'jenis_barang': jenisBarang,
        'harga_sewa': hargaSewa,
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateOrAddLokasiAndPolygon({
    required String idLokasi,
    required String latitude,
    required String longitude,
    required List<Map<String, dynamic>> polygons,
  }) async {
    await _loadToken();
    try {
      final url = Uri.parse('$baseUrl/update/or/add/titik/polygon');
      final body = jsonEncode({
        'id_lokasi': idLokasi,
        'latitude': latitude,
        'longitude': longitude,
        'polygons': polygons,
      });

      final res = await http.post(
        url,
        headers: {..._headers(), 'Content-Type': 'application/json'},
        body: body,
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
