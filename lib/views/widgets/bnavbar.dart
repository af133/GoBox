import 'package:gobox/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:gobox/routes/routes.dart';

class Bnavbar extends StatelessWidget {
  final int currentIndex; // Tambahkan ini

  const Bnavbar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: goBox,
      unselectedItemColor: Colors.grey.shade600,
      backgroundColor: Colors.white,

      currentIndex: currentIndex, 

      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppRoutes.home);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, AppRoutes.gudang);
            break;
          case 2:
            Navigator.pushReplacementNamed(context, AppRoutes.listOrder);
            break;
          case 3:
            // Navigator.pushReplacementNamed(context, AppRoutes.chat);
            break;
          case 4:
            // Navigator.pushReplacementNamed(context, AppRoutes.profil);
            break;
        }
      },

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.warehouse), label: 'Gudang'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Order'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
        BottomNavigationBarItem(icon:  Icon(Icons.attach_money), label: 'Saldo'),
      ],
    );
  }
}
