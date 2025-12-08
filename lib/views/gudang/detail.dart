import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gobox/controllers/gudang.dart';

class DetailGudangPage extends StatefulWidget {
  final String idLokasi;
  const DetailGudangPage({super.key, required this.idLokasi});

  @override
  State<DetailGudangPage> createState() => _DetailGudangPageState();
}

class _DetailGudangPageState extends State<DetailGudangPage> {
  Map<String, dynamic>? lokasi;
  bool loading = true;

  List<Marker> markers = [];
  List<Polygon> polygons = [];

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    final controller = ManagemenGudang();
    final data = await controller.getLokasiDetail(widget.idLokasi);

    if (data != null) {
      // Marker titik
      if (data['latitude'] != null && data['longitude'] != null) {
        markers.add(Marker(
          point: LatLng(data['latitude'], data['longitude']),
          width: 80,
          height: 80,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ));
      }

      // Polygon
      if (data['area'] != null) {
        for (var a in data['area']) {
          if (a['polygon'] != null && a['polygon'] != '') {
            final List coords = List.from(jsonDecode(a['polygon']));
            polygons.add(Polygon(
              points: coords.map((c) => LatLng(c[0], c[1])).toList(),
              color: Colors.blue.withOpacity(0.3),
              borderColor: Colors.blue,
              borderStrokeWidth: 2,
            ));
          }
        }
      }
    }

    setState(() {
      lokasi = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (lokasi == null) {
      return const Scaffold(
        body: Center(child: Text("Lokasi tidak ditemukan")),
      );
    }

    final initialLatLng = LatLng(
      lokasi!['latitude'] ,
      lokasi!['longitude'],
    );

    return Scaffold(
      appBar: AppBar(title: Text(lokasi!['nama_lokasi'] ?? 'Detail Gudang')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MAP
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
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    ),
                    if (polygons.isNotEmpty) PolygonLayer(polygons: polygons),
                    if (markers.isNotEmpty) MarkerLayer(markers: markers),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Informasi Lokasi
            Text("Deskripsi: ${lokasi!['deskripsi'] ?? '-'}"),
            const SizedBox(height: 8),
            Text("Latitude: ${lokasi!['latitude'] ?? '-'}"),
            Text("Longitude: ${lokasi!['longitude'] ?? '-'}"),
            const SizedBox(height: 12),

            // List Polygon
            if (lokasi!['area'] != null && (lokasi!['area'] as List).isNotEmpty) ...[
              const Text("Area Gudang (Polygon):", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...((lokasi!['area'] as List).map((a) => Card(
                    child: ListTile(
                      title: Text("ID Polygon: ${a['id_polygon']}"),
                      subtitle: Text(a['polygon'] ?? ''),
                    ),
                  ))),
            ],
          ],
        ),
      ),
    );
  }
}
