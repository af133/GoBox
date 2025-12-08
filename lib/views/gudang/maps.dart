import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gobox/controllers/gudang.dart';

class EditLokasiPage extends StatefulWidget {
  final String idLokasi;
  const EditLokasiPage({super.key, required this.idLokasi});

  @override
  State<EditLokasiPage> createState() => _EditLokasiPageState();
}

class _EditLokasiPageState extends State<EditLokasiPage> {
  Map<String, dynamic>? lokasi;
  bool loading = true;

  LatLng? marker;
  List<List<LatLng>> polygonsCoords = [];

  int? editingPolygonIndex;
  List<LatLng> currentEditingPolygon = [];

  List<Polygon> get polygons => polygonsCoords
      .where((poly) => poly.isNotEmpty)
      .map((poly) => Polygon(
            points: poly,
            color: Colors.blue.withOpacity(0.3),
            borderColor: Colors.blue,
            borderStrokeWidth: 2,
          ))
      .toList();

  @override
  void initState() {
    super.initState();
    fetchLokasi();
  }

  Future<void> fetchLokasi() async {
    setState(() => loading = true);
    final controller = ManagemenGudang();
    final data = await controller.getLokasiDetail(widget.idLokasi);

    if (data != null) {
      final double lat =
          double.tryParse(data['latitude']?.toString() ?? '') ?? 0.0;
      final double lng =
          double.tryParse(data['longitude']?.toString() ?? '') ?? 0.0;
      marker = (lat != 0.0 && lng != 0.0) ? LatLng(lat, lng) : null;

      if (marker == null) {
        bool permissionGranted = await _requestLocationPermission();
        if (permissionGranted) {
          Position pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          marker = LatLng(pos.latitude, pos.longitude);
        }
      }

      List<List<LatLng>> tmpPolygons = [];

      if (data['area'] != null && (data['area'] as List).isNotEmpty) {
        for (var a in data['area']) {
          final polygonStr = a['polygon'];
          if (polygonStr != null && polygonStr.isNotEmpty) {
            try {
              final geoJson = jsonDecode(polygonStr);
              if (geoJson['type'] == 'Polygon') {
                final coords = geoJson['coordinates'][0] as List;
                tmpPolygons.add(coords
                    .map((c) => LatLng(
                        double.parse(c[1].toString()),
                        double.parse(c[0].toString())))
                    .toList());
              }
            } catch (e) {
              print("Error parsing polygon: $e");
            }
          }
        }
      }

      polygonsCoords = tmpPolygons;

      setState(() {
        lokasi = data;
        loading = false;
      });
    } else {
      setState(() {
        lokasi = null;
        loading = false;
      });
    }
  }

  Future<bool> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hidupkan GPS untuk melanjutkan")),
      );
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin lokasi diperlukan")),
      );
      return false;
    }

    return true;
  }

  void updateMarker(LatLng newMarker) {
    setState(() => marker = newMarker);
  }

  void startEditingPolygon(int index) {
    setState(() {
      editingPolygonIndex = index;
      currentEditingPolygon = List.from(polygonsCoords[index]);
    });
  }

  void addPointToPolygon(LatLng point) {
    if (editingPolygonIndex != null) {
      setState(() {
        currentEditingPolygon.add(point);
      });
    }
  }

  void saveEditingPolygon() {
    if (editingPolygonIndex != null) {
      setState(() {
        polygonsCoords[editingPolygonIndex!] =
            List.from(currentEditingPolygon);
        editingPolygonIndex = null;
        currentEditingPolygon = [];
      });
    }
  }

  void cancelEditingPolygon() {
    setState(() {
      editingPolygonIndex = null;
      currentEditingPolygon = [];
    });
  }

  void addNewPolygon() {
    setState(() {
      polygonsCoords.add([]);
      editingPolygonIndex = polygonsCoords.length - 1;
      currentEditingPolygon = [];
    });
  }

  void removePolygon(int index) {
    setState(() {
      if (editingPolygonIndex == index) {
        editingPolygonIndex = null;
        currentEditingPolygon = [];
      }
      polygonsCoords.removeAt(index);
    });
  }

  Future<void> saveData() async {
    final controller = ManagemenGudang();

    if (marker != null) {
      await controller.updateLokasi(
        idLokasi: widget.idLokasi,
        latitude: marker!.latitude.toString(),
        longitude: marker!.longitude.toString(),
      );
    }

    List<Map<String, dynamic>> polygonsJson = polygonsCoords.map((poly) {
    return {
      "id_polygon": null,
      "polygon": jsonEncode({
        "type": "Polygon",
        "coordinates": [
          poly.map((p) => [p.longitude, p.latitude]).toList()
        ]
      })
    };
  }).toList();


    await controller.updateLokasiAndPolygon(
      idLokasi: widget.idLokasi,
      latitude: marker?.latitude.toString() ?? '0',
      longitude: marker?.longitude.toString() ?? '0',
      polygons: polygonsJson,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil disimpan')),

    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (lokasi == null) {
      return const Scaffold(
          body: Center(child: Text("Lokasi tidak ditemukan")));
    }

    LatLng initialPos =
        marker ??
            (polygonsCoords.isNotEmpty && polygonsCoords.first.isNotEmpty
                ? polygonsCoords.first.first
                : LatLng(0, 0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Lokasi & Polygon'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: initialPos,
              initialZoom: 16,
              onTap: (tapPos, latlng) {
                if (editingPolygonIndex != null) {
                  addPointToPolygon(latlng);
                } else {
                  updateMarker(latlng);
                }
              },
            ),
            children: [
              TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.gobox.app',
              ),

              if (marker != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: marker!,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on,
                          color: Colors.red, size: 40),
                    ),
                  ],
                ),

              if (polygons.isNotEmpty) PolygonLayer(polygons: polygons),

              if (editingPolygonIndex != null &&
                  currentEditingPolygon.isNotEmpty)
                PolygonLayer(polygons: [
                  Polygon(
                    points: currentEditingPolygon,
                    color: Colors.orange.withOpacity(0.3),
                    borderColor: Colors.orange,
                    borderStrokeWidth: 2,
                  )
                ]),
            ],
          ),

          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              color: Colors.white.withOpacity(0.7),
              child: const Text(
                "© OpenStreetMap contributors",
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: addNewPolygon,
                        child: const Text('Tambah Polygon')),
                    const SizedBox(width: 8),

                    if (editingPolygonIndex != null) ...[
                      ElevatedButton(
                          onPressed: saveEditingPolygon,
                          child: const Text('Simpan Polygon')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                          onPressed: cancelEditingPolygon,
                          child: const Text('Batal')),
                    ],

                    const SizedBox(width: 8),
                    ElevatedButton(
                        onPressed: saveData,
                        child: const Text('Simpan Semua Data')),
                  ],
                ),
              ),
            ),
          ),

          if (polygonsCoords.isNotEmpty)
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: polygonsCoords.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () => startEditingPolygon(i),
                        onLongPress: () => removePolygon(i),
                        child: Text('Polygon ${i + 1}'),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
