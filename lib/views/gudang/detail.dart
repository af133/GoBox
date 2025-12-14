import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gobox/controllers/gudang.dart';
import 'package:gobox/controllers/auth.dart';
import 'package:http/http.dart' as http;
// Import yang diperlukan
import 'maps.dart'; 
import 'update.dart';

// Asumsi warna GoBox (Hijau Primer)
const Color goBox = Color(0xFF4CAF50); 

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

  // Map Controller untuk mengontrol tampilan Map
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchDetail();
  }

  // =================================================
  // LOGIC DATA FETCHING & PARSING
  // =================================================

  Future<void> fetchUser() async {
    final user = await AuthController().getUser();
    if (user == null) return;
    idUser = user.idUser.toString();
  }

  Future<void> _getAddress(double lat, double lng) async {
    // Reverse Geocoding menggunakan Nominatim (OpenStreetMap)
    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?"
        "format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1",
      );

      final res = await http.get(url, headers: {
        "User-Agent": "com.gobox.app" // Wajib
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            alamat = data["display_name"] ?? "Alamat tidak ditemukan";
          });
        }
      } else {
        if (mounted) setState(() => alamat = "Alamat tidak ditemukan");
      }
    } catch (e) {
      if (mounted) setState(() => alamat = "Gagal memuat alamat");
    }
  }

  Future<void> fetchDetail() async {
    if (!mounted) return;
    setState(() => loading = true);

    final controller = ManagemenGudang();
    final data = await controller.getLokasiDetail(widget.idLokasi);

    if (data == null) {
      if (mounted) {
        setState(() {
          lokasi = null;
          loading = false;
        });
      }
      return;
    }

    final double lat = double.tryParse(data['latitude']?.toString() ?? '') ?? 0.0;
    final double lng = double.tryParse(data['longitude']?.toString() ?? '') ?? 0.0;

    // Inisialisasi Marker (Titik Tengah Gudang)
    List<Marker> tmpMarkers = [];
    if (lat != 0.0 && lng != 0.0) {
      tmpMarkers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 60,
          height: 60,
          child: const Icon(Icons.warehouse_rounded, color: goBox, size: 40),
        ),
      );
    }

    // Inisialisasi Polygon (Area Gudang)
    List<Polygon> tmpPolygons = [];
    if (data['area'] != null && (data['area'] as List).isNotEmpty) {
      for (var a in data['area']) {
        final polygonStr = a['polygon'];
        if (polygonStr != null && polygonStr.isNotEmpty) {
          try {
            final geoJson = jsonDecode(polygonStr);
            // GeoJson Polygon coordinates: [[[lng, lat], [lng, lat], ...]]
            final List rings = geoJson['coordinates']; 

            for (var ring in rings) {
              final points = (ring as List)
                  .map((c) => LatLng(
                      double.parse(c[1].toString()), // Latitude
                      double.parse(c[0].toString()), // Longitude
                    ))
                  .toList();

              tmpPolygons.add(
                Polygon(
                  points: points,
                  color: goBox.withOpacity(0.2), // Warna GoBox transparan
                  borderColor: goBox,
                  borderStrokeWidth: 3,
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
    if (mounted) {
      setState(() {
        lokasi = data;
        markers = tmpMarkers;
        polygons = tmpPolygons;
        loading = false;
      });
    }

    // Ambil alamat otomatis
    if (lat != 0 && lng != 0) {
      _getAddress(lat, lng);
    } else {
      if (mounted) setState(() => alamat = "Alamat tidak tersedia (koordinat kosong)");
    }
  }

  // =================================================
  // WIDGET BUILDER
  // =================================================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: goBox)));
    }

    if (lokasi == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Detail Gudang")),
        body: const Center(child: Text("Lokasi tidak ditemukan")),
      );
    }

    final double initLat =
        double.tryParse(lokasi!['latitude']?.toString() ?? '') ?? 0.0;
    final double initLng =
        double.tryParse(lokasi!['longitude']?.toString() ?? '') ?? 0.0;
    final initialLatLng = LatLng(initLat, initLng);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(lokasi!['nama_lokasi'] ?? 'Detail Gudang', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [_buildEditMenuButton(context)], // Tombol Edit Menu
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Area
            _buildImageArea(),
            const SizedBox(height: 16),

            // Detail Utama (Nama & Deskripsi)
            _buildDetailCard(lokasi!),
            const SizedBox(height: 16),
            
            // Detail Alamat & Koordinat
            _buildLocationInfo(initialLatLng),
            const SizedBox(height: 16),

            // MAP
            if (markers.isNotEmpty || polygons.isNotEmpty)
              _buildMapWidget(initialLatLng),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.black87),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) async {
        bool? result = false;
        if (value == 'edit_lokasi') {
          // Navigasi ke Edit Lokasi (Nama/Deskripsi)
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
        } else if (value == 'edit_map') {
          // Navigasi ke Edit Map (Titik/Area)
          result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditLokasiPage(idLokasi: widget.idLokasi),
            ),
          );
        }

        if (result == true) {
          await fetchDetail();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data berhasil diperbarui!", style: TextStyle(color: Colors.white)), backgroundColor: goBox),
            );
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit_lokasi',
          child: Row(
            children: [
              Icon(Icons.edit_note_rounded, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text("Edit Nama & Deskripsi"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit_map',
          child: Row(
            children: [
              Icon(Icons.location_on_rounded, color: goBox),
              SizedBox(width: 8),
              Text("Edit Titik & Area Map"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageArea() {
    final imagePath = lokasi!['path_area'];
    if (imagePath == null || imagePath.toString().isEmpty) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300)
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_rounded, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text("Gambar Gudang Belum Ditambahkan", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imagePath,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: Colors.grey.shade100,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: goBox,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade300,
          height: 200,
          child: const Center(child: Icon(Icons.broken_image_rounded, size: 50, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildDetailCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: goBox, size: 24),
              const SizedBox(width: 8),
              Text(
                "Info Detail Gudang",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
          const Divider(height: 20),
          // Nama Lokasi
          _buildInfoRow(
            title: "Nama Gudang",
            value: data['nama_lokasi'] ?? '-',
            icon: Icons.title_rounded,
          ),
          const SizedBox(height: 12),
          // Deskripsi
          _buildInfoRow(
            title: "Deskripsi",
            value: data['deskripsi'] ?? 'Tidak ada deskripsi',
            icon: Icons.description_rounded,
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(LatLng initialLatLng) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_pin, color: goBox, size: 24),
              const SizedBox(width: 8),
              Text(
                "Informasi Lokasi",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
          const Divider(height: 20),
          // Alamat
          _buildInfoRow(
            title: "Alamat Lengkap (Otomatis)",
            value: alamat,
            icon: Icons.map_rounded,
            maxLines: 5,
          ),
          const SizedBox(height: 12),
          // Koordinat
          _buildInfoRow(
            title: "Koordinat (Lat, Lng)",
            value: "${initialLatLng.latitude.toStringAsFixed(6)}, ${initialLatLng.longitude.toStringAsFixed(6)}", // Format 6 angka di belakang koma
            icon: Icons.gps_fixed_rounded,
            isMonospace: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String value,
    required IconData icon,
    int maxLines = 1,
    bool isMonospace = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: goBox.withOpacity(0.8)),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
              fontFamily: isMonospace ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapWidget(LatLng initialLatLng) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16), // Radius Map konsisten
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialLatLng,
            initialZoom: 16,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate, // Nonaktifkan rotasi
            ),
          ),
          children: [
            TileLayer(
              // Menggunakan TileLayer OSM standar untuk kecepatan
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.gobox.app',
            ),
            if (polygons.isNotEmpty) PolygonLayer(polygons: polygons),
            if (markers.isNotEmpty) MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}