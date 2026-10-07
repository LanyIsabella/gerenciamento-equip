import 'package:flutter/material.dart';

import 'screens/books_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'widgets/route_guard.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/cadastro';
  static const home = '/inicio';
  static const profile = '/perfil';
  static const books = '/livros';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        home: (_) => const RouteGuard(child: HomeScreen()),
        profile: (_) => const RouteGuard(child: ProfileScreen()),
        books: (_) => const RouteGuard(child: BooksScreen()),
      };
}
