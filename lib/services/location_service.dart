import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;    
import 'dart:convert';                      

class LocationService {
  static Future<bool> requestPermission(BuildContext context) async {
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

    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin lokasi diperlukan")),
      );
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izinkan lokasi dari pengaturan HP")),
      );
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  static Future<Position> getPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1",
    );

    final res = await http.get(url, headers: {
      "User-Agent": "com.gobox.app", 
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["display_name"] ?? "Alamat tidak ditemukan";
    } else {
      return "Alamat tidak ditemukan";
    }
  }
}
