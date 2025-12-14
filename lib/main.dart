import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'routes/routes.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const BoxGoApp());
}

class BoxGoApp extends StatelessWidget {
  const BoxGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      locale: const Locale('id', 'ID'),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
