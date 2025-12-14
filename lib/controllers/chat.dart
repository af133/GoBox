import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gobox/model/chat.dart';
import 'package:gobox/controllers/auth.dart';
import 'http.dart';
class ChatService {
  final String baseUrl =httpss;
  String? token;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  Map<String, String> _headers({required String userType, required userId}) {
    final headers = {
      'Content-Type': 'application/json',
      'idUser': userId.toString(),
      'userType': userType,
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Ambil semua chat
  Future<List<Chat>> getChats({required String userType}) async {
    await _loadToken();
    final user = await AuthController().getUser();
    if (user == null) return [];

    final res = await http.get(
      Uri.parse("$baseUrl/chats"),
      headers: _headers(userType: userType, userId: user.idUser),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch chats');
    }

    final data = jsonDecode(res.body) as List;
    return data.map((e) => Chat.fromJson(e)).toList();
  }

  // Ambil detail chat
  Future<Chat> getChat(int id, {required String userType}) async {
    await _loadToken();
    final user = await AuthController().getUser();
    if (user == null) throw Exception('User not logged in');

    final res = await http.get(
      Uri.parse("$baseUrl/chats/$id"),
      headers: _headers(userType: userType, userId: user.idUser),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch chat');
    }

    return Chat.fromJson(jsonDecode(res.body));
  }

  // Kirim pesan
  Future<Message> sendMessage(int chatId, String message, {required String userType}) async {
    await _loadToken();
    final user = await AuthController().getUser();
    if (user == null) throw Exception('User not logged in');

    final res = await http.post(
      Uri.parse("$baseUrl/chats/$chatId/send"),
      headers: _headers(userType: userType, userId: user.idUser),
      body: jsonEncode({'message': message}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to send message');
    }

    return Message.fromJson(jsonDecode(res.body));
  }
}
