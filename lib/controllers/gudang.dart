import 'dart:convert';
import 'dart:io';
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
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

  // ============================================================
  // GET LOKASI GUDANG MITRA
  // ============================================================
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

  // ============================================================
  // GET JENIS BARANG + HARGA
  // ============================================================
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

  // ============================================================
  // ADD LOKASI MITRA (DENGAN GAMBAR)
  // ============================================================
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

    request.files.add(await http.MultipartFile.fromPath(
      'path_area', // harus sama dengan Laravel
      imageFile.path,
    ));

    var response = await request.send();
    var respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print("Upload berhasil: $respStr");
      return true;
    } else {
      print("Upload gagal: Status ${response.statusCode}, Body: $respStr");
      return false;
    }
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
      body: {'id_lokasi': idLokasi, 'polygon': polygonJson},
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
      request.files.add(await http.MultipartFile.fromPath('path_area', imageFile.path));
    }

    var res = await request.send();
    var respStr = await res.stream.bytesToString();
    print("Update Lokasi Response: $respStr");
    return res.statusCode == 200;
  }

  // ============================================================
  // ADD JENIS BARANG (harga mitra)
  // ============================================================
  Future<bool> addJenisBarang({
    required String idMitra,
    required String jenisBarang,
    required String hargaSewa,
  }) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/add/jenis/barang'),
      headers: _headers(),
      body: {'id_mitra': idMitra, 'jenis_barang': jenisBarang, 'harga_sewa': hargaSewa},
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
      body: {'id_harga_mitra': idHargaMitra, 'harga_sewa': hargaSewa},
    );
    return response.statusCode == 200;
  }
  Future<Map<String, dynamic>?> getLokasiDetail(String idLokasi) async {
  await _loadToken();
  final response = await http.get(
    Uri.parse('$baseUrl/lokasi/$idLokasi'),
    headers: _headers(),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    print('Error getLokasiDetail: ${response.statusCode}, ${response.body}');
    return null;
  }
}

}
