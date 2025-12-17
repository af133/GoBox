class AppNotification {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final String? createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] == true,
      createdAt: json['created_at'],
    );
  }
}
