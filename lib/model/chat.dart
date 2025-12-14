class Chat {
  final int id;
  final List<Message> messages;
  final User? mitra;
  final User? pelanggan;

  Chat({required this.id, required this.messages, this.mitra, this.pelanggan});

  factory Chat.fromJson(Map<String, dynamic> json) {
    var messagesJson = json['messages'] as List? ?? [];
    return Chat(
      id: json['id'],
      messages: messagesJson.map((m) => Message.fromJson(m)).toList(),
      mitra: json['mitra'] != null ? User.fromJson(json['mitra']) : null,
      pelanggan: json['pelanggan'] != null
          ? User.fromJson(json['pelanggan'])
          : null,
    );
  }
}

class Message {
  final int id;
  final String sender;
  final String message;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.sender,
    required this.message,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sender: json['sender'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}

class User {
  final int id;
  final String nama;

  User({required this.id, required this.nama});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_mitra'] ?? json['id_pelanggan'],
      nama: json['nama'] ?? '',
    );
  }
}
