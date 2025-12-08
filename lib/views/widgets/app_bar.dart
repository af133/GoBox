import 'package:flutter/material.dart';
import '../../controllers/auth.dart'; 

class AppbarHome extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String? pathProfil;

  AppbarHome({super.key, required this.name, required this.pathProfil});

  final AuthController _auth = AuthController();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 0,
      title: Row(
        children: [
          // Popup Menu (Foto Profil)
          PopupMenuButton<int>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            icon: CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(pathProfil ?? 'https://via.placeholder.com/150'),
            ),
            onSelected: (value) async {
              if (value == 1) {
                Navigator.pushNamed(context, "/profile");
              }
              if (value == 2) {
                await _auth.logout();
                if(!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false); 
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 10),
                    Text("Profile"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 10),
                    Text("Logout"),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selamat datang...",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
      actions: const [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}