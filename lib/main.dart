import 'package:flutter/material.dart';
import 'routes/routes.dart';

void main() {
  runApp(const BoxGoApp());
}

class BoxGoApp extends StatelessWidget {
  const BoxGoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
} 