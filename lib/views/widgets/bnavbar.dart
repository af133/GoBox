import 'package:gobox/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:gobox/routes/routes.dart';

// Asumsi 'goBox' didefinisikan di shared/constants.dart sebagai Color (misal: Color(0xFF4CAF50))

class Bnavbar extends StatelessWidget {
  final int currentIndex;

  const Bnavbar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) {
      return; 
    }
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
        Navigator.pushReplacementNamed(context, AppRoutes.chat); 
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.penarikan); 
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definisi item navigasi
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.warehouse_rounded, 'label': 'Gudang'},
      {'icon': Icons.receipt_long_rounded, 'label': 'Order'},
      {'icon': Icons.chat_bubble_rounded, 'label': 'Chat'},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Saldo'},
    ];

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      elevation: 10.0,
      color: Colors.white,
      
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 4.0),
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            final item = navItems[index];
            final isSelected = index == currentIndex;
            
            return Expanded(
              child: InkWell(
                onTap: () => _onItemTapped(context, index), 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 3.0,
                      width: 30.0,
                      decoration: BoxDecoration(
                        color: isSelected ? goBox : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      margin: const EdgeInsets.only(bottom: 3.0),
                    ),
                    
                    // Icon
                    Icon(
                      item['icon'] as IconData,
                      color: isSelected ? goBox : Colors.grey.shade600,
                      size: 24.0,
                    ),
                    
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: isSelected ? goBox : Colors.grey.shade600,
                        fontSize: 10.0,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}