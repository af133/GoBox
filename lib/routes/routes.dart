import 'package:flutter/material.dart';
import 'package:gobox/views/auth/login.dart';
import 'package:gobox/views/auth/signup.dart';
import 'package:gobox/views/dashboard.dart';
import 'package:gobox/views/splash_page.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const signup = '/signup';
  static const profil = '/profile';
  static const allmitra = '/all_mitra';
  static const detailmitra = '/detail_mitra';
  static const ordermitra = '/order_form';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => SplashPage(),
    login: (_) => LoginView(),
    signup: (_) => SignUpView(),
    home:(_) => Dashboard(),
  };
}
