import 'package:flutter/material.dart';
import '../../controllers/auth.dart'; 
const Color goBox = Color(0xFF4CAF50); 
class AppbarHome extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String? pathProfil;

  AppbarHome({super.key, required this.name, required this.pathProfil});

  final AuthController _auth = AuthController();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0.5,
      titleSpacing: 16.0,
      
      title: Row(
        children: [
          PopupMenuButton<int>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), 
            ),
            icon: CircleAvatar(
              radius: 24, 
              backgroundColor: goBox.withOpacity(0.1),
              backgroundImage: pathProfil != null
                  ? NetworkImage(pathProfil!)
                  : null,
              child: pathProfil == null
                  ? const Icon(Icons.person, color: goBox)
                  : null,
            ),
            onSelected: (value) async {
              if (value == 1) {
                Navigator.pushNamed(context, "/profile");
              }
              if (value == 2) {
                await _auth.logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
              }
            },
            itemBuilder: (context) => [
              _buildPopupMenuItem(1, Icons.person_rounded, "Profile"),
              _buildPopupMenuItem(2, Icons.logout_rounded, "Logout", color: Colors.red),
            ],
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selamat datang,",
                style: TextStyle(
                    fontSize: 13, color: Colors.black54),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 17, 
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () { /* Aksi Notifikasi */ },
          icon: const Icon(Icons.notifications_none_rounded, color: goBox, size: 28),
        ),
        IconButton(
          onPressed: () { /* Aksi Pengaturan */ },
          icon: const Icon(Icons.settings_outlined, color: Colors.grey, size: 26),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  PopupMenuItem<int> _buildPopupMenuItem(int value, IconData icon, String text, {Color color = Colors.black}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}