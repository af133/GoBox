import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gobox/controllers/gudang.dart';

const Color goBox = Color(0xFF4CAF50);
const Color editingColor = Color(0xFFFF9800); 

class EditLokasiPage extends StatefulWidget {
  final String idLokasi;
  const EditLokasiPage({super.key, required this.idLokasi});

  @override
  State<EditLokasiPage> createState() => _EditLokasiPageState();
}

class _EditLokasiPageState extends State<EditLokasiPage> {
  Map<String, dynamic>? lokasi;
  bool loading = true;
  
  final MapController mapController = MapController(); 

  LatLng? marker;
  List<List<LatLng>> polygonsCoords = [];

  int? editingPolygonIndex;
  List<LatLng> currentEditingPolygon = [];

  List<Polygon> get displayedPolygons {
    final List<Polygon> polys = [];
    
    polys.addAll(polygonsCoords
      .asMap()
      .entries
      .where((entry) => entry.value.isNotEmpty && entry.key != editingPolygonIndex)
      .map((entry) => Polygon(
            points: entry.value,
            color: goBox.withOpacity(0.25),
            borderColor: goBox,
            borderStrokeWidth: 3,
          ))
      .toList());

    if (editingPolygonIndex != null && currentEditingPolygon.isNotEmpty) {
      polys.add(
        Polygon(
          points: currentEditingPolygon,
          color: editingColor.withOpacity(0.4),
          borderColor: editingColor,
          borderStrokeWidth: 4,
        ),
      );
    }
    
    return polys;
  }
  
