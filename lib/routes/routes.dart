import 'package:flutter/material.dart';
import 'package:gobox/views/splashScreen/onboarding_screen.dart';
import 'package:gobox/views/splashScreen/splash_screen_logic.dart';

class AppRoute {
  static const splash = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const onboarding = '/onboardingscreen';
  static Map<String, WidgetBuilder> routes = {
    splash: (_) => SplashScreenLogic(),
    onboarding: (_) => OnboardingScreen(),
  };
}
