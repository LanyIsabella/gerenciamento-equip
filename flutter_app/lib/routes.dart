import 'package:flutter/material.dart';

import 'screens/equipamentos_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/manutencoes_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'widgets/route_guard.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/cadastro';
  static const home = '/inicio';
  static const profile = '/perfil';
  static const equipamentos = '/equipamentos';
  static const manutencoes = '/manutencoes';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        home: (_) => const RouteGuard(child: HomeScreen()),
        profile: (_) => const RouteGuard(child: ProfileScreen()),
        equipamentos: (_) => const RouteGuard(child: EquipamentosScreen()),
        manutencoes: (_) => const RouteGuard(child: ManutencoesScreen()),
      };
}
