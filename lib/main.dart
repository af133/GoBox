import 'package:flutter/material.dart';
import 'package:gobox/routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      routes: AppRoute.routes,
      initialRoute: AppRoute.splash,
    );
  }
}
