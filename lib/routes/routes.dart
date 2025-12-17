import 'package:flutter/material.dart';
import 'package:gobox/views/auth/login.dart';
import 'package:gobox/views/auth/signup.dart';
import 'package:gobox/views/dashboard.dart';
import 'package:gobox/views/splash_page.dart';
import 'package:gobox/views/gudang/index.dart';
import 'package:gobox/views/order/index.dart';
import 'package:gobox/views/chat/index.dart';
import 'package:gobox/views/profile/index.dart';
import 'package:gobox/views/saldo/index.dart';
import 'package:gobox/views/notifikasi/index.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const signup = '/signup';
  static const profil = '/profile';
  static const notifikasi = '/notifikasi';
  static const gudang = '/gudang';
  static const listOrder = '/order';
  static const chat = '/chat';
  static const penarikan = '/penarikan';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => SplashPage(),
    login: (_) => LoginView(),
    signup: (_) => SignUpView(),
    home: (_) => Dashboard(),
    gudang: (_) => ManajemenGudangPage(),
    listOrder: (_) => OrderListPage(),
    chat: (_) => ChatListPage(),
    penarikan: (_) => SaldoIndexPage(),
    profil: (_) => ProfilePage(),
    notifikasi: (_) => NotifikasiPage(),
  };
}
