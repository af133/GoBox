import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gobox/controllers/chat.dart';
import 'package:gobox/model/chat.dart';

class ChatRoomPage extends StatefulWidget {
  final int chatId;
  final String chatTitle;
  final String userType;

  const ChatRoomPage({
    super.key,
    required this.chatId,
    required this.chatTitle,
    required this.userType,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ChatService service = ChatService();
  final TextEditingController controller = TextEditingController();
  List<Message> messages = [];
  Timer? _timer;

  String formatTime(DateTime time) {
    return DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(time);
  }

  Future<void> loadMessages() async {
    try {
      final chat = await service.getChat(
        widget.chatId,
        userType: widget.userType,
      );
      if (!mounted) return;
      setState(() => messages = chat.messages);
    } catch (e) {
      debugPrint("Failed to load messages: $e");
    }
  }

  Future<void> sendMessage() async {
    if (controller.text.isEmpty) return;
    try {
      final msg = await service.sendMessage(
        widget.chatId,
        controller.text,
        userType: widget.userType,
      );
      if (!mounted) return;
      setState(() => messages.add(msg));
      controller.clear();
    } catch (e) {
      debugPrint("Failed to send message: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadMessages();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => loadMessages());
  }

  @override
  void dispose() {
    _timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 134, 255, 148),
        title: Text(widget.chatTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                final isMe = msg.sender == widget.userType;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color.fromARGB(255, 3, 188, 74)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.message,
                          style: TextStyle(
                            color: isMe
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatTime(msg.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// INPUT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
