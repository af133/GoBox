import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gobox/controllers/gudang.dart';
import 'package:gobox/controllers/auth.dart';
import 'package:http/http.dart' as http;
import 'maps.dart';
import 'update.dart';

class DetailGudangPage extends StatefulWidget {
  final String idLokasi;
  const DetailGudangPage({super.key, required this.idLokasi});

  @override
  State<DetailGudangPage> createState() => _DetailGudangPageState();
}

class _DetailGudangPageState extends State<DetailGudangPage> {
  Map<String, dynamic>? lokasi;
  bool loading = true;
  String idUser = '';

  String alamat = "Memuat alamat...";

  List<Marker> markers = [];
  List<Polygon> polygons = [];

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchDetail();
  }

  Future<void> fetchUser() async {
    final user = await AuthController().getUser();
    if (user == null) return;
    idUser = user.idUser.toString();
  }

  /// ==============================
  /// AMBIL ALAMAT DARI KOORDINAT
  /// ==============================
  Future<void> _getAddress(double lat, double lng) async {
    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?"
        "format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1",
      );

      final res = await http.get(url, headers: {
        "User-Agent": "com.gobox.app" // wajib
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          alamat = data["display_name"] ?? "Alamat tidak ditemukan";
        });
      } else {
        setState(() {
          alamat = "Alamat tidak ditemukan";
        });
      }
    } catch (e) {
      setState(() {
        alamat = "Gagal memuat alamat";
      });
    }
  }

  /// =================================================
  /// FETCH DETAIL + MAP + POLYGON + ALAMAT OTOMATIS
  /// =================================================
  Future<void> fetchDetail() async {
    setState(() => loading = true);

    final controller = ManagemenGudang();
    final data = await controller.getLokasiDetail(widget.idLokasi);

    if (data == null) {
      setState(() {
        lokasi = null;
        loading = false;
      });
      return;
    }

    final double lat =
        double.tryParse(data['latitude']?.toString() ?? '') ?? 0.0;
    final double lng =
        double.tryParse(data['longitude']?.toString() ?? '') ?? 0.0;

    // ============ Marker ============
    List<Marker> tmpMarkers = [];
    if (lat != 0.0 && lng != 0.0) {
      tmpMarkers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 80,
          height: 80,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      );
    }

    // ============ Polygon ============
    List<Polygon> tmpPolygons = [];
    if (data['area'] != null && (data['area'] as List).isNotEmpty) {
      for (var a in data['area']) {
        final polygonStr = a['polygon'];
        if (polygonStr != null && polygonStr.isNotEmpty) {
          try {
            final geoJson = jsonDecode(polygonStr);
            final List rings = geoJson['coordinates'];

            for (var ring in rings) {
              final points = (ring as List)
                  .map((c) => LatLng(
                        double.parse(c[1].toString()),
                        double.parse(c[0].toString()),
                      ))
                  .toList();

              tmpPolygons.add(
                Polygon(
                  points: points,
                  color: Colors.blue.withOpacity(0.3),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2,
                ),
              );
            }
          } catch (e) {
            print("Error parsing polygon: $e");
          }
        }
      }
    }

    // SET STATE
    setState(() {
      lokasi = data;
      markers = tmpMarkers;
      polygons = tmpPolygons;
      loading = false;
    });

    // Ambil alamat otomatis
    if (lat != 0 && lng != 0) {
      _getAddress(lat, lng);
    } else {
      alamat = "Alamat tidak tersedia (koordinat kosong)";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (lokasi == null) {
      return const Scaffold(
        body: Center(child: Text("Lokasi tidak ditemukan")),
      );
    }

    final double initLat =
        double.tryParse(lokasi!['latitude']?.toString() ?? '') ?? 0.0;
    final double initLng =
        double.tryParse(lokasi!['longitude']?.toString() ?? '') ?? 0.0;
    final initialLatLng = LatLng(initLat, initLng);

    bool result = false;

    return Scaffold(
      appBar: AppBar(title: Text(lokasi!['nama_lokasi'] ?? 'Detail Gudang')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            //  Gambar Area
            // =========================
            if (lokasi!['path_area'] != null &&
                lokasi!['path_area'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  lokasi!['path_area'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    height: 200,
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // =========================
            // Tombol Edit
            // =========================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditLokasiPage(idLokasi: widget.idLokasi),
                        ),
                      );

                      if (result == true) fetchDetail();
                    },
                    child: const Text("Edit Titik & Area"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditItemForm(
                            type: 'gudang',
                            initialData: lokasi!,
                            idUser: idUser,
                          ),
                        ),
                      );

                      if (result == true) fetchDetail();
                    },
                    child: const Text("Edit Lokasi"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // =========================
            // Nama Lokasi
            // =========================
            Text(
              lokasi!['nama_lokasi'] ?? '-',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // =========================
            // Deskripsi
            // =========================
            Text(lokasi!['deskripsi'] ?? '-'),
            const SizedBox(height: 12),

            // =========================
            // Alamat (Auto)
            // =========================
            Text(
              "Alamat:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(alamat),
            const SizedBox(height: 16),

            // =========================
            // MAP
            // =========================
            if (markers.isNotEmpty || polygons.isNotEmpty)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: initialLatLng,
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.gobox.app',
                    ),
                    if (polygons.isNotEmpty) PolygonLayer(polygons: polygons),
                    if (markers.isNotEmpty) MarkerLayer(markers: markers),
                  ],
                ),
              ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
