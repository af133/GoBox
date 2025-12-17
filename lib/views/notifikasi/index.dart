import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gobox/controllers/auth.dart';
import 'package:gobox/controllers/notifikasi.dart';
import 'package:gobox/model/notifikasi.dart';

const Color goBox = Color(0xFF4CAF50);

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  bool loading = true;
  List<AppNotification> notifikasi = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final user = await AuthController().getUser();
    if (user == null) return;

    try {
      final data = await NotificationService().fetchNotifications(
        idUser: user.idUser!,
        autoRead: true, 
      );

      if (!mounted) return;
      setState(() {
        notifikasi = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  String formatTanggal(String date) {
    final dt = DateTime.parse(date);
    return DateFormat('dd MMM yyyy • HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikasi"),
        backgroundColor: goBox,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: goBox))
          : notifikasi.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada notifikasi",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifikasi.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final n = notifikasi[index];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: n.isRead
                            ? Colors.white
                            : goBox.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notifications_rounded,
                            color: goBox,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  n.message,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formatTanggal(n.createdAt!),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
