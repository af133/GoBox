import 'package:gobox/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:gobox/routes/routes.dart';

class Bnavbar extends StatelessWidget {
  const Bnavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: goBox,
      unselectedItemColor: Colors.grey.shade600,
      backgroundColor: Colors.white,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppRoutes.home);
            break;
          case 1:
            // Navigator.pushReplacementNamed(context, AppRoutes.gudang);
            break;
          case 2:
            // Navigator.pushReplacementNamed(context, AppRoutes.order);
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
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Akun'),
      ],
    );
  }
}
