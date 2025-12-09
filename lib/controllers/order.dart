import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:gobox/model/order.dart';
class OrderController {
  static final OrderController _instance = OrderController._internal();
  factory OrderController() => _instance;
  OrderController._internal();

  final String baseUrl = 'http://10.0.2.2:8000/api';
  String? token;

  Future<Map<String, dynamic>> showDashboard({required String idUser}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/dashboard/mitra'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'id_mitra': idUser}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'total_orders': data['total_orders'] ?? 0,
          'total_penghasilan': data['total_penghasilan'] ?? 0,
          'saldo_tersedia': data['saldo_tersedia'] ?? 0,
          'orderanNow': data['orderanNow'] ?? [],
          'orderAll': data['orderAll'] ?? [],
        };
      } else {
        debugPrint('Failed to load dashboard: ${response.statusCode}');
        return {
          'total_orders': 0,
          'total_penghasilan': 0,
          'saldo_tersedia': 0,
          'orderanNow': [],
          'orderAll': [],
        };
      }
    } catch (e) {
      debugPrint('Error fetching dashboard: $e');
      return {
        'total_orders': 0,
        'total_penghasilan': 0,
        'saldo_tersedia': 0,
        'orderanNow': [],
        'orderAll': [],
      };
    }
  }
  
  Future<List<OrderModel>> getOrdersMitra(String idMitra) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/dashboard/mitra'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'id_mitra': idMitra}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<OrderModel> orders = [];

      for (var o in data['orderAll']) {
        orders.add(OrderModel.fromJson(o));
      }

      return orders;
    } else {
      return [];
    }
  } catch (e) {
    debugPrint("Error: $e");
    return [];
  }
}
Future<OrderModel?> getOrderDetail(String idOrder) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/order/detail'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'id_order': idOrder}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OrderModel.fromJson(data['order']);
      }
    } catch (e) {
      debugPrint('Error getOrderDetail: $e');
    }
    return null;
  }

  
}
