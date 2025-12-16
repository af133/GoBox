import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gobox/services/notification_api.dart';
import 'routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await NotificationService.init();

  runApp(const BoxGoApp());
}

class BoxGoApp extends StatelessWidget {
  const BoxGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      locale: const Locale('id', 'ID'),
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