  List<Marker> get polygonEditingMarkers {
    if (editingPolygonIndex == null) return [];
    
    return currentEditingPolygon.map((point) {
      return Marker(
        point: point,
        width: 15,
        height: 15,
        child: Container(
          decoration: BoxDecoration(
            color: editingColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      );
    }).toList();
  }
  
  List<Marker> get mainMarker {
    if (marker == null) return [];
    return [
      Marker(
        point: marker!,
        width: 80,
        height: 80,
        child: const Icon(
          Icons.warehouse_rounded,
          color: goBox,
          size: 45,
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    fetchLokasi();
  }

  Future<void> fetchLokasi() async {
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
    LatLng? initialMarker = (lat != 0.0 && lng != 0.0) ? LatLng(lat, lng) : null;

    if (initialMarker == null) {
      bool permissionGranted = await _requestLocationPermission();
      if (permissionGranted) {
        try {
          Position pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          initialMarker = LatLng(pos.latitude, pos.longitude);
        } catch (e) {
          print("Error getting current location: $e");
        }
      }
    }

    List<List<LatLng>> tmpPolygons = [];
    if (data['area'] != null && (data['area'] as List).isNotEmpty) {
      for (var a in data['area']) {
        final polygonStr = a['polygon'];
        if (polygonStr != null && polygonStr.isNotEmpty) {
          try {
            final geoJson = jsonDecode(polygonStr);
            if (geoJson['type'] == 'Polygon' && geoJson['coordinates'] is List && geoJson['coordinates'].isNotEmpty) {
              final List<dynamic> outerRing = geoJson['coordinates'][0];
              tmpPolygons.add(outerRing
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

    if (mounted) {
      setState(() {
        lokasi = data;
        marker = initialMarker;
        polygonsCoords = tmpPolygons;
        loading = false;
      });
      if (marker != null) {
        mapController.move(marker!, 16);
      } else if (polygonsCoords.isNotEmpty && polygonsCoords.first.isNotEmpty) {
        mapController.move(polygonsCoords.first.first, 16);
      }
    }
  }

  Future<bool> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hidupkan GPS untuk mencoba mengambil lokasi saat ini"), backgroundColor: Colors.red),
        );
        await Geolocator.openLocationSettings();
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Izin lokasi diperlukan untuk mengambil posisi awal."), backgroundColor: Colors.red),
        );
      }
      return false;
    }
    return true;
  }

  void updateMarker(LatLng newMarker) {
    if (editingPolygonIndex != null) {
      addPointToPolygon(newMarker);
    } else {
      setState(() => marker = newMarker);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Titik Lokasi diperbarui: (${newMarker.latitude.toStringAsFixed(4)}, ${newMarker.longitude.toStringAsFixed(4)})"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void startEditingPolygon(int index) {
    if (editingPolygonIndex != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap simpan atau batalkan polygon yang sedang diedit."), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() {
      editingPolygonIndex = index;
      currentEditingPolygon = List.from(polygonsCoords[index]);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mode Edit Polygon Aktif. Tap pada map untuk menambah titik."), backgroundColor: editingColor),
      );
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
      if (currentEditingPolygon.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Polygon minimal membutuhkan 3 titik."), backgroundColor: Colors.red),
        );
        return;
      }
      
      setState(() {
        polygonsCoords[editingPolygonIndex!] = List.from(currentEditingPolygon);
        editingPolygonIndex = null;
        currentEditingPolygon = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Polygon berhasil disimpan!"), backgroundColor: goBox),
      );
    }
  }

  void cancelEditingPolygon() {
    setState(() {
      editingPolygonIndex = null;
      currentEditingPolygon = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Edit Polygon dibatalkan."), backgroundColor: Colors.redAccent),
    );
  }

  void addNewPolygon() {
    if (editingPolygonIndex != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap simpan atau batalkan polygon yang sedang diedit."), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() {
      polygonsCoords.add([]);
      editingPolygonIndex = polygonsCoords.length - 1;
      currentEditingPolygon = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mode Edit Polygon Baru Aktif. Tap pada map untuk menambah titik."), backgroundColor: editingColor),
      );
  }

  void removePolygon(int index) {
    if (editingPolygonIndex != null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap simpan atau batalkan polygon yang sedang diedit terlebih dahulu."), backgroundColor: Colors.orange),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Polygon"),
        content: Text("Apakah Anda yakin ingin menghapus Polygon ${index + 1}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                polygonsCoords.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Polygon berhasil dihapus."), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void removeLastPoint() {
     if (editingPolygonIndex != null && currentEditingPolygon.isNotEmpty) {
      setState(() {
        currentEditingPolygon.removeLast();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Titik terakhir dihapus. Sisa: ${currentEditingPolygon.length}"), duration: const Duration(milliseconds: 500)),
      );
    }
  }

  Future<void> saveData() async {
    if (editingPolygonIndex != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap simpan atau batalkan polygon yang sedang diedit sebelum menyimpan semua data."), backgroundColor: Colors.orange),
      );
      return;
    }
    
    if (marker == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Titik Lokasi Gudang tidak boleh kosong."), backgroundColor: Colors.red),
      );
      return;
    }

    final controller = ManagemenGudang();

    List<Map<String, dynamic>> polygonsJson = polygonsCoords
        .where((poly) => poly.length >= 3)
        .map((poly) {
          final coordinatesList = poly.map((p) => [p.longitude, p.latitude]).toList();
          
          if (coordinatesList.isNotEmpty && coordinatesList.first != coordinatesList.last) {
            coordinatesList.add(coordinatesList.first);
          }
          
          return {
            "id_polygon": null, 
            "polygon": jsonEncode({
              "type": "Polygon",
              "coordinates": [coordinatesList]
            })
          };
        }).toList();

    final success = await controller.updateLokasiAndPolygon(
      idLokasi: widget.idLokasi,
      latitude: marker?.latitude.toString() ?? '0',
      longitude: marker?.longitude.toString() ?? '0',
      polygons: polygonsJson,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan'), backgroundColor: goBox),
        );
        Navigator.pop(context, true); 
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data. Coba lagi.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: goBox)));
    }

    if (lokasi == null) {
      return const Scaffold(
          body: Center(child: Text("Lokasi tidak ditemukan")));
    }
    
    LatLng initialPos = marker ?? (polygonsCoords.isNotEmpty && polygonsCoords.first.isNotEmpty
                ? polygonsCoords.first.first
                : LatLng(-6.2088, 106.8456)); 

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Lokasi & Area (${lokasi!['nama_lokasi']})', style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: initialPos,
              initialZoom: 16,
              onTap: (_, latlng) => updateMarker(latlng),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate, 
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', 
                userAgentPackageName: 'com.gobox.app',
              ),
              PolygonLayer(polygons: displayedPolygons),
              
              MarkerLayer(markers: mainMarker),

              MarkerLayer(markers: polygonEditingMarkers),
            ],
          ),
          _buildPolygonControlPanel(),
          _buildActionButtons(),
          
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "© OpenStreetMap contributors",
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: saveData,
              icon: const Icon(Icons.save_rounded, color: Colors.white),
              label: const Text('Simpan Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: goBox,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 5,
              ),
            ),
            const SizedBox(height: 12),
            
            if (editingPolygonIndex != null && currentEditingPolygon.isNotEmpty)
              ElevatedButton.icon(
                onPressed: removeLastPoint,
                icon: const Icon(Icons.undo_rounded, color: Colors.black87),
                label: const Text('Hapus Titik Terakhir', style: TextStyle(color: Colors.black87)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 5,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPolygonControlPanel() {
    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: Column(
        children: [
          if (editingPolygonIndex != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: saveEditingPolygon,
                      icon: const Icon(Icons.check_rounded, color: Colors.white),
                      label: Text('Simpan Polygon (${currentEditingPolygon.length} Titik)'),
                      style: ElevatedButton.styleFrom(backgroundColor: goBox, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: cancelEditingPolygon,
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      label: const Text('Batal'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 12),
          
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: polygonsCoords.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ElevatedButton.icon(
                      onPressed: addNewPolygon,
                      icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
                      label: const Text('Tambah Area', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goBox,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 5,
                      ),
                    ),
                  );
                }
                
                final index = i - 1;
                final isEditing = editingPolygonIndex == index;
                final color = isEditing ? editingColor : Colors.blueGrey;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () => startEditingPolygon(index),
                    onLongPress: () => removePolygon(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditing ? editingColor : Colors.white,
                      foregroundColor: isEditing ? Colors.white : Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: color, width: 2),
                      ),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Area ${index + 1}'),
                        if (isEditing) const SizedBox(width: 4),
                        if (isEditing) const Icon(Icons.mode_edit_outline_rounded, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}