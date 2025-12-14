import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:gobox/model/user.dart';
import 'http.dart';
class AuthController {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  final String baseUrl = httpss;
  String? token;

  
  Future<String> signUp(
      String nama, String email, String password, String alamat,BuildContext context, ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'password': password,
          'alamat': alamat,
          'role': 'mitra',
        }),
      );

      final data = jsonDecode(response.body);

      if (data['user'] == null) {
        return data['message']?.toString() ?? 'Data user kosong dari server';
      }

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final user = User.fromJson(data['user']);

        await prefs.setString('user', jsonEncode(user.toJson()));
        await prefs.setString('token', data['token'] ?? '');
        await prefs.setString('role', data['role'] ?? '');
        token = data['token'] ?? '';

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }

        return data['message']?.toString() ?? 'Registrasi berhasil';
      } else if (response.statusCode == 422) {
        if (data['errors'] != null) {
          final firstError = data['errors'].values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
        return data['message']?.toString() ?? 'Data tidak valid';
      } else {
        return data['message']?.toString() ?? 'Terjadi kesalahan server';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  // =================== LOGIN ===================
Future<String> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': 'mitra',
      }),
    );

    // Safe check headers
    if (response.headers['content-type'] == null ||
        !response.headers['content-type']!.contains('application/json')) {
      return 'Server tidak mengembalikan JSON';
    }

    final data = jsonDecode(response.body);

    // Pastikan user tidak null
    final userJson = data['user'] ?? {};
    if (userJson.isEmpty) {
      return data['message']?.toString() ?? 'Data user kosong dari server';
    }

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      final user = User.fromJson(userJson);

      await prefs.setString('user', jsonEncode(user.toJson()));
      await prefs.setString('token', data['token'] ?? '');
      token = data['token'] ?? '';

      return data['message']?.toString() ?? 'Login berhasil';
    } else if (response.statusCode == 401 || response.statusCode == 404) {
      return data['message']?.toString() ?? 'Email atau password salah';
    } else if (response.statusCode == 422) {
      if (data['errors'] != null) {
        final firstError = data['errors'].values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }
      return data['message']?.toString() ?? 'Data tidak valid';
    } else {
      return 'Terjadi kesalahan server';
    }
  } catch (e) {
    return 'Error: $e';
  }
}

  // =================== LOGOUT ===================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
    token = null;
  }

    // =================== AMBIL USER ===================
    Future<User?> getUser() async {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null) {
        final userJson = jsonDecode(userString);
        return User.fromJson(userJson);
      }
      return null;
    }
}
