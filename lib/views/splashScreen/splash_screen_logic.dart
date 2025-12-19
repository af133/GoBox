import 'package:flutter/material.dart';
import 'package:gobox/routes/routes.dart';
import 'package:gobox/views/splashScreen/splash_screen1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenLogic extends StatefulWidget {
  const SplashScreenLogic({super.key});

  @override
  State<SplashScreenLogic> createState() => _SplashScreenLogicState();
}

class _SplashScreenLogicState extends State<SplashScreenLogic> {
  @override
  void initState() {
    super.initState();
    _decideRoute();
  }

  Future<void> _decideRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      token != null ? AppRoute.dashboard : AppRoute.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen1();
  }
}
