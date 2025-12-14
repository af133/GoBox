import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:gobox/controllers/chat.dart';
import 'package:gobox/controllers/auth.dart';
import 'package:gobox/model/chat.dart';
import 'package:gobox/views/widgets/bnavbar.dart';
import 'chat_room.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late ChatService service;
  String userType = 'mitra';
  List<Chat> chats = [];
  bool isLoading = true;

  Timer? _timer;
  bool _isActivePage = true; // ⬅ kontrol aktif halaman

  String formatTime(DateTime time) {
    return DateFormat('HH:mm', 'id_ID').format(time);
  }

  @override
  void initState() {
    super.initState();
    service = ChatService();
    _init();
  }

  Future<void> _init() async {
    final user = await AuthController().getUser();
    if (!mounted) return;

    if (user != null) {
      setState(() => userType = 'mitra');
      await _loadChats();
      _startPolling();
    }
  }

  // =======================
  // LOAD CHAT
  // =======================
  Future<void> _loadChats() async {
    if (!_isActivePage) return; // ⛔ jangan reload kalau tidak aktif

    try {
      final data = await service.getChats(userType: userType);
      if (!mounted) return;

      setState(() {
        chats = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Load chat error: $e");
    }
  }

  // =======================
  // POLLING CONTROL
  // =======================
  void _startPolling() {
    _timer?.cancel(); // cegah double timer
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _loadChats());
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  // =======================
  // UI
  // =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 190, 246, 192),
      appBar: AppBar(
        title: const Text(
          "Chats",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: chats.length,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemBuilder: (context, index) {
                final chat = chats[index];
                final displayName = userType == 'mitra'
                    ? chat.pelanggan?.nama ?? 'Pelanggan'
                    : chat.mitra?.nama ?? 'Mitra';

                final lastMsg = chat.messages.isNotEmpty
                    ? chat.messages.last
                    : null;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        // ⛔ STOP polling saat masuk chat
                        _isActivePage = false;
                        _stopPolling();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatRoomPage(
                              chatId: chat.id,
                              chatTitle: displayName,
                              userType: userType,
                            ),
                          ),
                        ).then((_) {
                          // ▶️ LANJUT polling saat balik
                          _isActivePage = true;
                          _startPolling();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.green,
                              child: Text(
                                displayName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    lastMsg?.message ?? 'Belum ada pesan',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (lastMsg != null)
                              Text(
                                formatTime(lastMsg.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const Bnavbar(currentIndex: 3),
    );
  }
}
